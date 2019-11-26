#!/bin/bash
set -em

SNAP_ARCH=$1

docker run --net=host --rm -v "$(pwd)/packages:/data/packages" --name pypiserver pypiserver/pypiserver &

PIP_SERVER_PID=$!

function cleanup() {
    docker rm -s pypiserver
}

trap cleanup EXIT

docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker run --rm --net=host -v $(pwd):$(pwd) -w $(pwd) -e "PIP_EXTRA_INDEX_URL=http://localhost:8080/simple/" -t "adferrand/snapcraft:${SNAP_ARCH}" snapcraft --destructive-mode
