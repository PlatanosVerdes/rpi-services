# rpi-services

Personal services running on my Raspberry Pi home server. This is the private counterpart to [rpi-homeserver](https://github.com/PlatanosVerdes/rpi-homeserver), which handles the core infrastructure (Caddy, Pi-hole, monitoring, media stack).

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

```bash
ln -s ~/rpi-services/config/caddy ~/rpi-homeserver/config/caddy/services/rpi-services
```

Caddy auto-imports everything under `config/caddy/services/`, so this is enough to add HTTPS routes without touching the main repo.

### 3. Run

```bash
docker compose up -d
```

Use `COMPOSE_PROFILES` in `.env` to select which services to start (e.g. `COMPOSE_PROFILES=cal,bot`).

### One-off services

```bash
# Download One Pace episodes
docker compose run --rm one-pace-downloader
```
