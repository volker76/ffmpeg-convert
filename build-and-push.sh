#!/bin/bash

set -e

IMAGE="volkerhaensel/ffmpeg-convert"
VERSION="${1:-latest}"

echo "==> Prüfe Docker Login..."

if ! docker info 2>/dev/null | grep -q "Username:"; then
    echo "Nicht eingeloggt. Docker Login erforderlich."
    docker login
else
    echo "Docker Login vorhanden."
fi

echo "==> Baue Image ${IMAGE}:${VERSION}"
docker build -t ${IMAGE}:${VERSION} .

if [ "$VERSION" != "latest" ]; then
    echo "==> Setze zusätzlich latest Tag"
    docker tag ${IMAGE}:${VERSION} ${IMAGE}:latest
fi

echo "==> Push ${IMAGE}:${VERSION}"
docker push ${IMAGE}:${VERSION}

if [ "$VERSION" != "latest" ]; then
    echo "==> Push ${IMAGE}:latest"
    docker push ${IMAGE}:latest
fi

echo "==> Fertig."
