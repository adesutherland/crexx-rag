# Identity Gateway decision, revision 1

Captured: 2026-01-12T10:00:00Z
Source stance: architecture decision accepted at the January review.

The Identity Gateway validates sign-in tokens and reads customer profiles from
the Cedar Store relational database. The operations team also calls Cedar Store
"CSDB". The gateway sends an audit event to the Lantern Stream after every
successful sign-in.

The January decision places the Identity Gateway on the Amber Cluster. The
gateway depends on Cedar Store, and Cedar Store is backed up by the Vault
Service. This gives a directed operational path from Identity Gateway to Vault
Service through Cedar Store.

Project Mercury is the programme that funded the migration. Mercury Service is
a separate billing component. This note says nothing about which database
Mercury Service uses.
