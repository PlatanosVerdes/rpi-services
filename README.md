# rpi-services

Personal services running on my Raspberry Pi home server. This is the personal counterpart to [rpi-homeserver](https://github.com/PlatanosVerdes/rpi-homeserver), which handles the core infrastructure (Caddy, Pi-hole, monitoring, media stack) and is meant to be clonable by anyone. Everything specific to me lives here instead, so that repo stays generic.

Both repos are deployed by `rpi-homeserver/scripts/apply.sh` (webhook on push, cron every 30 min as fallback) and follow the same conventions: versions in a committed `versions.env`, no `:latest`, one shared host crontab.

## Services

| Service | Profile | Description |
| :--- | :--- | :--- |
| `cal-bridge` | `cal`, `all` | Google Calendar + Microsoft API bridge for an ESP32 display |
| `pol-academy-offers-bot` | `bot`, `all` | Telegram bot for Pol Ferrer Academy offers |
| `one-pace-downloader` | `one-pace` | One-shot downloader for One Pace episodes |
| `anisette` | `airtag`, `all` | Self-hosted Apple auth (anisette) server used by air-tag |
| `air-tag` | `airtag`, `all` | AirTag location tracker + private Leaflet map (see [air-tag repo](https://github.com/PlatanosVerdes/air-tag)) |

## Setup

### Prerequisites

A running instance of [rpi-homeserver](https://github.com/PlatanosVerdes/rpi-homeserver) with the `media-network` Docker network already created.

### 1. Clone and configure

```bash
git clone https://github.com/PlatanosVerdes/rpi-services.git ~/rpi-services
cp ~/rpi-services/.env.example ~/rpi-services/.env
# Fill in secrets in .env
```

### 2. Link Caddy routes

Point rpi-homeserver at this repo's Caddy config by adding one line to **its** `.env`:

```bash
EXT_CADDY_PATH=/home/raspi/rpi-services/config/caddy
```

Caddy mounts it at `/etc/caddy/ext-services` and auto-imports every `*.caddy` in it, so HTTPS
routes are added here without touching the main repo. Restart Caddy once after setting it.

### 3. Run

App versions live in `versions.env`, so compose needs both env files. `apply.sh` sets this
automatically; to run compose by hand, export it first or the `${..._VERSION}` refs resolve empty:

```bash
export COMPOSE_ENV_FILES=versions.env,.env
docker compose up -d
```

Use `COMPOSE_PROFILES` in `.env` to select which services to start (e.g. `COMPOSE_PROFILES=cal,bot`).

### One-off services

```bash
export COMPOSE_ENV_FILES=versions.env,.env
# Download One Pace episodes
docker compose run --rm one-pace-downloader
```
