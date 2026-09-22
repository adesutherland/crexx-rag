"""Compile the real NSIS script before an expensive SDK/application build."""
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts/release"))
import package


class NsisCompilation(unittest.TestCase):
    def test_payload_with_spaces_and_nested_files(self):
        with tempfile.TemporaryDirectory(prefix="RAG NSIS fixture ") as directory:
            work = Path(directory)
            prefix = work / "payload with spaces"
            (prefix / "bin").mkdir(parents=True)
            # This case proves the installer compiler/file selection, not execution.
            (prefix / "bin/crexxrag.exe").write_bytes(b"MZ compile fixture")
            nested = prefix / "share/crexxrag/installer"
            nested.mkdir(parents=True)
            (nested / "update-user-path.ps1").write_bytes(
                (package.ROOT / "packaging/windows/update-user-path.ps1").read_bytes())
            installer = work / "rag-installer.exe"
            package.windows_installer(prefix, installer, "0.1.0-dev.1")
            self.assertTrue(installer.is_file())
            with installer.open("rb") as binary:
                self.assertEqual(binary.read(2), b"MZ")


if __name__ == "__main__":
    unittest.main()
