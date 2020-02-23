#!/bin/bash
set -em

SNAP_ARCH=$1

docker run --net=host -d --rm -v "$(pwd)/packages:/data/packages" --name pypiserver pypiserver/pypiserver

PIP_SERVER_PID=$!

function cleanup() {
    docker rm --force pypiserver
}

trap cleanup EXIT

docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker run --rm --net=host -v $(pwd):$(pwd) -w $(pwd) -e "PIP_EXTRA_INDEX_URL=http://localhost:8080/simple" -t "builder:${SNAP_ARCH}" bash -c "apt-get update && snapcraft"
