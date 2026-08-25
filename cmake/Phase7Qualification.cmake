foreach(required_var CPRAG_SOURCE_ROOT CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(required_files
    "docs/tutorials/phase-7-qualification.md"
    "docs/evidence/2026-08-24-phase7/README.md"
    "docs/evidence/2026-08-24-phase7/cutover-decision.md"
    "docs/evidence/2026-08-25-phase7-application/README.md"
    "tools/qualify_phase7_hosted.py"
    "incubator/phase1b/provider/hosted_http_completion_probe.crexx"
    "incubator/phase1b/provider/p7_hosted_provider_probe.crexx")
foreach(relative IN LISTS required_files)
    if(NOT EXISTS "${CPRAG_SOURCE_ROOT}/${relative}")
        message(FATAL_ERROR "Phase-7 artifact is missing: ${relative}")
    endif()
endforeach()

file(READ "${CPRAG_SOURCE_ROOT}/docs/evidence/2026-08-24-phase7/README.md" evidence)
file(READ "${CPRAG_SOURCE_ROOT}/docs/evidence/2026-08-24-phase7/cutover-decision.md" decision)
file(READ "${CPRAG_SOURCE_ROOT}/docs/evidence/2026-08-25-phase7-application/README.md" application_evidence)
file(READ "${CPRAG_SOURCE_ROOT}/docs/tutorials/phase-7-qualification.md" tutorial)
file(READ "${CPRAG_SOURCE_ROOT}/docs/crexx-only-implementation-roadmap.md" roadmap)
foreach(required IN ITEMS
        "P7-01" "P7-02" "P7-03" "P7-04" "P7-05" "P7-06" "P7-07" "P7-08"
        "reject/defer cutover" "env:OPENAI_API_KEY" "credential values logged: zero"
        "Exact downstream Linux: open" "native-v1 remains the default oracle")
    string(FIND "${evidence}\n${decision}" "${required}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Phase-7 evidence lacks required boundary: ${required}")
    endif()
endforeach()
foreach(required IN ITEMS
        "crexxrag provider test" "phase7_provider_smoke"
        "ctest --preset debug" "cutover decision")
    string(FIND "${tutorial}" "${required}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Phase-7 tutorial lacks ${required}")
    endif()
endforeach()
foreach(required IN ITEMS
        "public synthetic" "exact answer/citations schema" "768-dimensional"
        "Human:" "Machine:" "Agent:" "p7r_01_provider_smoke"
        "zero-call budget denial" "2026-08-24 reject/defer" "cutover decision")
    string(FIND "${application_evidence}" "${required}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Phase-7 application evidence lacks ${required}")
    endif()
endforeach()
string(FIND "${roadmap}" "Gate 7 decision: reject/defer cutover" gate_position)
if(gate_position EQUAL -1)
    message(FATAL_ERROR "roadmap does not retain the exact Gate-7 decision")
endif()
file(WRITE "${CPRAG_WORK_DIR}/qualification-audit.txt"
    "phase=7\nchecklist=8/8\ndecision=reject/defer-cutover\n"
    "provider_smoke=human,json,mcp\nexact_output_validation=1\n"
    "hosted_credentials=symbolic-only\nlinux=open\n")
message(STATUS
    "Phase 7 qualification record passed: P7-01 through P7-08 and the native provider-smoke extension are evidenced; cutover is explicitly deferred")
