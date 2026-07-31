# Identity Gateway decision, revision 2

Captured: 2026-03-18T15:30:00Z
Source stance: this decision supersedes revision 1 for deployment only.

The Identity Gateway still validates sign-in tokens and reads customer profiles
from Cedar Store, also known as CSDB. It still sends successful sign-in audit
events to Lantern Stream.

The March decision moves the Identity Gateway from Amber Cluster to Blue
Cluster. The data dependency is unchanged: Identity Gateway depends on Cedar
Store, and Cedar Store remains protected by Vault Service.

Project Mercury remains the migration programme. Mercury Service remains a
different billing component. No database for Mercury Service is identified.
