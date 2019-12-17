FROM alpine:3 as build

# get dnscrypt binary from github releases (see https://github.com/DNSCrypt/dnscrypt-proxy/releases)
ARG DNSCRYPT_PROXY_VERSION
ARG DNSCRYPT_PROXY_ARCH
RUN wget -O- -q "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-${DNSCRYPT_PROXY_ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz" \
    | tar x -z -f- -C /tmp && mv /tmp/* /tmp/dnscrypt-proxy

# install simple-blacklist binary
ARG SIMPLE_BLACKLIST_VERSION
ARG SIMPLE_BLACKLIST_ARCH
RUN wget -O- "https://github.com/fekle/simple-blacklist/releases/download/${SIMPLE_BLACKLIST_VERSION}/simple-blacklist-${SIMPLE_BLACKLIST_ARCH}.gz" | \
    gunzip > /usr/local/bin/simple-blacklist && chmod 0755 /usr/local/bin/simple-blacklist

FROM alpine:3

# install dependencies, add dnscrypt user and group and create config dir
RUN apk add --no-cache ca-certificates && \
    addgroup -S -g 3000 dnscrypt && adduser -S -G dnscrypt -u 3000 dnscrypt

# copy simple-blacklist binary
COPY --from=build /usr/local/bin/simple-blacklist /usr/local/bin/simple-blacklist

# copy dnscrypt files
COPY --from=build --chown=3000:3000 /tmp/dnscrypt-proxy /opt/dnscrypt-proxy

# copy entrypoint
COPY entrypoint.sh /usr/local/bin/docker-entrypoint

EXPOSE 53
VOLUME /etc/dnscrypt-proxy

WORKDIR /opt/dnscrypt-proxy
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
