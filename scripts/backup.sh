#!/bin/bash
# Backup script for homelab critical data
# Backs up: PostgreSQL dump, Docker compose configs (not secrets/.env).
# Does NOT back up bulk media (Immich/Jellyfin/Nextcloud content) — that lives on the
# external enclosure and should have its own separate backup strategy if needed.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="/mnt/external-storage/backups"
RETENTION_DAYS=30
DATE=$(date +%Y-%m-%d_%H-%M-%S)
DEST="$BACKUP_DIR/$DATE"
LOG_FILE="/var/log/homelab-backup.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

mkdir -p "$DEST"

log "Starting backup -> $DEST"

# Dump PostgreSQL
if docker exec shared-postgres pg_dumpall -U admin > "$DEST/postgres-dump.sql"; then
  log "PostgreSQL dump OK"
else
  log "ERROR: PostgreSQL dump failed"
  exit 1
fi

# Copy docker-compose configs (not secrets/.env)
cp -r "$REPO_DIR/configs" "$DEST/configs"
log "Config copy OK"

# Prune backups older than $RETENTION_DAYS days
find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" -exec rm -rf {} \;
log "Pruned backups older than ${RETENTION_DAYS}d"

log "Backup complete: $DEST"
