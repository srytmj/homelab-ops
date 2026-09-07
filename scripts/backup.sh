#!/bin/bash
# Backup script for homelab critical data
# Backs up: PostgreSQL dump, Docker compose configs (not secrets/.env).
# Targets HDD-Backup (WD Blue 320GB) — physically separate from HDD-Music/Media/Cloud,
# so this backup survives any one of those 3 drives failing.
# Does NOT back up bulk media (Jellyfin/Nextcloud content) — Nextcloud has its own
# separate Restic -> VaultS3 backup (see docs/decisions.md); Jellyfin media is
# considered re-downloadable and intentionally not backed up.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="/mnt/hdd-backup/backups"
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
