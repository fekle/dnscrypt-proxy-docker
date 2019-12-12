FROM alpine:3 as build

# get dnscrypt binary from github releases (see https://github.com/DNSCrypt/dnscrypt-proxy/releases)
ARG DNSCRYPT_PROXY_VERSION
ARG DNSCRYPT_PROXY_ARCH
RUN wget -O- -q "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-${DNSCRYPT_PROXY_ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz" \
    | tar x -z -f- -C /tmp && mv /tmp/* /tmp/dnscrypt-proxy

FROM alpine:3

# add dnscrypt user and group as well as create config dir
RUN addgroup -S -g 3000 dnscrypt && adduser -S -G dnscrypt -u 3000 dnscrypt && \
    mkdir -p /etc/dnscrypt-proxy && chown -R 3000:3000 /etc/dnscrypt-proxy && touch /etc/dnscrypt-proxy/.gen

# copy dnscrypt files
COPY --from=build --chown=3000:3000 /tmp/dnscrypt-proxy /opt/dnscrypt-proxy

# copy entrypoint
COPY entrypoint.sh /usr/local/bin/docker-entrypoint

EXPOSE 53
VOLUME /etc/dnscrypt-proxy

WORKDIR /opt/dnscrypt-proxy
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
