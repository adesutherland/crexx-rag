# Installer delivery — 20 September 2026

## Scope and reviewed baseline

Request: use the CREXX build/signing pattern for Windows and macOS RAG
installers, skip macOS signing when secrets are absent, and keep Windows
signing as a separate post-release maintainer operation.

RAG started clean on `main` at `78c2c015f1f3469d91c842f6eea20ff3d12c3fde`.
Implementation was committed as `daaa5de7ada997c1b4f3ad416b46456518a7f9e1`, pushed
on `temp/platform-installers` and opened as [PR #1](https://github.com/adesutherland/crexx-rag/pull/1)
following explicit approval. No tag or release was created. The sibling CREXX checkout was inspected read-only
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
| Build three native platform packages from fixed sources | Published for review in PR #1. Both macOS hosted build/package/install checks pass; Windows installer repair acceptance is pending below. Exact source/dependency IDs and per-file hashes are recorded in each package. |
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

The [first hosted run](https://github.com/adesutherland/crexx-rag/actions/runs/35515227153)
passed metadata/contracts but exposed a cold-SDK dependency omission on Apple
Silicon: RAG's configure-time capability check correctly refused the missing
`rxsqlite.a`. The generic staged targets had not built the SQLite static target
or the required vector pair. The workflow now requests `sqlite sqlite_static
vector vector_static` explicitly, invalidates the old SDK cache recipe and saves
the installed SDK before downstream RAG checks. The passing local installed-SDK
control and failed clean runner distinguish this from a product regression.
The [second hosted run](https://github.com/adesutherland/crexx-rag/actions/runs/35515745584)
builds PR head `52b36bfb6f713f07712481a5d26cbdab4227374f` as merge commit
`cb35df524ad514f1f8e6c4485c7ba00015081387`. All three installed SDK builds pass
and are saved in exact-platform/SHA caches. Both macOS platforms additionally pass
native RAG build, portable ZIP smoke, real PKG installation and installed smoke.
Windows builds native RAG successfully, then NSIS rejects the Unix `payload/*`
wildcard. The repair uses a Windows separator and adds a real NSIS compilation
fixture with spaces and nested files before the expensive Windows SDK/RAG steps.
The failed Windows job is the reproduction; local NSIS compilation with the
corrected script is the positive control. Actual Windows installer execution
still awaits the repaired hosted run. Subsequent terminal platform results are
attached to PR #1; this record retains the two initial runs and their repairs.
The rerun also uses the runner's CPU count, capped at four, for RAG compilation
instead of the initial fixed two workers. SDK recipe/options remain unchanged.

Published CREXX snapshot binaries were reviewed as a simpler dependency route.
They currently lack the installed SDK parts required by native RAG. The
[upstream packaging gap](integration-issues.md#snapshot-sdk-packaging--20-september-2026)
records the evidence and proposed archive; the cached SDK remains the working
route without changing the sibling repository.

Run the three-platform workflow after source publication, retaining its exact
SHA and terminal results. Run a credentials-enabled macOS build and the local
Windows signing operation when credentials are configured. Confirm the signed
Windows installer on Windows before describing signed delivery as qualified.
The workflow's package smoke checks do not close the wider RAG-QA-03 functional
and fault coverage. The historical beta exception for ESC-OPS-06 is unchanged.

Operational instructions, secret names and signing commands are in
[Builds, installers and signing](build-and-release.md). The roadmap is the sole
current status register.
