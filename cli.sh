#!/usr/bin/env bash
set -euf -o pipefail

# ensure that we are in the correct dir
cd "$(dirname "${0}")"

# base image ref
IMAGE_REF="fekle/dnscrypt-proxy"

# dnscrypt proxy version (see https://github.com/DNSCrypt/dnscrypt-proxy/releases)
DNSCRYPT_PROXY_VERSION=2.0.44
DNSCRYPT_PROXY_SHORT_VERSION=2

# simple-blacklist version
SIMPLE_BLACKLIST_VERSION=release-24c1376d977708f6d5ad6c148fb5ca76ae747764

# cli
case "${1:-}" in
build)
  docker buildx build \
    -t "${IMAGE_REF}:latest" \
    -t "${IMAGE_REF}:${DNSCRYPT_PROXY_VERSION}" \
    -t "${IMAGE_REF}:${DNSCRYPT_PROXY_SHORT_VERSION}" \
    --build-arg "DNSCRYPT_PROXY_VERSION=${DNSCRYPT_PROXY_VERSION}" \
    --build-arg "SIMPLE_BLACKLIST_VERSION=${SIMPLE_BLACKLIST_VERSION}" \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --pull --push \
    -f Dockerfile .
  ;;
*)
  echo "usage: ${0} <build>"
  ;;
esac
