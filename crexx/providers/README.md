# Provider adapters

This directory contains the Level-G provider contract, capability catalogue,
HTTP transport adapter, Gemini/OpenAI-compatible adapter, and Codex App Server
adapter used by `crexxrag`.

Application code selects a provider by configured `kind`; it does not construct
a Gemini backend directly. Provider results are data, not authority: the
application validates exact structured schemas and then applies normal claim,
embedding, citation, and budget policy. Source privacy and route labels remain
metadata; they do not override the configured provider selection.

Codex authentication and token refresh remain owned by App Server. Each worker
owns its child process/session. No token or process handle is shared between
workers.
