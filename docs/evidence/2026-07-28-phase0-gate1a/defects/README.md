# Frozen Native-v1 Defects

These records are negative demonstrations of current executable-oracle defects.
Every record has `desired_parity:false`. A later cREXX implementation must not
reproduce these behaviors merely to match native-v1.

`phase0_oracle_defects` constructs only scratch libraries. It demonstrates
same-URI chunk identifier churn, graph support that survives revision replacement
and source deletion, a queue with no atomic claim/lease/fence boundary, and the
1 MiB whole-result JSON buffer failure. The test compares stable semantic defect
records and excludes volatile row identifiers.
