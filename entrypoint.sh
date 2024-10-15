#!/bin/sh

# Enable strict mode:
# - e: Exit immediately if a command exits with a non-zero status.
# - u: Treat unset variables as an error when substituting.
# - x: Print commands and their arguments as they are executed.
set -eux

# Start the Tailscale daemon in the background:
# - --tun=userspace-networking: Use userspace networking instead of creating a tun device.
# - --statedir=/config/tailscale: Specify the directory to store Tailscale state.
tailscaled --tun=userspace-networking --statedir=/config/tailscale &

# Authenticate and connect to the Tailscale network:
# - --authkey=${TS_AUTH_KEY}: Use the provided authentication key to connect.
# Split TS_EXTRA_ARGS on whitespace and pass as additional arguments
tailscale up --authkey="${TS_AUTH_KEY}" ${TS_EXTRA_ARGS}

# Set up Tailscale to serve HTTP(S) traffic:
# - --bg: Run in the background.
# - ${CADDY_PORT:-8080}: Use the CADDY_PORT environment variable if set, otherwise default to 8080.
tailscale serve --bg ${CADDY_PORT:-8080}

# Start the Caddy web server:
# - run: Run the Caddy server.
# - --config /etc/caddy/Caddyfile: Specify the location of the Caddyfile configuration.
# - --adapter caddyfile: Use the Caddyfile adapter to parse the configuration.
caddy run \
    --config /etc/caddy/Caddyfile \
    --adapter caddyfile
