include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

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

add_executable(
  UnitTests
  main.cc
  ${TEST_HEADER_FILES}
  ${TEST_SOURCE_FILES}
)

target_link_libraries(UnitTests PRIVATE GTest::gtest_main)
target_link_libraries(UnitTests PUBLIC ${FOO_LIBRARY})

include(GoogleTest)
gtest_discover_tests(UnitTests)