foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_SOURCE_ROOT CPRAG_REPORT
        CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}/bundles" "${CPRAG_WORK_DIR}/compiled")
set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR}/compiled;${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "item=P2-09\nreport_version=1\ncandidates=3\n"
    "provider_calls=0\ncredential_reads=0\ndonation_submissions=0\n")

set(candidates
    "rxsqlite-candidate|incubator/p1a/sqlite_boundary|incubator/p1a/sqlite_boundary/BUNDLE.tsv"
    "rxllm-candidate|incubator/phase1b/provider|incubator/phase1b/provider/BUNDLE.tsv"
    "rxvector-portable-candidate|incubator/phase1b/vector|incubator/phase1b/vector/BUNDLE.tsv")
set(required_roles
    user-doc system-doc package contract source test example benchmark reproducer evidence)
set(audit_sources "")
set(audit_hashes "")
set(total_files 0)

file(READ "${CPRAG_REPORT}" workload_report)
foreach(candidate_spec IN LISTS candidates)
    string(REPLACE "|" ";" candidate_parts "${candidate_spec}")
    list(GET candidate_parts 0 candidate_id)
    list(GET candidate_parts 1 implementation_root)
    list(GET candidate_parts 2 manifest_relative)
    set(candidate_root "${CPRAG_SOURCE_ROOT}/${implementation_root}")
    set(manifest "${CPRAG_SOURCE_ROOT}/${manifest_relative}")
    foreach(required_file IN ITEMS README.md SYSTEM.md PACKAGE.toml BUNDLE.tsv)
        if(NOT EXISTS "${candidate_root}/${required_file}")
            message(FATAL_ERROR "${candidate_id} is missing adjacent ${required_file}")
        endif()
    endforeach()
    file(READ "${candidate_root}/PACKAGE.toml" package_metadata)
    foreach(required_value IN ITEMS
            "schema = \"crexx-candidate-package/1\""
            "status = \"review-bundle-not-approved\""
            "license = \"not-yet-specified\""
            "donation_submission_authorized = false")
        string(FIND "${package_metadata}" "${required_value}" metadata_position)
        if(metadata_position EQUAL -1)
            message(FATAL_ERROR "${candidate_id} package metadata is missing ${required_value}")
        endif()
    endforeach()
    string(FIND "${workload_report}" "| `${candidate_id}` |" report_position)
    if(report_position EQUAL -1)
        message(FATAL_ERROR "workload report does not classify ${candidate_id}")
    endif()

    set(bundle_root "${CPRAG_WORK_DIR}/bundles/${candidate_id}")
    file(MAKE_DIRECTORY "${bundle_root}")
    file(STRINGS "${manifest}" manifest_lines)
    set(roles_seen ",")
    set(destinations_seen "|")
    set(candidate_files 0)
    foreach(line IN LISTS manifest_lines)
        if(line STREQUAL "" OR line MATCHES "^#")
            continue()
        endif()
        string(REPLACE "\t" ";" columns "${line}")
        list(LENGTH columns column_count)
        if(NOT column_count EQUAL 3)
            message(FATAL_ERROR "${candidate_id} manifest row must have source, destination, roles: ${line}")
        endif()
        list(GET columns 0 source_relative)
        list(GET columns 1 destination_relative)
        list(GET columns 2 roles)
        if(source_relative MATCHES "^/" OR destination_relative MATCHES "^/" OR
           source_relative MATCHES "(^|/)\.\.(/|$)" OR
           destination_relative MATCHES "(^|/)\.\.(/|$)")
            message(FATAL_ERROR "${candidate_id} manifest path escapes its review boundary: ${line}")
        endif()
        set(source "${CPRAG_SOURCE_ROOT}/${source_relative}")
        if(NOT EXISTS "${source}")
            message(FATAL_ERROR "${candidate_id} manifest source is missing: ${source_relative}")
        endif()
        string(FIND "${destinations_seen}" "|${destination_relative}|" duplicate_position)
        if(NOT duplicate_position EQUAL -1)
            message(FATAL_ERROR "${candidate_id} repeats destination ${destination_relative}")
        endif()
        set(destinations_seen "${destinations_seen}${destination_relative}|")
        get_filename_component(destination_parent "${bundle_root}/${destination_relative}" DIRECTORY)
        file(MAKE_DIRECTORY "${destination_parent}")
        file(COPY_FILE "${source}" "${bundle_root}/${destination_relative}" ONLY_IF_DIFFERENT)
        file(SHA256 "${source}" source_hash)
        file(SHA256 "${bundle_root}/${destination_relative}" staged_hash)
        if(NOT source_hash STREQUAL staged_hash)
            message(FATAL_ERROR "${candidate_id} staged hash differs for ${destination_relative}")
        endif()
        file(APPEND "${bundle_root}/SHA256SUMS.tsv"
            "${source_hash}\t${destination_relative}\t${roles}\n")
        list(APPEND audit_sources "${source}")
        list(APPEND audit_hashes "${source_hash}")
        set(roles_seen "${roles_seen}${roles},")
        math(EXPR candidate_files "${candidate_files} + 1")
        math(EXPR total_files "${total_files} + 1")
    endforeach()
    foreach(required_role IN LISTS required_roles)
        string(FIND "${roles_seen}" ",${required_role}," role_position)
        if(role_position EQUAL -1)
            message(FATAL_ERROR "${candidate_id} bundle is missing role ${required_role}")
        endif()
    endforeach()
    if(candidate_files LESS 8)
        message(FATAL_ERROR "${candidate_id} bundle is unexpectedly small")
    endif()
    file(APPEND "${report}" "bundle=${candidate_id} files=${candidate_files} roles=complete\n")
endforeach()

function(compile_crexx source output imports mode_flag label)
    execute_process(COMMAND "${CPRAG_RXC}" ${mode_flag} -i "${imports}"
        -o "${output}" "${source}"
        OUTPUT_VARIABLE compile_out ERROR_VARIABLE compile_err
        RESULT_VARIABLE compile_result)
    if(NOT compile_result EQUAL 0)
        message(FATAL_ERROR "${label} compile failed:\n${compile_out}\n${compile_err}")
    endif()
    execute_process(COMMAND "${CPRAG_RXAS}" ${mode_flag} -o "${output}" "${output}"
        OUTPUT_VARIABLE assemble_out ERROR_VARIABLE assemble_err
        RESULT_VARIABLE assemble_result)
    if(NOT assemble_result EQUAL 0)
        message(FATAL_ERROR "${label} assembly failed:\n${assemble_out}\n${assemble_err}")
    endif()
    file(APPEND "${report}"
        "${label} compile:\n${compile_out}${compile_err}"
        "${label} assemble:\n${assemble_out}${assemble_err}\n")
endfunction()

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_SOURCE_ROOT}/incubator/phase1b/provider/provider_contract.crexx"
        "${CPRAG_WORK_DIR}/compiled/provider_contract" "${base_import}"
        "${mode_flag}" "${mode} provider contract")
    compile_crexx("${CPRAG_SOURCE_ROOT}/incubator/phase1b/vector/vector_codec.crexx"
        "${CPRAG_WORK_DIR}/compiled/vector_codec" "${base_import}"
        "${mode_flag}" "${mode} vector codec")
    compile_crexx("${CPRAG_SOURCE_ROOT}/incubator/phase1b/vector/vector_search.crexx"
        "${CPRAG_WORK_DIR}/compiled/vector_search" "${base_import}"
        "${mode_flag}" "${mode} vector search")
    compile_crexx("${CPRAG_SOURCE_ROOT}/incubator/p1a/sqlite_boundary/candidate_probe.crexx"
        "${CPRAG_WORK_DIR}/compiled/sqlite-probe-${mode}" "${program_import}"
        "${mode_flag}" "${mode} SQLite candidate probe")
    compile_crexx("${CPRAG_SOURCE_ROOT}/incubator/phase1b/provider/candidate_probe.crexx"
        "${CPRAG_WORK_DIR}/compiled/provider-probe-${mode}" "${program_import}"
        "${mode_flag}" "${mode} provider candidate probe")
    compile_crexx("${CPRAG_SOURCE_ROOT}/incubator/phase1b/vector/candidate_probe.crexx"
        "${CPRAG_WORK_DIR}/compiled/vector-probe-${mode}" "${program_import}"
        "${mode_flag}" "${mode} vector candidate probe")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/compiled/sqlite-probe-${mode}"
            rx_sqlite_boundary library
            OUTPUT_VARIABLE sqlite_out ERROR_VARIABLE sqlite_err
            RESULT_VARIABLE sqlite_result TIMEOUT 15)
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/compiled/provider-probe-${mode}"
            provider_contract library
            OUTPUT_VARIABLE provider_out ERROR_VARIABLE provider_err
            RESULT_VARIABLE provider_result TIMEOUT 15)
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/compiled/vector-probe-${mode}"
            vector_codec vector_search library
            OUTPUT_VARIABLE vector_out ERROR_VARIABLE vector_err
            RESULT_VARIABLE vector_result TIMEOUT 15)
        if(NOT sqlite_result EQUAL 0 OR NOT sqlite_out MATCHES "P2_09_SQLITE_CANDIDATE_OK answer=42")
            message(FATAL_ERROR "${cell} SQLite candidate probe failed (${sqlite_result}):\n${sqlite_out}\n${sqlite_err}")
        endif()
        if(NOT provider_result EQUAL 0 OR NOT provider_out MATCHES "P2_09_PROVIDER_CANDIDATE_OK local=allowed hosted_restricted=denied provider_calls=0")
            message(FATAL_ERROR "${cell} provider candidate probe failed (${provider_result}):\n${provider_out}\n${provider_err}")
        endif()
        if(NOT vector_result EQUAL 0 OR NOT vector_out MATCHES "P2_09_VECTOR_CANDIDATE_OK codec=f32le-v1 dimension=2 deterministic=1")
            message(FATAL_ERROR "${cell} vector candidate probe failed (${vector_result}):\n${vector_out}\n${vector_err}")
        endif()
        file(APPEND "${report}" "${cell}:\n${sqlite_out}${sqlite_err}${provider_out}${provider_err}${vector_out}${vector_err}\n")
    endforeach()
endforeach()

list(LENGTH audit_sources audit_count)
math(EXPR audit_last "${audit_count} - 1")
foreach(index RANGE 0 ${audit_last})
    list(GET audit_sources ${index} source)
    list(GET audit_hashes ${index} expected_hash)
    file(SHA256 "${source}" actual_hash)
    if(NOT actual_hash STREQUAL expected_hash)
        message(FATAL_ERROR "P2-09 changed source while staging bundle: ${source}")
    endif()
endforeach()

message(STATUS
    "P2-09 passed: report version 1, three complete review-bundle manifests (${total_files} files), required colocated docs/roles, hash-identical isolated staging, and 12 candidate-probe cells with zero provider calls or donation submissions")
