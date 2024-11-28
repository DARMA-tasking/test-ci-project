include(CheckCXXCompilerFlag)

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  add_compile_options(-fdiagnostics-color=always)
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  add_compile_options(-fcolor-diagnostics)
endif()

macro(add_cxx_compiler_flag_if_supported flag)
  check_cxx_compiler_flag(${flag} flag_supported)
  if(flag_supported)
    list(APPEND FOO_WARNING_FLAGS "${flag}")
  endif()
  unset(flag_supported CACHE)
endmacro()

if(NOT DEFINED FOO_WARNING_FLAGS)
  add_cxx_compiler_flag_if_supported("-Wall")
  add_cxx_compiler_flag_if_supported("-Wextra")
  add_cxx_compiler_flag_if_supported("-Wno-unknown-pragmas")
  add_cxx_compiler_flag_if_supported("-Wnon-virtual-dtor")
  add_cxx_compiler_flag_if_supported("-Wshadow")
  add_cxx_compiler_flag_if_supported("-Wsign-compare")
  add_cxx_compiler_flag_if_supported("-Wsuggest-override")
  add_cxx_compiler_flag_if_supported("-pedantic")
  # Not really a warning, is still diagnostic related..
  if (NOT CMAKE_CXX_COMPILER_ID STREQUAL Intel OR
      CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 2021)
    add_cxx_compiler_flag_if_supported("-ftemplate-backtrace-limit=100")
  endif()

  if (FOO_WERROR_ENABLED)   # Treat warning as errors
    add_cxx_compiler_flag_if_supported("-Werror")
  endif()
endif()

set(
    FOO_WARNING_FLAGS ${FOO_WARNING_FLAGS} CACHE INTERNAL
  "Project's warning options")

macro(turn_on_warnings foo_target)
  target_compile_options(${foo_target} PRIVATE ${FOO_WARNING_FLAGS})
endmacro()