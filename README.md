# tailscale-relay

This is a docker image based on `alpine:3` for setting up a [tailscale](https://tailscale.com) instance in relay mode and exit node.

## Prerequisites

- Defined docker network via `docker network create -d bridge <network name>`
- Subnet network via `docker inspect <NETWORK ID> | grep Subnet`
- If you want, you can add multiple subnets using comma to seperate, eg. 172.23.0.0/16, 10.0.0.0/24
- Auth key from https://login.tailscale.com/admin/authkeys (e.g. `tskey-123abc...`)

## Requirements

- `--cap-add=NET_ADMIN`
- Volume for persistent storage `/tailscale`

## Use

Run the following `docker run` command.

- `AUTHKEY=tskey-123abc...`
- `ROUTES=172.31.0.0/16`

```bash
docker run -d \
    -v /tailscale \
    --cap-add=NET_ADMIN \
    --network=<docker_net> \
    -e "ROUTES=<docker_network>" \
    -e "AUTHKEY=<your_auth_key>" \
    ido1990/tailscale-docker:latest
```

**This version should pull the lastest version of Tailscale for every deployment.**
**You can use [Watchtower](https://github.com/containrrr/watchtower) to keep Tailscale updated.**

Find this image on [Docker Hub](https://hub.docker.com/r/ido1990/tailscale-docker)
