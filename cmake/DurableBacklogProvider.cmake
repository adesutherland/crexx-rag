foreach(required_var CPRAG_NATIVE_APPLICATION CPRAG_LOOPBACK CPRAG_CONFIG_TEMPLATE CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()
find_program(CPRAG_SQLITE sqlite3 REQUIRED)
if(NOT DEFINED CPRAG_CONCURRENT_ITEMS)
    set(CPRAG_CONCURRENT_ITEMS 40)
endif()
math(EXPR concurrent_remainder "${CPRAG_CONCURRENT_ITEMS} % 2")
if(CPRAG_CONCURRENT_ITEMS LESS 2 OR CPRAG_CONCURRENT_ITEMS GREATER 10000 OR NOT concurrent_remainder EQUAL 0)
    message(FATAL_ERROR "CPRAG_CONCURRENT_ITEMS must be even and between 2 and 10000")
endif()
math(EXPR concurrent_extra "${CPRAG_CONCURRENT_ITEMS} - 1")
math(EXPR concurrent_pairs "${CPRAG_CONCURRENT_ITEMS} / 2")
if(NOT DEFINED CPRAG_CASES)
    set(CPRAG_CASES valid receipt-recovery advanced malformed rejected manual concurrent budget continuation item-limit correction correction-failed correction-budget correction-advanced)
endif()
if(NOT DEFINED CPRAG_COMMAND_TIMEOUT)
    set(CPRAG_COMMAND_TIMEOUT 60)
endif()
file(REMOVE_RECURSE "${CPRAG_WORK_DIR}")
file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")

function(run_cli output)
    set(selection_args)
    if(case STREQUAL "large-target")
        set(selection_args --config gemini-loopback --profile it-architecture-profile)
    endif()
    execute_process(COMMAND "${CMAKE_COMMAND}" -E env
        "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
        "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}" "${CPRAG_NATIVE_APPLICATION}" ${selection_args} ${ARGN}
        WORKING_DIRECTORY "${work}" RESULT_VARIABLE status OUTPUT_VARIABLE result ERROR_VARIABLE detail TIMEOUT ${CPRAG_COMMAND_TIMEOUT})
    file(APPEND "${work}/commands.log" "${ARGN}\n${result}${detail}\n")
    if(NOT status EQUAL 0)
        message(FATAL_ERROR "durable maintenance command failed: ${ARGN}\n${result}${detail}")
    endif()
    set(${output} "${result}" PARENT_SCOPE)
endfunction()

foreach(case IN LISTS CPRAG_CASES)
    set(work "${CPRAG_WORK_DIR}/${case}")
    file(MAKE_DIRECTORY "${work}/source")
    file(WRITE "${work}/source/architecture.txt" "BillingService depends on CustomerDatabase.\nAgain, BillingService depends on CustomerDatabase.\n")
    set(CPRAG_FIXTURE_SOURCE "${work}/source")
    set(CPRAG_FIXTURE_GLOSSARY "${work}/glossary.tsv")
    file(WRITE "${CPRAG_FIXTURE_GLOSSARY}" "format\tcrexx-rag.glossary/1\nconcept\tBillingService\tapplication-component\tBilling Service\nconcept\tCustomerDatabase\tdata-store\tCustomer DB\n")
    set(request_count 3)
    if(CPRAG_CONFIGURED_ROUTE)
        set(request_count 2)
    endif()
    set(maintenance_calls 1)
    set(maintenance_mode automatic)
    set(maintenance_workers 1)
    set(fixture_scenario "product-backlog-${case}")
    if(case STREQUAL "large-acquisition")
        set(request_count 4)
        set(maintenance_calls 2)
    elseif(case STREQUAL "large-target")
        set(request_count 20)
        set(CPRAG_COMMAND_TIMEOUT 120)
    endif()
    if(case STREQUAL "upgrade")
        set(request_count 8)
    endif()
    set(CPRAG_FIXTURE_PORT 19013)
    if(case STREQUAL "malformed")
        set(CPRAG_FIXTURE_PORT 19014)
    elseif(case STREQUAL "rejected")
        set(CPRAG_FIXTURE_PORT 19015)
    elseif(case STREQUAL "manual")
        set(CPRAG_FIXTURE_PORT 19016)
        set(request_count 2)
        set(maintenance_calls 0)
        set(maintenance_mode manual)
    elseif(case STREQUAL "concurrent")
        set(CPRAG_FIXTURE_PORT 19017)
        if(DEFINED CPRAG_CONCURRENT_PORT)
            set(CPRAG_FIXTURE_PORT ${CPRAG_CONCURRENT_PORT})
        endif()
        math(EXPR request_count "${CPRAG_CONCURRENT_ITEMS} + 2")
        set(maintenance_calls ${CPRAG_CONCURRENT_ITEMS})
        set(maintenance_workers 2)
        set(fixture_scenario product-concurrent)
    elseif(case STREQUAL "budget" OR case STREQUAL "continuation" OR case STREQUAL "item-limit")
        set(CPRAG_FIXTURE_PORT 19018)
        set(request_count 6)
        set(maintenance_calls 4)
        set(maintenance_workers 2)
        set(fixture_scenario product-concurrent)
    endif()
    if(case MATCHES "^correction")
        set(CPRAG_FIXTURE_PORT 19019)
        if(NOT case STREQUAL "correction-budget")
            set(request_count 4)
            set(maintenance_calls 2)
        endif()
        if(case STREQUAL "correction-limit")
            set(request_count 3)
            set(maintenance_calls 1)
        endif()
    endif()
    set(CPRAG_FIXTURE_PORT 0)
    execute_process(COMMAND /bin/sh -c
        "( \"$1\" \"$2\" \"$7\" \"$3\"; printf '%s' $? >\"$6\" ) >\"$4\" 2>\"$5\" &"
        backlog-test "${CPRAG_LOOPBACK}" "${CPRAG_FIXTURE_PORT}" "${fixture_scenario}"
        "${work}/server.out" "${work}/server.err" "${work}/server.status" "${request_count}"
        COMMAND_ERROR_IS_FATAL ANY)
    set(ready FALSE)
    foreach(poll RANGE 1 200)
        if(EXISTS "${work}/server.out")
            file(READ "${work}/server.out" server)
            if(server MATCHES "READY ([0-9]+)")
                set(CPRAG_FIXTURE_PORT "${CMAKE_MATCH_1}")
                set(ready TRUE)
                break()
            endif()
        endif()
        execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
    endforeach()
    if(NOT ready)
        message(FATAL_ERROR "durable backlog loopback did not become ready")
    endif()
    if(case STREQUAL "large-target")
        # The typed configuration exposes the per-call input control needed
        # to carry multiple bounded pages and a correction in one request.
        if(NOT DEFINED CPRAG_TYPED_CONFIG_TEMPLATE OR NOT EXISTS "${CPRAG_TYPED_CONFIG_TEMPLATE}")
            message(FATAL_ERROR "large-target requires a captured typed configuration template")
        endif()
        file(READ "${CPRAG_TYPED_CONFIG_TEMPLATE}" typed_config)
        string(REPLACE "config.id = google-gemini" "config.id = gemini-loopback" typed_config "${typed_config}")
        string(REPLACE "source.architecture-docs.root = ./source-docs" "source.architecture-docs.root = ${CPRAG_FIXTURE_SOURCE}" typed_config "${typed_config}")
        string(REPLACE "https://generativelanguage.googleapis.com/v1beta" "http://127.0.0.1:${CPRAG_FIXTURE_PORT}/gemini/v1beta" typed_config "${typed_config}")
        string(REPLACE "route_class = hosted" "route_class = local" typed_config "${typed_config}")
        string(REPLACE "env:GEMINI_API_KEY" "env:CPRAG_FIXTURE_GEMINI_KEY" typed_config "${typed_config}")
        string(REPLACE "role.extractor.max_input_tokens = 8192" "role.extractor.max_input_tokens = 32768" typed_config "${typed_config}")
        string(REPLACE "worker.processes = 1" "worker.processes = 2" typed_config "${typed_config}")
        file(WRITE "${work}/crexxrag.conf" "${typed_config}")
    else()
        configure_file("${CPRAG_CONFIG_TEMPLATE}" "${work}/crexxrag.conf" @ONLY)
    endif()
    run_cli(init init)
    run_cli(ingest ingest --yes --workers 1)
    set(database "${work}/library/library.sqlite")
    execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
        "SELECT (SELECT count(*) FROM provider_runs WHERE outcome='failed')+(SELECT count(*) FROM job_items WHERE state NOT IN('processed','skipped'));"
        OUTPUT_VARIABLE ingestion_failures OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    if(NOT ingestion_failures STREQUAL "0")
        message(FATAL_ERROR "backlog fixture ingestion failed before maintenance")
    endif()
    set(note_text "Resolve the dependency question")
    set(note_action "Investigate")
    if(case STREQUAL "large-acquisition")
        set(note_text "Review source")
        set(note_action "")
    endif()
    if(NOT case STREQUAL "large-target")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "INSERT INTO analysis_notes(note_id,note_kind,text,importance,uncertainty,next_action,state,grounding_json,author,created_generation,created_at,updated_at) SELECT 'fixture-note','lead','${note_text}',900000,100000,'${note_action}','active','{}','fixture',published_generation,'fixture','fixture' FROM library_meta; INSERT INTO analysis_note_links(link_id,note_id,object_type,object_id,revision_chunk_id,span_start,span_end) SELECT 'fixture-note-link','fixture-note','chunk',revision_chunk_id,revision_chunk_id,0,43 FROM revision_chunks WHERE visible_to_generation IS NULL LIMIT 1;"
            COMMAND_ERROR_IS_FATAL ANY)
    endif()
    if(case STREQUAL "large-target")
        string(REPEAT "e" 64 late_source_suffix)
        string(REPEAT "f" 64 late_revision_suffix)
        string(REPEAT "a" 64 early_source_suffix)
        string(REPEAT "b" 64 early_revision_suffix)
        set(late_source_id "source-sha256:${late_source_suffix}")
        set(late_revision_id "revision-sha256:${late_revision_suffix}")
        set(early_source_id "source-sha256:${early_source_suffix}")
        set(early_revision_id "revision-sha256:${early_revision_suffix}")
        # The decisive source and target sit beyond independently bounded
        # passage and catalogue prefixes. These rows are synthetic only.
        set(late_seed_sql "
INSERT INTO source_artifacts(artifact_id,raw_digest,mime_type,encoding,bytes,external_reference,created_at) VALUES('late-artifact','late-raw','text/plain','utf-8',NULL,'fixture://late','fixture');
INSERT INTO source_revision_texts(text_id,text_digest,normalized_utf8,extractor_version,normalization_version,created_at) VALUES('late-text','late-digest','PlatformService depends on AzureStore.','fixture','utf8-v1','fixture');
INSERT INTO sources(source_id,connector_type,stable_key,current_revision_id,lifecycle_state,observed_uri,observed_title,visible_from_generation) SELECT '${late_source_id}','fixture','late','${late_revision_id}','active','fixture://late','Late dependency source',published_generation FROM library_meta;
INSERT INTO source_revisions(revision_id,source_id,revision_envelope_digest,artifact_id,text_id,metadata_fingerprint,captured_at,visible_from_generation) SELECT '${late_revision_id}','${late_source_id}','late-envelope','late-artifact','late-text','late-meta','fixture',published_generation FROM library_meta;
INSERT INTO chunk_contents(content_id,content_digest,text,input_fingerprint) VALUES('late-content','late-content-digest','PlatformService depends on AzureStore.','late-input');
INSERT INTO revision_chunks(revision_chunk_id,revision_id,ordinal,normalized_start,normalized_end,content_id,continuity_key,parser_version,evidence_class,visible_from_generation) SELECT 'late-chunk','${late_revision_id}',1,0,38,'late-content','late-continuity','fixture','direct',published_generation FROM library_meta;
INSERT INTO chunks_fts(revision_chunk_id,content_id,body) VALUES('late-chunk','late-content','PlatformService depends on AzureStore.');
INSERT INTO source_artifacts(artifact_id,raw_digest,mime_type,encoding,bytes,external_reference,created_at) VALUES('early-artifact','early-raw','text/plain','utf-8',NULL,'fixture://early','fixture');
INSERT INTO source_revision_texts(text_id,text_digest,normalized_utf8,extractor_version,normalization_version,created_at) VALUES('early-text','early-digest','PlatformService is catalogued.','fixture','utf8-v1','fixture');
INSERT INTO sources(source_id,connector_type,stable_key,current_revision_id,lifecycle_state,observed_uri,observed_title,visible_from_generation) SELECT '${early_source_id}','fixture','early','${early_revision_id}','active','fixture://early','Earlier catalogue source',published_generation FROM library_meta;
INSERT INTO source_revisions(revision_id,source_id,revision_envelope_digest,artifact_id,text_id,metadata_fingerprint,captured_at,visible_from_generation) SELECT '${early_revision_id}','${early_source_id}','early-envelope','early-artifact','early-text','early-meta','fixture',published_generation FROM library_meta;
INSERT INTO chunk_contents(content_id,content_digest,text,input_fingerprint) VALUES('early-content','early-content-digest','PlatformService is catalogued.','early-input');
INSERT INTO revision_chunks(revision_chunk_id,revision_id,ordinal,normalized_start,normalized_end,content_id,continuity_key,parser_version,evidence_class,visible_from_generation) SELECT 'early-chunk','${early_revision_id}',1,0,30,'early-content','early-continuity','fixture','direct',published_generation FROM library_meta;
INSERT INTO chunks_fts(revision_chunk_id,content_id,body) VALUES('early-chunk','early-content','PlatformService is catalogued.');
INSERT INTO concepts(concept_id,canonical_label,concept_type,lifecycle_state,visible_from_generation) SELECT 'zz-subject','PlatformService','application-component','active',published_generation FROM library_meta UNION ALL SELECT 'zz-target','AzureStore','data-store','active',published_generation FROM library_meta;
INSERT INTO mentions(mention_id,concept_id,revision_chunk_id,span_start,span_end,visible_from_generation) SELECT 'zz-late-subject','zz-subject','late-chunk',0,15,published_generation FROM library_meta UNION ALL SELECT 'zz-late-target','zz-target','late-chunk',27,37,published_generation FROM library_meta;
WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM n WHERE i<105) INSERT INTO concepts(concept_id,canonical_label,concept_type,lifecycle_state,visible_from_generation) SELECT 'concept:'||printf('%064x',i),'Platform catalogue candidate with longer metadata','concept','active',published_generation FROM n,library_meta;
INSERT INTO mentions(mention_id,concept_id,revision_chunk_id,span_start,span_end,visible_from_generation) SELECT 'fixture-large-'||c.concept_id,c.concept_id,r.revision_chunk_id,0,14,c.visible_from_generation FROM concepts c JOIN revision_chunks r ON r.visible_to_generation IS NULL AND r.revision_chunk_id='late-chunk' WHERE c.concept_id LIKE 'concept:%' LIMIT 105;
WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM n WHERE i<12) INSERT INTO mentions(mention_id,concept_id,revision_chunk_id,span_start,span_end,visible_from_generation) SELECT 'm-subject-'||printf('%03d',i),'zz-subject','early-chunk',0,15,published_generation FROM n,library_meta;
WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM n WHERE i<500) INSERT INTO mentions(mention_id,concept_id,revision_chunk_id,span_start,span_end,visible_from_generation) SELECT 'zzzz-byte-mention-'||i,'zz-subject','early-chunk',0,15,published_generation FROM n,library_meta;")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}" "${late_seed_sql}"
            COMMAND_ERROR_IS_FATAL ANY)
    endif()
    if(case STREQUAL "large-acquisition")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM n WHERE i<105) INSERT INTO concepts(concept_id,canonical_label,concept_type,lifecycle_state,visible_from_generation) SELECT 'concept:'||printf('%064x',i),'Platform catalogue candidate with longer metadata','concept','active',published_generation FROM n,library_meta; INSERT INTO mentions(mention_id,concept_id,revision_chunk_id,span_start,span_end,visible_from_generation) SELECT 'fixture-large-'||c.concept_id,c.concept_id,r.revision_chunk_id,0,14,c.visible_from_generation FROM concepts c JOIN revision_chunks r ON r.visible_to_generation IS NULL WHERE c.concept_id LIKE 'concept:%';"
            COMMAND_ERROR_IS_FATAL ANY)
    endif()
    if(case STREQUAL "concurrent" OR case STREQUAL "budget" OR case STREQUAL "continuation" OR case STREQUAL "item-limit")
        set(note_extra ${concurrent_extra})
        if(case STREQUAL "budget" OR case STREQUAL "continuation" OR case STREQUAL "item-limit")
            set(note_extra 3)
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "WITH RECURSIVE n(x) AS(SELECT 1 UNION ALL SELECT x+1 FROM n WHERE x<${note_extra}) INSERT INTO analysis_notes(note_id,note_kind,text,importance,uncertainty,next_action,state,grounding_json,author,created_generation,created_at,updated_at) SELECT 'fixture-note-'||x,'lead','Resolve dependency question '||x,900000,100000,'Investigate','active','{}','fixture',published_generation,'fixture','fixture' FROM n,library_meta; INSERT INTO analysis_note_links(link_id,note_id,object_type,object_id,revision_chunk_id,span_start,span_end) SELECT 'fixture-note-link-'||n.note_id,n.note_id,'chunk',r.revision_chunk_id,r.revision_chunk_id,0,43 FROM analysis_notes n,revision_chunks r WHERE n.note_id LIKE 'fixture-note-%' AND r.visible_to_generation IS NULL;"
            COMMAND_ERROR_IS_FATAL ANY)
    endif()
    execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
        "SELECT (SELECT count(*) FROM revision_chunks)||':'||(SELECT group_concat(hex(vector)) FROM embeddings)||':'||(SELECT count(*) FROM revision_chunk_embeddings)||':'||(SELECT count(*) FROM provider_runs);"
        OUTPUT_VARIABLE before OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    file(READ "${work}/crexxrag.conf" config)
    if(case STREQUAL "large-target")
        string(REPLACE "budget.minutes = 30" "budget.minutes = 2" config "${config}")
        string(REPLACE "budget.item_limit = 100" "budget.item_limit = 2" config "${config}")
        string(REPLACE "budget.model_calls = 50" "budget.model_calls = 2" config "${config}")
        string(REPLACE "budget.input_tokens = 100000" "budget.input_tokens = 8192" config "${config}")
        string(REPLACE "budget.output_tokens = 50000" "budget.output_tokens = 1024" config "${config}")
        string(REPLACE "maintenance.batch_items = 1000\n" "" config "${config}")
    endif()
    if(CPRAG_CONFIGURED_ROUTE)
        # Hosted planning makes no provider call. The existing public/local
        # case separately exercises execution against synthetic loopback.
        string(REPLACE "source.architecture-docs.privacy = public"
            "source.architecture-docs.privacy = local" config "${config}")
        string(REPLACE "route_class = local" "route_class = hosted" config "${config}")
        string(REPLACE "http://127.0.0.1:" "https://127.0.0.1:" config "${config}")
    endif()
    set(window_items 1)
    if(case STREQUAL "large-target")
        set(window_items 10)
    endif()
    if(case STREQUAL "upgrade")
        set(window_items 2)
    endif()
    set(batch_items 1)
    if(case STREQUAL "concurrent" OR case STREQUAL "budget" OR case STREQUAL "continuation" OR case STREQUAL "item-limit")
        set(window_items ${CPRAG_CONCURRENT_ITEMS})
        set(batch_items 10)
        if(case STREQUAL "budget" OR case STREQUAL "continuation" OR case STREQUAL "item-limit")
            set(window_items 4)
            set(batch_items 4)
        endif()
        math(EXPR input_ceiling "8192 * ${window_items}")
        math(EXPR output_ceiling "1024 * ${window_items}")
        if(case STREQUAL "continuation" OR case STREQUAL "item-limit")
            set(output_ceiling 16384)
        endif()
        string(REPLACE "budget.input_tokens = 8192" "budget.input_tokens = ${input_ceiling}" config "${config}")
        string(REPLACE "budget.output_tokens = 1024" "budget.output_tokens = ${output_ceiling}" config "${config}")
        string(APPEND config "\nprovider.gemini-generate.concurrent_requests = 2\n")
        if(CPRAG_CONCURRENT_ITEMS GREATER 40)
            # Explicit offline scale lane: no hosted credential or route.
            string(REPLACE "budget.minutes = 2" "budget.minutes = 60" config "${config}")
            string(APPEND config "\nprovider.gemini-generate.requests_per_minute = 60000\nprovider.gemini-generate.tokens_per_minute = 2000000000\n")
        endif()
    endif()
    set(window_calls ${window_items})
    if(case STREQUAL "large-acquisition")
        set(window_calls 2)
    elseif(case STREQUAL "large-target")
        set(window_calls 16)
        string(REPLACE "budget.minutes = 2" "budget.minutes = 10" config "${config}")
        string(REPLACE "budget.output_tokens = 1024" "budget.output_tokens = 32768" config "${config}")
    endif()
    if(case STREQUAL "upgrade")
        set(window_calls 2)
    endif()
    if(case STREQUAL "budget")
        set(window_calls 2)
    endif()
    if(case STREQUAL "correction" OR case STREQUAL "correction-limit" OR case STREQUAL "correction-failed" OR case STREQUAL "correction-advanced")
        set(window_calls 2)
        string(REPLACE "budget.input_tokens = 8192" "budget.input_tokens = 16384" config "${config}")
        string(REPLACE "budget.output_tokens = 1024" "budget.output_tokens = 2048" config "${config}")
    endif()
    # The current strict resolution request exceeds half of the old aggregate
    # 8192-token allowance when the two-worker fixture reserves both slots.
    string(REPLACE "budget.input_tokens = 8192" "budget.input_tokens = 16384" config "${config}")
    if(case STREQUAL "large-target")
        string(REPLACE "budget.input_tokens = 16384" "budget.input_tokens = 200000" config "${config}")
    endif()
    if(case STREQUAL "large-acquisition")
        string(REPLACE "budget.input_tokens = 16384" "budget.input_tokens = 20000" config "${config}")
    endif()
    string(REPLACE "budget.model_calls = 2" "budget.model_calls = ${window_calls}" config "${config}")
    string(REPLACE "budget.item_limit = 2" "budget.item_limit = ${window_items}" config "${config}")
    string(APPEND config "\nmaintenance.mode = ${maintenance_mode}\nmaintenance.batch_items = ${batch_items}\nmaintenance.maximum_attempts = 1\nmaintenance.resolution_prompt = fixture-resolution-prompt\n")
    if(case STREQUAL "large-acquisition")
        string(REPLACE "maintenance.maximum_attempts = 1" "maintenance.maximum_attempts = 2" config "${config}")
        string(REPLACE "maintenance.resolution_prompt = fixture-resolution-prompt" "maintenance.resolution_prompt = Inspect." config "${config}")
        string(APPEND config "maintenance.search_reads = 1\n")
    elseif(case STREQUAL "large-target")
        string(REPLACE "maintenance.maximum_attempts = 1" "maintenance.maximum_attempts = 10" config "${config}")
        string(APPEND config "maintenance.search_reads = 12\n")
    endif()
    if(case STREQUAL "upgrade")
        string(REPLACE "maintenance.maximum_attempts = 1" "maintenance.maximum_attempts = 3" config "${config}")
        string(REPLACE "budget.input_tokens = 8192" "budget.input_tokens = 32768" config "${config}")
        string(APPEND config "maintenance.retry_seconds = 1\nrole.advanced-resolver.max_input_tokens = 8192\n")
    endif()
    if(case STREQUAL "receipt-recovery")
        string(REPLACE "max_attempts = 1" "max_attempts = 3" config "${config}")
        string(REPLACE "maintenance.maximum_attempts = 1" "maintenance.maximum_attempts = 3" config "${config}")
        string(APPEND config "\nworker.max_restarts = 0\n")
    endif()
    if(case STREQUAL "advanced" OR case STREQUAL "correction-advanced" OR case STREQUAL "upgrade")
        string(APPEND config "\nrole.advanced-resolver = gemini-generate\n")
    endif()
    if(case STREQUAL "correction" OR case STREQUAL "correction-limit" OR case STREQUAL "correction-advanced")
        string(REPLACE "maintenance.maximum_attempts = 1" "maintenance.maximum_attempts = 2" config "${config}")
        string(APPEND config "\nmaintenance.advanced_attempts = 2\n")
    endif()
    if(case STREQUAL "correction-limit")
        string(REPLACE "budget.input_tokens = 16384" "budget.input_tokens = 14000" config "${config}")
    endif()
    file(WRITE "${work}/crexxrag.conf" "${config}")
    run_cli(config_plan --format json --access plan config plan --reason "bounded durable backlog fixture")
    string(JSON configuration_plan GET "${config_plan}" records 0 fields canonical_plan)
    string(JSON configuration_digest GET "${config_plan}" records 0 fields digest)
    run_cli(config_apply --access admin config apply --plan-json "${configuration_plan}" --expect-digest "${configuration_digest}")
    if(case STREQUAL "large-target")
        run_cli(phase_plan --format json --access plan maintain plan --phase graph --cohort-after zz-0 --cohort-limit 1)
        string(JSON phase_canonical GET "${phase_plan}" records 0 fields canonical_plan)
        string(JSON phase_digest GET "${phase_plan}" records 0 fields digest)
        string(JSON phase_policy GET "${phase_canonical}" action window_policy)
        string(JSON selected_subject GET "${phase_policy}" phase_cohort 0)
        if(NOT selected_subject STREQUAL "zz-subject")
            message(FATAL_ERROR "large-target phase did not isolate the synthetic subject: ${selected_subject}")
        endif()
        run_cli(phase_apply --format json --access curate maintain apply --plan-json "${phase_canonical}" --expect-digest "${phase_digest}")
        string(JSON phase_job GET "${phase_apply}" records 0 fields job_id)
        run_cli(maintain --format json --access control worker start --job "${phase_job}" --count 1 --poll-ms 20 --max-polls 0)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM maintenance_tasks WHERE kind='sparse-node' AND subject_id='zz-subject')||':'||(SELECT count(*) FROM maintenance_decisions WHERE disposition='propose-relationship:review')||':'||(SELECT count(*) FROM reviews WHERE state='pending' AND subject_id IN(SELECT task_id FROM maintenance_tasks WHERE subject_id='zz-subject'))||':'||(SELECT count(*) FROM claims WHERE source_concept_id='zz-subject' AND target_concept_id='zz-target')||':'||(SELECT count(*) FROM job_events WHERE event_type='citation-correction-requested')||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.body_bytes')=length(CAST(json_extract(message,'$.body') AS BLOB)) AND json_extract(message,'$.body_bytes')<=98304)||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-request')||':'||(SELECT coalesce(sum(reserved_calls+reserved_tokens+reserved_cost),-1) FROM jobs);"
            OUTPUT_VARIABLE result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        file(READ "${work}/server.out" server)
        file(READ "${work}/server.status" server_status)
        string(REPLACE ":" ";" result_fields "${result}")
        list(GET result_fields 5 measured_requests)
        list(GET result_fields 6 retained_requests)
        if(NOT result MATCHES "^1:1:1:0:1:[0-9]+:[0-9]+:0$" OR
           NOT measured_requests EQUAL retained_requests OR NOT server_status STREQUAL "0" OR
           NOT server MATCHES "passage_pages=[2-9]" OR NOT server MATCHES "catalogue_pages=[2-9]")
            message(FATAL_ERROR "late-target model-wire proposal, paging, correction or exact request bounds failed: ${result}\n${server}\n${maintain}")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM maintenance_decisions d,json_each(d.grounding_json,'$[0].items') p WHERE json_extract(d.response_json,'$.question')='passages' AND json_extract(d.response_json,'$.object_id')<>'' AND json_extract(p.value,'$.evidence_id')='zz-late-subject')||':'||(SELECT count(*) FROM maintenance_decisions d,json_each(d.grounding_json,'$[0].items') c WHERE json_extract(d.response_json,'$.question')='catalogue' AND json_extract(d.response_json,'$.object_id')<>'' AND json_extract(c.value,'$.concept_id')='zz-target')||':'||(SELECT count(*) FROM maintenance_decisions WHERE disposition='inspect:pending' AND length(CAST(grounding_json AS BLOB))>8192)||':'||(SELECT count(*) FROM provider_runs)||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-request' AND instr(json_extract(message,'$.body.messages[2].content'),'An invented dependency quotation.')>0 AND instr(json_extract(message,'$.body.messages[3].content'),'Citation correction (one attempt)')>0 AND instr(json_extract(message,'$.body.messages[1].content'),'Selected source spans')>0)||':'||(SELECT count(*) FROM maintenance_decisions WHERE task_id IN(SELECT task_id FROM maintenance_tasks WHERE subject_id='zz-subject'));"
            OUTPUT_VARIABLE journey OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT journey STREQUAL "1:1:0:11:1:8")
            message(FATAL_ERROR "late source/target, bounded pages, correction history or receipts were incomplete: ${journey}")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM (SELECT input_json FROM job_items WHERE item_type='maintenance-resolution' ORDER BY rowid LIMIT 1) WHERE instr(input_json,'late-chunk')>0 OR instr(input_json,'${late_source_id}')>0 OR instr(input_json,'PlatformService depends on AzureStore.')>0)||':'||(SELECT count(*) FROM maintenance_decisions d,json_each(d.grounding_json,'$[0].items') p WHERE d.decision_id=(SELECT decision_id FROM maintenance_decisions WHERE json_extract(response_json,'$.question')='passages' ORDER BY rowid LIMIT 1) AND json_extract(p.value,'$.revision_chunk_id')='late-chunk')||':'||(SELECT count(*) FROM maintenance_decisions d,json_each(d.grounding_json,'$[0].items') p WHERE json_extract(d.response_json,'$.question')='passages' AND json_extract(d.response_json,'$.object_id')<>'' AND json_extract(p.value,'$.revision_chunk_id')='late-chunk');"
            OUTPUT_VARIABLE late_coverage OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT late_coverage STREQUAL "0:0:1")
            message(FATAL_ERROR "decisive source was visible before bounded passage continuation: ${late_coverage}")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT review_id FROM reviews WHERE state='pending' AND subject_id IN(SELECT task_id FROM maintenance_tasks WHERE subject_id='zz-subject') LIMIT 1;"
            OUTPUT_VARIABLE review_id OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        run_cli(decide --format json --access curate review decide "${review_id}" --decision accept --apply)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM claims WHERE source_concept_id='zz-subject' AND target_concept_id='zz-target' AND relationship_type='depends-on' AND visible_to_generation IS NULL)||':'||(SELECT count(*) FROM claim_support s JOIN claims c ON c.claim_id=s.claim_id WHERE c.source_concept_id='zz-subject' AND c.target_concept_id='zz-target' AND s.revision_chunk_id='late-chunk' AND s.span_start=0 AND s.span_end=38); PRAGMA integrity_check; SELECT count(*) FROM pragma_foreign_key_check;"
            OUTPUT_VARIABLE accepted OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT accepted STREQUAL "1:1\nok\n0")
            message(FATAL_ERROR "review did not publish the exact directed, cited relationship: ${accepted}\n${decide}")
        endif()
        run_cli(verify --access diagnose library verify)
        continue()
    endif()
    if(case STREQUAL "large-acquisition")
        run_cli(maintain maintain --yes --workers 1)
        run_cli(second maintain --yes --workers 1)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM maintenance_decisions WHERE disposition='inspect:pending' AND json_extract(grounding_json,'$[0].page_complete')=0 AND length(CAST(grounding_json AS BLOB))<=8192 AND json_array_length(grounding_json,'$[0].items')>0)||':'||(SELECT count(*) FROM maintenance_decisions WHERE disposition='acquisition-wait:unresolved')||':'||(SELECT count(*) FROM maintenance_tasks WHERE subject_id='fixture-note' AND state='unresolved' AND escalation_origin='evidence-limit')||':'||(SELECT count(*) FROM provider_runs)||':'||(SELECT coalesce(sum(reserved_calls+reserved_tokens+reserved_cost),-1) FROM jobs);"
            OUTPUT_VARIABLE acquired OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT acquired STREQUAL "1:1:1:4:0")
            message(FATAL_ERROR "real provider acquisition did not retain a bounded page and scoped hold: ${acquired}\n${maintain}")
        endif()
        continue()
    endif()
    run_cli(explain --format json config explain)
    if(NOT explain MATCHES "resolution_prompt_sha256" OR NOT explain MATCHES "automatic_actions")
        message(FATAL_ERROR "configuration explanation omitted durable maintenance policy")
    endif()
    if(CPRAG_CONFIGURED_ROUTE)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM jobs)||':'||(SELECT count(*) FROM provider_runs)||':'||(SELECT count(*) FROM maintenance_tasks);"
            OUTPUT_VARIABLE route_before OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        run_cli(configured_plan --format json --access plan maintain plan)
        string(JSON route_plan GET "${configured_plan}" records 0 fields canonical_plan)
        string(JSON route_policy GET "${route_plan}" action window_policy)
        string(JSON route_privacy GET "${route_policy}" privacy)
        if(NOT route_privacy STREQUAL "local" OR NOT configured_plan MATCHES "monetary-api")
            message(FATAL_ERROR "hosted maintenance plan lost source classification or charging: ${configured_plan}")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM jobs)||':'||(SELECT count(*) FROM provider_runs)||':'||(SELECT count(*) FROM maintenance_tasks);"
            OUTPUT_VARIABLE route_after OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT route_after STREQUAL route_before)
            message(FATAL_ERROR "configured route preview wrote work or made a provider call: ${route_before} -> ${route_after}")
        endif()
        file(WRITE "${work}/configured-route-result.txt"
            "Hosted maintenance planning accepted local source metadata with public-only provider metadata; work and provider counts unchanged: ${route_after}.\n")
        continue()
    endif()
    if(case STREQUAL "valid")
        # Timing controls are read-only until the reviewed plan is applied.
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM jobs)||':'||(SELECT count(*) FROM provider_runs);"
            OUTPUT_VARIABLE timing_before OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        run_cli(past --format json --access plan maintain plan --until 2000-01-01T06:00:00Z)
        run_cli(past_guided maintain --until=2000-01-01T06:00:00Z --yes)
        if(NOT past MATCHES "skipped" OR NOT past_guided MATCHES "skipped")
            message(FATAL_ERROR "past deadline did not skip cleanly: ${past}${past_guided}")
        endif()
        file(WRITE "${work}/timing-mcp.jsonl" "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"rag_maintain_plan\",\"arguments\":{\"until\":\"2000-01-01T06:00:00Z\"}}}\n")
        execute_process(COMMAND "${CPRAG_NATIVE_APPLICATION}" --access plan serve mcp
            WORKING_DIRECTORY "${work}" INPUT_FILE "${work}/timing-mcp.jsonl"
            OUTPUT_VARIABLE timing_mcp ERROR_VARIABLE timing_mcp_err RESULT_VARIABLE timing_mcp_rc TIMEOUT 30)
        if(NOT timing_mcp_rc EQUAL 0 OR NOT timing_mcp MATCHES "skipped")
            message(FATAL_ERROR "MCP timing control failed: ${timing_mcp}${timing_mcp_err}")
        endif()
        run_cli(timing_plan --format json --access plan maintain plan --minutes 120)
        string(JSON resolved_timing GET "${timing_plan}" records 1 fields timing)
        string(JSON resolved_start GET "${resolved_timing}" started_epoch)
        string(JSON resolved_end GET "${resolved_timing}" deadline_epoch)
        math(EXPR elapsed_window "${resolved_end} - ${resolved_start}")
        string(JSON timed_plan GET "${timing_plan}" records 0 fields canonical_plan)
        string(JSON timed_policy GET "${timed_plan}" action window_policy)
        string(JSON saved_window GET "${timed_policy}" window_seconds)
        if(NOT saved_window EQUAL 7200)
            message(FATAL_ERROR "saved policy retained the configured duration instead of the requested duration")
        endif()
        if(NOT elapsed_window EQUAL 7200)
            message(FATAL_ERROR "duration was reduced by configured aggregate budget")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM jobs)||':'||(SELECT count(*) FROM provider_runs);"
            OUTPUT_VARIABLE timing_after OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT timing_after STREQUAL timing_before)
            message(FATAL_ERROR "timing preview or skipped run mutated work")
        endif()
    endif()
    if(case STREQUAL "continuation" OR case STREQUAL "item-limit")
        run_cli(plan --format json --access plan maintain plan)
        string(JSON maintenance_plan GET "${plan}" records 0 fields canonical_plan)
        string(JSON maintenance_digest GET "${plan}" records 0 fields digest)
        run_cli(applied --format json --access curate maintain apply --plan-json "${maintenance_plan}" --expect-digest "${maintenance_digest}")
        string(JSON continuing_job GET "${applied}" records 0 fields job_id)
        set(batch_limit --max-polls)
        if(case STREQUAL "item-limit")
            set(batch_limit --max-items)
            # Hold real queued work until both workers have survived three
            # empty polls with an item allowance of one. Release by observed
            # state, not by guessing a provider delay or process startup time.
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "UPDATE job_items SET retry_at=2147483647 WHERE job_id='${continuing_job}' AND state='queued'; CREATE TABLE qa_idle_polls(instance_id TEXT PRIMARY KEY,polls INTEGER); CREATE TRIGGER qa_count_idle AFTER UPDATE ON runtime_instances WHEN NEW.kind='worker' AND NEW.state='idle' BEGIN INSERT INTO qa_idle_polls VALUES(NEW.instance_id,1) ON CONFLICT(instance_id) DO UPDATE SET polls=polls+1; END;"
                COMMAND_ERROR_IS_FATAL ANY)
            execute_process(COMMAND /bin/sh -c
                "( CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key CREXXRAG_SELF=\"$1\" \"$1\" --format json --access control worker start --poll-ms 20 --max-items 1 --job \"$2\"; printf '%s' $? >\"$5\" ) >\"$3\" 2>\"$4\" &"
                item-limit-test "${CPRAG_NATIVE_APPLICATION}" "${continuing_job}" "${work}/first.out" "${work}/first.err" "${work}/first.status"
                WORKING_DIRECTORY "${work}" COMMAND_ERROR_IS_FATAL ANY)
            set(waited FALSE)
            foreach(poll RANGE 1 400)
                execute_process(COMMAND "${CPRAG_SQLITE}" -cmd ".timeout 5000" "${database}"
                    "SELECT count(*) FROM qa_idle_polls WHERE polls>=3;"
                    OUTPUT_VARIABLE waiting OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
                if(waiting STREQUAL "2")
                    set(waited TRUE)
                    break()
                endif()
                execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
            endforeach()
            # Always release the test gate so a failed assertion cannot strand workers.
            execute_process(COMMAND "${CPRAG_SQLITE}" -cmd ".timeout 5000" "${database}"
                "UPDATE job_items SET retry_at=0 WHERE job_id='${continuing_job}' AND state='queued';"
                COMMAND_ERROR_IS_FATAL ANY)
            if(NOT waited)
                message(FATAL_ERROR "item-limited workers stopped during empty polls")
            endif()
            foreach(poll RANGE 1 400)
                if(EXISTS "${work}/first.status")
                    break()
                endif()
                execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 0.02)
            endforeach()
            file(READ "${work}/first.status" first_status)
            file(READ "${work}/first.out" first)
            if(NOT first_status STREQUAL "0")
                message(FATAL_ERROR "item-limited worker group failed: ${first}")
            endif()
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT (SELECT count(*) FROM maintenance_decisions)||':'||(SELECT count(*) FROM runtime_instances r WHERE job_filter='${continuing_job}' AND kind='worker' AND state='stopped' AND exit_code=0 AND (SELECT count(*) FROM attempts a WHERE a.worker_id=r.instance_id AND a.outcome<>'cancelled')=1); DROP TRIGGER qa_count_idle; DROP TABLE qa_idle_polls;"
                OUTPUT_VARIABLE item_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT item_result STREQUAL "2:2")
                message(FATAL_ERROR "empty polls consumed the work allowance or workers exceeded it: ${item_result}")
            endif()
        else()
            run_cli(first --format json --access control worker start --max-polls 1 --job "${continuing_job}")
        endif()
        if(NOT first MATCHES "identical-no-op" OR NOT first MATCHES "\"vector_generations\":1")
            message(FATAL_ERROR "bounded worker group lost existing vector availability: ${first}")
        endif()
        run_cli(second --format json --access control worker start ${batch_limit} 1 --job "${continuing_job}")
        run_cli(finish --format json --access control worker start --max-polls 1 --job "${continuing_job}")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM maintenance_windows)||':'||(SELECT count(*) FROM maintenance_decisions WHERE disposition='retain:resolved')||':'||(SELECT count(*) FROM job_items WHERE state IN('queued','running','cancel_requested','dead_letter'));"
            OUTPUT_VARIABLE continuation_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT continuation_result STREQUAL "1:4:0")
            message(FATAL_ERROR "bounded worker groups did not continue one plan: ${continuation_result}")
        endif()
    elseif(case STREQUAL "budget")
        # Use the configured two-worker group, exactly as the nightly wrapper does.
        run_cli(maintain maintain --yes)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM maintenance_windows WHERE state='budget-exhausted')||':'||(SELECT count(*) FROM maintenance_decisions WHERE disposition='retain:resolved')||':'||(SELECT count(*) FROM maintenance_tasks WHERE subject_id LIKE 'fixture-note%' AND state='pending')||':'||(SELECT count(*) FROM job_items WHERE state IN('queued','running','cancel_requested','dead_letter'))||':'||(SELECT sum(reserved_calls+reserved_tokens+reserved_cost) FROM jobs);"
            OUTPUT_VARIABLE bounded_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT bounded_result STREQUAL "1:2:2:0:0")
            message(FATAL_ERROR "budget boundary lost unfinished work or reported a failure: ${bounded_result}")
        endif()
        run_cli(resume maintain --yes)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM maintenance_windows WHERE state='budget-exhausted')||':'||(SELECT count(*) FROM maintenance_decisions WHERE disposition='retain:resolved')||':'||(SELECT count(*) FROM job_items WHERE state IN('queued','running','cancel_requested','dead_letter'))||':'||(SELECT sum(reserved_calls+reserved_tokens+reserved_cost) FROM jobs);"
            OUTPUT_VARIABLE resumed_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        file(READ "${work}/server.out" budget_server)
        if(NOT resumed_result STREQUAL "2:4:0:0" OR NOT budget_server MATCHES "barrier_pairs=2")
            message(FATAL_ERROR "fresh plan did not resume remaining work with two workers: ${resumed_result}\n${budget_server}")
        endif()
    else()
        if(case STREQUAL "advanced" OR case STREQUAL "correction-advanced" OR case STREQUAL "upgrade")
            run_cli(first_plan --format json --access plan maintain plan)
            string(JSON first_canonical GET "${first_plan}" records 0 fields canonical_plan)
            string(JSON first_digest GET "${first_plan}" records 0 fields digest)
            run_cli(first_apply --format json --access curate maintain apply --plan-json "${first_canonical}" --expect-digest "${first_digest}")
            string(JSON first_job GET "${first_apply}" records 0 fields job_id)
            run_cli(first_pause --format json --access control job pause "${first_job}")
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "UPDATE maintenance_tasks SET required_capability='advanced-reasoning',escalation_reason='Fixture handoff for final assessment' WHERE subject_id='fixture-note';"
                COMMAND_ERROR_IS_FATAL ANY)
            if(case STREQUAL "upgrade")
                execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                    "UPDATE maintenance_tasks SET not_before_epoch=unixepoch()+86400 WHERE subject_id<>'fixture-note';"
                    COMMAND_ERROR_IS_FATAL ANY)
            endif()
        endif()
        if(case STREQUAL "receipt-recovery")
            # Fail after receipt commit but before settlement, then reuse the
            # frozen model reference mapping without another provider call.
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "CREATE TRIGGER receipt_fault BEFORE INSERT ON provider_runs WHEN NEW.model='gemini-3.5-flash-lite' BEGIN SELECT RAISE(ABORT,'injected resolution receipt settlement failure'); END;"
                COMMAND_ERROR_IS_FATAL ANY)
            execute_process(COMMAND "${CMAKE_COMMAND}" -E env
                "CPRAG_FIXTURE_GEMINI_KEY=synthetic-product-gemini-key"
                "CREXXRAG_SELF=${CPRAG_NATIVE_APPLICATION}" "${CPRAG_NATIVE_APPLICATION}" maintain --yes --workers 1
                WORKING_DIRECTORY "${work}" RESULT_VARIABLE fault_status OUTPUT_VARIABLE interrupted ERROR_VARIABLE fault_detail TIMEOUT 60)
            file(APPEND "${work}/commands.log" "receipt fault status=${fault_status}\n${interrupted}${fault_detail}\n")
            if(NOT "${fault_status}" MATCHES "^[0-9]+$" OR fault_status EQUAL 0)
                message(FATAL_ERROR "resolution receipt fault did not produce a failure exit: ${fault_status}")
            endif()
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT count(*) FROM attempts a JOIN job_events e USING(attempt_id) JOIN job_items i USING(item_id) WHERE e.event_type='provider-response' AND i.item_type='maintenance-resolution' AND a.provider_run_id IS NULL;"
                OUTPUT_VARIABLE unsettled OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT unsettled STREQUAL "1")
                message(FATAL_ERROR "fault did not preserve exactly one unsettled model response: ${unsettled}")
            endif()
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "DROP TRIGGER receipt_fault; UPDATE job_items SET lease_until=unixepoch()-1 WHERE state='running';"
                COMMAND_ERROR_IS_FATAL ANY)
            run_cli(maintain --access control --format json worker start --count 2 --poll-ms 20 --max-polls 10)
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT (SELECT count(*) FROM job_events WHERE event_type='provider-receipt-reused')||':'||(SELECT count(*) FROM job_items WHERE state NOT IN('processed','skipped'))||':'||(SELECT sum(reserved_calls+reserved_tokens+reserved_cost) FROM jobs);"
                OUTPUT_VARIABLE recovered OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT recovered STREQUAL "1:0:0")
                message(FATAL_ERROR "resolution receipt recovery lost completion or accounting: ${recovered}")
            endif()
        elseif(case STREQUAL "upgrade")
            run_cli(upgrade_plan --format json --access plan maintain plan --minutes 5)
            string(JSON upgrade_canonical GET "${upgrade_plan}" records 0 fields canonical_plan)
            string(JSON upgrade_digest GET "${upgrade_plan}" records 0 fields digest)
            run_cli(upgrade_apply --format json --access curate maintain apply --plan-json "${upgrade_canonical}" --expect-digest "${upgrade_digest}")
            string(JSON upgrade_job GET "${upgrade_apply}" records 0 fields job_id)
            if(CPRAG_UPGRADE_QUEUED_ONLY)
                message(STATUS "Synthetic queued v7 job retained at ${work}")
                return()
            endif()
            run_cli(maintain --format json --access control worker run --once --poll-ms 20 --max-polls 2 --job "${upgrade_job}")
        elseif(case STREQUAL "advanced")
            run_cli(maintain maintain --yes --minutes 1 --workers ${maintenance_workers})
        else()
            run_cli(maintain maintain --yes --workers ${maintenance_workers})
        endif()
    endif()
    if(case STREQUAL "upgrade")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM job_items WHERE item_type='maintenance-resolution' AND json_extract(input_json,'$.resolution_contract')='crexx-rag.resolution-contract/7' AND length(json_extract(input_json,'$.prompt_sha256'))=64 AND length(json_extract(input_json,'$.schema_sha256'))=64)||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-response' AND json_extract(message,'$.status')<>0);"
            OUTPUT_VARIABLE retained OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT retained STREQUAL "2:1")
            message(FATAL_ERROR "baseline did not retain the queued and rejected v7 work: ${retained}")
        endif()
        message(STATUS "Synthetic v7 rejected job retained at ${work}")
        return()
    endif()
    run_cli(status --format json maintain status)
    run_cli(report --format json library report)
    execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
        "SELECT count(*) FROM maintenance_tasks WHERE state NOT IN('resolved','superseded');"
        OUTPUT_VARIABLE expected_open OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    if(NOT report MATCHES "\"kind\":\"durable-maintenance-backlog\"" OR
       NOT report MATCHES "\"open_tasks\":${expected_open}[,}]")
        message(FATAL_ERROR "report omitted or miscounted durable tasks: ${report}")
    endif()
    if(case STREQUAL "manual")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT count(*) FROM maintenance_tasks WHERE state='review';"
            OUTPUT_VARIABLE expected_review OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(expected_review LESS 1 OR NOT report MATCHES "\"review_tasks\":${expected_review}[,}]" OR
           NOT report MATCHES "\"dimension\":\"review\",\"state\":\"attention\"")
            message(FATAL_ERROR "manual review questions were reported healthy or omitted: ${report}")
        endif()
        run_cli(snapshot --format json --access read,control library snapshot --trigger maintenance --reason "Durable review census regression")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT work_backlog||':'||pending_reviews FROM observation_snapshots ORDER BY sequence_number DESC LIMIT 1;"
            OUTPUT_VARIABLE observed_backlog OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT observed_backlog STREQUAL "${expected_open}:${expected_review}")
            message(FATAL_ERROR "snapshot omitted durable work/reviews: ${observed_backlog}")
        endif()
    endif()
    execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
        "SELECT (SELECT count(*) FROM revision_chunks)||':'||(SELECT group_concat(hex(vector)) FROM embeddings)||':'||(SELECT count(*) FROM revision_chunk_embeddings)||':'||((SELECT count(*) FROM provider_runs)-${maintenance_calls});"
        OUTPUT_VARIABLE after OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    if(NOT before STREQUAL after)
        message(FATAL_ERROR "maintenance changed source/vector state or made an unexpected number of calls")
    endif()
    execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
        "SELECT state FROM maintenance_tasks WHERE kind='analysis-lead' AND subject_id='fixture-note';"
        OUTPUT_VARIABLE task_state OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    if(case STREQUAL "correction-limit")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.resolution_references.S1')='fixture-note')||':'||(SELECT count(*) FROM job_events WHERE event_type='citation-correction-requested')||':'||(SELECT count(*) FROM provider_runs)||':'||(SELECT coalesce(sum(reserved_calls+reserved_tokens+reserved_cost),-1) FROM jobs)||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.body_bytes')=length(CAST(json_extract(message,'$.body') AS BLOB)));"
            OUTPUT_VARIABLE guarded OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT state||':'||escalation_origin||':'||CASE WHEN instr(escalation_reason,'serialized resolution request ')>0 AND instr(escalation_reason,'21000-byte input bound')>0 THEN 'measured' ELSE 'unmeasured' END FROM maintenance_tasks WHERE kind='analysis-lead' AND subject_id='fixture-note';"
            OUTPUT_VARIABLE hold OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT guarded STREQUAL "1:1:3:0:3" OR NOT hold STREQUAL "review:request-capability:measured")
            message(FATAL_ERROR "full correction request did not stop before the provider while retaining prior receipts and usage: ${guarded}, ${hold}\n${maintain}${status}")
        endif()
        continue()
    endif()
    if(case MATCHES "^correction")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT (SELECT count(*) FROM job_events WHERE event_type='citation-correction-requested')||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-response')||':'||(SELECT sum(reserved_calls+reserved_tokens+reserved_cost) FROM jobs)||':'||(SELECT count(*) FROM job_items WHERE state='dead_letter');"
            OUTPUT_VARIABLE correction_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        set(expected_correction "1:4:0:0")
        set(expected_task resolved)
        if(case STREQUAL "correction-failed")
            set(expected_correction "1:4:0:1")
            set(expected_task unresolved)
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT semantic_failures||':'||required_capability||':'||escalation_origin FROM maintenance_tasks WHERE kind='analysis-lead' AND subject_id='fixture-note';"
                OUTPUT_VARIABLE escalation OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT escalation STREQUAL "2:advanced-reasoning:validation-failures")
                message(FATAL_ERROR "repeated invalid provider content did not flag advanced reasoning: ${escalation}")
            endif()
        elseif(case STREQUAL "correction-budget")
            set(expected_correction "1:3:0:0")
            set(expected_task pending)
        endif()
        if(NOT correction_result STREQUAL expected_correction OR NOT task_state STREQUAL expected_task)
            message(FATAL_ERROR "citation correction lost its one-call bound, receipt or outcome: ${correction_result}, task=${task_state}\n${maintain}${status}")
        endif()
        if(NOT case STREQUAL "correction-budget")
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT count(*)||':'||count(DISTINCT json_extract(message,'$.resolution_references')) FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.resolution_references.S1')='fixture-note' AND json_extract(message,'$.resolution_references.E1')='fixture-note-link';"
                OUTPUT_VARIABLE correction_mapping OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT correction_mapping STREQUAL "2:1")
                message(FATAL_ERROR "correction did not retain exactly the initial reference mapping: ${correction_mapping}")
            endif()
        endif()
        if(case STREQUAL "correction" OR case STREQUAL "correction-advanced")
            # Real stored requests must agree: fresh allowance in both system
            # text and presented input, while durable task evidence stays frozen.
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT group_concat(remaining,',') FROM (SELECT CASE WHEN instr(json_extract(message,'$.body.messages[0].content'),'Remaining reasoning calls including this one: 2;')>0 THEN 2 WHEN instr(json_extract(message,'$.body.messages[0].content'),'Remaining reasoning calls including this one: 1;')>0 THEN 1 ELSE -1 END remaining FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.resolution_references.S1')='fixture-note' ORDER BY event_id);"
                OUTPUT_VARIABLE displayed_allowance OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT displayed_allowance STREQUAL "2,1")
                message(FATAL_ERROR "correction repeats stale remaining-call instructions: ${displayed_allowance}")
            endif()
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT group_concat(remaining,',') FROM (SELECT CASE WHEN instr(json_extract(message,'$.body.messages[1].content'),'\"remaining_calls_including_this\":2')>0 THEN 2 WHEN instr(json_extract(message,'$.body.messages[1].content'),'\"remaining_calls_including_this\":1')>0 THEN 1 ELSE -1 END remaining FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.resolution_references.S1')='fixture-note' ORDER BY event_id);"
                OUTPUT_VARIABLE presented_allowance OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT presented_allowance STREQUAL "2,1")
                message(FATAL_ERROR "presented correction input disagrees with system allowance: ${presented_allowance}")
            endif()
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT count(*)||':'||count(DISTINCT json_extract(message,'$.input_hash'))||':'||count(DISTINCT json_extract(message,'$.prompt_sha256')) FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.resolution_references.S1')='fixture-note'; SELECT count(*) FROM job_items WHERE state='processed' AND json_extract(input_json,'$.evidence.subject.id')='fixture-note' AND json_extract(input_json,'$.remaining_calls_including_this')=2;"
                OUTPUT_VARIABLE frozen_allowance OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT frozen_allowance STREQUAL "2:1:2\n1")
                message(FATAL_ERROR "correction changed frozen input or lost actual prompt identities: ${frozen_allowance}")
            endif()
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT job_id FROM job_events WHERE event_type='citation-correction-requested' LIMIT 1;"
            OUTPUT_VARIABLE correction_job OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        run_cli(correction_status --format json --access read job status "${correction_job}" --seconds 3600)
        string(JSON requested ERROR_VARIABLE missing_requested GET "${correction_status}" records 0 fields correction_requested_items)
        string(JSON corrected ERROR_VARIABLE missing_corrected GET "${correction_status}" records 0 fields correction_processed_items)
        set(expected_corrected 0)
        if(case STREQUAL "correction" OR case STREQUAL "correction-advanced")
            set(expected_corrected 1)
        endif()
        if(missing_requested OR missing_corrected OR NOT requested EQUAL 1 OR NOT corrected EQUAL expected_corrected)
            message(FATAL_ERROR "Public correction status cannot distinguish requested and accepted corrections: ${correction_status}")
        endif()
    elseif(case STREQUAL "advanced")
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT count(*) FROM maintenance_decisions d JOIN job_items i ON i.item_id=d.item_id WHERE d.disposition='no-change:resolved' AND d.applied_generation IS NULL AND json_extract(i.input_json,'$.role')='advanced-resolver' AND length(json_extract(i.input_json,'$.prompt_sha256'))=64 AND length(json_extract(i.input_json,'$.schema_sha256'))=64;"
            OUTPUT_VARIABLE advanced_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT task_state STREQUAL "resolved" OR NOT advanced_result STREQUAL "1")
            message(FATAL_ERROR "advanced native route did not retain its prompt/schema and final no-change: ${advanced_result}, ${task_state}\n${maintain}${status}")
        endif()
    elseif(case STREQUAL "manual")
        if(NOT task_state STREQUAL "review")
            message(FATAL_ERROR "manual window did not collect its note question: ${task_state}")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}" "SELECT count(*) FROM maintenance_windows WHERE state='active';"
            OUTPUT_VARIABLE active_windows OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        if(NOT active_windows STREQUAL "0")
            message(FATAL_ERROR "guided manual census left a window active with no queued provider work")
        endif()
    elseif(case STREQUAL "valid" OR case STREQUAL "receipt-recovery" OR case STREQUAL "concurrent" OR case STREQUAL "budget" OR case STREQUAL "continuation" OR case STREQUAL "item-limit")
        if(NOT task_state STREQUAL "resolved")
            message(FATAL_ERROR "valid Gemini resolution was not applied: ${task_state}\n${maintain}${status}")
        endif()
        if(case STREQUAL "valid" OR case STREQUAL "receipt-recovery")
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT (SELECT count(*) FROM maintenance_decisions WHERE json_extract(response_json,'$.object_id')='fixture-note' AND json_extract(response_json,'$.evidence[0].evidence_id')='fixture-note-link')||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-request' AND json_extract(message,'$.resolution_references.S1')='fixture-note' AND json_extract(message,'$.resolution_references.E1')='fixture-note-link')||':'||(SELECT count(*) FROM job_events WHERE event_type='provider-response' AND json_extract(nullif(json_extract(message,'$.content'),''),'$.object_id')='S1' AND json_extract(nullif(json_extract(message,'$.content'),''),'$.evidence[0].evidence_id')='E1');"
                OUTPUT_VARIABLE reference_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            if(NOT reference_result STREQUAL "1:1:1")
                message(FATAL_ERROR "model references, retained mapping, original response and canonical decision disagree: ${reference_result}")
            endif()
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT task_id FROM maintenance_tasks WHERE subject_id='fixture-note';"
            OUTPUT_VARIABLE task_id OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
        run_cli(inspect --format json maintain inspect "${task_id}")
        run_cli(task_evidence --format json maintain evidence "${task_id}" --limit 1)
        if(NOT inspect MATCHES "rag_task_evidence" OR NOT inspect MATCHES "retain:resolved" OR NOT task_evidence MATCHES "fixture-note-link" OR NOT task_evidence MATCHES "crexx-rag:.*:utf8-")
            message(FATAL_ERROR "durable task inspection or paged source evidence omitted evidence, citation or decision")
        endif()
        if(case STREQUAL "concurrent")
            execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
                "SELECT (SELECT count(*) FROM maintenance_decisions WHERE disposition='retain:resolved')||':'||(SELECT count(*) FROM job_items WHERE state NOT IN('processed','skipped'))||':'||(SELECT count(DISTINCT a.worker_id) FROM attempts a JOIN job_items i USING(item_id) WHERE i.item_type='maintenance-resolution')||':'||(SELECT sum(reserved_calls+reserved_tokens+reserved_cost) FROM jobs);"
                OUTPUT_VARIABLE concurrent_result OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
            file(READ "${work}/server.out" concurrent_server)
            if(NOT concurrent_result STREQUAL "${CPRAG_CONCURRENT_ITEMS}:0:2:0" OR NOT concurrent_server MATCHES "barrier_pairs=${concurrent_pairs}")
                message(FATAL_ERROR "native concurrency/publication/accounting proof failed: ${concurrent_result}\n${concurrent_server}")
            endif()
            run_cli(verify --access diagnose library verify)
        endif()
    else()
        if(NOT task_state STREQUAL "failed")
            message(FATAL_ERROR "malformed response did not reach bounded failure: ${task_state}")
        endif()
        execute_process(COMMAND "${CPRAG_SQLITE}" "${database}"
            "SELECT recovery_json FROM provider_runs WHERE outcome='failed';"
            OUTPUT_VARIABLE diagnostic COMMAND_ERROR_IS_FATAL ANY)
        if(diagnostic MATCHES "synthetic-product-gemini-key")
            message(FATAL_ERROR "resolution failure diagnostic exposed a fixture credential")
        endif()
        if(case STREQUAL "rejected" AND (NOT diagnostic MATCHES "REDACTED" OR NOT diagnostic MATCHES "credential-redacted"))
            message(FATAL_ERROR "resolution failure diagnostic did not retain redacted evidence")
        endif()
    endif()
    execute_process(COMMAND "${CPRAG_SQLITE}" "${database}" "PRAGMA integrity_check; SELECT count(*) FROM pragma_foreign_key_check;"
        OUTPUT_VARIABLE integrity OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    if(NOT integrity STREQUAL "ok\n0")
        message(FATAL_ERROR "durable backlog database integrity failure: ${integrity}")
    endif()
    if(NOT EXISTS "${work}/server.status")
        message(FATAL_ERROR "loopback did not finish its exact bounded requests")
    endif()
    file(READ "${work}/server.status" server_status)
    if(NOT server_status STREQUAL "0")
        message(FATAL_ERROR "durable backlog loopback failed")
    endif()
endforeach()
file(WRITE "${CPRAG_WORK_DIR}/result.txt" "Cases: ${CPRAG_CASES}. Concurrent gate: ${CPRAG_CONCURRENT_ITEMS} decisions, two actual workers, ${concurrent_pairs} forced overlapping request pairs, zero failed/unfinished items and zero outstanding reservations, preserved source/vector state and exact call accounting.\n")
