#!/bin/sh
set -euf

# determine correct arch names for given target platform
case "${TARGETPLATFORM}" in
"linux/amd64")
  export DNSCRYPT_PROXY_ARCH=linux_x86_64
  export SIMPLE_BLACKLIST_ARCH=linux-amd64
  ;;
"linux/arm64")
  export DNSCRYPT_PROXY_ARCH=linux_arm64
  export SIMPLE_BLACKLIST_ARCH=linux-arm64
  ;;
"linux/arm/v7")
  export DNSCRYPT_PROXY_ARCH=linux_arm
  export SIMPLE_BLACKLIST_ARCH=linux-arm
  ;;
*)
  echo "invalid TARGETPLATFORM: ${TARGETPLATFORM}"
  exit 1
  ;;
esac

# dirty hack to return requested variable
eval 'printf ${'"${1}"'}'
