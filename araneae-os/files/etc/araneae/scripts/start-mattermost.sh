#!/bin/sh
set -eu
. /etc/araneae/araneae.env

MM_DIR="/srv/araneae/mattermost"
LOG="/tmp/araneae-mattermost.log"
mkdir -p "$MM_DIR/volumes/mattermost" "$MM_DIR/volumes/postgres"
cp -n /etc/araneae/mattermost/docker-compose.yml "$MM_DIR/docker-compose.yml"
cp -n /etc/araneae/mattermost/.env.template "$MM_DIR/.env"

# Generate a local random PostgreSQL password on first boot.
if grep -q 'CHANGE_ME_GENERATED_ON_FIRST_BOOT' "$MM_DIR/.env"; then
  PASS="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 40 || true)"
  [ -n "$PASS" ] || PASS="araneae$(date +%s)"
  sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=${PASS}/" "$MM_DIR/.env"
fi

# Keep .env aligned with firmware profile.
sed -i "s/^ARANAE_WG_SERVER_IP=.*/ARANAE_WG_SERVER_IP=${ARANAE_WG_SERVER_IP}/" "$MM_DIR/.env"
sed -i "s/^ARANAE_MATTERMOST_PORT=.*/ARANAE_MATTERMOST_PORT=${ARANAE_MATTERMOST_PORT}/" "$MM_DIR/.env"
sed -i "s#^MATTERMOST_SITE_URL=.*#MATTERMOST_SITE_URL=http://${ARANAE_WG_SERVER_IP}:${ARANAE_MATTERMOST_PORT}#" "$MM_DIR/.env"

# Mattermost container expects these paths to be writable by uid 2000.
mkdir -p "$MM_DIR/volumes/mattermost/config" \
         "$MM_DIR/volumes/mattermost/data" \
         "$MM_DIR/volumes/mattermost/logs" \
         "$MM_DIR/volumes/mattermost/plugins" \
         "$MM_DIR/volumes/mattermost/client-plugins" \
         "$MM_DIR/volumes/mattermost/bleve-indexes"
chown -R 2000:2000 "$MM_DIR/volumes/mattermost" 2>/dev/null || true

# Wait for dockerd to be responsive.
for i in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

cd "$MM_DIR"
{
  echo "[$(date)] Starting Araneae Mattermost on http://${ARANAE_WG_SERVER_IP}:${ARANAE_MATTERMOST_PORT}"
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose pull || true
    docker compose up -d
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose pull || true
    docker-compose up -d
  else
    echo "docker compose not found"
    exit 1
  fi
} >> "$LOG" 2>&1
