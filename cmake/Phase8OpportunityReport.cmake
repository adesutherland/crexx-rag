if(NOT DEFINED CPRAG_SOURCE_ROOT OR "${CPRAG_SOURCE_ROOT}" STREQUAL "")
    message(FATAL_ERROR "CPRAG_SOURCE_ROOT is required")
endif()

set(report "${CPRAG_SOURCE_ROOT}/docs/reports/phase-8-donation-opportunities.md")
set(evidence "${CPRAG_SOURCE_ROOT}/docs/evidence/2026-08-24-phase8/README.md")
set(current_evidence "${CPRAG_SOURCE_ROOT}/docs/evidence/2026-08-25-phase8-current-report/README.md")
set(command_contract "${CPRAG_SOURCE_ROOT}/crexx/application/ragcommand.crexx")
if(NOT EXISTS "${report}" OR NOT EXISTS "${evidence}" OR
   NOT EXISTS "${current_evidence}" OR NOT EXISTS "${command_contract}")
    message(FATAL_ERROR "Phase-8 report, evidence, or command contract is missing")
endif()
file(READ "${report}" report_text)
file(READ "${evidence}" evidence_text)
file(READ "${current_evidence}" current_evidence_text)
file(READ "${command_contract}" command_contract_text)
foreach(required IN ITEMS
        "Phase-8 report complete" "Gate 8 programme closeout is not satisfied"
        "Report maintained through: 2026-08-25"
        "SQLite typed boundary" "Provider-neutral LLM/embedding"
        "Portable float32 codec" "Parse-once JSON" "SHA-256"
        "MCP transport helpers" "donation_submission_authorized=false"
        "Native-v1 remains the default oracle" "No compatibility window has started"
        "native human/JSON/MCP provider smoke" "Why this is not a `crexxrag` command"
        "not authority to create an issue, pull request, donation branch, or CREXX commit")
    string(FIND "${report_text}" "${required}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Phase-8 report lacks required boundary: ${required}")
    endif()
endforeach()
foreach(forbidden IN ITEMS
        "cREXX hosted response completion fails"
        "cREXX hosted provider cannot reliably complete"
        "Level-G public worker/provider and embedding-item path is incomplete")
    string(FIND "${report_text}" "${forbidden}" position)
    if(NOT position EQUAL -1)
        message(FATAL_ERROR "Phase-8 report retains superseded blocker: ${forbidden}")
    endif()
endforeach()
foreach(required IN ITEMS
        "Phase 8 is intentionally not a tutorial" "donation submission: not performed"
        "native deletion: not performed" "exact downstream Linux: open")
    string(FIND "${evidence_text}" "${required}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "Phase-8 evidence lacks required boundary: ${required}")
    endif()
endforeach()
foreach(required IN ITEMS
        "Phase 8 remains intentionally not a tutorial" "runtime command: not added"
        "donation submission: not performed" "native deletion: not performed"
        "exact downstream Linux: open" "absence of a `report` operation")
    string(FIND "${current_evidence_text}" "${required}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR "current Phase-8 evidence lacks required boundary: ${required}")
    endif()
endforeach()

string(FIND "${command_contract_text}" "if noun = \"report\"" report_operation)
if(NOT report_operation EQUAL -1)
    message(FATAL_ERROR "Phase 8 governance was incorrectly added to the runtime operation vocabulary")
endif()

foreach(candidate IN ITEMS p1a/sqlite_boundary phase1b/provider phase1b/vector)
    foreach(name IN ITEMS README.md SYSTEM.md PACKAGE.toml BUNDLE.tsv)
        if(NOT EXISTS "${CPRAG_SOURCE_ROOT}/incubator/${candidate}/${name}")
            message(FATAL_ERROR "candidate metadata is incomplete: ${candidate}/${name}")
        endif()
    endforeach()
    file(READ "${CPRAG_SOURCE_ROOT}/incubator/${candidate}/PACKAGE.toml" package)
    string(FIND "${package}" "review-bundle-not-approved" review_position)
    string(FIND "${package}" "donation_submission_authorized = false" authority_position)
    if(review_position EQUAL -1 OR authority_position EQUAL -1)
        message(FATAL_ERROR "candidate metadata overstates authority: ${candidate}")
    endif()
endforeach()

file(GLOB phase8_tutorials "${CPRAG_SOURCE_ROOT}/docs/tutorials/*phase-8*"
    "${CPRAG_SOURCE_ROOT}/docs/tutorials/*phase8*"
    "${CPRAG_SOURCE_ROOT}/crexx/tutorials/*phase-8*"
    "${CPRAG_SOURCE_ROOT}/crexx/tutorials/*phase8*")
if(phase8_tutorials)
    message(FATAL_ERROR "Phase 8 must be a report, not a tutorial: ${phase8_tutorials}")
endif()

message(STATUS
    "Phase 8 current opportunity report passed: superseded blockers are reconciled, candidate/adoption/retirement states are explicit, and no runtime verb, tutorial, or unauthorized closeout action is claimed")
