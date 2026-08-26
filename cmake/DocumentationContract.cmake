foreach(required_var CPRAG_SOURCE_DIR CPRAG_WORK_DIR)
    if(NOT DEFINED ${required_var} OR "${${required_var}}" STREQUAL "")
        message(FATAL_ERROR "${required_var} is required")
    endif()
endforeach()

file(GLOB_RECURSE documents
    "${CPRAG_SOURCE_DIR}/README.md"
    "${CPRAG_SOURCE_DIR}/docs/*.md"
    "${CPRAG_SOURCE_DIR}/skills/*.md"
    "${CPRAG_SOURCE_DIR}/skills/*.json")
set(combined "")
foreach(document IN LISTS documents)
    if(document MATCHES "/docs/integration-issues.md$")
        continue()
    endif()
    file(READ "${document}" content)
    string(APPEND combined "\nFILE=${document}\n${content}")
endforeach()

foreach(obsolete
        "crexxrag-improve"
        "rag_improve_"
        "improve plan"
        "improve apply"
        "Current deliberate limits"
        "not available in the baseline")
    if(combined MATCHES "${obsolete}")
        message(FATAL_ERROR "documentation contains obsolete or postponement vocabulary: ${obsolete}")
    endif()
endforeach()
if(NOT combined MATCHES "Production vector execution uses the published IVF-flat" OR
   NOT combined MATCHES "exact cosine scan exists only in QA" OR
   NOT combined MATCHES "crexxrag-maintain" OR
   NOT combined MATCHES "[Gg]lossary" OR
   NOT combined MATCHES "drift fails before" OR
   NOT combined MATCHES "Methodology closure checklist")
    message(FATAL_ERROR "documentation does not state the implemented ANN, maintenance, glossary-drift and closure contracts")
endif()
if(EXISTS "${CPRAG_SOURCE_DIR}/skills/crexxrag-improve")
    message(FATAL_ERROR "obsolete crexxrag-improve skill directory remains")
endif()
if(NOT EXISTS "${CPRAG_SOURCE_DIR}/skills/crexxrag-maintain/SKILL.md" OR
   NOT EXISTS "${CPRAG_SOURCE_DIR}/docs/methodology-closure.md")
    message(FATAL_ERROR "maintenance skill or definitive closure table is missing")
endif()

file(MAKE_DIRECTORY "${CPRAG_WORK_DIR}")
file(WRITE "${CPRAG_WORK_DIR}/result.txt"
    "test=documentation-contract\nobsolete_surface=absent\nann=ivf-flat-only\nworklist=methodology-closure-table\nintegration_ledger=separate\n")
message(STATUS "Documentation and installed-skill source describe the implemented maintain and IVF-flat ANN surface without a product-methodology postponement list")
