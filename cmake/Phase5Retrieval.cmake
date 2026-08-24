foreach(required_var CPRAG_RXC CPRAG_RXAS CPRAG_RXVME CPRAG_RXBVM
        CPRAG_CREXX_BIN_DIR CPRAG_PLUGIN_DIR CPRAG_APP_DIR CPRAG_PROVIDER_CONTRACT
        CPRAG_PROFILE CPRAG_SCENARIO CPRAG_TUTORIAL CPRAG_TUTORIAL_FIXTURE
        CPRAG_TUTORIAL_EXPECTED CPRAG_IT_V1 CPRAG_IT_V2 CPRAG_IT_HELD_OUT
        CPRAG_IT_OPERATIONS CPRAG_SCOTLAND_CHRONICLE CPRAG_SCOTLAND_LEDGER
        CPRAG_NATIVE_CLI CPRAG_NATIVE_MCP CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}" "${CPRAG_WORK_DIR}/fixtures"
    "${CPRAG_WORK_DIR}/packets")
foreach(fixture IN ITEMS CPRAG_IT_V1 CPRAG_IT_V2 CPRAG_IT_HELD_OUT
        CPRAG_IT_OPERATIONS CPRAG_SCOTLAND_CHRONICLE CPRAG_SCOTLAND_LEDGER)
    file(COPY "${${fixture}}" DESTINATION "${CPRAG_WORK_DIR}/fixtures")
endforeach()

set(base_import "${CPRAG_PLUGIN_DIR};${CPRAG_CREXX_BIN_DIR}")
set(program_import "${CPRAG_WORK_DIR};${base_import}")
set(report "${CPRAG_WORK_DIR}/commands-and-output.txt")
file(WRITE "${report}"
    "phase=5\nlevel=G\nquery_plan=crexx-rag.query-plan/1\n"
    "evidence=crexx-rag.evidence/1\nanswer_context=crexx-rag.answer-context/1\n"
    "vector_generation=crexx-rag.rxvector-generation/1\n"
    "hosted_calls=0\nsecret_values_logged=0\n"
    "fixtures=frozen-4-it-plus-5-scotland-questions\n")

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

set(modules ragschema ragfile ragstore ragbackup ragingest ragfolder ragprofile
    it_architecture_profile ragmodel ragevidence ragquery ragembedding ragretrieval
    ragevidencejson provider_contract rx_sqlite_boundary rx_hash rx_system rxfs
    rxvector rxfnsg library)

foreach(mode IN ITEMS noopt opt)
    set(mode_flag)
    if(mode STREQUAL "noopt")
        set(mode_flag -n)
    endif()
    compile_crexx("${CPRAG_PROVIDER_CONTRACT}"
        "${CPRAG_WORK_DIR}/provider_contract" "${base_import}" "${mode_flag}"
        "${mode} provider contract")
    foreach(module IN ITEMS ragschema ragfile ragstore ragbackup ragingest ragfolder
            ragprofile ragmodel ragevidence ragquery ragembedding ragretrieval
            ragevidencejson)
        compile_crexx("${CPRAG_APP_DIR}/${module}.crexx"
            "${CPRAG_WORK_DIR}/${module}" "${program_import}" "${mode_flag}"
            "${mode} ${module}")
    endforeach()
    compile_crexx("${CPRAG_PROFILE}" "${CPRAG_WORK_DIR}/it_architecture_profile"
        "${program_import}" "${mode_flag}" "${mode} IT architecture profile")
    compile_crexx("${CPRAG_SCENARIO}" "${CPRAG_WORK_DIR}/scenario-${mode}"
        "${program_import}" "${mode_flag}" "${mode} Phase-5 scenario")
    compile_crexx("${CPRAG_TUTORIAL}" "${CPRAG_WORK_DIR}/tutorial-${mode}"
        "${program_import}" "${mode_flag}" "${mode} Phase-5 tutorial")

    foreach(runtime_name IN ITEMS rxvme rxbvm)
        if(runtime_name STREQUAL "rxvme")
            set(runtime "${CPRAG_RXVME}")
        else()
            set(runtime "${CPRAG_RXBVM}")
        endif()
        set(cell "${mode}-${runtime_name}")
        set(packet_arg)
        if(cell STREQUAL "opt-rxvme")
            set(packet_arg "${CPRAG_WORK_DIR}/packets")
        endif()
        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/scenario-${mode}" ${modules}
            -a "${cell}" "${CPRAG_WORK_DIR}/library-${cell}"
            "${CPRAG_WORK_DIR}/fixtures" ${packet_arg}
            OUTPUT_VARIABLE scenario_out ERROR_VARIABLE scenario_err
            RESULT_VARIABLE scenario_result TIMEOUT 180)
        if(NOT scenario_result EQUAL 0 OR
           NOT scenario_out MATCHES "P5_RETRIEVAL_OK cell=${cell}.*judged=9/9 score=144/144 required_recall=17/17 critical_failures=0 scorer_resets=2")
            message(FATAL_ERROR "${cell} Phase-5 scenario failed (${scenario_result}):\n${scenario_out}\n${scenario_err}")
        endif()
        file(APPEND "${report}" "${cell} scenario:\n${scenario_out}${scenario_err}\n")

        execute_process(COMMAND "${runtime}" -l "${program_import}"
            "${CPRAG_WORK_DIR}/tutorial-${mode}" ${modules}
            -a "${CPRAG_WORK_DIR}/tutorial-library-${cell}" "${CPRAG_TUTORIAL_FIXTURE}"
            OUTPUT_VARIABLE tutorial_out ERROR_VARIABLE tutorial_err
            RESULT_VARIABLE tutorial_result TIMEOUT 120)
        file(READ "${CPRAG_TUTORIAL_EXPECTED}" tutorial_expected)
        string(REPLACE "\r\n" "\n" tutorial_out "${tutorial_out}")
        string(STRIP "${tutorial_out}" tutorial_out)
        string(STRIP "${tutorial_expected}" tutorial_expected)
        if(NOT tutorial_result EQUAL 0 OR NOT tutorial_out STREQUAL tutorial_expected)
            message(FATAL_ERROR "${cell} Phase-5 tutorial mismatch (${tutorial_result}):\nactual:\n${tutorial_out}\nexpected:\n${tutorial_expected}\n${tutorial_err}")
        endif()
        file(APPEND "${report}" "${cell} tutorial:\n${tutorial_out}\n${tutorial_err}\n")
    endforeach()
endforeach()

set(crexx_context_total 0)
set(crexx_packet_total 0)
set(crexx_context_max 0)
foreach(case_index RANGE 1 9)
    set(context_file "${CPRAG_WORK_DIR}/packets/case-${case_index}.context.json")
    set(packet_file "${CPRAG_WORK_DIR}/packets/case-${case_index}.json")
    if(NOT EXISTS "${context_file}" OR NOT EXISTS "${packet_file}")
        message(FATAL_ERROR "Phase-5 packet ${case_index} was not retained")
    endif()
    file(SIZE "${context_file}" context_bytes)
    file(SIZE "${packet_file}" packet_bytes)
    if(context_bytes GREATER 65536 OR packet_bytes GREATER 65536)
        message(FATAL_ERROR "Phase-5 packet ${case_index} exceeded the 64 KiB ceiling")
    endif()
    math(EXPR crexx_context_total "${crexx_context_total}+${context_bytes}")
    math(EXPR crexx_packet_total "${crexx_packet_total}+${packet_bytes}")
    if(context_bytes GREATER crexx_context_max)
        set(crexx_context_max ${context_bytes})
    endif()
    file(READ "${context_file}" context_text)
    foreach(required IN ITEMS
            "\"schema\":\"crexx-rag.answer-context/1\""
            "\"citation\":\"crexx-rag:"
            "\"passages\":[" "\"accepted_claims\":[" "\"gaps\":[")
        string(FIND "${context_text}" "${required}" required_position)
        if(required_position EQUAL -1)
            message(FATAL_ERROR "Phase-5 answer context ${case_index} lacks ${required}")
        endif()
    endforeach()
endforeach()

set(native_library "${CPRAG_WORK_DIR}/native-v1.cprag")
execute_process(COMMAND "${CPRAG_NATIVE_CLI}" init "${native_library}"
    RESULT_VARIABLE native_init OUTPUT_VARIABLE native_init_out ERROR_VARIABLE native_init_err)
set(native_ingest_report "")
foreach(source IN ITEMS CPRAG_IT_V1 CPRAG_IT_V2 CPRAG_IT_HELD_OUT
        CPRAG_IT_OPERATIONS CPRAG_SCOTLAND_CHRONICLE CPRAG_SCOTLAND_LEDGER)
    get_filename_component(source_name "${${source}}" NAME)
    get_filename_component(source_ext "${${source}}" EXT)
    set(source_format plain)
    if(source_ext STREQUAL ".md")
        set(source_format markdown)
    endif()
    execute_process(COMMAND "${CPRAG_NATIVE_CLI}" ingest-file "${native_library}"
        "${${source}}" "${source_format}" 512 0 "${source_name}"
        RESULT_VARIABLE ingest_result OUTPUT_VARIABLE ingest_out ERROR_VARIABLE ingest_err)
    if(NOT ingest_result EQUAL 0)
        message(FATAL_ERROR "native-v1 fixture ingest failed for ${source_name}:\n${ingest_out}${ingest_err}")
    endif()
    string(APPEND native_ingest_report "${source_name}:\n${ingest_out}${ingest_err}")
endforeach()
if(NOT native_init EQUAL 0)
    message(FATAL_ERROR "native-v1 baseline init failed:\n${native_init_out}${native_init_err}")
endif()

set(questions
    "Trace the approved dependency path from Parcel API to destination records and identify the replica risk."
    "What is ADX, and which component reads it?"
    "What datastore does Orion use?"
    "Does the design claim every destination replica is current during regional failover?"
    "What role did Rannoch play in the Glen Mora removals, and how do the sources judge it?"
    "Why were the Brannochs called the Children of the Rain?"
    "Trace the origin of the Northwatch Regiment and explain An Freiceadan Gorm."
    "Were the Houses of Brannoch and Rannoch allied, and which northern claims are direct rather than graph-adjacent?"
    "Can the Glen Mora removals be described simply as lawful or unlawful from this source set?")
set(mcp_requests "")
set(request_id 0)
foreach(question IN LISTS questions)
    math(EXPR request_id "${request_id}+1")
    string(REPLACE "\\" "\\\\" question_json "${question}")
    string(REPLACE "\"" "\\\"" question_json "${question_json}")
    string(APPEND mcp_requests
        "{\"jsonrpc\":\"2.0\",\"id\":${request_id},\"method\":\"tools/call\",\"params\":{\"name\":\"library_answer_evidence\",\"arguments\":{\"question\":\"${question_json}\",\"focus\":\"${question_json}\",\"mode\":\"auto\",\"top_k\":12,\"hops\":3}}}\n")
endforeach()
set(mcp_request_file "${CPRAG_WORK_DIR}/native-mcp-requests.jsonl")
set(mcp_output_file "${CPRAG_WORK_DIR}/native-mcp-output.jsonl")
file(WRITE "${mcp_request_file}" "${mcp_requests}")
execute_process(COMMAND "${CPRAG_NATIVE_MCP}" --library "${native_library}"
    INPUT_FILE "${mcp_request_file}" OUTPUT_FILE "${mcp_output_file}"
    ERROR_VARIABLE mcp_err RESULT_VARIABLE mcp_result TIMEOUT 120)
if(NOT mcp_result EQUAL 0)
    message(FATAL_ERROR "native-v1 MCP baseline failed (${mcp_result}):\n${mcp_err}")
endif()
file(READ "${mcp_output_file}" mcp_output)
string(REGEX MATCHALL "\"jsonrpc\":\"2\\.0\"" mcp_responses "${mcp_output}")
list(LENGTH mcp_responses mcp_response_count)
string(FIND "${mcp_output}" "\\\"narrative_chunks\\\"" narrative_position)
string(FIND "${mcp_output}" "\\\"graph_claims\\\"" graph_position)
string(FIND "${mcp_output}" "\\\"answer_guidance\\\"" guidance_position)
if(NOT mcp_response_count EQUAL 9 OR narrative_position EQUAL -1 OR
   graph_position EQUAL -1 OR guidance_position EQUAL -1)
    message(FATAL_ERROR "native-v1 MCP baseline did not return nine evidence packets:\n${mcp_output}\n${mcp_err}")
endif()
file(SIZE "${mcp_output_file}" native_mcp_bytes)

set(full_context_bytes 0)
foreach(source IN ITEMS CPRAG_IT_V1 CPRAG_IT_V2 CPRAG_IT_HELD_OUT
        CPRAG_IT_OPERATIONS CPRAG_SCOTLAND_CHRONICLE CPRAG_SCOTLAND_LEDGER)
    file(SIZE "${${source}}" source_bytes)
    math(EXPR full_context_bytes "${full_context_bytes}+${source_bytes}")
endforeach()
if(NOT crexx_context_total LESS native_mcp_bytes)
    message(FATAL_ERROR "typed cREXX answer contexts were not smaller than the current native-v1 MCP baseline: cREXX=${crexx_context_total}, native=${native_mcp_bytes}")
endif()
file(WRITE "${CPRAG_WORK_DIR}/baseline-metrics.txt"
    "frozen_questions=9\n"
    "crexx_answer_context_total_bytes=${crexx_context_total}\n"
    "crexx_answer_context_max_bytes=${crexx_context_max}\n"
    "crexx_full_evidence_total_bytes=${crexx_packet_total}\n"
    "native_v1_mcp_total_bytes=${native_mcp_bytes}\n"
    "full_source_context_bytes_per_question=${full_context_bytes}\n"
    "comparison=crexx-context-smaller-than-native-mcp;full-context-micro-fixture-smaller-but-untyped\n")
math(EXPR full_context_nine "${full_context_bytes}*9")
file(APPEND "${CPRAG_WORK_DIR}/baseline-metrics.txt"
    "full_source_context_total_bytes_for_9_questions=${full_context_nine}\n")
file(APPEND "${report}"
    "native-v1 baseline init:\n${native_init_out}${native_init_err}\n"
    "native-v1 fixture ingestion:\n${native_ingest_report}\n"
    "native-v1 MCP stderr:\n${mcp_err}\n"
    "baseline metrics: cREXX-context=${crexx_context_total};cREXX-max=${crexx_context_max};cREXX-packets=${crexx_packet_total};native-MCP=${native_mcp_bytes};full-context-per-question=${full_context_bytes};full-context-nine=${full_context_nine}\n")

message(STATUS "Phase 5 passed: four optimized/non-optimized dual-VM retrieval/tutorial cells, exact rxvector generation, 9/9 frozen deterministic judgements, stable evidence packets, and native-v1/full-context baselines")
