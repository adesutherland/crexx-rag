# CREXX and platform integration issues

These are current boundaries, not product workarounds.

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

## cREXX VM register range

Large Level-G compilation can encounter the VM's current 8-bit register range.
The CREXX roadmap records the infrastructure defect. `crexxrag` does not hide it
with product-specific native code.

## Interactive input

The current CREXX line-input behavior can require an additional Enter after a
confirmation prompt on affected builds. This is a known CREXX issue; the
product does not carry a duplicate roadmap entry.
