#!/usr/bin/env bash
set -euf -o pipefail
cd "$(dirname "${0}")"

IMAGE_REF="fekle/dnscrypt-proxy"

DNSCRYPT_PROXY_VERSION=2.0.35
DNSCRYPT_PROXY_SHORT_VERSION=2

function build() {
  buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. \
    --output "type=image,\"name=${IMAGE_REF}:latest${TAG_SUFFIX},${IMAGE_REF}:${DNSCRYPT_PROXY_VERSION}${TAG_SUFFIX},${IMAGE_REF}:${DNSCRYPT_PROXY_SHORT_VERSION}${TAG_SUFFIX}\",push=true" \
    --opt "build-arg:DNSCRYPT_PROXY_ARCH=${DNSCRYPT_PROXY_ARCH}" \
    --opt "build-arg:DNSCRYPT_PROXY_VERSION=${DNSCRYPT_PROXY_VERSION}"
}

case "${1:-}" in
build-x86)
  TAG_SUFFIX=""
  DNSCRYPT_PROXY_ARCH=linux_x86_64
  build
  ;;
build-rpi)
  TAG_SUFFIX="-rpi"
  DNSCRYPT_PROXY_ARCH=linux_arm64
  build
  ;;
build | build-all)
  ${0} build-x86
  ${0} build-rpi
  ;;
*)
  echo "usage: ${0} <build-x86|build-rpi|build-all>"
  ;;
esac
