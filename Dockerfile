FROM caddy:2.7.6-builder as builder

ENV XCADDY_SETCAP 0

# Install additional plugins/modules
RUN xcaddy build v2.7.6
#    --with github.com/mholt/caddy-webdav
#    --with github.com/greenpau/caddy-security
#    --with --with github.com/mholt/caddy-l4/layer4

FROM tailscale/tailscale:stable

RUN set -eux; \
    mkdir -p \
            /config/tailscale \
            /usr/share/caddy \
            /etc/caddy; \
    wget -O /usr/share/caddy/index.html "https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html"

ENV TS_VERBOSE 0
ENV TS_AUTH_KEY ''
ENV CADDY_PORT 8080

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY ./entrypoint.sh /entrypoint.sh

COPY Caddyfile /etc/caddy/Caddyfile

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

WORKDIR /srv

CMD ["sh", "/entrypoint.sh"]
