# Stage 1: Build Caddy with custom modules
FROM caddy:2.8.4-builder as builder

# Disable setcap for xcaddy build
ENV XCADDY_SETCAP 0

# Build Caddy v2.8.4 with xcaddy
# Uncomment and add any additional modules as needed
RUN xcaddy build v2.8.4
#    --with github.com/mholt/caddy-webdav
#    --with github.com/greenpau/caddy-security
#    --with --with github.com/mholt/caddy-l4/layer4

# Stage 2: Create the final image
FROM tailscale/tailscale:stable

# Set up the directory structure and download the default Caddy welcome page
RUN set -eux; \
    mkdir -p \
            /config/tailscale \
            /usr/share/caddy \
            /etc/caddy; \
    wget -O /usr/share/caddy/index.html "https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html"

# Set environment variables for Tailscale
ENV TS_PORT 80
ENV TS_VERBOSE 0
ENV TS_AUTH_KEY ''

# Set XDG environment variables for application data
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

# Copy the custom-built Caddy binary from the builder stage
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Copy the entrypoint script into the container
COPY ./entrypoint.sh /entrypoint.sh

# Copy the Caddyfile configuration into the container
COPY Caddyfile /etc/caddy/Caddyfile

# Set the working directory to /srv
WORKDIR /srv

# Set the entrypoint script as the container's entrypoint
CMD ["sh", "/entrypoint.sh"]
