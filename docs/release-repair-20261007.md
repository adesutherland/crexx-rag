# 7 October 2026 WAL close repair and v0.1.2

Scope: recover the affected private library to the newest verified state,
check and bound writable close cleanup, and publish/install the next product
patch release. No schema, provider implementation, hosted model call or corpus
maintenance job is part of this repair.

## Corpus recovery

The private recovery record and original files are retained outside this
public repository. A WAL-free candidate passed full SQLite integrity and
cREXX-RAG repository verification with zero issues before and after
replacement of the active path. The origin of the mismatched file pair is
not established.

## Product ownership and behavior

`ragstore` checks `sqlitecheckpoint(truncate)`, the actual response to
`PRAGMA journal_mode=DELETE`, and the provider close call. Lock contention is
retried for a bounded stable-bundle close; ordinary concurrent workers close
their handle and report deferred WAL cleanup when another reader prevents
conversion. Initialization and staged backup publication require stable close.
Backup abort now propagates read-snapshot close errors, while a manifest error
during initialization closes its writable handle. The source backup continues
to use SQLite's online backup API; a published backup contains its committed
snapshot in `library.sqlite` and has no source WAL copy.

## Baseline and regression

The starting checkout was clean `main` at v0.1.1 (`dce7583`). Before editing,
`publication` and `native_publication` passed. The new pinned-reader close
case failed on the old close code because it returned success despite an
incomplete checkpoint. A first strict-on-every-worker patch then failed native
two-worker supervision: legitimate concurrent connections blocked journal-mode
conversion. The revised bounded stable-bundle contract passed focused
`publication` and `native_publication`. The final exact-input focused selection
passed 2/2; the fast tier passed 11/11. The native build passed library init
and two-worker supervision. The full regression selection completed in 662.47
seconds and the required QA report accounts for 145/145 passing cases, with
no failed, disabled, interrupted or missing case. CTest reused 13 earlier
current-input passes, including the focused publication cases.

## Qualification and publication

The release packaging contract passed 22 controls, the local NSIS fixture
compiled, `actionlint` passed, and `git diff --check` passed before commit.
`install-local` installed the exact qualified native executable into the
per-user prefix; its SHA-256 matches the build artifact
`e9292f5a9fe17d531279037b3079dcd9247a3c299f5fba7e3bd6c854dc21d9d8`.
The installed executable verified the recovered private library at zero
repository issues and an aligned manifest. The
[tag-triggered hosted run](https://github.com/adesutherland/crexx-rag/actions/runs/37641634792)
passed metadata, Windows x64, macOS x86_64, macOS arm64 and publication jobs.
The Windows job verified the portable ZIP and executed the installer and
uninstaller; both macOS jobs verified their ZIP and installer. The
[v0.1.2 release](https://github.com/adesutherland/crexx-rag/releases/tag/v0.1.2)
is public and contains 12 assets: four signed macOS payloads with checksums,
and a signed Windows ZIP and installer with checksums. The original unsigned
Windows ZIP's SHA-256 was
`b772387fa223fe56b8853a9446b3b1b94fdc4ddc5269e4c8eae577f461018b29`,
matching the hosted artifact downloaded and checked locally. Signing first
failed with PKCS#11 `CKR_FUNCTION_FAILED` while the token was unavailable.
After the maintainer logged in, `scripts/sign-windows-release.sh --upload`
completed against the exact tag and source
`2d36ec804e4b0b56919d09f6e09b313528dc1ccb`. The signed ZIP and installer
passed their local SHA-256 checks; the installer passed `osslsigncode verify`
with a valid Certum signature. The published signed ZIP SHA-256 is
`326ccdb36590be074e5763c2c554f790c5a510901aaff81ea321cf4f5606a00a`;
the installer is
`687c0df13a5d0b8a2a56ca312c0f0271570d2e2a7353d6e7c158966c34523405`.
Their local hashes match GitHub's asset digests. The script removed only the
four unsigned Windows assets after verifying the signed uploads; the macOS
assets remain.
