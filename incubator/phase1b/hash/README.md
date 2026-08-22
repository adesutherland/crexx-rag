# Installed SHA-256 Capability Proof

This directory is a downstream qualification harness for installed
`rxhash.sha256`; it is not a local hash implementation or donation package.

`p1_hash_01.crexx` calls the native function directly from Level G with owned
binary input. It verifies the raw 32-byte result, standard empty and `abc`
vectors, embedded zero/`0xff` bytes, UTF-8, and text/binary byte equivalence in
optimized and non-optimized builds on both VMs. The VM command names no native
provider: declarative metadata must autoload `rx_hash` from the installed
package.

The installed contract is one-shot binary SHA-256. This proof does not claim
incremental state or a file/path convenience API. Application file ingestion
must keep byte ownership and file-size policy explicit until one of those
surfaces is separately approved and implemented.
