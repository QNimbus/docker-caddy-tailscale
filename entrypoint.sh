#!/bin/sh

set -eux

tailscaled --tun=userspace-networking --statedir=/config/tailscale &
tailscale up --authkey=${TS_AUTH_KEY}
tailscale serve --bg ${CADDY_PORT:-8080}

caddy run \
    --config /etc/caddy/Caddyfile \
    --adapter caddyfile
