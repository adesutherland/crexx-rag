# Installed SHA-256 Capability Proof

This directory is a downstream qualification harness for installed
the complete public `rxhash` SHA-256 family; it is not a local hash
implementation or donation package.

`p1_hash_01.crexx` calls the native function directly from Level G with owned
binary input. It verifies raw and canonical lowercase hexadecimal results,
standard empty and `abc` vectors, embedded zero/`0xff` bytes, UTF-8,
text/binary byte equivalence, immutable and independently forked incremental
states, empty updates, repeatable finalization, and bounded provider-owned file
hashing. The proof runs optimized and non-optimized builds on both VMs. The VM
command names no native provider: declarative metadata must autoload `rx_hash`
from the installed package.

The same source is also packaged and executed with installed `crexx -native`,
proving selection of the installed static `rx_hash` provider. Application
sidecar verification retains its caller-controlled size ceiling and byte count
in the narrow `ragfile` Level-B foundation while using the immutable
incremental provider state; callers without that policy requirement may use
`rxhash.sha256file` or `rxhash.sha256filehex` directly.
