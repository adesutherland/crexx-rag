# CREXX and platform integration issues

These are current boundaries. Any source-level containment used by the product
is stated explicitly.

## Attached task provider discovery

An attached cREXX task running in a child thread cannot currently discover/load
the native SQLite RXPA provider in its task VM. The SQLite library and provider
are thread-safe when built with mutex support; the missing capability is CREXX
provider lifecycle/discovery for attached task VMs.

`crexxrag` therefore uses operating-system worker processes. Every process
starts a fresh VM and opens its own connection, which is supported and covered
by regression tests. A controller-owned SQLite design remains valid for future
in-process tasks that exchange ordinary transferable values.

## Provider lifetime

The application currently uses one operation-scoped provider pool/process per
adapter invocation. It does not claim long-lived reuse, streaming, or
cancellation across operations.

## Installed Linux replay

The exact installed-package Linux replay of the hosted-provider path remains a
separate platform qualification. macOS evidence must not be represented as
Linux qualification.

## cREXX branch-local value merge

When a typed object receives its first assignment independently in both arms of
an `if`/`else`, the installed compiler can allocate distinct branch-local
registers and use only the `else` register after the control-flow join. On the
true branch the generated program ends the other register's lifetime and then
accesses the wrong object. Both CREXX VMs report `SIGNAL OUT_OF_RANGE`; optimized
and non-optimized compilation are affected.

This is not an 8-bit register-count limit. `crexxrag` contains the issue by
initializing the provider-result object in the enclosing scope before either
branch, and an application regression exercises that exact path.

## Interactive input

The current CREXX line-input behavior can require an additional Enter after a
confirmation prompt on affected builds. This is a known CREXX issue; the
product does not carry a duplicate roadmap entry.
