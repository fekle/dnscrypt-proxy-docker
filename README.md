# dnscrypt-proxy-docker
DNSCrypt Proxy in Docker

## building
see `cli.sh`

## tags
`latest, 2.x.x, 2` -> dnscrypt-proxy 2.0, x86
`latest-rpi, 2.x.x-rpi, 2-rpi` -> dnscrypt-proxy 2.0, arm64 (for raspberry pi)

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
    ulimits:
      nofile:
        soft: 90000
        hard: 90000
## custom dnscrypt-proxy config
#    volumes:
#      - /home/docker/dnscrypt-proxy/data/config:/etc/dnscrypt-proxy
```

## specifying your own dnscrypt config
The container uses the example dnscrypt-proxy config by default, which should work fine for many applications.
If you want to specify your own DNSCrypt config, mount the directory containing `dnscrypt-proxy.toml` in `/etc/dnscrypt-proxy`, as shown in the docker-compose example above.
