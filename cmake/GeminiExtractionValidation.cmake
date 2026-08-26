foreach(required_var CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK CPRAG_CONFIG_TEMPLATE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

find_program(CREXXRAG_SQLITE3 sqlite3 REQUIRED)
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
set(cli "${CMAKE_COMMAND}" -E env
    "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
    "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}"
    "${CPRAG_NATIVE_APPLICATION}")

function(run_invalid_extraction case_name port expected_error)
    set(case_dir "${CPRAG_WORK_DIR}/${case_name}")
    file(MAKE_DIRECTORY "${case_dir}/source")
    file(WRITE "${case_dir}/source/architecture.txt"
        "BillingService depends on CustomerDatabase.\n")
    set(CPRAG_FIXTURE_SOURCE "${case_dir}/source")
    set(CPRAG_FIXTURE_GLOSSARY "${case_dir}/architecture.glossary.tsv")
    file(WRITE "${CPRAG_FIXTURE_GLOSSARY}"
        "format\tcrexx-rag.glossary/1\n"
        "concept\tBillingService\tapplication-component\tBilling Service\n"
        "concept\tCustomerDatabase\tdata-store\tCustomer DB\n"
        "exclude\tDeprecatedSystem\n")
    set(CPRAG_FIXTURE_PORT "${port}")
    set(config "${case_dir}/crexxrag.conf")
    configure_file("${CPRAG_CONFIG_TEMPLATE}" "${config}" @ONLY)
    set(library "${case_dir}/library")

    execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
        --profile it-architecture-profile --access admin --format json library init
        OUTPUT_VARIABLE init_out ERROR_VARIABLE init_err RESULT_VARIABLE init_result TIMEOUT 30)
    if(NOT init_result EQUAL 0)
        message(FATAL_ERROR "${case_name}: library init failed:\n${init_out}${init_err}")
    endif()
    execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
        --profile it-architecture-profile --access plan --format json
        ingest plan --source-set architecture-docs
        OUTPUT_VARIABLE plan_out ERROR_VARIABLE plan_err RESULT_VARIABLE plan_result TIMEOUT 30)
    if(NOT plan_result EQUAL 0)
        message(FATAL_ERROR "${case_name}: ingestion plan failed:\n${plan_out}${plan_err}")
    endif()
    string(JSON plan_json ERROR_VARIABLE plan_json_error GET "${plan_out}" records 0 fields canonical_plan)
    string(JSON plan_digest ERROR_VARIABLE plan_digest_error GET "${plan_out}" records 0 fields digest)
    if(plan_json_error OR plan_digest_error)
        message(FATAL_ERROR "${case_name}: ingestion plan was not reviewable:\n${plan_out}")
    endif()
    execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
        --profile it-architecture-profile --access ingest --format json --progress off
        ingest apply --plan-json "${plan_json}" --expect-digest "${plan_digest}"
        OUTPUT_VARIABLE apply_out ERROR_VARIABLE apply_err RESULT_VARIABLE apply_result TIMEOUT 30)
    if(NOT apply_result EQUAL 0 OR NOT apply_out MATCHES "\"items_queued\":2")
        message(FATAL_ERROR "${case_name}: ingestion apply failed:\n${apply_out}${apply_err}")
    endif()
    string(JSON job_id ERROR_VARIABLE job_error GET "${apply_out}" records 0 fields job_id)
    if(job_error OR job_id STREQUAL "")
        message(FATAL_ERROR "${case_name}: ingestion did not expose a job id")
    endif()

    set(server_out "${case_dir}/loopback.out")
    set(server_err "${case_dir}/loopback.err")
    set(server_status "${case_dir}/loopback.status")
    execute_process(COMMAND /bin/sh -c
        "( \"$1\" \"$2\" 2 \"$3\"; printf '%s' $? >\"$6\" ) >\"$4\" 2>\"$5\" &"
        extraction-negative "${CPRAG_LOOPBACK}" "${port}" "${case_name}"
        "${server_out}" "${server_err}" "${server_status}"
        RESULT_VARIABLE launch_result)
    if(NOT launch_result EQUAL 0)
        message(FATAL_ERROR "${case_name}: could not start provider fixture")
    endif()
    set(ready FALSE)
    foreach(poll RANGE 1 200)
        if(EXISTS "${server_out}")
            file(READ "${server_out}" current_server_out)
            if(current_server_out MATCHES "READY ${port}")
                set(ready TRUE)
                break()
            endif()
        endif()
        execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
    endforeach()
    if(NOT ready)
        message(FATAL_ERROR "${case_name}: provider fixture did not become ready")
    endif()

    set(all_worker_out "")
    set(all_worker_err "")
    foreach(worker_run RANGE 1 2)
        execute_process(COMMAND ${cli} --library "${library}" --config-file "${config}"
            --profile it-architecture-profile --access control --format json --progress off
            worker run --once --poll-ms 20 --max-polls 1 --job "${job_id}"
            OUTPUT_VARIABLE worker_out ERROR_VARIABLE worker_err RESULT_VARIABLE worker_result TIMEOUT 60)
        if(NOT worker_result EQUAL 0 OR NOT worker_out MATCHES "\"items_processed\":1" OR
           worker_out MATCHES "synthetic-product-gemini-key" OR worker_err MATCHES "synthetic-product-gemini-key")
            message(FATAL_ERROR "${case_name}: failed output was not safely handled:\n${worker_out}${worker_err}")
        endif()
        string(APPEND all_worker_out "${worker_out}")
        string(APPEND all_worker_err "${worker_err}")
    endforeach()

    execute_process(COMMAND "${CREXXRAG_SQLITE3}" "${library}/library.sqlite"
        "SELECT (SELECT count(*) FROM job_items WHERE state='dead_letter') || ':' || (SELECT count(*) FROM claims) || ':' || (SELECT count(*) FROM claim_support) || ':' || (SELECT count(*) FROM candidate_mentions WHERE extractor_version='provider-discovery-v1') || ':' || (SELECT count(*) FROM provider_runs WHERE outcome='failed') || ':' || coalesce((SELECT validation_state FROM attempts WHERE outcome='dead_letter' LIMIT 1),'');"
        OUTPUT_VARIABLE state OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE state_err RESULT_VARIABLE state_result)
    string(FIND "${state}" "${expected_error}" error_position)
    if(NOT state_result EQUAL 0 OR NOT state MATCHES "^1:0:0:0:1:" OR error_position LESS 0)
        message(FATAL_ERROR "${case_name}: invalid extraction did not dead-letter without product mutation: ${state} ${state_err}")
    endif()
    file(GLOB vectors "${library}/vectors.*.rxvec")
    if(vectors)
        message(FATAL_ERROR "${case_name}: rejected extraction unexpectedly published a vector sidecar")
    endif()

    set(exited FALSE)
    foreach(poll RANGE 1 200)
        if(EXISTS "${server_status}")
            set(exited TRUE)
            break()
        endif()
        execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
    endforeach()
    if(NOT exited)
        message(FATAL_ERROR "${case_name}: provider fixture did not exit")
    endif()
    file(READ "${server_status}" server_result)
    file(READ "${server_out}" final_server_out)
    file(READ "${server_err}" final_server_err)
    if(NOT server_result STREQUAL "0" OR
       NOT final_server_out MATCHES "SUMMARY scenario=${case_name} connections=2")
        message(FATAL_ERROR "${case_name}: provider fixture failed:\n${final_server_out}${final_server_err}")
    endif()
endfunction()

run_invalid_extraction(product-extraction-invalid-span 19021
    "provider mention does not match its exact evidence span")
run_invalid_extraction(product-extraction-unknown-type 19022
    "provider mention concept type is not in the selected profile")
run_invalid_extraction(product-extraction-unknown-relationship 19023
    "provider relationship type is not in the selected profile")
run_invalid_extraction(product-extraction-malformed 19024
    "structured response is not valid JSON")

file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "Gemini extraction validation rejected invalid UTF-8 spans, unknown concept and relationship types, and malformed structured output through durable workers. Every case dead-lettered with no graph, candidate, support, or vector publication and no credential disclosure.\n")
message(STATUS "Gemini extraction negative validation passed four durable-worker cases")
