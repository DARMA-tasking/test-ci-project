# This file enables to build and test this sample project using a DARMA/workflows generated docker image

# Path into the container to mount the current project directory
WORKSPACE=/workspace

# Available images from DARMA/workflows
# IMAGE=lifflander1/vt:wf-amd64-alpine-clang-13-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-icpc-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-icpx-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-18.04-gcc-8-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-10-openmpi-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-11-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-12-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-12-vtk-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-gcc-12-zoltan-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cuda-12.2.0-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cuda-11.2.2-cpp
IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-clang-9-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-clang-10-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-11-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-12-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-13-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-22.04-clang-14-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-24.04-clang-16-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-24.04-clang-16-vtk-cpp
# IMAGE=lifflander1/vt:wf-amd64-ubuntu-24.04-clang-16-zoltan-cpp

# Environment (.env) overrides
CCACHE_DIR="/tmp/cache/$TAG/ubuntu-cpp/foo/ccache" # similar path as in VT ci
# FOO_CLEAN=ON

sudo mkdir -p /opt/foo
sudo chown -R $(whoami) /opt/foo

# Command to run from inside the container
CMD='
    cd '$WORKSPACE'; \
    ls -l;
    chmod +x ./build.sh; \
    \
    ./build.sh'

# Use .env but override 
# - CCACHE_DIR to get usnique cache dir per tested image
# - FOO_CLEAN=0 to prevent build dir to be cleared as it contains also the ccache dir

TAG=$(echo "lifflander1/vt:wf-amd64-ubuntu-20.04-clang-9-cpp" | cut -d':' -f 2)

# create or recreate a container and run the build command.
docker rm foo-$TAG
docker run \
    --name foo-$TAG \
    --env-file ./.env \
    -w $WORKSPACE \
    -v .:/workspace \
    -v /opt/foo/build:/opt/foo/build \
    -v /opt/foo/output:/opt/foo/output \
    -e CI="1" \
    -e https_proxy="" \
    -e http_proxy="" \
    -e FOO_CLEAN=$FOO_CLEAN \
    -e CCACHE_DIR="$CCACHE_DIR" \
    -v $CCACHE_DIR:$CCACHE_DIR \
    $IMAGE \
    bash -c "$CMD"

# To test interactively run the following
# docker run \
#     -it \
#     --name test-container \
#     -w $WORKSPACE \
#     -v .:/workspace \
#     -v /opt/foo/build:/opt/foo/build \
#     -v /opt/foo/output:/opt/foo/output \
#     -e CI="1" \
#     -e https_proxy="" \
#     -e http_proxy="" \
#     $IMAGE \
