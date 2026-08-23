if(NOT DEFINED CPRAG_SOURCE_ROOT OR CPRAG_SOURCE_ROOT STREQUAL "")
    message(FATAL_ERROR "CPRAG_SOURCE_ROOT is required")
endif()

file(GLOB_RECURSE phase1b_sources
    "${CPRAG_SOURCE_ROOT}/incubator/phase1b/*.crexx")
file(GLOB_RECURSE crexx_sources
    "${CPRAG_SOURCE_ROOT}/crexx/*.crexx")

set(historical_levelb_sources
    "${CPRAG_SOURCE_ROOT}/crexx/benchmarks/phase0_components.crexx")
set(foundation_levelb_sources
    "${CPRAG_SOURCE_ROOT}/crexx/application/ragfile.crexx")
set(maintained_sources ${phase1b_sources} ${crexx_sources})
list(REMOVE_ITEM maintained_sources ${historical_levelb_sources})
list(REMOVE_ITEM maintained_sources ${foundation_levelb_sources})
list(REMOVE_DUPLICATES maintained_sources)
list(SORT maintained_sources)

set(source_count 0)
foreach(source IN LISTS maintained_sources)
    math(EXPR source_count "${source_count} + 1")
    file(READ "${source}" source_text)
    if(source_text MATCHES "(^|\n)[ \t]*options[ \t]+levelb([ \t\r\n]|$)")
        file(RELATIVE_PATH relative_source "${CPRAG_SOURCE_ROOT}" "${source}")
        message(FATAL_ERROR
            "maintained advanced/application cREXX source must use Level G: ${relative_source}")
    endif()
    if(NOT source_text MATCHES "(^|\n)[ \t]*options[ \t]+levelg([ \t\r\n]|$)")
        file(RELATIVE_PATH relative_source "${CPRAG_SOURCE_ROOT}" "${source}")
        message(FATAL_ERROR
            "maintained cREXX source has no explicit Level G option: ${relative_source}")
    endif()
endforeach()

foreach(source IN LISTS foundation_levelb_sources)
    file(READ "${source}" source_text)
    if(NOT source_text MATCHES "(^|\n)[ \t]*options[ \t]+levelb([ \t\r\n]|$)" OR
       NOT source_text MATCHES "Minimized Level-B foundation exception")
        file(RELATIVE_PATH relative_source "${CPRAG_SOURCE_ROOT}" "${source}")
        message(FATAL_ERROR
            "approved foundation exception is missing Level-B identity or rationale: ${relative_source}")
    endif()
endforeach()

set(policy_requirements
    "AGENTS.md|Level G is the default language level for advanced user-facing libraries"
    "docs/crexx-only-architecture.md|Level G owns product algorithms"
    "docs/crexx-only-implementation-roadmap.md|Create the Level G application module layout"
    "docs/gate1b-decision-ledger.md|G1B-D6"
    "docs/test-strategy.md|must be cREXX Level G")
foreach(requirement IN LISTS policy_requirements)
    string(REPLACE "|" ";" requirement_parts "${requirement}")
    list(GET requirement_parts 0 policy_file)
    list(GET requirement_parts 1 policy_text)
    file(READ "${CPRAG_SOURCE_ROOT}/${policy_file}" policy_document)
    string(FIND "${policy_document}" "${policy_text}" policy_position)
    if(policy_position EQUAL -1)
        message(FATAL_ERROR
            "${policy_file} is missing Level-G policy text: ${policy_text}")
    endif()
endforeach()

list(LENGTH phase1b_sources phase1b_count)
message(STATUS
    "CREXX_LANGUAGE_LEVEL_AUDIT_OK maintained=${source_count} phase1b=${phase1b_count} foundation_levelb=${foundation_levelb_sources} historical_levelb=${historical_levelb_sources}")
