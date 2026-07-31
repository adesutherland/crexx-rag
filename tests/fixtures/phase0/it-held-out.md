# Fulfilment architecture note

Captured: 2026-04-02T12:00:00Z
Source stance: approved design with one unresolved risk.

The Parcel API writes dispatch requests to the Juniper Queue. Warehouse Worker
consumes Juniper Queue and reads destination records from the Atlas Directory,
which the team sometimes calls ADX. Atlas Directory is replicated by Mirror
Agent.

The approved call path is Parcel API to Juniper Queue to Warehouse Worker to
Atlas Directory. The note warns that Mirror Agent can lag during regional
failover, so it does not claim that every replica is current.

Orion is ambiguous in this programme: Orion Team operates Parcel API, while
Orion Service is an unrelated notification component. This note contains no
evidence about the datastore used by Orion Service.
