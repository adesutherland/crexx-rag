# Phase 1B Structured Data

This application-cREXX incubation consumes the installed `rxjson` document and
projection facilities. It does not contain a second parser or serialized
document representation. One immutable `.jsondocument` owns each parsed input;
callers traverse its document-local node identifiers and use typed node getters.

Encoding helpers delegate quoting to installed `rxjson` and enforce explicit
UTF-8 byte limits on the returned application payload. Limits and payload
schemas remain caller owned.
