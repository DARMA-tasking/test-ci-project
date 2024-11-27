set(
  TOP_LEVEL_SUBDIRS
  bar
)

set(FOO_INSTALL_DESTINATION "include/foo")
set(FOO_EXTERNAL_DESTINATION "include")

foreach(DIR ${TOP_LEVEL_SUBDIRS})
  install(
    DIRECTORY "foo/${DIR}"
    DESTINATION ${FOO_INSTALL_DESTINATION}
    FILES_MATCHING PATTERN "*.h"
  )
endforeach()

file(GLOB TOP_HEADERS "foo/*.h")
install(
  FILES ${TOP_HEADERS}
  DESTINATION ${FOO_INSTALL_DESTINATION}
)
file(
  GLOB
  HEADER_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/foo/*.h
)
file(
  GLOB
  SOURCE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/foo/*.cc
)
foreach(SUB_DIR ${TOP_LEVEL_SUBDIRS})
  file(
    GLOB
    "${SUB_DIR}_HEADER_FILES"
    RELATIVE
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/foo/${SUB_DIR}/*.h"
  )

  file(
    GLOB
    "${SUB_DIR}_SOURCE_FILES"
    RELATIVE
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/foo/${SUB_DIR}/*.cc"
  )
  list(
    APPEND
    HEADER_FILES
    "${${SUB_DIR}_HEADER_FILES}"
  )
  list(
    APPEND
    SOURCE_FILES
    "${${SUB_DIR}_SOURCE_FILES}"
  )
endforeach()

add_library(${FOO_LIBRARY} STATIC ${HEADER_FILES} ${SOURCE_FILES})
add_library(${FOO_LIBRARY_NS} ALIAS ${FOO_LIBRARY})

set_target_properties(${FOO_LIBRARY} PROPERTIES LINKER_LANGUAGE C)

include(turn_on_warnings)
turn_on_warnings(${FOO_LIBRARY})

target_include_directories(
  ${FOO_LIBRARY} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include>
)

target_include_directories(
  ${FOO_LIBRARY} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)

install(
  TARGETS                   ${FOO_LIBRARY}
  EXPORT                    ${FOO_LIBRARY}
  LIBRARY DESTINATION       lib
  ARCHIVE DESTINATION       lib
  RUNTIME DESTINATION       bin
  INCLUDES DESTINATION      ${FOO_EXTERNAL_DESTINATION}
)

install(
  EXPORT                    ${FOO_LIBRARY}
  DESTINATION               cmake
  FILE                      "fooTargets.cmake"
  NAMESPACE                 foo::
  COMPONENT                 runtime
)

export(
  TARGETS                   ${FOO_LIBRARY}
  FILE                      "fooTargets.cmake"
  NAMESPACE                 foo::
)
