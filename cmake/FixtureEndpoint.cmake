# The fixture has already bound port zero and retains that listener. Update the
# private, not-yet-planned config only after readiness; never probe a free port.
macro(crexxrag_fixture_endpoint ready_file config_file)
    file(READ "${ready_file}" endpoint_ready)
    if(NOT endpoint_ready MATCHES "READY ([0-9]+)")
        message(FATAL_ERROR "fixture did not publish its owned endpoint: ${ready_file}")
    endif()
    set(CPRAG_FIXTURE_PORT "${CMAKE_MATCH_1}")
    file(READ "${config_file}" endpoint_config)
    string(REPLACE "127.0.0.1:0" "127.0.0.1:${CPRAG_FIXTURE_PORT}" endpoint_config "${endpoint_config}")
    file(WRITE "${config_file}" "${endpoint_config}")
    # Several fixtures derive a later policy from their in-memory config.
    if(DEFINED config)
        string(REPLACE "127.0.0.1:0" "127.0.0.1:${CPRAG_FIXTURE_PORT}" config "${config}")
    endif()
endmacro()
