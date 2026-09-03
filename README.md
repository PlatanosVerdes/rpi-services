# rpi-services

Personal services running on my Raspberry Pi home server. This is the personal counterpart to [rpi-homeserver](https://github.com/PlatanosVerdes/rpi-homeserver), which handles the core infrastructure (Caddy, Pi-hole, monitoring, media stack) and is meant to be clonable by anyone. Everything specific to me lives here instead, so that repo stays generic.

Both repos are deployed by `rpi-homeserver/scripts/apply.sh` (webhook on push, cron every 30 min as fallback) and follow the same conventions: versions in a committed `versions.env`, no `:latest`, one shared host crontab.

Monitoring is one label away: a container carrying `prometheus.probe: "http://<name>:<port>/<path>"`
is probed every 15s by the blackbox exporter over there, and shows up in the Service probes
dashboard and in the "Service not answering" alert. Nothing to add on the rpi-homeserver side. A
service that serves no HTTP (the bot, the one-off downloader) has no label: for those, liveness is
the container running.

## Services

| Service | Profile | Description |
| :--- | :--- | :--- |
| `cal-bridge` | `cal`, `all` | Google Calendar + Microsoft API bridge for an ESP32 display |
| `pol-academy-offers-bot` | `bot`, `all` | Telegram bot for Pol Ferrer Academy offers |
| `one-pace-downloader` | `one-pace` | One-shot downloader for One Pace episodes (see [one-pace-downloader repo](https://github.com/PlatanosVerdes/one-pace-downloader)) |
| `anisette` | `airtag`, `all` | Self-hosted Apple auth (anisette) server used by air-tag |
| `air-tag` | `airtag`, `all` | AirTag location tracker + private Leaflet map (see [air-tag repo](https://github.com/PlatanosVerdes/air-tag)) |
| `laliga-fantasy` | `fantasy`, `all` | LaLiga Fantasy decision panel (see [laliga-fantasy repo](https://github.com/PlatanosVerdes/laliga-fantasy)) |
| `wallapop-reactivator` | `wallapop`, `all` | Reactivates my expired Wallapop listings daily (see [wallapop-reactivator repo](https://github.com/PlatanosVerdes/wallapop-reactivator)) |

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

## laliga-fantasy

**Sesion.** El login es un OAuth por navegador, que un contenedor no puede hacer. No hace falta
copiar nada a mano: si no hay sesion, la propia pagina la pide. Abre
`https://fantasy.platanosverdes.com`, pulsa el enlace de login, y pega la direccion a la que te
redirija (fallara al abrir `authredirect://…`, eso es lo normal: el codigo esta en la barra).
Tambien acepta un `tokens.json` pegado tal cual, y lo comprueba contra la API antes de aceptarlo.

A partir de ahi el refresh token rota solo y el fichero se actualiza en su sitio, asi que es cosa
de una vez. `/healthz` dice cuanta vida le queda a la sesion, que es lo que convierte "se me ha
muerto el token" en un aviso en vez de en una sorpresa.

**Acceso.** Solo se llega desde el tailnet, y eso es toda la puerta: la pagina puede gastar
dinero real de la liga, asi que lo que la protege es que nadie mas llegue. Nada se ejecuta sin
confirmarlo en la pagina, y las instrucciones permanentes solo actuan dentro de los limites que
se les pongan ahi. Con `--read-only` en el `command` se sirve la pagina y se rechaza cualquier
operacion, por si algun dia interesa mirar sin poder tocar.
