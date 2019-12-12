#!/bin/sh
set -euf -o pipefail

# autoconfigure if no custom config was mounted
if [ -f /etc/dnscrypt-proxy/.gen ]; then
  # copy config if missing
  cp -p /opt/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

  # set dnscrypt user
  sed -i "s/^# user_name = 'nobody'$/user_name = 'dnscrypt'/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

  # set listen address if set in env
  if [ -n "${DNSCRYPT_PROXY_LISTEN_ADDRESSES:-}" ]; then
    echo "configuring listen_addresses"
    sed -i "s/^listen_addresses = .*$/listen_addresses = ${DNSCRYPT_PROXY_LISTEN_ADDRESSES}/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi
  # set server_names if set in env
  if [ -n "${DNSCRYPT_PROXY_SERVER_NAMES:-}" ]; then
    echo "configuring server_names"
    sed -i "s/^# server_names = .*$/server_names  = ${DNSCRYPT_PROXY_SERVER_NAMES}/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi
  # set static server if set in env
  if [ -n "${DNSCRYPT_PROXY_STATIC:-}" ]; then
    echo "adding static server configurations"
    printf "\n%s\n" "${DNSCRYPT_PROXY_STATIC}" >>/etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi
fi

# set config permissions
chown -R 3000:3000 /etc/dnscrypt-proxy

# execute cmd
exec "${@}"
