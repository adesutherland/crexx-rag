if(NOT DEFINED CPRAG_SOURCE_ROOT OR CPRAG_SOURCE_ROOT STREQUAL "")
    message(FATAL_ERROR "CPRAG_SOURCE_ROOT is required")
endif()

set(candidate_directories
    "incubator/p1a/sqlite_boundary"
    "incubator/phase1b/provider"
    "incubator/phase1b/vector")

set(candidate_count 0)
foreach(candidate IN LISTS candidate_directories)
    math(EXPR candidate_count "${candidate_count} + 1")
    set(candidate_root "${CPRAG_SOURCE_ROOT}/${candidate}")
    foreach(document IN ITEMS README.md SYSTEM.md PACKAGE.toml BUNDLE.tsv)
        set(document_path "${candidate_root}/${document}")
        if(NOT EXISTS "${document_path}")
            message(FATAL_ERROR
                "donation candidate ${candidate} is missing colocated ${document}")
        endif()
        file(SIZE "${document_path}" document_size)
        if(document_size EQUAL 0)
            message(FATAL_ERROR
                "donation candidate ${candidate} has empty ${document}")
        endif()
    endforeach()

    file(READ "${candidate_root}/README.md" usage_document)
    foreach(required_heading IN ITEMS "Status:" "## Tests" "## Current Limits")
        string(FIND "${usage_document}" "${required_heading}" heading_position)
        if(heading_position EQUAL -1)
            message(FATAL_ERROR
                "${candidate}/README.md is missing required content: ${required_heading}")
        endif()
    endforeach()

    file(READ "${candidate_root}/SYSTEM.md" system_document)
    foreach(required_heading IN ITEMS "Boundary" "## Donation Readiness")
        string(FIND "${system_document}" "${required_heading}" heading_position)
        if(heading_position EQUAL -1)
            message(FATAL_ERROR
                "${candidate}/SYSTEM.md is missing required content: ${required_heading}")
        endif()
    endforeach()

    file(READ "${candidate_root}/PACKAGE.toml" package_document)
    foreach(required_value IN ITEMS
            "schema = \"crexx-candidate-package/1\""
            "status = \"review-bundle-not-approved\""
            "license = \"not-yet-specified\""
            "donation_submission_authorized = false")
        string(FIND "${package_document}" "${required_value}" value_position)
        if(value_position EQUAL -1)
            message(FATAL_ERROR
                "${candidate}/PACKAGE.toml is missing required value: ${required_value}")
        endif()
    endforeach()
endforeach()

set(audit_path "${CPRAG_SOURCE_ROOT}/incubator/README.md")
if(NOT EXISTS "${audit_path}")
    message(FATAL_ERROR "incubator/README.md donation-candidate audit is missing")
endif()
file(READ "${audit_path}" audit_document)
foreach(candidate IN LISTS candidate_directories)
    string(REGEX REPLACE "^incubator/" "" audit_reference "${candidate}")
    string(FIND "${audit_document}" "${audit_reference}/" candidate_position)
    if(candidate_position EQUAL -1)
        message(FATAL_ERROR
            "incubator/README.md does not classify candidate ${candidate}")
    endif()
endforeach()

message(STATUS
    "DONATION_DOCS_AUDIT_OK candidates=${candidate_count} use_docs=${candidate_count} system_docs=${candidate_count} package_manifests=${candidate_count} review_bundles=${candidate_count}")
