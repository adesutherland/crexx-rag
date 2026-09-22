"""Release tooling only; synthetic private payloads and no signing/network calls."""
import importlib.util
import json
from pathlib import Path
import tempfile
import subprocess
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("release_package", ROOT / "scripts/release/package.py")
package = importlib.util.module_from_spec(spec)
spec.loader.exec_module(package)


class PackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="rag package test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "payload"
        self.bin = self.root / "bin"
        self.bin.mkdir(parents=True)
        (self.bin / "crexxrag").write_bytes(b"executable")
        (self.bin / "crexxrag").chmod(0o755)
        (self.bin / "engine.so").write_bytes(b"engine")
        identity = dict(version=1, provider="rxllama", platform="Darwin", arch="arm64", engine="pinned")
        entry = dict(path="engine.so", sha256=package.digest(self.bin / "engine.so"))
        runtime = dict(identity, backends=[dict(entry, backend="cpu")])
        (self.bin / "rxllama.runtime.json").write_text(json.dumps(runtime))
        native = dict(identity, link_libraries=[entry], runtime_files=[entry, dict(
            path="rxllama.runtime.json", sha256=package.digest(self.bin / "rxllama.runtime.json"))])
        (self.bin / "rxllama.native.json").write_text(json.dumps(native))

    def test_missing_and_partial_credentials_skip_all_apple_signing(self):
        self.assertEqual(package.apple_credentials({})[0], False)
        full = {key: "present" for key in package.APPLE_SECRETS}
        self.assertEqual(package.apple_credentials(full), (True, []))
        for key in full:
            partial = dict(full, **{key: ""})
            self.assertEqual(package.apple_credentials(partial), (False, [key]))

    def test_provider_manifest_detects_damage_then_tracks_signed_bytes(self):
        package.provider_manifests(self.bin, refresh=False)
        (self.bin / "engine.so").write_bytes(b"signed engine")
        with self.assertRaisesRegex(ValueError, "hash"):
            package.provider_manifests(self.bin, refresh=False)
        package.provider_manifests(self.bin, refresh=True)
        package.provider_manifests(self.bin, refresh=False)
        runtime = json.loads((self.bin / "rxllama.runtime.json").read_text())
        self.assertEqual(runtime["backends"][0]["sha256"], package.digest(self.bin / "engine.so"))

    def test_provider_manifest_rejects_escape_even_when_refreshing(self):
        native = json.loads((self.bin / "rxllama.native.json").read_text())
        native["runtime_files"][0]["path"] = "../outside"
        (self.root / "outside").write_bytes(b"outside")
        (self.bin / "rxllama.native.json").write_text(json.dumps(native))
        with self.assertRaisesRegex(ValueError, "local"):
            package.provider_manifests(self.bin, refresh=True)

    def test_payload_manifest_detects_missing_changed_and_extra_files(self):
        package.write_inventory(self.root, "0.1.0-beta.1", "a" * 40, "b" * 40, "macos-arm64", "unsigned")
        package.verify_inventory(self.root)
        manifest = json.loads((self.root / "release.json").read_text())
        self.assertEqual(manifest["source_commit"], "a" * 40)
        self.assertEqual(manifest["signing"], "unsigned")
        (self.root / "unexpected").write_text("not declared")
        with self.assertRaisesRegex(ValueError, "file set"):
            package.verify_inventory(self.root)
        (self.root / "unexpected").unlink()
        (self.bin / "crexxrag").write_bytes(b"modified")
        with self.assertRaisesRegex(ValueError, "hash"):
            package.verify_inventory(self.root)
        (self.bin / "crexxrag").unlink()
        with self.assertRaisesRegex(ValueError, "file set"):
            package.verify_inventory(self.root)

    def test_archive_preserves_spaces_and_executable_permission(self):
        package.write_inventory(self.root, "0.1.0-dev.1", "a" * 40, "b" * 40, "macos-arm64", "unsigned")
        archive = Path(self.temp.name) / "release.zip"
        package.archive(self.root, archive)
        with zipfile.ZipFile(archive) as z:
            self.assertIsNone(z.testzip())
            self.assertEqual(z.read("bin/crexxrag"), b"executable")
            self.assertTrue((z.getinfo("bin/crexxrag").external_attr >> 16) & 0o111)

    def test_unsafe_release_metadata_is_rejected(self):
        for version in ("../release", '0.1.0\"', "v0.1.0", "latest"):
            with self.assertRaises(ValueError):
                package.write_inventory(self.root, version, "a" * 40, "b" * 40, "macos-arm64", "unsigned")

    def test_unsigned_package_does_not_invoke_signing_or_notary(self):
        args = SimpleNamespace(prefix=self.root, output=Path(self.temp.name)/"assets", version="0.1.0-beta.1",
                               commit="a"*40, crexx_commit="b"*40, platform="macos-arm64")
        def installer(prefix, output, version, keychain):
            self.assertIsNone(keychain)
            output.write_bytes(b"fixture package")
        with patch.dict(package.os.environ, {}, clear=True), patch.object(package, "apple_sign_payload") as signer, patch.object(package, "macos_installer", side_effect=installer):
            package.package(args)
            signer.assert_not_called()
        z = next(args.output.glob("*.zip"))
        document = package.unpack(z, Path(self.temp.name)/"unpacked")
        self.assertEqual(document["signing"], "unsigned")
        self.assertEqual(z.with_name(z.name+".sha256").read_text().split()[0], package.digest(z))

    def test_configured_signing_failure_cannot_become_unsigned_success(self):
        args = SimpleNamespace(prefix=self.root, output=Path(self.temp.name)/"failed", version="0.1.0-beta.1",
                               commit="a"*40, crexx_commit="b"*40, platform="macos-arm64")
        with patch.dict(package.os.environ, {key:"credential" for key in package.APPLE_SECRETS}, clear=True), patch.object(package, "apple_sign_payload", side_effect=RuntimeError("signing failed")):
            with self.assertRaisesRegex(RuntimeError, "signing failed"):
                package.package(args)
        self.assertEqual(list(args.output.iterdir()), [])

    def test_uninstaller_is_only_allowed_in_installed_windows_payload(self):
        package.write_inventory(self.root, "0.1.0", "a"*40, "b"*40, "windows-x64", "unsigned")
        (self.root/"Uninstall.exe").write_bytes(b"NSIS generated")
        package.verify_inventory(self.root, installed=True)
        with self.assertRaisesRegex(ValueError, "file set"):
            package.verify_inventory(self.root)

    def test_archive_rejects_windows_drive_and_traversal(self):
        for name in ("../outside", "/outside", "C:/outside", "C:outside", "a\\outside"):
            z = Path(self.temp.name)/"hostile.zip"
            with zipfile.ZipFile(z, "w") as archive:
                archive.writestr(name, "unexpected")
            with self.assertRaisesRegex(ValueError, "Nonlocal"):
                package.unpack(z, Path(self.temp.name)/"extracted")

    def windows_input(self):
        (self.bin / "crexxrag").write_bytes(b"MZapplication")
        (self.root / "helper.ps1").write_bytes(b"# installer helper")
        (self.bin / "engine.so").write_bytes(b"MZengine")
        package.provider_manifests(self.bin, refresh=True)
        package.write_inventory(self.root, "0.1.0-beta.1", "a"*40, "b"*40, "windows-x64", "unsigned")
        unsigned = Path(self.temp.name)/"unsigned.zip"
        package.archive(self.root, unsigned)
        return SimpleNamespace(zip=unsigned, output=Path(self.temp.name)/"signed", upload=False, repo=None, tag=None)

    def test_windows_signing_preserves_unsigned_and_refreshes_all_signed_hashes(self):
        args = self.windows_input()
        original = package.digest(args.zip)
        def sign(path):
            path.write_bytes(path.read_bytes() + b"signature")
        def installer(prefix, output, version, helper):
            self.assertTrue(helper.is_file())
            self.assertEqual(package.verify_inventory(prefix)["signing"], "signed")
            output.write_bytes(b"MZinstaller")
        with patch.dict(package.os.environ, {"PROVIDER":"fixture", "CERTUM_ALIAS":"fixture"}), patch.object(package, "sign_file", side_effect=sign) as signer, patch.object(package, "windows_installer", side_effect=installer), patch.object(package, "run") as commands:
            package.windows_sign(args)
            self.assertEqual(signer.call_count, 4)  # Application, engine, script and installer.
            commands.assert_not_called()  # No implicit upload.
        self.assertEqual(package.digest(args.zip), original)
        result = package.unpack(next(args.output.glob("*.zip")), Path(self.temp.name)/"signed unpacked")
        self.assertEqual(result["source_commit"], "a"*40)
        self.assertEqual(result["crexx_commit"], "b"*40)
        self.assertEqual(result["signing"], "signed")
        self.assertEqual((Path(self.temp.name)/"signed unpacked/bin/engine.so").read_bytes(), b"MZenginesignature")

    def test_windows_upload_checks_release_identity_before_signing(self):
        args = self.windows_input()
        args.upload, args.repo, args.tag = True, "owner/repo", "v0.1.0-beta.1"
        with patch.dict(package.os.environ, {"PROVIDER":"fixture", "CERTUM_ALIAS":"fixture"}), patch.object(package.subprocess, "check_output", return_value="c"*40), patch.object(package, "sign_file") as signer:
            with self.assertRaisesRegex(ValueError, "tag differs"):
                package.windows_sign(args)
            signer.assert_not_called()

    def test_signing_errors_do_not_echo_secret_command_arguments(self):
        with patch.object(package.subprocess, "run", side_effect=subprocess.CalledProcessError(1, ["security", "secret-value"])):
            with self.assertRaises(RuntimeError) as caught:
                package.run("security", "secret-value")
        self.assertNotIn("secret-value", str(caught.exception))

    def test_windows_preserves_valid_vendor_signatures(self):
        with patch.dict(package.os.environ, {"PROVIDER":"fixture", "CERTUM_ALIAS":"fixture"}), patch.object(package.subprocess, "run", return_value=SimpleNamespace(returncode=0)), patch.object(package, "run") as signer:
            package.sign_file(self.bin / "engine.so")
            signer.assert_not_called()

    def test_failed_apple_signing_cleans_up_private_keychain(self):
        args = SimpleNamespace(prefix=self.root, output=Path(self.temp.name)/"failed", version="0.1.0",
                               commit="a"*40, crexx_commit="b"*40, platform="macos-arm64")
        def fail(prefix, keychain):
            keychain.touch()
            raise RuntimeError("signing failed")
        with patch.dict(package.os.environ, {key:"credential" for key in package.APPLE_SECRETS}, clear=True), patch.object(package, "apple_sign_payload", side_effect=fail), patch.object(package, "run") as commands:
            with self.assertRaisesRegex(RuntimeError, "signing failed"):
                package.package(args)
            self.assertEqual(commands.call_args.args[:2], ("security", "delete-keychain"))

    def test_windows_package_includes_owned_path_helper(self):
        args = SimpleNamespace(prefix=self.root, output=Path(self.temp.name)/"assets", version="0.1.0",
                               commit="a"*40, crexx_commit="b"*40, platform="windows-x64")
        helper = "share/crexxrag/installer/update-user-path.ps1"
        def installer(prefix, output, version):
            meta = package.verify_inventory(prefix)
            self.assertIn(helper, meta["files"])
            self.assertEqual((prefix/helper).read_bytes(), (ROOT/"packaging/windows/update-user-path.ps1").read_bytes())
            output.write_bytes(b"MZinstaller")
        with patch.dict(package.os.environ, {}, clear=True), patch.object(package, "windows_installer", side_effect=installer):
            package.package(args)
        self.assertFalse((self.root/helper).exists())  # Original staged prefix is unchanged.


if __name__ == "__main__":
    unittest.main()
