#!/bin/bash

# Description: This script builds foo project and optionnaly run tests and coverage

set -e

# A function to convert a value (1,0, Yes, no etc.) to ON or OFF.
# If no value ON will be returned
function on_off() {
  case $1 in
    TRUE|true|True|ON|on|On|1|YES|yes|Yes|Y|y) echo "ON" ;;
    FALSE|false|False|OFF|off|Off|0|NO|no|No|N|n) echo "OFF" ;;
    "") echo "ON" ;;
    *) exit 2 ;; # not supported
   esac
}

# A function to determine the number of available processors
get_num_processors() {
    case "$(uname)" in
        Linux)
            nproc
            ;;
        Darwin)
            sysctl -n hw.ncpu
            ;;
        *)
            getconf _NPROCESSORS_ONLN
            ;;
    esac
}

CURRENT_DIR="$(dirname -- "$(realpath -- "$0")")"
PARENT_DIR="$(dirname "$CURRENT_DIR")"

CC="${CC:-$(which gcc || echo '')}"
CXX="${CXX:-$(which g++ || echo '')}"
GCOV="${GCOV:-$(which gcov || echo '')}"
FOO_SRC_DIR="${FOO_SRC_DIR:-$CURRENT_DIR}"
FOO_BUILD_DIR="${FOO_BUILD_DIR:-$CURRENT_DIR/build}"
FOO_OUTPUT_DIR="${FOO_OUTPUT_DIR:-$CURRENT_DIR/output}"
# >> Build settings
FOO_BUILD=$(on_off ${FOO_BUILD:-ON}) # option to turn off the build to only run tests
FOO_BUILD_TYPE=${FOO_BUILD_TYPE:-Release}
FOO_CMAKE_JOBS=${FOO_CMAKE_JOBS:-$(get_num_processors)}
FOO_TESTS_ENABLED=$(on_off ${FOO_TESTS_ENABLED:-ON})
FOO_TEST_REPORT=${FOO_TEST_REPORT:-"$FOO_OUTPUT_DIR/junit-report.xml"}
FOO_COVERAGE_ENABLED=$(on_off ${FOO_COVERAGE_ENABLED:-OFF})
FOO_CLEAN=$(on_off ${FOO_CLEAN:-ON})
FOO_WERROR_ENABLED=$(on_off ${FOO_WERROR_ENABLED:-OFF})
# >> Run tests settings
FOO_RUN_TESTS=$(on_off ${FOO_RUN_TESTS:-OFF})
FOO_RUN_TESTS_FILTER=${FOO_RUN_TESTS_FILTER:-""}
FOO_COVERAGE_REPORT=${FOO_COVERAGE_REPORT:-"${FOO_OUTPUT_DIR}/cov"}

# >> CLI args support

# # HELP FUNCTION
help() {
  cat <<EOF
  A script to build and test the foo library.
  Options can be passed as arguments or environment variables or both (CC, CXX and FOO_*).

  Usage: <[environment variables]> build.sh <[options]>
  Options:
      -c   --cc=[str]               The C compiler (CC=$CC)
      -x   --cxx=[str]              The C++ compiler (CXX=$CXX)

      -b   --build=[bool]           Build foo. Can be turned off for example to run tests without rebuilding. (FOO_BUILD=$FOO_BUILD)
      -d   --build-dir=[str]        Build directory (FOO_BUILD_DIR=$FOO_BUILD_DIR)
      -m   --build-type=[str]       Set the CMAKE_BUILD_TYPE value (Debug|Release|...) (FOO_BUILD_TYPE=$FOO_BUILD_TYPE)
      -y   --clean=[bool]           Clean the output directory and the CMake cache. (FOO_CLEAN=$FOO_CLEAN)

      -g   --coverage               Build with coverage support or enable coverage output (FOO_COVERAGE_ENABLED=$FOO_COVERAGE_ENABLED)
      -z   --coverage-report=[str]  Target path to generate coverage HTML report files (FOO_COVERAGE_REPORT=$FOO_COVERAGE_REPORT). Empty for no report.

      -j   --jobs=[int]             Number of processors to build (FOO_CMAKE_JOBS=$FOO_CMAKE_JOBS)
      -o   --output-dir=[str]       Output directory. Used to host lcov .info files. Also default to host junit report (FOO_OUTPUT_DIR=$FOO_OUTPUT_DIR).

      -t   --tests=[bool]           Build foo tests (FOO_TESTS_ENABLED=$FOO_TESTS_ENABLED)
      -a   --tests-report[str]      Unit tests Junit report path (FOO_TEST_REPORT=$FOO_TEST_REPORT). Empty for no report.
      -r   --tests-run=[bool]       Run unit tests (and build coverage report if coverage is enabled) (FOO_RUN_TESTS=$FOO_RUN_TESTS)
      -f   --tests-run-filter=[str] Filter unit test to run. (FOO_RUN_TESTS_FILTER=$FOO_RUN_TESTS_FILTER)

      -h   --help                   Show help and default option values.

  Examples:
      Using environment variables:
        Build & run tests:          FOO_RUN_TESTS=ON FOO_COVERAGE_ENABLED=ON build.sh
        Build with coverage:        FOO_TESTS_ENABLED=ON FOO_COVERAGE_ENABLED=ON build.sh
        Build (debug):              FOO_BUILD_TYPE=Debug build.sh
        Test:                       FOO_BUILD=OFF FOO_RUN_TESTS=ON build.sh
        Run Test & coverage:        FOO_BUILD=OFF FOO_COVERAGE_ENABLED=ON FOO_COVERAGE_REPORT=output FOO_RUN_TESTS=ON build.sh

      Using arguments:
        Build & Run tests:          build.sh --tests-run --coverage
        Build with coverage:        build.sh --coverage
        Build (debug):              build.sh --build-type=Debug
        Run Test & coverage:        build.sh --build=0 --tests-run --coverage --coverage-report=output/lcov-report
        Coverage report only:       build.sh --build=0 --coverage-report=output/lcov-report

      Using both:
        Build with coverage & run tests: FOO_COVERAGE=ON build.sh --tests-run
EOF
  exit 1;
}

while getopts btch-: OPT; do  # allow -b -t -c -h, and --long_attr=value"
  # support long options: https://stackoverflow.com/a/28466267/519360
  if [ "$OPT" == "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$OPT" in
    b | build )           FOO_BUILD=$(on_off $OPTARG) ;;
    d | build-dir )       FOO_BUILD_DIR=$(realpath "$OPTARG") ;;
    m | build-type)       FOO_BUILD_TYPE=$(on_off $OPTARG) ;;
    c | cc)               CC="$OPTARG" ;;
    x | cxx)              CXX="$OPTARG" ;;
    y | clean)            FOO_CLEAN=$(on_off $OPTARG) ;;
    g | coverage)         FOO_COVERAGE_ENABLED=$(on_off $OPTARG) ;;
    z | coverage-report)  FOO_COVERAGE_REPORT=$(realpath -q "$OPTARG") ;;
    j | jobs)             FOO_CMAKE_JOBS=$OPTARG ;;
    o | output-dir )      FOO_OUTPUT_DIR=$(realpath "$OPTARG") ;;
    t | tests)            FOO_TESTS_ENABLED=$(on_off $OPTARG) ;;
    a | tests-report)     FOO_TEST_REPORT=$(realpath -q "$OPTARG") ;;
    r | tests-run )       FOO_RUN_TESTS=$(on_off $OPTARG) ;;
    f | tests-run-filter) FOO_RUN_TESTS_FILTER="$OPTARG" ;;
    h | help )            help ;;

    \? )           exit 2 ;;  # bad short option (error reported via getopts)
    * )            echo "Illegal option --$OPT";  exit 2 ;; # bad long option
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list

# !! CLI args support

echo "Computed build options:"
echo PATH=$PATH
echo FOO_CLEAN=$FOO_CLEAN
echo FOO_OUTPUT_DIR=$FOO_OUTPUT_DIR
echo FOO_BUILD_DIR=$FOO_BUILD_DIR
echo FOO_BUILD_TYPE=$FOO_BUILD_TYPE
echo FOO_RUN_TESTS=$FOO_RUN_TESTS
echo FOO_WERROR_ENABLED=$FOO_WERROR_ENABLED
echo FOO_TESTS_ENABLED=$FOO_TESTS_ENABLED
echo FOO_TEST_REPORT=$FOO_TEST_REPORT
echo FOO_RUN_TESTS_FILTER=$FOO_RUN_TESTS_FILTER
echo FOO_COVERAGE_ENABLED=$FOO_COVERAGE_ENABLED
echo FOO_COVERAGE_REPORT=$FOO_COVERAGE_REPORT
echo CC=$CC
echo CXX=$CXX
echo GCOV=$GCOV
echo DISPLAY=$DISPLAY

# Build
if [[ "${FOO_BUILD}" == "ON" ]]; then
  if [[ "${FOO_CLEAN}" == "ON" ]]; then
    echo "> Cleaning"
    if [ -f "CMakeCache.txt" ]; then
      # Remove CMakeCache for fresh build
      rm -rf CMakeCache.txt
    fi
    if [ -d "${FOO_BUILD_DIR}" ]; then
      rm -rf ${FOO_BUILD_DIR}/* # empty the build directory
    fi
  fi

  mkdir -p ${FOO_BUILD_DIR}
  pushd ${FOO_BUILD_DIR}

  echo "> Building (CMake|${FOO_BUILD_TYPE})..."
  cmake -B "${FOO_BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE:STRING=${FOO_BUILD_TYPE} \
    \
    -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    \
    -DFOO_WERROR_ENABLED="${FOO_WERROR_ENABLED}" \
    \
    -DBUILD_TESTING=${FOO_TESTS_ENABLED} \
    -DFOO_TESTS_ENABLED=${FOO_TESTS_ENABLED} \
    -DFOO_COVERAGE_ENABLED=${FOO_COVERAGE_ENABLED} \
    \
    "${FOO_SRC_DIR}"

  time cmake --build . --parallel -j "${FOO_CMAKE_JOBS}"

  popd

fi # End build

# Run tests
if [ "$FOO_RUN_TESTS" == "ON" ]; then
  mkdir -p "$FOO_OUTPUT_DIR"
  pushd $FOO_OUTPUT_DIR
  # Tests
  echo "> Running tests..."
  # Run GTest unit tests and display detail for failing tests
  GTEST_OPTIONS=""
  if [ "$FOO_TEST_REPORT" != "" ]; then
    echo "Generating JUnit report..."
    GTEST_OPTIONS="$GTEST_OPTIONS --gtest_output=\"xml:$FOO_TEST_REPORT\""
  fi
  if [ "$FOO_RUN_TESTS_FILTER" != "" ]; then
    echo "Filtering Tests ($FOO_RUN_TESTS_FILTER)..."
    GTEST_OPTIONS="$GTEST_OPTIONS --gtest_filter=\"$FOO_RUN_TESTS_FILTER\""
  fi

  gtest_cmd="\"$FOO_BUILD_DIR/tests/UnitTests\" $GTEST_OPTIONS"
  echo "Run GTest..."
  eval "$gtest_cmd" || true
  echo "Tests done."

  popd
fi

# Coverage
if [ "$FOO_COVERAGE_ENABLED" == "ON" ]; then
  mkdir -p "$FOO_OUTPUT_DIR"
  pushd $FOO_OUTPUT_DIR
  # base coverage files
  echo "lcov capture:"
  lcov --capture --directory $FOO_BUILD_DIR --output-file lcov_foo_test.info --gcov-tool $GCOV
  lcov --remove lcov_foo_test.info -o lcov_foo_test_no_deps.info '*/lib/*'
  lcov --list lcov_foo_test_no_deps.info
  # optional coverage html report
  if [ "$FOO_COVERAGE_REPORT" != "" ]; then
    genhtml --prefix ./src --ignore-errors source lcov_foo_test_no_deps.info --legend --title "$(git rev-parse HEAD)" --output-directory="$FOO_COVERAGE_REPORT"
  fi
  popd
fi