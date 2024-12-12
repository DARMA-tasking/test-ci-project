# This file enables to build and test this sample project using a DARMA/workflows generated docker image

WORKSPACE=/workspace

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


CMD='
    cd '$WORKSPACE'; \
    nvcc --version; \
    ls -l;
    chmod +x ./build.sh; \
    \
    export $(cat .env | egrep -v "(^#.*|^$)" | xargs) && ./build.sh'

# in host: volume for build dir should be /tmp/cache/amd64-ubuntu-22.04-gcc-12-gcc-12-cache/ubuntu-cpp (example from VT)

# docker run \
#       --name test-container \
#       -w $WORKSPACE \
#       -v .:/workspace \
#       -v /opt/foo/build:/opt/foo/build \
#       -v /opt/foo/output:/opt/foo/output \
#       -e CI="1" \
#       -e https_proxy="" \
#       -e http_proxy="" \
#       $IMAGE \
#       bash -c "$CMD"

docker run \
    -it \
    --name test-container \
    -w $WORKSPACE \
    -v .:/workspace \
    -v /opt/foo/build:/opt/foo/build \
    -v /opt/foo/output:/opt/foo/output \
    -e CI="1" \
    -e https_proxy="" \
    -e http_proxy="" \
    $IMAGE \
