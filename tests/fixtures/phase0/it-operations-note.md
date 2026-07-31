# Operations assurance note

Captured: 2026-03-20T09:00:00Z
Source stance: the reliability team corroborates the storage dependency but
disputes the earlier claim that every successful sign-in produces an audit
event during Lantern Stream maintenance.

Customer profile records used during authentication are stored in Cedar Store.
The database is protected by Vault Service snapshots. During a Lantern Stream
maintenance window, successful sign-ins continue, but their audit events may be
buffered and delivered later.

This note uses the full name Cedar Store and does not use the alias CSDB.
