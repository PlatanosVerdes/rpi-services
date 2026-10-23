# rpi-services

Personal services running on my Raspberry Pi home server. This is the personal counterpart to [rpi-homeserver](https://github.com/PlatanosVerdes/rpi-homeserver), which handles the core infrastructure (Caddy, Pi-hole, monitoring, media stack) and is meant to be clonable by anyone. Everything specific to me lives here instead, so that repo stays generic.

Both repos are deployed by `rpi-homeserver/scripts/apply.sh` (webhook on push, cron every 30 min as fallback) and follow the same conventions: versions in a committed `versions.env`, no `:latest`, one shared host crontab.

## Services

| Service | Profile | Description |
| :--- | :--- | :--- |
| `pol-academy-offers-bot` | `bot`, `all` | Telegram bot for Pol Ferrer Academy offers |
| `one-pace-downloader` | `one-pace` | One-shot downloader for One Pace episodes (see [one-pace-downloader repo](https://github.com/PlatanosVerdes/one-pace-downloader)) |
| `laliga-fantasy` | `fantasy`, `all` | LaLiga Fantasy decision panel (see [laliga-fantasy repo](https://github.com/PlatanosVerdes/laliga-fantasy)) |
| `wallabot` | `wallapop`, `all` | Public Telegram bot, [@WuallaBot](https://t.me/WuallaBot), that announces what is new in each chat's Wallapop searches (see [wallabot repo](https://github.com/PlatanosVerdes/wallabot)) |
| `wallapop-catalogue` | `wallapop`, `all` | Reactivates my expired Wallapop listings daily, with commands in @PlatanosServicesBot (see [wallapop-catalogue repo](https://github.com/PlatanosVerdes/wallapop-catalogue)) |
| `torre` | `torre`, `all` | AENA departures and arrivals on the phone, with alerts through @TorreFlightsBot. **Public**, through the Cloudflare Tunnel, on a network of its own (see [torre repo](https://github.com/PlatanosVerdes/torre)) |

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

App versions live in `versions.env`, where each app's release pins its own tag ([Renovate](renovate.json)
only updates the GitHub Actions). Compose needs both env files: `apply.sh` sets this automatically,
and to run compose by hand, export it first or the `${..._VERSION}` refs resolve empty:

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

## Docs

| | |
| :--- | :--- |
| [Monitoring and muninn](docs/monitoring.md) | The `prometheus.probe` label that adds a service to the probes and the alert, and the `muninn.stats` label for bots |
| [laliga-fantasy](docs/laliga-fantasy.md) | Logging the container in, and who can reach it |
