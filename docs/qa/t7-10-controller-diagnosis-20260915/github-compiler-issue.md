## Problem

During cREXX-RAG's T7-10 operator-output repair, using the public `rxfnsb`
`closefile` operation to close a failed output stream was followed by repeatable
compiler failures in two importing modules during the ordinary multi-member
source-project build. The importing modules compiled successfully against built
interfaces. Replacing that cleanup with the supported `lineout(stream)` close
form allowed the ordinary project build to complete.

This is a compiler/source-import finding, not a report that `closefile` fails at
runtime. The close operation compiled and ran in isolated checks on both VMs.
The precise compiler cause has not been isolated.

## Environment

- Installed toolchain: `crexx-1.0.0-beta.3+local.g037e7939bc29` (macOS 64,
  build date `20260913`). This installed version was checked again when filing.
- Host: macOS ARM64; current `uname -srm`: `Darwin 25.6.0 arm64`.
- Downstream: cREXX-RAG Level-G application, T7-10 working-tree repair on
  15 September 2026, based on `dd96144bb3689ad4da4a9a43c8df914555402877`.
  The triggering downstream change was uncommitted, so that SHA alone is not
  a reproducer.
- Normal installed `crexx --program` multi-source build, driven by CMake/Ninja.
  The retained unchanged failing retry compiled `ragcommand` and `ragprocess`
  in a two-member wave.

## Recorded reproduction sequence

There is **no reduced, self-contained reproducer yet**. These are the observed
application-level steps, supplied so the finding can be tracked without
blocking downstream work:

1. In `ragtrace.writeoperatorline`, catch `NOTREADY` from operator stdout/stderr
   output, mark that sink closed, and close the failed stream using `closefile`
   inside a second narrow `NOTREADY` handler. Closing the stream discards pending
   output before process-exit flushing.
2. Run the ordinary downstream build:

   ```sh
   cmake --preset debug
   cmake --build --preset debug
   ```

   Its application build invokes the installed `crexx --program` driver with
   the full source member list, including `ragtrace`, `ragcommand` and
   `ragprocess`.
3. The build fails with the diagnostics below. Retrying the unchanged build
   reproduces the failures.
4. Compile the affected importing modules against their built interfaces:
   this succeeds in the retained investigation.
5. Replace only the failed-stream close operation with the documented
   `lineout(stream)` close form, written as `call lineout stream` in the repair.
   The ordinary project build succeeds. The output-close checks pass on both
   VMs, and the subsequent combined downstream candidate passes 79/79 local
   tests, including broken-output and signal-drain regressions.

## Actual diagnostics

The retained retry log contains:

```text
WAVE: project compile/assemble jobs=2
START: project member ragcommand
START: project member ragprocess
FAILED: compile project member ragcommand rc=255
INTERNAL_CONVERGENCE_ERROR: Loop failed to converge. Active flags: 0x0002
FAILED: compile project member ragprocess rc=2
...
Error in ragprocess.crexx @ 588:103 - #TYPE_MISMATCH: Type mismatch., "provider"
1 error(s) in source file
```

The successful alternative's build log records both members built and proceeds
through the normal linked/native packaging. The failing retry log is retained
downstream as `docs/qa/t7-10-controller-diagnosis-20260915/compiler-closefile-retry.log`;
the investigation and successful alternative are recorded in
`docs/t7-10-controller-diagnosis-20260915.md`.

## Expected behaviour and scope

A valid call to the public close operation should compile consistently through
source imports and built-interface imports. The compiler should not terminate
with an internal convergence error. The provider type diagnostic should be
investigated alongside it; it has not been proved to be the same underlying bug.

The evidence suggests a source-import/validation interaction, but does not
establish whether the cause is symbol resolution, type propagation, dependency
state or something else. This report does not claim that every `closefile` call
fails or that the small cleanup fragment alone reproduces the failure.

The `lineout(stream)` alternative currently removes the downstream build blocker.
Please retain this as an upstream compiler investigation; a reduced source
fixture and source-import/built-interface regression are the next useful steps.
