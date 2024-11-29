set(BUILD_GMOCK ON CACHE BOOL "Builds the googlemock subproject" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "Enable installation of googletest. (Projects embedding googletest may want to turn this OFF.)" FORCE)

if (NOT TARGET gtest)
  # include GoogleTest and enable testing
  add_subdirectory(${PROJECT_LIB_DIR}/googletest ${PROJECT_BIN_DIR}/lib/googletest)
endif()
set(GOOGLETEST_LIBRARY gtest)

include(GoogleTest)

# Hide various options from UI-based property editors
mark_as_advanced(
  BUILD_GTEST INSTALL_GTEST BUILD_SHARED_LIBS
  gtest_build_samples gtest_build_tests
  gtest_disable_pthreads gtest_force_shared_crt gtest_hide_internal_symbols
)

# Group targets, in IDEs supporting such
set_target_properties(gtest PROPERTIES FOLDER lib)
set_target_properties(gtest_main PROPERTIES FOLDER lib)

set(PROJECT_TEST_UNIT_DIR ${SRC_DIR}/unit)

# Collect sources
file(
  GLOB_RECURSE
  TEST_SOURCE_FILES
  "*.cc"
)

file(
  GLOB_RECURSE
  TEST_HEADER_FILES
  "*.h"
)

include(turn_on_warnings)

# Macro to link foo, gtest and gmock to a target
macro(foo_link_target target)
  target_include_directories(${target} PRIVATE
    ${gtest_SOURCE_DIR}/include
    ${gmock_SOURCE_DIR}/include
  )
  target_link_libraries(${target} PRIVATE GTest::gtest_main GTest::gmock_main)
  target_link_libraries(${target} PUBLIC ${FOO_LIBRARY})
  target_compile_definitions(${target} PUBLIC FOO_HAS_TESTS)
endmacro()

add_executable(
  UnitTests
  main.cc
  ${TEST_HEADER_FILES}
  ${TEST_SOURCE_FILES}
)

turn_on_warnings(UnitTests)

# Required if using vtk
# # Initialize VTK modules
# vtk_module_autoinit(
#   TARGETS UnitTests
#   MODULES ${VTK_LIBRARIES}
# )

foo_link_target(UnitTests)
gtest_discover_tests(UnitTests)