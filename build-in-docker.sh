# This file enables to build and test this sample project locally
# using a DARMA/workflows generated docker image

FOO_ENV_FILE=.env

# some variables we want to override
FOO_CLEAN=1

# Path into the container to mount the current project directory
WORKSPACE=/workspace

INTERACTIVE=1

# Image to use
# The list can be retrieved from the DARMA-tasking/workflows repository which has built these images
# @see https://raw.githubusercontent.com/DARMA-tasking/workflows/refs/heads/master/ci/shared/matrix/github.json
# IMAGE=lifflander1/vt:wf-amd64-alpine-clang-13-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-icpc-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-icpx-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-18.04-gcc-8-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-10-openmpi-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-11-cpp
IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-12-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-12-vtk-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-12-zoltan-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cuda-12.2.0-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cuda-11.2.2-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-clang-9-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-clang-10-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-11-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-12-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-13-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-14-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-24.04-clang-16-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-24.04-clang-16-vtk-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-24.04-clang-16-zoltan-cpp

TAG=$(echo $IMAGE | cut -d':' -f 2)

CURRENT_DIR="$(dirname $(realpath $0))"
PARENT_DIR="$(dirname "$CURRENT_DIR")"

# Directories to mount volumes.
# use subdirectories named using the image tag name.
HOST_SRC_DIR="${FOO_SRC_DIR:-$CURRENT_DIR}"
HOST_BUILD_DIR="${FOO_BUILD_DIR:-$CURRENT_DIR/build/$TAG}"
HOST_OUTPUT_DIR="${FOO_OUTPUT_DIR:-$CURRENT_DIR/output/$TAG}"
HOST_CCACHE_DIR="$FOO_HOST_BUILD_DIR/ccache/$TAG/ubuntu-cpp/foo/ccache"

# Command to run from inside the container
CMD='
    cd '$WORKSPACE'; \
    ls -l;
    chmod +x ./build.sh; \
    \
    ./build.sh'

# Create or recreate a container and run the build command.
docker rm foo-$TAG
docker run \
    --name foo-$TAG \
    --env-file $FOO_ENV_FILE \
    -w $WORKSPACE \
    -v .:/workspace \
    -v $HOST_BUILD_DIR:/opt/foo/build \
    -v $HOST_OUTPUT_DIR:/opt/foo/output \
    -e CI="0" \
    -e https_proxy="" \
    -e http_proxy="" \
    -e FOO_CLEAN=$FOO_CLEAN \
    -v $HOST_CCACHE_DIR:/opt/foo/ccache \
    $IMAGE \
    bash -c "$CMD"
