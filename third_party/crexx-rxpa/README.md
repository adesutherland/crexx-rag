# Temporary CREXX rxpa Header

`crexxpa.h` was copied from the sibling CREXX source checkout as a temporary
compatibility shim so `crexx-rag` can build an external dynamic CREXX plugin.
`crexx_version.h` was copied from the sibling generated build headers because
`crexxpa.h` includes it.

TODO: remove these vendored headers and the CMake fallback that uses them once
the installed CREXX distribution provides version-matched rxpa development
headers and plugin build metadata.
