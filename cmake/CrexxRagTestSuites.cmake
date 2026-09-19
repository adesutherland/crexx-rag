# Disjoint tiers: widening coverage never selects an aggregate over its children.
set(fast_tests vector_provider regression_command_metadata regression_command_catalogue
    regression_claim_policy regression_prompt_inspection linked_application
    documentation_contract qa_execution regression_smoke_stale_workers regression_smoke_terminal_state)
set(component_tests native_vector regression_policy_file_vm regression_rule_simplification
    configuration_contract regression_supervision provider_durability codex_protocol
    ann_methodology lifecycle_methodology evidence_methodology maintenance_methodology
    quotation_grounding temporal_provenance durable_backlog durable_backlog_escalation durable_backlog_budget durable_backlog_recording regression_lifecycle
    regression_sql_performance task_reset)
get_property(tests DIRECTORY PROPERTY TESTS)
foreach(test IN LISTS tests)
    set(tier integration)
    set(priority 10)
    if(test IN_LIST fast_tests)
        set(tier fast)
        set(priority 100)
    elseif(test IN_LIST component_tests OR test MATCHES "^codex_protocol_(noopt|opt)_")
        set(tier component)
        set(priority 80)
    endif()
    get_property(timeout TEST "${test}" PROPERTY TIMEOUT)
    if(NOT timeout)
        set(timeout 330)
        set_property(TEST "${test}" PROPERTY TIMEOUT ${timeout})
    endif()
    math(EXPR owned_timeout "${timeout}-5")
    set_property(TEST "${test}" APPEND PROPERTY ENVIRONMENT "CREXXRAG_TEST_TIMEOUT=${owned_timeout}")
    if(test STREQUAL "codex_protocol_turnover")
        set(tier scale)
    endif()
    set_property(TEST "${test}" APPEND PROPERTY LABELS "tier-${tier}")
    set_property(TEST "${test}" PROPERTY COST ${priority})
    # These spawn pools internally. Most tests consume one scheduling slot;
    # wider process matrices must not overcommit the host.
    # The real-model case starts two inference workers plus native model-loader
    # threads. Its 10-second load assertion timed out in a two-slot allocation
    # but passed unchanged in isolation; reserve the eight-slot local lane.
    if(test MATCHES "^(regression_supervision$|controller_recovery_|native_supervision_(outage|outage24|bad-task)$|process_workers$|native_embedding_windows$)")
        set_property(TEST "${test}" PROPERTY PROCESSORS 8)
    elseif(test MATCHES "^embedding_(recovery|exhaustion)$")
        set_property(TEST "${test}" PROPERTY PROCESSORS 8)
    elseif(test MATCHES "^(native_|durable_backlog_provider_|embedding_)")
        set_property(TEST "${test}" PROPERTY PROCESSORS 2)
    endif()
endforeach()

# These assert real elapsed boundaries; keep them out of iterative selections.
set_property(TEST worker_recovery_preflight-once embedding_exhaustion qa_fixture_lifetime
    APPEND PROPERTY LABELS "real-time-boundary")
