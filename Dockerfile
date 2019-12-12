FROM alpine:3 as build

ARG DNSCRYPT_PROXY_VERSION
ARG DNSCRYPT_PROXY_ARCH
RUN wget -O- -q "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-${DNSCRYPT_PROXY_ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz" \
    | tar x -z -f- -C /tmp && mv /tmp/* /tmp/dnscrypt-proxy

FROM alpine:3
RUN addgroup -S -g 3000 dnscrypt && adduser -S -u 3000 dnscrypt

COPY --from=build --chown=3000:3000 /tmp/dnscrypt-proxy /opt/dnscrypt-proxy
COPY --from=build --chown=3000:3000 /tmp/dnscrypt-proxy/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

EXPOSE 53
WORKDIR /opt/dnscrypt-proxy
CMD ["/opt/dnscrypt-proxy/dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
