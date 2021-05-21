# Pritunl Docker Container (amd64, arm64)

---

## Description

Pritunl container built on Alpine Linux. Supports IPv6 and running behind a reverse proxy. This container requires an external Mongo DB and should be run via Docker Compose or other orchestration.

---

## Usage

This container exposes the following five ports:
* `80/tcp` pritunl web server http port (standalone mode)
* `443/tcp` pritunl web server https port (standalone and wireguard reverse-proxy mode)
* `1194/tcp` pritunl VPN service port
* `1194/tcp` pritunl OpenVPN service port
* `1195/udp` pritunl wireguard service port - No default in app, this is a suggestion only.
* `9700/tcp` pritunl web server http port (non-wireguard reverse-proxy mode)

---

**Basic docker-compose.yml to launch a Mongo DB container instance, pritunl in standalone mode, and make the web and VPN ports accessible**

```bash
version: '3'

services:
  ddclient:
    image: ghcr.io/omegion/ddclient:latest-arm
    container_name: ddclient
    network_mode: bridge
    privileged: true
    restart: always
    command: >
      set --record=${RECORD} --zone=${ZONE} --dns-provider=cloudflare --logLevel debug --daemon
    environment:
      - CF_API_KEY
      - RECORD
      - ZONE

  mongo:
    image: mongo:latest
    container_name: pritunldb
    hostname: pritunldb
    network_mode: bridge
    restart: always
    volumes:
      - ./db:/data/db

  pritunl:
    image: omegion/pritunl:latest
    container_name: pritunl
    hostname: pritunl
    depends_on:
      - mongo
    network_mode: bridge
    privileged: true
    restart: always
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
    links:
      - mongo
    volumes:
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 80:80
      - 443:443
      - 1194:1194
      - 1194:1194/udp
      - 1195:1195/udp
    environment:
      - TZ=UTC
```

**Environment variables:**

| Variable | Default | Description |
| :--- | :---: | --- |
| `DEBUG` | ***false*** | Set to *true* for extra entrypoint script verbosity for debugging |
| `MONGODB_URI` | ***mongodb://mongo:27017/pritunl*** | Sets the URI Pritunl will access for the Mongo DB instance |
| `PRITUNL_OPTS` | ***unset*** | Any additional custom run options for the container pritunl process

