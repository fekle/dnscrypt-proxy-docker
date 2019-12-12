#!/usr/bin/env bash
set -euf -o pipefail

# ensure that we are in the correct dir
cd "$(dirname "${0}")"

# base image ref
IMAGE_REF="fekle/dnscrypt-proxy"

# dnscrypt proxy version (see https://github.com/DNSCrypt/dnscrypt-proxy/releases)
DNSCRYPT_PROXY_VERSION=2.0.35
DNSCRYPT_PROXY_SHORT_VERSION=2

# build <arch> <tag suffix>
# builds the docker image for the given arch, appending the tag suffix to the tag if present
function build() {
  DNSCRYPT_PROXY_ARCH="${1}"
  TAG_SUFFIX="${2:-}"
  buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. \
    --output "type=image,\"name=${IMAGE_REF}:latest${TAG_SUFFIX},${IMAGE_REF}:${DNSCRYPT_PROXY_VERSION}${TAG_SUFFIX},${IMAGE_REF}:${DNSCRYPT_PROXY_SHORT_VERSION}${TAG_SUFFIX}\",push=true" \
    --opt "build-arg:DNSCRYPT_PROXY_ARCH=${DNSCRYPT_PROXY_ARCH}" \
    --opt "build-arg:DNSCRYPT_PROXY_VERSION=${DNSCRYPT_PROXY_VERSION}"
}

# arch check <arch>
# ensures that corresponding images are only build on the correct architecture
function arch_check() {
  arch="$(uname -p)"
  if [[ ${arch} != "${1}" ]]; then
    echo "wrong architecture. required: ${1}, current: ${arch}"
    exit 1
  fi
}

# cli
case "${1:-}" in
build-x86)
  arch_check x86_64
  build linux_x86_64
  ;;
build-rpi)
  arch_check aarch64
  build linux_arm64 -rpi
  ;;
build | build-all)
  ${0} build-x86
  ${0} build-rpi
  ;;
*)
  echo "usage: ${0} <build-x86|build-rpi|build-all>"
  ;;
esac
