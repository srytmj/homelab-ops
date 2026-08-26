#!/bin/bash
# Health check for homelab services.
# Checks if expected containers are running; auto-restarts any that are down
# and logs every check + restart attempt.

set -uo pipefail

EXPECTED_CONTAINERS=(
  "shared-postgres"
  "shared-redis"
  "jellyfin"
  "immich-server"
  "kavita"
  "navidrome"
)

LOG_FILE="/var/log/homelab-health-check.log"
MAX_RESTART_ATTEMPTS=1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Running health check..."

for container in "${EXPECTED_CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
    continue
  fi

  log "WARNING: $container is not running. Attempting restart..."

  if docker restart "$container" >> "$LOG_FILE" 2>&1; then
    sleep 5
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
      log "RECOVERED: $container is back up."
    else
      log "ERROR: $container restart command succeeded but container is still not running. Manual intervention needed."
      # Optional: send notification (e.g. via ntfy, Telegram bot, etc.)
    fi
  else
    log "ERROR: docker restart failed for $container. It may not exist or was never started (use 'docker start' once, then this script can restart it going forward)."
    # Optional: send notification (e.g. via ntfy, Telegram bot, etc.)
  fi
done

log "Health check complete."
