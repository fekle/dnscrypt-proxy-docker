#!/bin/sh
set -euf

info() {
  printf "> %s\n" "${@}"
}

update_cron() {
  info "started blacklist update cron, updating every ${DNSCRYPT_BLACKLIST_UPDATE_HOURS} hours"
  while true; do
    sleep "$((DNSCRYPT_BLACKLIST_UPDATE_HOURS * 3600))"
    info "updating blacklist ..."
    load_blacklists cron
  done
}

load_blacklists() {
  BLACKLIST_TMP_FILE="$(mktemp)"

  /usr/local/bin/simple-blacklist -u "${DNSCRYPT_BLACKLIST_URLS}" -o "${BLACKLIST_TMP_FILE}" -e '='

  info "blacklists loaded, $(wc -l <"${BLACKLIST_TMP_FILE}") domains found"

  if ! cmp -s /etc/dnscrypt-proxy/blacklist.txt "${BLACKLIST_TMP_FILE}"; then
    cp -f "${BLACKLIST_TMP_FILE}" /etc/dnscrypt-proxy/blacklist.txt

    if [ "${1:-}" = "cron" ]; then
      info "blacklist changed, restarting..."
      kill -TERM "${PID}"
    fi
  else
    if [ "${1:-}" = "cron" ]; then
      info "blacklist not changed"
    fi
  fi

  rm "${BLACKLIST_TMP_FILE}"
}

# autoconfigure if no custom config was mounted
if [ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ] || [ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml.gen ]; then
  # set gen flag
  if [ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml.gen ]; then
    echo "# delete this file if you want to edit dnscrypt-proxy.toml manually" >/etc/dnscrypt-proxy/dnscrypt-proxy.toml.gen
  fi

  # copy config
  cp -p /opt/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

  # set dnscrypt user
  sed -i "s/^# user_name = 'nobody'$/user_name = 'dnscrypt'/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

  # set listen address if set in env
  if [ -n "${DNSCRYPT_PROXY_LISTEN_ADDRESSES:-}" ]; then
    info "configuring listen_addresses ..."
    sed -i "s/^listen_addresses = .*$/listen_addresses = ${DNSCRYPT_PROXY_LISTEN_ADDRESSES}/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi
  # set server_names if set in env
  if [ -n "${DNSCRYPT_PROXY_SERVER_NAMES:-}" ]; then
    info "configuring server_names ..."
    sed -i "s/^# server_names = .*$/server_names  = ${DNSCRYPT_PROXY_SERVER_NAMES}/g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi

  # load blacklists
  if [ -n "${DNSCRYPT_BLACKLIST_URLS:-}" ]; then
    info "loading blacklists ..."

    DNSCRYPT_BLACKLIST=/etc/dnscrypt-proxy/blacklist.txt
    export DNSCRYPT_BLACKLIST

    load_blacklists
  fi

  # set blacklist if set in env
  if [ -n "${DNSCRYPT_BLACKLIST:-}" ]; then
    info "configuring blacklist ..."
    sed -i "s;^  # blacklist_file = 'blacklist.txt'$;  blacklist_file = '${DNSCRYPT_BLACKLIST}';g" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi
  # set static server if set in env
  if [ -n "${DNSCRYPT_PROXY_STATIC:-}" ]; then
    info "adding static server configurations ..."
    printf "\n%s\n" "${DNSCRYPT_PROXY_STATIC}" >>/etc/dnscrypt-proxy/dnscrypt-proxy.toml
  fi
fi

# set config permissions
info "ensuring permissions ..."
chown -R 3000:3000 /etc/dnscrypt-proxy

# start command
eval "${@}" &
PID=$!
export PID

# start update_cron if enabled
if [ -n "${DNSCRYPT_BLACKLIST_URLS:-}" ] && [ -n "${DNSCRYPT_BLACKLIST_UPDATE_HOURS:-}" ]; then
  update_cron &
fi

# wait for exit
wait "${PID}"
sleep .1
exit 0
