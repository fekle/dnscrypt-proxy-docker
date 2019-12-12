# dnscrypt-proxy-docker
DNSCrypt Proxy in Docker

## building
see `cli.sh`

## usage
docker-compose example:
```yaml
version: "2.4"
services:
  dnscrypt-proxy:
    image: fekle/dnscrypt-proxy:latest-rpi
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
    volumes:
      - /home/docker/dnscrypt-proxy/data/config:/etc/dnscrypt-proxy
```
