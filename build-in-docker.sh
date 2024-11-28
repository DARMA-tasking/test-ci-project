WORKSPACE=/workspace
IMAGE=lifflander1/vt:wf-amd64-ubuntu-20.04-gcc-9-cuda-11.2.2-cpp

CMD='
    cd '$WORKSPACE'; \
    ls -l;
    chmod +x ./build.sh; \
    \
    export $(cat .env | egrep -v "(^#.*|^$)" | xargs) && ./build.sh'

docker run \
      --name test-container \
      -w $WORKSPACE \
      -v .:/workspace \
      -v /opt/foo/build:/opt/foo/build \
      -v /opt/foo/output:/opt/foo/output \
      -e CI="1" \
      -e https_proxy="" \
      -e http_proxy="" \
      $IMAGE \
      bash -c "$CMD"