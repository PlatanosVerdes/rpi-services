#!/bin/bash

PROJECT_DIR="$HOME/rpi-services"

set -a; source "$PROJECT_DIR/.env"; set +a

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"; }

cd "$PROJECT_DIR" || { log "Directory not found"; exit 1; }

log "Fetching updates from origin..."
BEFORE=$(git rev-parse HEAD)
if ! git pull origin main; then
    log "Error: Git pull failed."
    exit 1
fi
AFTER=$(git rev-parse HEAD)

if [ ! -f .env ]; then
    log "Error: .env file not found."
    exit 1
fi

if [ "$BEFORE" != "$AFTER" ]; then
    log "Changes detected ($BEFORE -> $AFTER), rebuilding..."
    docker compose up -d --build --remove-orphans
else
    log "No changes detected, ensuring containers are running..."
    docker compose up -d --remove-orphans
fi

log "Done."

# crontab -e
# */15 * * * * /home/raspi/rpi-services/scripts/deploy_control.sh >> /home/raspi/rpi-services/deploy_control.log 2>&1
