cmake_minimum_required(VERSION 3.17 FATAL_ERROR)
project(foo VERSION 0.0.1)

# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 2.24:
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

# Try to find ccache to speed up compilation
find_program(ccache_binary ccache)
if (ccache_binary)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${ccache_binary}")
endif()

file(
  GLOB
  HEADER_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h
)

set(FOO_LIBRARY foo CACHE INTERNAL "" FORCE)
set(FOO_LIBRARY_NS foo::lib)

# Search path for CMake modules to be loaded by the include() or find_package() commands
# before checking the default modules that come with CMake
set(
  CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/"
)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17 CACHE STRING "The C++ standard to use")
endif()
message(STATUS "CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")

option(FOO_WERROR_ENABLED "Build foo with warnings as errors" OFF)
option(FOO_TESTS_ENABLED "Build foo with unit tests" ON)
option(FOO_COVERAGE_ENABLED "Build foo with coverage" OFF)

if(APPLE AND NOT CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
  add_compile_options(-ffat-lto-objects)
endif()

add_compile_definitions(SRC_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_compile_definitions(BUILD_DIR="${CMAKE_BINARY_DIR}")

set(PROJECT_BIN_DIR      ${CMAKE_CURRENT_BINARY_DIR})
set(PROJECT_BASE_DIR     ${CMAKE_CURRENT_SOURCE_DIR})
set(PROJECT_LIB_DIR      ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(PROJECT_EXAMPLE_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/examples)
set(PROJECT_APP_DIR      ${CMAKE_CURRENT_SOURCE_DIR}/apps)
set(PROJECT_BINDINGS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/bindings)

add_subdirectory(src)

message(STATUS "FOO_COVERAGE_ENABLED: ${FOO_COVERAGE_ENABLED}")
if (FOO_COVERAGE_ENABLED)
  add_compile_options(-fprofile-arcs -ftest-coverage -O0)
  add_link_options(--coverage)
endif()

message(STATUS "FOO_TESTS_ENABLED: ${FOO_TESTS_ENABLED}")
if (BUILD_TESTING AND FOO_TESTS_ENABLED)
  set(CTEST_SOURCE_DIRECTORY ${SOURCE_DIR}/src)
  add_subdirectory(tests)
endif()
