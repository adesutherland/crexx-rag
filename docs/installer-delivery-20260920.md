# Installer delivery — 20 September 2026

## Scope and reviewed baseline

Request: use the CREXX build/signing pattern for Windows and macOS RAG
installers, skip macOS signing when secrets are absent, and keep Windows
signing as a separate post-release maintainer operation.

RAG started clean on `main` at `78c2c015f1f3469d91c842f6eea20ff3d12c3fde`.
Implementation is on `temp/platform-installers`; no commit, push, tag or release
is claimed by this record. The sibling CREXX checkout was inspected read-only
at `47168a1f16365d6c2aaa54de770889c0e8dce6a4`; its unrelated dirty work was preserved.
The runtime pin remains the installed/published CREXX
`5949ef27efd813b8bb96d23c58717b9a72aad1b9`.

Reviewed CREXX's build workflow, macOS PKG packaging, Windows NSIS compiler and
installer acceptance, post-release PKCS11 signing, and provider manifest refresh.
Reused the responsibilities and secret names, keeping RAG's implementation
independent of a sibling source checkout. One deliberate change: an unsigned
macOS installer is still built when signing credentials are absent.

No application source, schema, provider selection, operational configuration or
Scottish corpus was changed. The CMake changes register one fast packaging test
and its explicit receipt dependencies. Build/release tooling remains outside
the Level-G product implementation.

## Acceptance and evidence

| Requirement | Evidence / current boundary |
| --- | --- |
| Build three native platform packages from fixed sources | Workflow implemented; first Windows/Intel/Apple Silicon hosted matrix is pending publication. Exact source/dependency IDs and per-file hashes are recorded in each package. |
| Missing/partial Apple configuration still produces unsigned PKG and ZIP | Unit contract plus real unsigned Apple Silicon PKG/ZIP produced locally with all nine Apple settings absent. |
| Configured signing failures fail the build and clean up credentials | Simulated failure/cleanup and secret-output tests pass. Real certificates/notarization have not been exercised. |
| Signed bytes retain valid provider manifests | Tests modify the engine bytes, reject stale hashes, refresh nested backend/native hashes, then verify the complete package. |
| Windows post-release signing preserves unsigned assets and source identity | Simulated PE/script/installer signing and wrong-tag negative control pass; no implicit upload. Real PKCS11 signing remains pending. |
| Install and uninstall safely | NSIS compiles locally using a private payload with spaces in its path. Hosted Windows acceptance checks normal, long, absent and existing PATH, reinstall, native execution and preservation of user files; actual Windows execution pending. |
| Real packaged application runs independently | Both relocated ZIP and expanded PKG payload pass library init, two-worker supervision and library verification with no provider calls. Hosted macOS also performs actual system installation on its disposable runner. |
| No duplicate product test execution without changed inputs | Existing `installed_product` and `documentation_contract` passes were audited before implementation and reused. Packaging contracts are a separate fast case; product binaries are unchanged. |

The release contract has 16 passing controls. Workflow `actionlint`, shell
`shellcheck`, Python compilation and whitespace checks pass. A focused regression
selection executes the changed packaging/documentation checks and retains the
unchanged installed-product pass. The full receipt audit accounts for the
134 required cases using existing exact-input product passes; it does not rerun
the unchanged functional suite. Final report: `out/installer-20260920/full-report.json`.

Local evidence is under `out/installer-20260920/`: staged install log,
`package.log`, actual unsigned `.pkg`/ZIP/checksums in `assets/`,
`zip-smoke.json`, `pkg-smoke.json` and `nsis-compile.log`. The development
artifact uses version `0.1.0-dev.78c2c01` and the already qualified baseline
binary. It is a packaging proof, not an installer built/published from a new
clean release commit. No system-wide PKG was installed on the user's Mac.

The initial packaging test import failed because the new module did not exist;
the implementation now passes the release contract cases. Controls cover
credential completeness, signing failure/cleanup, redacted command failure,
unsigned-input preservation, wrong release identity, private Windows helper
inclusion, checksums, changed/missing/extra payload files, executable permission,
ZIP traversal, and provider-file escape rejection. The installed-only NSIS
uninstaller exception does not allow extra files in the portable ZIP.
An additional failing-first control reproduced replacing an already valid
vendor signature; signing now verifies and preserves such DLLs, including the
Microsoft runtime. `vendor-signature-before.log` retains that failed assertion.
The PATH helper is a packaged PowerShell file so neither the user PATH nor the
helper program is constrained by NSIS's 1024-character string buffer.

## Remaining qualification

Run the three-platform workflow after source publication, retaining its exact
SHA and terminal results. Run a credentials-enabled macOS build and the local
Windows signing operation when credentials are configured. Confirm the signed
Windows installer on Windows before describing signed delivery as qualified.
The workflow's package smoke checks do not close the wider RAG-QA-03 functional
and fault coverage. The historical beta exception for ESC-OPS-06 is unchanged.

Operational instructions, secret names and signing commands are in
[Builds, installers and signing](build-and-release.md). The roadmap is the sole
current status register.
