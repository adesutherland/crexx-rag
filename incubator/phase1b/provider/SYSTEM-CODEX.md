# Codex provider maintainer notes

The adapter uses CREXX child-process and byte-endpoint providers. It performs
the documented initialize/initialized handshake, starts one thread and turn,
collects the final `agentMessage` plus `thread/tokenUsage/updated`, and deletes
the thread. `codexrunobserver` is the durability boundary: an application can
persist external thread/turn identities, token usage, and the completed output
before settlement.

The permanent P3R-04 test drives initialize, account/rate-limit reads, a
schema-constrained structured turn, usage events and thread cleanup through a
deterministic JSONL fixture in both CREXX VMs. The current App Server command
remains experimental, so protocol changes additionally require a bounded live
probe against the installed Codex executable before hosted qualification.
