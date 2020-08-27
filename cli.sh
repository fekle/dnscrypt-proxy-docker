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
SIMPLE_BLACKLIST_VERSION=release-3a087536bd073f877f4a849830d415df48ce1714

# build <arch> <tag suffix>
# builds the docker image for the given arch, appending the tag suffix to the tag if present
function build() {
  TAG_SUFFIX="${1:-}"

  # if LOCAL=true, copy to local docker instead of pushing
  if [[ ${LOCAL:-} == "true" ]]; then
    TYPE=docker
    docker_load() {
      docker load
    }
  else
    TYPE=image
    docker_load() {
      true
    }
  fi

  buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. \
    --output "type=${TYPE},\"name=${IMAGE_REF}:latest${TAG_SUFFIX},${IMAGE_REF}:${DNSCRYPT_PROXY_VERSION}${TAG_SUFFIX},${IMAGE_REF}:${DNSCRYPT_PROXY_SHORT_VERSION}${TAG_SUFFIX}\",push=true" \
    --opt "build-arg:DNSCRYPT_PROXY_ARCH=${DNSCRYPT_PROXY_ARCH}" \
    --opt "build-arg:DNSCRYPT_PROXY_VERSION=${DNSCRYPT_PROXY_VERSION}" \
    --opt "build-arg:SIMPLE_BLACKLIST_ARCH=${SIMPLE_BLACKLIST_ARCH}" \
    --opt "build-arg:SIMPLE_BLACKLIST_VERSION=${SIMPLE_BLACKLIST_VERSION}" | docker_load

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
  DNSCRYPT_PROXY_ARCH=linux_x86_64
  SIMPLE_BLACKLIST_ARCH=linux-amd64
  build
  ;;
build-rpi)
  arch_check aarch64
  DNSCRYPT_PROXY_ARCH=linux_arm64
  SIMPLE_BLACKLIST_ARCH=linux-arm64
  build -rpi
  ;;
build | build-all)
  ${0} build-x86
  ${0} build-rpi
  ;;
*)
  echo "usage: ${0} <build-x86|build-rpi|build-all>"
  ;;
esac
