# dnscrypt-proxy-docker

[dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) in docker

## building

see `cli.sh`

## supported architectures
- amd64
- arm64
- armv7

## tags

- `latest, 2.x.x, 2` -> dnscrypt-proxy 2.0

## usage

docker-compose example:

```yaml
version: "2.4"
services:
  dnscrypt-proxy:
    image: fekle/dnscrypt-proxy:latest
    restart: always
    container_name: dnscrypt-proxy
    network_mode: host
    init: true
    ports:
      - 53:53/tcp
      - 53:53/udp
## config overrides
#    environment:
#      DNSCRYPT_PROXY_LISTEN_ADDRESSES: '["0.0.0.0:53"]'
#      DNSCRYPT_PROXY_SERVER_NAMES: '["your-server"]'
#      DNSCRYPT_BLACKLIST_URLS: https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
#      DNSCRYPT_BLACKLIST_UPDATE_HOURS: 3
#      DNSCRYPT_PROXY_STATIC: |
#        [static.'your-server']
#        stamp = 'sdns://your-server-stamp'
## custom dnscrypt-proxy config
#    volumes:
#      - /home/docker/dnscrypt-proxy/data/config:/etc/dnscrypt-proxy
```

### config overrides

The following environment variables may be used to configure dnscrypt-proxy

> Note: this only applies if no custom dnscrypt-proxy config is mounted

- `DNSCRYPT_PROXY_LISTEN_ADDRESSES`
  - override listen addresses, for example: `["0.0.0.0:53"]`
- `DNSCRYPT_PROXY_SERVER_NAMES`
  - override upstream server names, for example: `["my-server"]`
  - this can be used in conjunction with `DNSCRYPT_PROXY_STATIC`
- `DNSCRYPT_PROXY_STATIC`
  - add static configurations to dnscrypt-proxy config file, can be a multiline string with multiple static configs
- `DNSCRYPT_BLACKLIST_URLS`
  - comma separated list of urls to fetch blacklists from
- `DNSCRYPT_BLACKLIST_UPDATE_HOURS`
  - blacklist update interval in hours
  - by default this is disabled
  - if enabled, make sure to set `restart: true`, as the container will exit when the blacklist changes
- `DNSCRYPT_BLACKLIST`
  - path to custom blacklist file, does not work if `DNSCRYPT_BLACKLIST_URLS` is set

### specifying your own dnscrypt-proxy config

The container uses the example dnscrypt-proxy config by default, which should work fine for many applications.
If you want to specify your own DNSCrypt config, mount the directory containing `dnscrypt-proxy.toml` in `/etc/dnscrypt-proxy`, as shown in the docker-compose example above.

> If you specify your own config file, set `user_name = 'dnscrypt'`, and make sure that the config file is readable by UID/GID `3000`. This allows dnscrypt-proxy to drop privileges.
