# Docker Caddy Tailscale

This repository provides a Docker configuration for setting up a sidecar container that integrates Caddy and Tailscale. This combination allows secure and easy exposure of web services over a Tailscale network, utilizing Caddy for reverse proxy capabilities and automatic HTTPS.

## Description

Utilize this Docker container to simplify the process of exposing web services securely over a private Tailscale network. Caddy automatically manages SSL/TLS certificate issuance and renewal, ensuring your services remain secure without manual intervention.

## Use Cases

- **Secure Internal Services**: Perfect for internal tools that need to be accessible over the internet without exposure to the public network.
- **Development Environments**: Safely expose development servers to a controlled set of devices on your Tailscale network.

## Configurable Environment Variables

- `TS_VERBOSE`: Sets the verbosity level of Tailscale logs (0 for normal verbosity, higher numbers for more detailed logs).
- `TS_AUTH_KEY`: [TailScale OAuth key](https://login.tailscale.com/admin/settings/oauth) used to connect this service to your Tailscale network.
- `CADDY_PORT`: The port on which Caddy listens for HTTP requests, default is 8080.
- `XDG_CONFIG_HOME`: Defines the path for configuration files; defaults to /config.
- `XDG_DATA_HOME`: Defines the path for data files; defaults to /data.

## Getting Started

### Prerequisites

- Docker installed on your machine.
- A Tailscale account.

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
---
services:
  caddy:
    hostname: web # This will dictate the hostname on your Tailnet. Comment out to get a random 12 hexadecimal hostname.
    restart: unless-stopped
    build: .
    environment:
      CADDY_PORT: 8080
      TS_VERBOSE: 0
      TS_AUTH_KEY: '' # If not provided, an auth link will be output to the log - in that case set TS_VERBOSE to 1
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    # Configure 'networks' so that the sidecar container has access to the containers that need proxying
    # networks:
    #   - proxy-network

volumes:
  caddy_data:
  caddy_config:

# Configure 'networks' so that the sidecar container has access to the containers that need proxying
# networks:
#   proxy-network:
#     external: true
```

- Insert Tailscale Auth key in your `docker-compose.yaml` using TS_AUTH_KEY or place it in a `.env` file. (See: [TailScale OAuth clients](https://login.tailscale.com/admin/settings/oauth) and [Environment variables precedence in Docker Compose](https://docs.docker.com/compose/environment-variables/envvars-precedence/))
- Ensure that the sidecar container has access to the containers that need proxying by adding it to the same (Docker) network

### Running

To start the service, use:

```bash
docker-compose up -d
```

_note: If you are using a discrete Docker network (e.g. `proxy-network`) ensure that is was created using `docker network create proxy-network`_

This will pull the necessary image, configure your environment, and start the container detached.

## Contributing

Contributions are welcome! Please submit pull requests, or create issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
