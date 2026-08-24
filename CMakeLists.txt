cmake_minimum_required(VERSION 3.21)

project(crexx-rag
    VERSION 0.1.0
    DESCRIPTION "Lightweight local GraphRAG core with CREXX and MCP frontends"
    LANGUAGES C CXX)

include(GNUInstallDirs)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(CPRAG_BUILD_CLI "Build the crexx-rag command line tool" ON)
option(CPRAG_BUILD_MCP "Build the crexx-rag-mcp stdio server" ON)
option(CPRAG_BUILD_CREXX_PLUGIN "Build the CREXX rxpa plugin when CREXX_ROOT is available" ON)
option(CPRAG_BUILD_TESTS "Build unit tests" ON)
option(CPRAG_ENABLE_FAISS "Enable optional FAISS-backed vector index support" OFF)
option(CPRAG_ALLOW_VENDORED_CREXXPA "Retired compatibility option; ignored" OFF)
option(CPRAG_ALLOW_CREXX_SOURCE_FALLBACK "Retired compatibility option; ignored" OFF)

if(CPRAG_ALLOW_VENDORED_CREXXPA OR CPRAG_ALLOW_CREXX_SOURCE_FALLBACK)
    message(WARNING
        "Ignoring stale CREXX source/vendored SDK fallback settings and resetting them to OFF; "
        "consume an installed CREXX package")
    set(CPRAG_ALLOW_VENDORED_CREXXPA OFF CACHE BOOL
        "Retired compatibility option; ignored" FORCE)
    set(CPRAG_ALLOW_CREXX_SOURCE_FALLBACK OFF CACHE BOOL
        "Retired compatibility option; ignored" FORCE)
endif()
mark_as_advanced(
    CPRAG_ALLOW_VENDORED_CREXXPA
    CPRAG_ALLOW_CREXX_SOURCE_FALLBACK)

find_package(CREXX CONFIG QUIET)
if(CREXX_FOUND)
    set(CREXX_EXECUTABLE "${CREXX_crexx_EXECUTABLE}")
    set(CREXX_RXC_EXECUTABLE "${CREXX_rxc_EXECUTABLE}")
    set(CREXX_RXAS_EXECUTABLE "${CREXX_rxas_EXECUTABLE}")
    set(CREXX_RXLINK_EXECUTABLE "${CREXX_rxlink_EXECUTABLE}")
    set(CREXX_RXVME_EXECUTABLE "${CREXX_rxvme_EXECUTABLE}")
    set(CREXX_RXBVM_EXECUTABLE "${CREXX_rxbvm_EXECUTABLE}")
    set(CREXX_INSTALL_BIN_DIR "${CREXX_BIN_DIR}")
    set(CREXX_VERSION_INCLUDE_DIR "${CREXX_INCLUDE_DIR}")
    message(STATUS
        "Using installed CREXX package ${CREXX_VERSION_DISPLAY} from ${CREXX_PACKAGE_PREFIX}")
elseif(CPRAG_BUILD_CREXX_PLUGIN)
    message(WARNING
        "Installed CREXX CMake package was not found; CREXX plugins and integration tests are unavailable")
endif()

find_package(SQLite3 QUIET)
if(NOT SQLite3_FOUND)
    message(FATAL_ERROR
        "SQLite3 development files are required (sqlite3.h and the link library). "
        "On Debian/Ubuntu, install them with: sudo apt-get install libsqlite3-dev. "
        "For a non-system installation, set SQLite3_INCLUDE_DIR and SQLite3_LIBRARY.")
endif()
find_package(CURL QUIET)

if(TARGET SQLite3::SQLite3)
    set(CPRAG_SQLITE_LINK SQLite3::SQLite3)
elseif(TARGET SQLite::SQLite3)
    set(CPRAG_SQLITE_LINK SQLite::SQLite3)
else()
    set(CPRAG_SQLITE_LINK ${SQLite3_LIBRARIES})
    set(CPRAG_SQLITE_INCLUDE_DIRS ${SQLite3_INCLUDE_DIRS})
endif()

set(CPRAG_FAISS_LINK "")
if(CPRAG_ENABLE_FAISS)
    find_package(faiss CONFIG QUIET)
    if(TARGET faiss)
        set(CPRAG_FAISS_LINK faiss)
    elseif(TARGET faiss::faiss)
        set(CPRAG_FAISS_LINK faiss::faiss)
    else()
        find_path(FAISS_INCLUDE_DIR faiss/IndexFlat.h)
        find_library(FAISS_LIBRARY faiss)
        if(FAISS_INCLUDE_DIR AND FAISS_LIBRARY)
            add_library(cprag_faiss UNKNOWN IMPORTED)
            set_target_properties(cprag_faiss PROPERTIES
                IMPORTED_LOCATION "${FAISS_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${FAISS_INCLUDE_DIR}")
            set(CPRAG_FAISS_LINK cprag_faiss)
        endif()
    endif()

    if(NOT CPRAG_FAISS_LINK)
        message(FATAL_ERROR "CPRAG_ENABLE_FAISS is ON, but FAISS was not found. Install FAISS or configure FAISS_INCLUDE_DIR/FAISS_LIBRARY.")
    endif()
endif()

add_library(cprag_core
    core/chunker.cpp
    core/ragcore.cpp)
add_library(crexx-rag::core ALIAS cprag_core)
set_target_properties(cprag_core PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(cprag_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
        $<INSTALL_INTERFACE:include>)
if(CPRAG_SQLITE_INCLUDE_DIRS)
    target_include_directories(cprag_core PUBLIC ${CPRAG_SQLITE_INCLUDE_DIRS})
endif()
target_link_libraries(cprag_core PUBLIC ${CPRAG_SQLITE_LINK})
if(CPRAG_ENABLE_FAISS)
    target_compile_definitions(cprag_core PUBLIC CPRAG_HAVE_FAISS=1)
    target_link_libraries(cprag_core PUBLIC ${CPRAG_FAISS_LINK})
endif()

if(CPRAG_BUILD_CLI)
    add_executable(crexx-rag cli/main.cpp)
    target_link_libraries(crexx-rag PRIVATE cprag_core)
    if(TARGET CURL::libcurl)
        target_link_libraries(crexx-rag PRIVATE CURL::libcurl)
        target_compile_definitions(crexx-rag PRIVATE CPRAG_HAVE_CURL=1)
    endif()
endif()

if(CPRAG_BUILD_MCP)
    add_executable(crexx-rag-mcp mcp/main.cpp)
    target_link_libraries(crexx-rag-mcp PRIVATE cprag_core)
endif()

if(CPRAG_BUILD_CREXX_PLUGIN)
    if(CREXX_FOUND AND TARGET CREXX::RXPA)
        set(CREXX_RXPA_PLUGIN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
        add_dynamic_plugin_target(_rag crexx/plugins/rag/rxrag.c)
        target_include_directories(_rag PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include")
        target_link_libraries(_rag PRIVATE cprag_core)

        add_dynamic_plugin_target(_sqlite_boundary
            incubator/p1a/sqlite_boundary/sqlite_boundary.c)
        target_link_libraries(_sqlite_boundary PRIVATE ${CPRAG_SQLITE_LINK})
        if(CPRAG_SQLITE_INCLUDE_DIRS)
            target_include_directories(_sqlite_boundary PRIVATE ${CPRAG_SQLITE_INCLUDE_DIRS})
        endif()
    endif()
endif()

install(TARGETS cprag_core
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}")
install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
if(TARGET crexx-rag)
    install(TARGETS crexx-rag RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
endif()
if(TARGET crexx-rag-mcp)
    install(TARGETS crexx-rag-mcp RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
endif()
if(TARGET _sqlite_boundary)
    install(TARGETS _sqlite_boundary
        RUNTIME DESTINATION "${CMAKE_INSTALL_LIBDIR}/crexx-rag/providers"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/crexx-rag/providers")
endif()
install(DIRECTORY crexx/application/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexx-rag/application"
    FILES_MATCHING PATTERN "*.crexx" PATTERN "README.md" PATTERN "SYSTEM.md")
install(DIRECTORY incubator/phase1b/provider/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexx-rag/provider"
    FILES_MATCHING PATTERN "*.crexx" PATTERN "README.md" PATTERN "SYSTEM.md")
install(DIRECTORY skills/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexx-rag/skills"
    FILES_MATCHING PATTERN "SKILL.md" PATTERN "manifest.json" PATTERN "README.md")
install(DIRECTORY tests/fixtures/tutorial/architecture-mini/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexx-rag/tutorial/architecture-mini")
install(FILES
    cmake/CompileInstalledCrexxRag.cmake
    DESTINATION "${CMAKE_INSTALL_DATADIR}/crexx-rag/cmake")
install(FILES
    docs/tutorials/phase-4-improvement.md
    docs/tutorials/phase-5-retrieval.md
    docs/tutorials/phase-6-surfaces.md
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/crexx-rag/tutorials")

if(CREXX_FOUND AND CPRAG_BUILD_TESTS)
    set(CPRAG_SURFACE_OPERATION_BASE
        "${CMAKE_BINARY_DIR}/contracts/surface_operation_contract")
    set(CPRAG_SURFACE_OPERATION_RXBIN
        "${CPRAG_SURFACE_OPERATION_BASE}.rxbin")
    add_custom_command(
        OUTPUT "${CPRAG_SURFACE_OPERATION_RXBIN}"
        BYPRODUCTS "${CPRAG_SURFACE_OPERATION_BASE}.rxas"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/contracts"
        COMMAND "${CREXX_RXC_EXECUTABLE}" -x
            -o "${CPRAG_SURFACE_OPERATION_BASE}"
            "${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/surface_boundary/surface_operation_contract.crexx"
        COMMAND "${CREXX_RXAS_EXECUTABLE}"
            -o "${CPRAG_SURFACE_OPERATION_BASE}" "${CPRAG_SURFACE_OPERATION_BASE}"
        DEPENDS
            "${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/surface_boundary/surface_operation_contract.crexx"
        VERBATIM)
    crexx_add_operation_contract(
        TARGET p1a_surface_operation_contract
        RXBIN "${CPRAG_SURFACE_OPERATION_RXBIN}"
        OPERATION surface_operation.statusoperation.status_evidence
        CONTRACT_VERSION 1.0.0
        OUTPUT "${CMAKE_BINARY_DIR}/contracts/surface_operation_contract.rxcontract.json")
    add_custom_target(p1a_contracts ALL DEPENDS p1a_surface_operation_contract)
endif()

if(CPRAG_BUILD_TESTS)
    enable_testing()
    add_test(
        NAME donation_docs_audit
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_SOURCE_ROOT=${CMAKE_CURRENT_LIST_DIR}"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/DonationDocsAudit.cmake")
    set_tests_properties(donation_docs_audit PROPERTIES
        LABELS "docs;incubation;donation;housekeeping")

    add_test(
        NAME crexx_language_level_audit
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_SOURCE_ROOT=${CMAKE_CURRENT_LIST_DIR}"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CrexxLanguageLevelAudit.cmake")
    set_tests_properties(crexx_language_level_audit PROPERTIES
        LABELS "crexx;levelg;architecture;housekeeping")

    add_executable(ragcore_smoke tests/ragcore_smoke.cpp)
    target_link_libraries(ragcore_smoke PRIVATE cprag_core)
    add_test(NAME ragcore_smoke COMMAND ragcore_smoke)
    set_tests_properties(ragcore_smoke PROPERTIES LABELS "core;smoke")

    add_executable(ragcore_work_queue_consumers tests/ragcore_work_queue_consumers.cpp)
    target_link_libraries(ragcore_work_queue_consumers PRIVATE cprag_core)
    add_test(NAME ragcore_work_queue_consumers COMMAND ragcore_work_queue_consumers)
    set_tests_properties(ragcore_work_queue_consumers PROPERTIES LABELS "core;queue;fixup;consumer")

    add_executable(phase0_oracle_semantics tests/phase0_oracle_semantics.cpp)
    target_link_libraries(phase0_oracle_semantics PRIVATE cprag_core)
    target_compile_definitions(phase0_oracle_semantics PRIVATE
        CPRAG_PHASE0_FIXTURE_DIR="${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0")
    add_test(
        NAME phase0_oracle_semantic_golden
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_ORACLE_CAPTURE=$<TARGET_FILE:phase0_oracle_semantics>"
            "-DCPRAG_GOLDEN=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/goldens/oracle-semantics.jsonl"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase0-oracle-semantic-golden"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase0OracleSemanticGolden.cmake")
    set_tests_properties(phase0_oracle_semantic_golden PROPERTIES LABELS "phase0;oracle;golden")

    add_executable(phase0_oracle_defects tests/phase0_oracle_defects.cpp)
    target_link_libraries(phase0_oracle_defects PRIVATE cprag_core)
    target_compile_definitions(phase0_oracle_defects PRIVATE
        CPRAG_PHASE0_FIXTURE_DIR="${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0")
    add_test(
        NAME phase0_oracle_defect_golden
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_DEFECT_CAPTURE=$<TARGET_FILE:phase0_oracle_defects>"
            "-DCPRAG_GOLDEN=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/defects/oracle-defects.jsonl"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase0-oracle-defect-golden"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase0OracleDefectGolden.cmake")
    set_tests_properties(phase0_oracle_defect_golden PROPERTIES LABELS "phase0;oracle;golden;defect")

    add_executable(phase0_native_benchmark tests/phase0_native_benchmark.cpp)
    target_link_libraries(phase0_native_benchmark PRIVATE ${CPRAG_SQLITE_LINK})
    add_executable(phase0_loopback_provider tests/phase0_loopback_provider.cpp)
    add_executable(p1a_provider_loopback tests/p1a_provider_loopback.cpp)
    if(CREXX_RXC_EXECUTABLE AND CREXX_RXAS_EXECUTABLE AND CREXX_RXVME_EXECUTABLE AND CREXX_RXBVM_EXECUTABLE)
        add_test(
            NAME phase0_component_benchmark
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                # The original phase0_components.crexx is hash-frozen Gate-0
                # evidence. Run the maintained Level-G compatibility successor.
                "-DCPRAG_BENCHMARK_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/benchmarks/phase0_components_current.crexx"
                "-DCPRAG_NATIVE_BENCHMARK=$<TARGET_FILE:phase0_native_benchmark>"
                "-DCPRAG_LOOPBACK_PROVIDER=$<TARGET_FILE:phase0_loopback_provider>"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase0-component-benchmark"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase0ComponentBenchmark.cmake")
        set_tests_properties(phase0_component_benchmark PROPERTIES LABELS "phase0;benchmark;crexx;sqlite;vector;provider")
        add_test(
            NAME p1a_rxjson_projection
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_TEST_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/rxjson_projection/rxjson_projection_test.crexx"
                "-DCPRAG_BENCHMARK_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/rxjson_projection/rxjson_projection_benchmark.crexx"
                "-DCPRAG_PROBE_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/rxjson_projection/binary_argument_optimizer_probe.crexx"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-rxjson-projection"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1AJsonDocument.cmake")
        set_tests_properties(p1a_rxjson_projection PROPERTIES
            LABELS "p1a;data;rxjson;parse-once;raw-binary;benchmark")
        if(CPRAG_BUILD_CREXX_PLUGIN AND TARGET _sqlite_boundary)
            add_test(
                NAME p1a_vector_boundary
                COMMAND "${CMAKE_COMMAND}"
                    "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                    "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                    "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                    "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                    "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                    "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
                    "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/vector_boundary/vector_boundary.crexx"
                    "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/vector_boundary/vector_boundary_test.crexx"
                    "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-vector-boundary"
                    -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1AVectorBoundary.cmake")
            set_tests_properties(p1a_vector_boundary PROPERTIES
                LABELS "p1a;vector;sqlite;cosine;raw-binary;schema-owned;benchmark;incubator")
        endif()
    endif()

    if(CREXX_FOUND AND CREXX_RXC_EXECUTABLE AND CREXX_RXAS_EXECUTABLE
            AND CREXX_RXVME_EXECUTABLE AND CREXX_RXBVM_EXECUTABLE)
        add_test(
            NAME p1a_crexx_closure_reproducers
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_RECORD_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-record-contract.crexx"
                "-DCPRAG_RECORD_FACADE=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-imported-record-return-repro.crexx"
                "-DCPRAG_PARSE_REPRO=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/repro/levelg-parseplan-repro.crexx"
                "-DCPRAG_LOOP_REPRO=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/repro/levelb-do-forever-return-repro.crexx"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-crexx-closure-reproducers"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1ACrexxClosureReproducers.cmake")
        set_tests_properties(p1a_crexx_closure_reproducers PROPERTIES
            LABELS "p1a;crexx;closure;levelg;record;parse;flow")
        add_test(
            NAME p1a_sdk_probe
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_CREXX_PREFIX=${CREXX_PACKAGE_PREFIX}"
                "-DCPRAG_CREXX_DIR=${CREXX_DIR}"
                "-DCPRAG_CREXX_VERSION=${CREXX_VERSION_DISPLAY}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_GENERATOR=${CMAKE_GENERATOR}"
                "-DCPRAG_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
                "-DCPRAG_PROBE_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/sdk_probe"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-sdk-probe"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1ASdkProbe.cmake")
        set_tests_properties(p1a_sdk_probe PROPERTIES LABELS "p1a;sdk;rxpa;incubator")

        set(P1_RXPA_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_CREXX_PREFIX=${CREXX_PACKAGE_PREFIX}"
            "-DCPRAG_CREXX_DIR=${CREXX_DIR}"
            "-DCPRAG_CREXX_VERSION=${CREXX_VERSION_DISPLAY}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_GENERATOR=${CMAKE_GENERATOR}"
            "-DCPRAG_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
            "-DCPRAG_FORBIDDEN_CREXX_SOURCE_DIR=${CMAKE_CURRENT_LIST_DIR}/../CREXX"
            "-DCPRAG_CONSUMER_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxpa_consumer"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-rxpa-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Rxpa01.cmake")
        add_custom_target(p1_rxpa_01
            COMMAND ${P1_RXPA_01_COMMAND}
            COMMENT "Running P1-RXPA-01 installed SDK external-consumer proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_rxpa_01 COMMAND ${P1_RXPA_01_COMMAND})
        set_tests_properties(p1_rxpa_01 PROPERTIES
            LABELS "P1-RXPA-01;phase1b;sdk;rxpa;installed-consumer")

        set(P1_RXPA_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_CREXX_PREFIX=${CREXX_PACKAGE_PREFIX}"
            "-DCPRAG_CREXX_DIR=${CREXX_DIR}"
            "-DCPRAG_CREXX_VERSION=${CREXX_VERSION_DISPLAY}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_GENERATOR=${CMAKE_GENERATOR}"
            "-DCPRAG_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
            "-DCPRAG_CONSUMER_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxpa_consumer"
            "-DCPRAG_PACKAGE_PROBE_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxpa_consumer/package_probe"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-rxpa-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Rxpa02.cmake")
        add_custom_target(p1_rxpa_02
            COMMAND ${P1_RXPA_02_COMMAND}
            COMMENT "Running P1-RXPA-02 development-package qualification"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_rxpa_02 COMMAND ${P1_RXPA_02_COMMAND})
        set_tests_properties(p1_rxpa_02 PROPERTIES
            LABELS "P1-RXPA-02;phase1b;sdk;rxpa;package-diagnostics")
    endif()

    add_test(
        NAME phase0_judgement_catalog
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_SCOTLAND=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/judgements/scotland-shaped-judgements.jsonl"
            "-DCPRAG_IT_QUESTIONS=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/judgements/it-held-out-questions.jsonl"
            "-DCPRAG_IT_JUDGEMENTS=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/judgements/it-held-out-judgements.jsonl"
            "-DCPRAG_RUBRIC=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/judgements/rubric.md"
            "-DCPRAG_PASSAGE_MAP=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/judgements/passage-map.tsv"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase0JudgementValidation.cmake")
    set_tests_properties(phase0_judgement_catalog PROPERTIES LABELS "phase0;judgement;quality")

    add_test(
        NAME phase0_gate_protocol
        COMMAND "${CMAKE_COMMAND}"
            "-DCPRAG_ROOT=${CMAKE_CURRENT_LIST_DIR}"
            "-DCPRAG_HASHES=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/frozen-hashes.tsv"
            "-DCPRAG_THRESHOLDS=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/thresholds.json"
            "-DCPRAG_PROTOCOL=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/ANSWER-EVALUATION-PROTOCOL.md"
            "-DCPRAG_NATIVE_RESULTS=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/raw/p0-06/native.csv"
            "-DCPRAG_RXVME_RESULTS=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/raw/p0-06/rxvme.csv"
            "-DCPRAG_RXBVM_RESULTS=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/raw/p0-06/rxbvm.csv"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase0GateProtocolValidation.cmake")
    set_tests_properties(phase0_gate_protocol PROPERTIES LABELS "phase0;gate;protocol")

    if(CPRAG_BUILD_CLI AND TARGET crexx-rag)
        add_test(
            NAME llama_extract_prompt_smoke
            COMMAND $<TARGET_FILE:crexx-rag>
                extract-llama-server
                --dry-prompt
                --profile scotland
                "The Macnicols held lands in Assynt and were connected with Sutherland.")
        set_tests_properties(llama_extract_prompt_smoke PROPERTIES
            PASS_REGULAR_EXPRESSION "Scotland profile node types"
            LABELS "cli;llm-adapter;prompt")
        add_test(
            NAME llama_advice_prompt_smoke
            COMMAND $<TARGET_FILE:crexx-rag>
                advise-llama-server
                --dry-prompt
                --task route
                --profile scotland
                --context "known=Clan Sutherland score=18"
                "The Mackays fought the Sutherlands at Dingwall.")
        set_tests_properties(llama_advice_prompt_smoke PROPERTIES
            PASS_REGULAR_EXPRESSION "gemma-extract"
            LABELS "cli;llm-adapter;prompt")
        add_test(
            NAME cli_work_queue_consumers_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_CLI=$<TARGET_FILE:crexx-rag>"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/cli-work-queue-consumers-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CliWorkQueueConsumersSmoke.cmake")
        set_tests_properties(cli_work_queue_consumers_smoke PROPERTIES LABELS "cli;queue;fixup;consumer")
    endif()

    if(CPRAG_BUILD_MCP AND TARGET crexx-rag-mcp)
        add_test(
            NAME mcp_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_MCP=$<TARGET_FILE:crexx-rag-mcp>"
                "-DCPRAG_CLI=$<TARGET_FILE:crexx-rag>"
                "-DCPRAG_FAISS_ENABLED=${CPRAG_ENABLE_FAISS}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/mcp-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/McpSmoke.cmake")
        set_tests_properties(mcp_smoke PROPERTIES LABELS "mcp;smoke")
        if(CPRAG_BUILD_CLI AND TARGET crexx-rag)
            add_test(
                NAME phase0_answer_evidence_golden
                COMMAND "${CMAKE_COMMAND}"
                    "-DCPRAG_CLI=$<TARGET_FILE:crexx-rag>"
                    "-DCPRAG_MCP=$<TARGET_FILE:crexx-rag-mcp>"
                    "-DCPRAG_GOLDEN=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/goldens/answer-evidence.jsonl"
                    "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase0-answer-evidence-golden"
                    -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase0AnswerEvidenceGolden.cmake")
            set_tests_properties(phase0_answer_evidence_golden PROPERTIES LABELS "phase0;oracle;golden;mcp;evidence")
        endif()
    endif()

    if(CPRAG_BUILD_CREXX_PLUGIN
            AND TARGET _rag
            AND CREXX_EXECUTABLE
            AND CREXX_RXC_EXECUTABLE
            AND CREXX_RXAS_EXECUTABLE
            AND CREXX_RXVME_EXECUTABLE)
        add_test(
            NAME p1a_sqlite_boundary
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
                "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/sqlite_boundary/sqlite_boundary_test.crexx"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-sqlite-boundary"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1ASqliteBoundary.cmake")
        set_tests_properties(p1a_sqlite_boundary PROPERTIES
            LABELS "p1a;sqlite;typed;incubator")
        set(P1_SQL_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_01.crexx"
            "-DCPRAG_MODULES=rx_sqlite_boundary"
            "-DCPRAG_EXPECTED=P1_SQL_01_OK"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase1bCrexxDualVm.cmake")
        add_custom_target(p1_sql_01
            COMMAND ${P1_SQL_01_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-01 ownership and error contract"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_01 COMMAND ${P1_SQL_01_COMMAND})
        set_tests_properties(p1_sql_01 PROPERTIES
            LABELS "P1-SQL-01;phase1b;sqlite;ownership;errors;incubator")
        set(P1_SQL_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_02.crexx"
            "-DCPRAG_MODULES=rx_sqlite_boundary"
            "-DCPRAG_EXPECTED=P1_SQL_02_OK"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase1bCrexxDualVm.cmake")
        add_custom_target(p1_sql_02
            COMMAND ${P1_SQL_02_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-02 typed and large-value proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_02 COMMAND ${P1_SQL_02_COMMAND})
        set_tests_properties(p1_sql_02 PROPERTIES
            LABELS "P1-SQL-02;phase1b;sqlite;typed;large-values;incubator")
        set(P1_SQL_03_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_03.crexx"
            "-DCPRAG_MODULES=rx_sqlite_boundary"
            "-DCPRAG_EXPECTED=P1_SQL_03_OK"
            -DCPRAG_DATABASE_ARGUMENT=ON
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-03"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase1bCrexxDualVm.cmake")
        add_custom_target(p1_sql_03
            COMMAND ${P1_SQL_03_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-03 transaction and capability controls"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_03 COMMAND ${P1_SQL_03_COMMAND})
        set_tests_properties(p1_sql_03 PROPERTIES
            LABELS "P1-SQL-03;phase1b;sqlite;transaction;fts5;json1;wal;incubator")
        set(P1_SQL_04_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_04.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-04"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Sql04.cmake")
        add_custom_target(p1_sql_04
            COMMAND ${P1_SQL_04_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-04 read-only zero-write proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_04 COMMAND ${P1_SQL_04_COMMAND})
        set_tests_properties(p1_sql_04 PROPERTIES
            LABELS "P1-SQL-04;phase1b;sqlite;read-only;zero-write;incubator")
        set(P1_SQL_05_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_05.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-05"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Sql05.cmake")
        add_custom_target(p1_sql_05
            COMMAND ${P1_SQL_05_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-05 separate-process concurrency proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_05 COMMAND ${P1_SQL_05_COMMAND})
        set_tests_properties(p1_sql_05 PROPERTIES
            LABELS "P1-SQL-05;phase1b;sqlite;concurrency;processes;wal;incubator")
        set(P1_SQL_06_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_06.crexx"
            "-DCPRAG_MODULES=rx_sqlite_boundary"
            "-DCPRAG_EXPECTED=P1_SQL_06_OK"
            -DCPRAG_DATABASE_ARGUMENT=ON
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-06"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase1bCrexxDualVm.cmake")
        add_custom_target(p1_sql_06
            COMMAND ${P1_SQL_06_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-06 backup, integrity, and cleanup proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_06 COMMAND ${P1_SQL_06_COMMAND})
        set_tests_properties(p1_sql_06 PROPERTIES
            LABELS "P1-SQL-06;phase1b;sqlite;backup;integrity;cleanup;incubator")
        set(P1_SQL_07_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/rxsqlite_address.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/rxsqlite/p1_sql_07.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-sql-07"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Sql07.cmake")
        add_custom_target(p1_sql_07
            COMMAND ${P1_SQL_07_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-SQL-07 optional ADDRESS SQLITE facade proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_sql_07 COMMAND ${P1_SQL_07_COMMAND})
        set_tests_properties(p1_sql_07 PROPERTIES
            LABELS "P1-SQL-07;phase1b;sqlite;address;syntax;incubator")
        set(P1_JSON_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/structured_data/p1_json_01.crexx"
            "-DCPRAG_MODULES=library"
            "-DCPRAG_EXPECTED=P1_JSON_01_OK"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-json-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase1bCrexxDualVm.cmake")
        add_custom_target(p1_json_01
            COMMAND ${P1_JSON_01_COMMAND}
            COMMENT "Running P1-JSON-01 installed parse-once JSON proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_json_01 COMMAND ${P1_JSON_01_COMMAND})
        set_tests_properties(p1_json_01 PROPERTIES
            LABELS "P1-JSON-01;phase1b;json;parse-once;unicode;typed;incubator")
        set(P1_JSON_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/structured_data/p1_json_02.crexx"
            "-DCPRAG_MODULES=library"
            "-DCPRAG_EXPECTED=P1_JSON_02_OK"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-json-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase1bCrexxDualVm.cmake")
        add_custom_target(p1_json_02
            COMMAND ${P1_JSON_02_COMMAND}
            COMMENT "Running P1-JSON-02 same-session provider/evidence comparison"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_json_02 COMMAND ${P1_JSON_02_COMMAND})
        set_tests_properties(p1_json_02 PROPERTIES
            LABELS "P1-JSON-02;phase1b;json;benchmark;provider;evidence;incubator")
        set(P1_REC_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_RECORD_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/structured_data/record_boundary.crexx"
            "-DCPRAG_FACADE_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/structured_data/record_facade.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/structured_data/p1_rec_01.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-rec-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Rec01.cmake")
        add_custom_target(p1_rec_01
            COMMAND ${P1_REC_01_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-REC-01 typed record crossing proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_rec_01 COMMAND ${P1_REC_01_COMMAND})
        set_tests_properties(p1_rec_01 PROPERTIES
            LABELS "P1-REC-01;phase1b;record;levelg;sqlite;incubator")
        set(P1_LLM_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_FACADE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_facade.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/p1_llm_01.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-llm-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Llm01.cmake")
        add_custom_target(p1_llm_01
            COMMAND ${P1_LLM_01_COMMAND}
            COMMENT "Running P1-LLM-01 provider-neutral contract proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_llm_01 COMMAND ${P1_LLM_01_COMMAND})
        set_tests_properties(p1_llm_01 PROPERTIES
            LABELS "P1-LLM-01;phase1b;provider;contract;levelg;incubator")
        set(P1_LLM_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/openai_compatible_provider.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/p1_llm_02.crexx"
            "-DCPRAG_LOOPBACK=$<TARGET_FILE:p1a_provider_loopback>"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-llm-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Llm02.cmake")
        add_custom_target(p1_llm_02
            COMMAND ${P1_LLM_02_COMMAND}
            DEPENDS p1a_provider_loopback
            COMMENT "Running P1-LLM-02 local OpenAI-compatible calls"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_llm_02 COMMAND ${P1_LLM_02_COMMAND})
        set_tests_properties(p1_llm_02 PROPERTIES
            LABELS "P1-LLM-02;phase1b;provider;openai-compatible;local;loopback;incubator")
        set(P1_LLM_03_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_CATALOG=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_catalog.crexx"
            "-DCPRAG_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/openai_compatible_provider.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/p1_llm_03.crexx"
            "-DCPRAG_LOOPBACK=$<TARGET_FILE:p1a_provider_loopback>"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-llm-03"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Llm03.cmake")
        add_custom_target(p1_llm_03
            COMMAND ${P1_LLM_03_COMMAND}
            DEPENDS p1a_provider_loopback
            COMMENT "Running P1-LLM-03 provider hardening proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_llm_03 COMMAND ${P1_LLM_03_COMMAND})
        set_tests_properties(p1_llm_03 PROPERTIES
            LABELS "P1-LLM-03;phase1b;provider;structured;batch;retry;privacy;capabilities;incubator")
        set(P1_LLM_04_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_CATALOG=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_catalog.crexx"
            "-DCPRAG_FACADE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_facade.crexx"
            "-DCPRAG_HTTP=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_http.crexx"
            "-DCPRAG_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/industrial_provider.crexx"
            "-DCPRAG_LOCAL_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/openai_compatible_provider.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/p1_llm_04.crexx"
            "-DCPRAG_LOOPBACK=$<TARGET_FILE:p1a_provider_loopback>"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-llm-04"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Llm04.cmake")
        add_custom_target(p1_llm_04
            COMMAND ${P1_LLM_04_COMMAND}
            DEPENDS p1a_provider_loopback
            COMMENT "Running P1-LLM-04 deterministic multi-provider proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_llm_04 COMMAND ${P1_LLM_04_COMMAND})
        set_tests_properties(p1_llm_04 PROPERTIES
            LABELS "P1-LLM-04;phase1b;provider;openai;anthropic;gemini;multimodal;embeddings;incubator")
        set(P1_LLM_04_HOSTED_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_CATALOG=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_catalog.crexx"
            "-DCPRAG_HTTP=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_http.crexx"
            "-DCPRAG_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/industrial_provider.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/p1_llm_04_hosted.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-llm-04-hosted"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Llm04Hosted.cmake")
        add_custom_target(p1_llm_04_hosted
            COMMAND ${P1_LLM_04_HOSTED_COMMAND}
            COMMENT "Running one-time P1-LLM-04 low-cost hosted qualification"
            USES_TERMINAL
            VERBATIM)
        set(P1_LLM_05_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_CATALOG=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_catalog.crexx"
            "-DCPRAG_HTTP=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_http.crexx"
            "-DCPRAG_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/industrial_provider.crexx"
            "-DCPRAG_LOCAL_ADAPTER=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/openai_compatible_provider.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/p1_llm_05.crexx"
            "-DCPRAG_LOOPBACK=$<TARGET_FILE:p1a_provider_loopback>"
            "-DCPRAG_SOURCE_ROOT=${CMAKE_CURRENT_LIST_DIR}"
            "-DCPRAG_HOSTED_OUTPUT=${CMAKE_BINARY_DIR}/p1-llm-04-hosted/hosted-output.txt"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-llm-05"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Llm05.cmake")
        add_custom_target(p1_llm_05
            COMMAND ${P1_LLM_05_COMMAND}
            DEPENDS p1a_provider_loopback
            COMMENT "Running P1-LLM-05 zero-outbound and secret-retention proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_llm_05 COMMAND ${P1_LLM_05_COMMAND})
        set_tests_properties(p1_llm_05 PROPERTIES
            LABELS "P1-LLM-05;phase1b;provider;privacy;zero-outbound;secrets;incubator")
        set(P1_VEC_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_CODEC=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_codec.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/p1_vec_01.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-vec-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Vec01.cmake")
        add_custom_target(p1_vec_01
            COMMAND ${P1_VEC_01_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-VEC-01 versioned float32 codec proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_vec_01 COMMAND ${P1_VEC_01_COMMAND})
        set_tests_properties(p1_vec_01 PROPERTIES
            LABELS "P1-VEC-01;phase1b;vector;codec;f32le;sqlite;incubator")
        set(P1_VEC_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_CODEC=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_codec.crexx"
            "-DCPRAG_SEARCH=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_search.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/p1_vec_02.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-vec-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Vec02.cmake")
        add_custom_target(p1_vec_02
            COMMAND ${P1_VEC_02_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-VEC-02 representative exact-ordering proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_vec_02 COMMAND ${P1_VEC_02_COMMAND})
        set_tests_properties(p1_vec_02 PROPERTIES
            LABELS "P1-VEC-02;phase1b;vector;rxvector;packed;cosine;top-k;ordering;sqlite;incubator")
        set(P1_VEC_03_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_CODEC=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_codec.crexx"
            "-DCPRAG_SEARCH=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_search.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/p1_vec_03.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-vec-03"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Vec03.cmake")
        add_custom_target(p1_vec_03
            COMMAND ${P1_VEC_03_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-VEC-03 representative component measurements"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_vec_03 COMMAND ${P1_VEC_03_COMMAND})
        set_tests_properties(p1_vec_03 PROPERTIES
            LABELS "P1-VEC-03;phase1b;vector;rxvector;packed;benchmark;transfer;memory;sqlite;incubator")
        set(P1_HASH_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_CREXX=${CREXX_EXECUTABLE}"
            "-DCPRAG_EXE_SUFFIX=${CMAKE_EXECUTABLE_SUFFIX}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/hash/p1_hash_01.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-hash-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Hash01.cmake")
        add_custom_target(p1_hash_01
            COMMAND ${P1_HASH_01_COMMAND}
            COMMENT "Running P1-HASH-01 installed SHA-256 capability proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_hash_01 COMMAND ${P1_HASH_01_COMMAND})
        set_tests_properties(p1_hash_01 PROPERTIES
            LABELS "P1-HASH-01;capability-sync;hash;sha256;autoload;static;native;phase1b;incubator")
        set(P1_ALG_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_store.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/p1_alg_01.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-alg-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Alg01.cmake")
        add_custom_target(p1_alg_01
            COMMAND ${P1_ALG_01_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-ALG-01 scratch source and lexical proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_alg_01 COMMAND ${P1_ALG_01_COMMAND})
        set_tests_properties(p1_alg_01 PROPERTIES
            LABELS "P1-ALG-01;phase1b;algorithm;source;chunk;fts5;sqlite;incubator")
        set(P1_ALG_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_store.crexx"
            "-DCPRAG_LIFECYCLE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_lifecycle.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/p1_alg_02.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-alg-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Alg02.cmake")
        add_custom_target(p1_alg_02
            COMMAND ${P1_ALG_02_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-ALG-02 revision no-op and chunk-reuse proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_alg_02 COMMAND ${P1_ALG_02_COMMAND})
        set_tests_properties(p1_alg_02 PROPERTIES
            LABELS "P1-ALG-02;phase1b;algorithm;source;revision;idempotence;sqlite;incubator")
        set(P1_ALG_03_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_store.crexx"
            "-DCPRAG_LIFECYCLE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_lifecycle.crexx"
            "-DCPRAG_CLAIMS=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/claim_store.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/p1_alg_03.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-alg-03"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Alg03.cmake")
        add_custom_target(p1_alg_03
            COMMAND ${P1_ALG_03_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-ALG-03 normalized claim-support retraction proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_alg_03 COMMAND ${P1_ALG_03_COMMAND})
        set_tests_properties(p1_alg_03 PROPERTIES
            LABELS "P1-ALG-03;phase1b;algorithm;claim;support;retraction;sqlite;incubator")
        set(P1_ALG_04_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_store.crexx"
            "-DCPRAG_LIFECYCLE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_lifecycle.crexx"
            "-DCPRAG_CLAIMS=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/claim_store.crexx"
            "-DCPRAG_EVIDENCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/evidence_packet.crexx"
            "-DCPRAG_CODEC=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_codec.crexx"
            "-DCPRAG_VECTOR_SEARCH=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/vector/vector_search.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/p1_alg_04.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-alg-04"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Alg04.cmake")
        add_custom_target(p1_alg_04
            COMMAND ${P1_ALG_04_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-ALG-04 typed evidence-packet proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_alg_04 COMMAND ${P1_ALG_04_COMMAND})
        set_tests_properties(p1_alg_04 PROPERTIES
            LABELS "P1-ALG-04;phase1b;algorithm;evidence;claim;ambiguity;vector;sqlite;incubator")
        set(P1_ALG_05_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_store.crexx"
            "-DCPRAG_LIFECYCLE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/source_lifecycle.crexx"
            "-DCPRAG_CLAIMS=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/claim_store.crexx"
            "-DCPRAG_EVIDENCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/evidence_packet.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/algorithm/p1_alg_05.crexx"
            "-DCPRAG_ORACLE=$<TARGET_FILE:phase0_oracle_semantics>"
            "-DCPRAG_GOLDEN=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/goldens/oracle-semantics.jsonl"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-alg-05"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Alg05.cmake")
        add_custom_target(p1_alg_05
            COMMAND ${P1_ALG_05_COMMAND}
            DEPENDS _sqlite_boundary phase0_oracle_semantics
            COMMENT "Running P1-ALG-05 native-oracle parity and profile proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_alg_05 COMMAND ${P1_ALG_05_COMMAND})
        set_tests_properties(p1_alg_05 PROPERTIES
            LABELS "P1-ALG-05;phase1b;algorithm;parity;oracle;benchmark;sqlite;incubator")
        set(P1_JOB_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/job_queue.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/p1_job_01.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-job-01"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Job01.cmake")
        add_custom_target(p1_job_01
            COMMAND ${P1_JOB_01_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-JOB-01 fenced worker lifecycle proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_job_01 COMMAND ${P1_JOB_01_COMMAND})
        set_tests_properties(p1_job_01 PROPERTIES
            LABELS "P1-JOB-01;phase1b;job;lease;fence;heartbeat;cancellation;sqlite;incubator")
        set(P1_JOB_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/job_queue.crexx"
            "-DCPRAG_FAULTS=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/job_faults.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/p1_job_02.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-job-02"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Job02.cmake")
        add_custom_target(p1_job_02
            COMMAND ${P1_JOB_02_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-JOB-02 forced-termination recovery proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_job_02 COMMAND ${P1_JOB_02_COMMAND})
        set_tests_properties(p1_job_02 PROPERTIES
            LABELS "P1-JOB-02;phase1b;job;crash;recovery;fence;idempotence;sqlite;incubator")
        set(P1_JOB_03_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_QUEUE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/job_queue.crexx"
            "-DCPRAG_BUDGET=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/job_budget.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/job/p1_job_03.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1-job-03"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1Job03.cmake")
        add_custom_target(p1_job_03
            COMMAND ${P1_JOB_03_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P1-JOB-03 budget reservation and settlement proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p1_job_03 COMMAND ${P1_JOB_03_COMMAND})
        set_tests_properties(p1_job_03 PROPERTIES
            LABELS "P1-JOB-03;phase1b;job;budget;reservation;usage;sqlite;incubator")
        add_test(
            NAME p1a_data_boundary
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
                "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/data_boundary/data_boundary.crexx"
                "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/data_boundary/data_boundary_test.crexx"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-data-boundary"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1ADataBoundary.cmake")
        set_tests_properties(p1a_data_boundary PROPERTIES
            LABELS "p1a;data;typed;incubator")
        add_test(
            NAME p1a_provider_boundary
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXLINK=${CREXX_RXLINK_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/provider_boundary/provider_boundary.crexx"
                "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/provider_boundary/provider_boundary_test.crexx"
                "-DCPRAG_LOOPBACK=$<TARGET_FILE:p1a_provider_loopback>"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-provider-boundary"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1AProviderBoundary.cmake")
        set_tests_properties(p1a_provider_boundary PROPERTIES
            LABELS "p1a;provider;gemini;loopback;incubator")
        add_test(
            NAME p1a_algorithm_slice
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
                "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/algorithm_slice/algorithm_slice.crexx"
                "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/algorithm_slice/algorithm_slice_test.crexx"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-algorithm-slice"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1AAlgorithmSlice.cmake")
        set_tests_properties(p1a_algorithm_slice PROPERTIES
            LABELS "p1a;algorithm;source;claim;evidence;sqlite")
        add_test(
            NAME p1a_job_slice
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
                "-DCPRAG_MODULE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/job_slice/job_slice.crexx"
                "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/job_slice/job_slice_scenario.crexx"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-job-slice"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1AJobSlice.cmake")
        set_tests_properties(p1a_job_slice PROPERTIES
            LABELS "p1a;job;fence;crash;recovery;sqlite")
        add_test(
            NAME p1a_surface_boundary
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/surface_boundary/surface_contract.crexx"
                "-DCPRAG_FACADE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/surface_boundary/surface_facade.crexx"
                "-DCPRAG_CLI=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/surface_boundary/surface_cli.crexx"
                "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/incubator/p1a/surface_boundary/surface_boundary_test.crexx"
                "-DCPRAG_OPERATION_CONTRACT=${p1a_surface_operation_contract_OUTPUT}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p1a-surface-boundary"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1ASurfaceBoundary.cmake")
        set_tests_properties(p1a_surface_boundary PROPERTIES
            LABELS "p1a;surface;levelg;cli;address;mcp")
        add_test(
            NAME p1a_gemini_canary_evidence
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_EVIDENCE=${CMAKE_CURRENT_LIST_DIR}/docs/evidence/2026-07-28-phase0-gate1a/raw/p1a-llm-01/gemini-canary.txt"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P1AGeminiCanaryEvidence.cmake")
        set_tests_properties(p1a_gemini_canary_evidence PROPERTIES
            LABELS "p1a;provider;gemini;canary;evidence")
        set(P2_01_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_MODEL=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragmodel.crexx"
            "-DCPRAG_EVIDENCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragevidence.crexx"
            "-DCPRAG_JOB=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragjob.crexx"
            "-DCPRAG_LIBRARY=${CMAKE_CURRENT_LIST_DIR}/crexx/application/raglibrary.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_01_contract_consumer.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-01-application-contract"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P201.cmake")
        add_custom_target(p2_01_application_contract
            COMMAND ${P2_01_COMMAND}
            COMMENT "Running P2-01 Level-G application contract proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_01_application_contract COMMAND ${P2_01_COMMAND})
        set_tests_properties(p2_01_application_contract PROPERTIES
            LABELS "P2-01;phase2;crexx;levelg;application;contract;evidence;job")
        set(P2_02_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_MODEL=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragmodel.crexx"
            "-DCPRAG_CONFIG=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragconfig.crexx"
            "-DCPRAG_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragprofile.crexx"
            "-DCPRAG_REGISTRY=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragregistry.crexx"
            "-DCPRAG_SAMPLE_CONFIG=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config/architecture_local_config.crexx"
            "-DCPRAG_GENERIC_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config/profiles/generic_profile.crexx"
            "-DCPRAG_IT_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config/profiles/it_architecture_profile.crexx"
            "-DCPRAG_OPERATOR_REGISTRY=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config/operator_registry.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_02_config_consumer.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-02-config-contract"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P202.cmake")
        add_custom_target(p2_02_config_contract
            COMMAND ${P2_02_COMMAND}
            COMMENT "Running P2-02 registered Level-G config/profile proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_02_config_contract COMMAND ${P2_02_COMMAND})
        set_tests_properties(p2_02_config_contract PROPERTIES
            LABELS "P2-02;phase2;crexx;levelg;application;config;profile;registry;privacy;zero-write;zero-outbound")
        set(P2_03_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SCHEMA=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragschema.crexx"
            "-DCPRAG_FILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragfile.crexx"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragstore.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_03_store_scenario.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-03-storage-foundation"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P203.cmake")
        add_custom_target(p2_03_storage_foundation
            COMMAND ${P2_03_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-03 Level-G storage foundation proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_03_storage_foundation COMMAND ${P2_03_COMMAND})
        set_tests_properties(p2_03_storage_foundation PROPERTIES
            LABELS "P2-03;phase2;crexx;levelg;application;sqlite;schema;migration;generation;snapshot;manifest;read-only;crash;verify;rollback")
        set(P2_04_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SCHEMA=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragschema.crexx"
            "-DCPRAG_FILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragfile.crexx"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragstore.crexx"
            "-DCPRAG_COMPAT=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragcompat.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_04_v1_compatibility.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-04-v1-compatibility"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P204.cmake")
        add_custom_target(p2_04_v1_compatibility
            COMMAND ${P2_04_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-04 Level-G version-1 compatibility proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_04_v1_compatibility COMMAND ${P2_04_COMMAND})
        set_tests_properties(p2_04_v1_compatibility PROPERTIES
            LABELS "P2-04;phase2;crexx;levelg;application;compatibility;import;dry-run;read-only;zero-write;quarantine;generation")
        set(P2_05_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SCHEMA=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragschema.crexx"
            "-DCPRAG_FILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragfile.crexx"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragstore.crexx"
            "-DCPRAG_BACKUP=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragbackup.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_05_backup_scenario.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-05-backup-restore"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P205.cmake")
        add_custom_target(p2_05_backup_restore
            COMMAND ${P2_05_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-05 cREXX backup, restore, and sidecar proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_05_backup_restore COMMAND ${P2_05_COMMAND})
        set_tests_properties(p2_05_backup_restore PROPERTIES
            LABELS "P2-05;phase2;crexx;levelg;levelb-foundation;application;sqlite;backup;restore;snapshot;generation;sidecar;sha256;read-only;crash;verify;atomic")
        set(P2_06_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SCHEMA=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragschema.crexx"
            "-DCPRAG_FILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragfile.crexx"
            "-DCPRAG_STORE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragstore.crexx"
            "-DCPRAG_REPOSITORY=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragrepository.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_06_repository_scenario.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-06-repositories"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P206.cmake")
        add_custom_target(p2_06_repositories
            COMMAND ${P2_06_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-06 Level-G paged repository proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_06_repositories COMMAND ${P2_06_COMMAND})
        set_tests_properties(p2_06_repositories PROPERTIES
            LABELS "P2-06;phase2;crexx;levelg;application;sqlite;repository;pagination;cursor;snapshot;generation;binary;lifecycle;orphan;verify")
        set(P2_07_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_MODEL=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragmodel.crexx"
            "-DCPRAG_COMMAND=${CMAKE_CURRENT_LIST_DIR}/crexx/application/ragcommand.crexx"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_07_command_contract.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-07-command-contract"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P207.cmake")
        add_custom_target(p2_07_command_contract
            COMMAND ${P2_07_COMMAND}
            COMMENT "Running P2-07 Level-G command and result contract proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_07_command_contract COMMAND ${P2_07_COMMAND})
        set_tests_properties(p2_07_command_contract PROPERTIES
            LABELS "P2-07;phase2;crexx;levelg;application;command;parser;argv;exit-code;human;json;ndjson;schema;bounded;zero-write")
        set(P2_08_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_APP_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_08_foundation_facade.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-08-foundation-facade"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P208.cmake")
        add_custom_target(p2_08_foundation_facade
            COMMAND ${P2_08_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-08 Level-G foundation facade proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_08_foundation_facade COMMAND ${P2_08_COMMAND})
        set_tests_properties(p2_08_foundation_facade PROPERTIES
            LABELS "P2-08;phase2;crexx;levelg;application;facade;doctor;library;backup;restore;migrate;provider;profile;access;zero-write;zero-outbound;secret-free")
        set(P2_09_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_SOURCE_ROOT=${CMAKE_CURRENT_LIST_DIR}"
            "-DCPRAG_REPORT=${CMAKE_CURRENT_LIST_DIR}/docs/crexx-rag-workload-capability-report.md"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-09-donation-bundles"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P209.cmake")
        add_custom_target(p2_09_donation_bundles
            COMMAND ${P2_09_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-09 workload report and review-bundle proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_09_donation_bundles COMMAND ${P2_09_COMMAND})
        set_tests_properties(p2_09_donation_bundles PROPERTIES
            LABELS "P2-09;phase2;crexx;levelg;report;capability;donation;bundle;manifest;package;docs;example;benchmark;reproducer;dual-vm;zero-outbound")
        set(P2_10_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_APP_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application"
            "-DCPRAG_SOURCE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p2_10_plan_revalidation.crexx"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/p2-10-plan-revalidation"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/P210.cmake")
        add_custom_target(p2_10_plan_revalidation
            COMMAND ${P2_10_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running P2-10 Level-G canonical plan/revalidation proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME p2_10_plan_revalidation COMMAND ${P2_10_COMMAND})
        set_tests_properties(p2_10_plan_revalidation PROPERTIES
            LABELS "P2-10;phase2;crexx;levelg;application;facade;plan;canonical;digest;expiry;generation;config;profile;source;provider-route;reservation;access;zero-write;zero-outbound")
        set(PHASE3_INGESTION_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_APP_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application"
            "-DCPRAG_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p3_01_ingest_scenario.crexx"
            "-DCPRAG_DELTA_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p3_02_oracle_delta.crexx"
            "-DCPRAG_RESUME_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p3_03_resume_scenario.crexx"
            "-DCPRAG_TUTORIAL=${CMAKE_CURRENT_LIST_DIR}/crexx/tutorials/phase3_ingestion_scenario.crexx"
            "-DCPRAG_TUTORIAL_FIXTURE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/tutorial/architecture-mini"
            "-DCPRAG_TUTORIAL_EXPECTED=${CMAKE_CURRENT_LIST_DIR}/tests/expected/tutorial-phase3.jsonl"
            "-DCPRAG_PHASE0_FIXTURE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0"
            "-DCPRAG_NATIVE_CLI=$<TARGET_FILE:crexx-rag>"
            "-DCPRAG_ORACLE_CAPTURE=$<TARGET_FILE:phase0_oracle_semantics>"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase3-ingestion"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase3Ingestion.cmake")
        add_custom_target(phase3_ingestion
            COMMAND ${PHASE3_INGESTION_COMMAND}
            DEPENDS _sqlite_boundary crexx-rag phase0_oracle_semantics
            COMMENT "Running Phase-3 Level-G ingestion and executable tutorial proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME phase3_ingestion COMMAND ${PHASE3_INGESTION_COMMAND})
        set_tests_properties(phase3_ingestion PROPERTIES
            TIMEOUT 300
            LABELS "phase3;P3-01;P3-02;P3-03;P3-04;P3-05;P3-06;P3-07;P3-08;P3-09;crexx;levelg;ingest;incremental;generation;sha256;normalization;chunking;fts;candidate;resume;crash;oracle;tutorial;dual-vm;zero-write;zero-outbound")
        set(PHASE4_IMPROVEMENT_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_APP_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application"
            "-DCPRAG_CLAIMS_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p4_01_claims_scenario.crexx"
            "-DCPRAG_WORK_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p4_02_worker_scenario.crexx"
            "-DCPRAG_TUTORIAL=${CMAKE_CURRENT_LIST_DIR}/crexx/tutorials/phase4_improvement_scenario.crexx"
            "-DCPRAG_TUTORIAL_FIXTURE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/tutorial/architecture-mini"
            "-DCPRAG_TUTORIAL_EXPECTED=${CMAKE_CURRENT_LIST_DIR}/tests/expected/tutorial-phase4.jsonl"
            "-DCPRAG_NATIVE_WORK_ORACLE=$<TARGET_FILE:ragcore_work_queue_consumers>"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase4-improvement"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase4Improvement.cmake")
        add_custom_target(phase4_improvement
            COMMAND ${PHASE4_IMPROVEMENT_COMMAND}
            DEPENDS _sqlite_boundary ragcore_work_queue_consumers
            COMMENT "Running Phase-4 Level-G claim, review, improvement, and worker proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME phase4_improvement COMMAND ${PHASE4_IMPROVEMENT_COMMAND})
        set_tests_properties(phase4_improvement PROPERTIES
            TIMEOUT 600
            LABELS "phase4;P4-01;P4-02;P4-03;P4-04;P4-05;P4-06;P4-07;P4-08;P4-09;crexx;levelg;claim;support;review;improve;worker;lease;fence;retry;dead-letter;budget;cancellation;two-process;crash;oracle;tutorial;dual-vm;provider-neutral;secret-reference")
        if(TARGET crexx-rag-mcp)
            set(PHASE5_RETRIEVAL_COMMAND
                "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
                "-DCPRAG_APP_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application"
                "-DCPRAG_PROVIDER_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
                "-DCPRAG_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config/profiles/it_architecture_profile.crexx"
                "-DCPRAG_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p5_01_retrieval_scenario.crexx"
                "-DCPRAG_TUTORIAL=${CMAKE_CURRENT_LIST_DIR}/crexx/tutorials/phase5_retrieval_scenario.crexx"
                "-DCPRAG_TUTORIAL_FIXTURE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/tutorial/architecture-mini"
                "-DCPRAG_TUTORIAL_EXPECTED=${CMAKE_CURRENT_LIST_DIR}/tests/expected/tutorial-phase5.jsonl"
                "-DCPRAG_IT_V1=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0/it-auth-decision-v1.md"
                "-DCPRAG_IT_V2=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0/it-auth-decision-v2.md"
                "-DCPRAG_IT_HELD_OUT=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0/it-held-out.md"
                "-DCPRAG_IT_OPERATIONS=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0/it-operations-note.md"
                "-DCPRAG_SCOTLAND_CHRONICLE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0/scotland-shaped-chronicle.md"
                "-DCPRAG_SCOTLAND_LEDGER=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/phase0/scotland-shaped-ledger.md"
                "-DCPRAG_NATIVE_CLI=$<TARGET_FILE:crexx-rag>"
                "-DCPRAG_NATIVE_MCP=$<TARGET_FILE:crexx-rag-mcp>"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase5-retrieval"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase5Retrieval.cmake")
            add_custom_target(phase5_retrieval
                COMMAND ${PHASE5_RETRIEVAL_COMMAND}
                DEPENDS _sqlite_boundary crexx-rag crexx-rag-mcp
                COMMENT "Running Phase-5 Level-G hybrid retrieval and executable tutorial proof"
                USES_TERMINAL
                VERBATIM)
            add_test(NAME phase5_retrieval COMMAND ${PHASE5_RETRIEVAL_COMMAND})
            set_tests_properties(phase5_retrieval PROPERTIES
                TIMEOUT 900
                LABELS "phase5;P5-01;P5-01A;P5-02;P5-03;P5-04;P5-05;P5-06;P5-07;P5-08;crexx;levelg;query-plan;fts5;rxvector;embedding;hybrid;rrf;graph;evidence;citation;provenance;stance;time;gap;judgement;baseline;tutorial;dual-vm;zero-outbound")
        endif()
        set(PHASE6_SURFACES_COMMAND
            "${CMAKE_COMMAND}"
            "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
            "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
            "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
            "-DCPRAG_RXBVM=${CREXX_RXBVM_EXECUTABLE}"
            "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
            "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_sqlite_boundary>"
            "-DCPRAG_APP_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application"
            "-DCPRAG_CONFIG_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config"
            "-DCPRAG_PROFILE_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application/config/profiles"
            "-DCPRAG_SURFACE_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx/application/surfaces"
            "-DCPRAG_CLI=${CMAKE_CURRENT_LIST_DIR}/crexx/application/surfaces/crexx_rag_cli.crexx"
            "-DCPRAG_ADDRESS=${CMAKE_CURRENT_LIST_DIR}/crexx/application/surfaces/rag_address_environment.crexx"
            "-DCPRAG_MCP=${CMAKE_CURRENT_LIST_DIR}/crexx/application/surfaces/ragmcp.crexx"
            "-DCPRAG_PROVIDER_CONTRACT=${CMAKE_CURRENT_LIST_DIR}/incubator/phase1b/provider/provider_contract.crexx"
            "-DCPRAG_ADDRESS_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p6_02_address_scenario.crexx"
            "-DCPRAG_MCP_SCENARIO=${CMAKE_CURRENT_LIST_DIR}/crexx/application/tests/p6_03_mcp_scenario.crexx"
            "-DCPRAG_TUTORIAL_FIXTURE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/tutorial/architecture-mini"
            "-DCPRAG_SKILLS_DIR=${CMAKE_CURRENT_LIST_DIR}/skills"
            "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/phase6-surfaces"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/Phase6Surfaces.cmake")
        add_custom_target(phase6_surfaces
            COMMAND ${PHASE6_SURFACES_COMMAND}
            DEPENDS _sqlite_boundary
            COMMENT "Running Phase-6 Level-G CLI, ADDRESS RAG, MCP, and skill proof"
            USES_TERMINAL
            VERBATIM)
        add_test(NAME phase6_surfaces COMMAND ${PHASE6_SURFACES_COMMAND})
        set_tests_properties(phase6_surfaces PROPERTIES
            TIMEOUT 900
            LABELS "phase6;P6-01;P6-02;P6-03;P6-04;P6-05;P6-06;P6-07;crexx;levelg;cli;address;mcp;structured-content;capability;plan;apply;skills;tutorial;deprecation;backup;restore;dual-vm;zero-write")
        add_test(
            NAME crexx_profile_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/profiles/balanced.crexx"
                "-DCPRAG_CREXX_SOURCE_DIR=${CMAKE_CURRENT_LIST_DIR}/crexx"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_rag>"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/crexx-profile-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CrexxProfileSmoke.cmake")
        set_tests_properties(crexx_profile_smoke PROPERTIES LABELS "crexx;profile;smoke")
        add_test(
            NAME crexx_deterministic_extractor_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/profiles/history/deterministic_extract.crexx"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_rag>"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/crexx-deterministic-extractor-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CrexxDeterministicExtractorSmoke.cmake")
        set_tests_properties(crexx_deterministic_extractor_smoke PROPERTIES LABELS "crexx;extractor;profile")
        add_test(
            NAME crexx_hybrid_extractor_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RXC=${CREXX_RXC_EXECUTABLE}"
                "-DCPRAG_RXAS=${CREXX_RXAS_EXECUTABLE}"
                "-DCPRAG_RXVME=${CREXX_RXVME_EXECUTABLE}"
                "-DCPRAG_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/profiles/history/hybrid_ingest_extract.crexx"
                "-DCPRAG_PROFILE_MODULE=${CMAKE_CURRENT_LIST_DIR}/crexx/profiles/pipeline_profile.crexx"
                "-DCPRAG_STAGE1B_PROFILE=${CMAKE_CURRENT_LIST_DIR}/crexx/profiles/history/stage1b_adjudicate_candidates.crexx"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_rag>"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/crexx-hybrid-extractor-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CrexxHybridExtractorSmoke.cmake")
        set_tests_properties(crexx_hybrid_extractor_smoke PROPERTIES LABELS "crexx;extractor;profile")
        add_test(
            NAME crexx_generic_pipeline_smoke
            COMMAND "${CMAKE_COMMAND}"
                "-DCPRAG_RUNNER=${CMAKE_CURRENT_LIST_DIR}/scripts/run_history_pipeline.sh"
                "-DCPRAG_IMPROVER=${CMAKE_CURRENT_LIST_DIR}/scripts/run_background_improvement.sh"
                "-DCPRAG_CLI=$<TARGET_FILE:crexx-rag>"
                "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_rag>"
                "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/crexx-generic-pipeline-smoke"
                -P "${CMAKE_CURRENT_LIST_DIR}/cmake/CrexxGenericPipelineSmoke.cmake")
        set_tests_properties(crexx_generic_pipeline_smoke PROPERTIES LABELS "crexx;pipeline;generic")
        if(CPRAG_BUILD_MCP AND TARGET crexx-rag-mcp)
            add_test(
                NAME use_case_wrapper_smoke
                COMMAND "${CMAKE_COMMAND}"
                    "-DCPRAG_USE_CASE=${CMAKE_CURRENT_LIST_DIR}/scripts/run_use_case.sh"
                    "-DCPRAG_CLI=$<TARGET_FILE:crexx-rag>"
                    "-DCPRAG_MCP=$<TARGET_FILE:crexx-rag-mcp>"
                    "-DCPRAG_PLUGIN_DIR=$<TARGET_FILE_DIR:_rag>"
                    "-DCPRAG_CREXX_BIN_DIR=${CREXX_INSTALL_BIN_DIR}"
                    "-DCPRAG_WORK_DIR=${CMAKE_BINARY_DIR}/use-case-wrapper-smoke"
                    "-DCPRAG_SOURCE_FILE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/generic-it.txt"
                    "-DCPRAG_INCREMENTAL_SOURCE_FILE=${CMAKE_CURRENT_LIST_DIR}/tests/fixtures/generic-it-incremental.txt"
                    -P "${CMAKE_CURRENT_LIST_DIR}/cmake/UseCaseWrapperSmoke.cmake")
            set_tests_properties(use_case_wrapper_smoke PROPERTIES
                LABELS "crexx;pipeline;generic;mcp;queue;fixup;use-case")
        endif()
    elseif(CPRAG_BUILD_CREXX_PLUGIN)
        message(STATUS "Skipping CREXX profile smoke test; installed rxc/rxas/rxvme was not found.")
    endif()
endif()
