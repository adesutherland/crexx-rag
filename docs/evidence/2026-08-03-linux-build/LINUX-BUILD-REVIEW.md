# Linux Debug And Release Build Review

Status date: 2026-08-03. This is fresh-clone portability evidence, not Phase-1B
authority or a revision of the retained Apple Gate-1A measurements.

## Environment

- `crexx-rag`: `main` at `ff96bb1e0decb3066509225e5e441f7a89c3af26`
- host: Linux 7.0.0-28-generic x86_64, 18 GiB RAM
- CMake 4.2.3, Ninja 1.13.2, GCC/G++ 15.2.0
- installed CREXX: `crexx-1.0.0-beta.3+local.gea25d1720c8d.dirty` from
  `/home/adrian/.local`; recorded source commit
  `ea25d1720c8dc4044614fa6ac4789811289dc8ca`
- no hosted provider call or credential

The host initially had `libsqlite3-0` 3.46.1 but not `libsqlite3-dev`.
`find_package(SQLite3)` therefore lacked both `sqlite3.h` and the unversioned
link library. System installation requires:

```bash
sudo apt-get install libsqlite3-dev
```

Because `sudo` required an interactive password, validation used the exact
Ubuntu 3.46.1 development-package header from the repository-ignored
`.local/sqlite-dev` directory and linked the already installed
`/usr/lib/x86_64-linux-gnu/libsqlite3.so.0.8.6`. This was a test-only user-local
substitute, not a replacement for the documented system prerequisite.

## Build Results

After making the native core explicitly position independent and adding its
missing direct `<algorithm>` include:

- Debug configure passed and all 27 Ninja targets built.
- Release configure passed and all 27 Ninja targets built.
- The initial Debug CTest run passed 24/28. Three failures were caused by the
  macOS-only `/usr/bin/time -l` command.
- After selecting BSD `time -l` on macOS, GNU `time -v` on Linux, and
  normalizing Linux peak RSS from KiB to bytes, the three focused tests passed
  3/3: `phase0_component_benchmark`, `p1a_rxjson_projection`, and
  `p1a_vector_boundary`.
- Stable Debug validation is 27/28. A concurrent CLion rebuild caused transient
  missing-artifact failures in the two final wrappers during the full rerun;
  after that build completed, `crexx_generic_pipeline_smoke` and
  `use_case_wrapper_smoke` passed 2/2 in 134.66 and 189.24 seconds. The sole
  remaining failure is the installed-CREXX `p1a_provider_boundary` timeout case
  tracked as CRI-15.

## CRI-15 Reproducer

The standalone Level B reproducer is
[`repro/rxsocket-timeout-repro.crexx`](repro/rxsocket-timeout-repro.crexx),
SHA-256
`70bf1881e3967ae939b97db03600998fb6cc104fa86da5bf6a7e6ffbd4b5eac6`.
It connects to the existing delayed loopback fixture, configures a 50 ms
blocking socket timeout, calls `socketrecv`, and asserts the documented timeout
status `2`.

Observed `rxvme` result:

```text
RXSOCKET_TIMEOUT status=-5 length=0 close=0 error=-5 received text is not valid UTF-8
vm_status=1
```

Observed `rxbvm` result:

```text
RXSOCKET_TIMEOUT status=2 length=2 close=0 error=2 timeout
vm_status=0
```

The relevant CREXX files are unchanged between the installed commit and the
current read-only source checkout. Inspection shows
`rxvm_socket_recv_bytes()` returning positive socket status `2` on timeout,
while `rxvm_socket_recv_string()` treats every positive return as a received
byte count and validates that many bytes from the receive buffer. `rxvme` then
overwrites the timeout with invalid-UTF-8 status `-5`; `rxbvm` retains status
`2` but exposes a two-byte payload. `rxhttp` consequently maps the `rxvme`
failure to local HTTP status `-7` rather than its structured timeout status
`-5`.

No downstream workaround was added because classifying arbitrary invalid UTF-8
as a timeout would hide the generic runtime defect and weaken provider error
semantics. The installed CREXX socket receive contract must be fixed or an
explicitly reviewed generic workaround selected before Linux provider timeout
qualification can pass.
