#!/bin/bash
# Polls each project's git repo for upstream changes and auto-deploys if found.
# Runs on a timer (see configs/systemd/homelab-git-deploy.timer) instead of a
# webhook, since this server has no public-facing endpoint (Tailscale-only access).
#
# Convention: each project lives in its own subdirectory under PROJECTS_ROOT,
# is a git repo, and has a docker-compose.yml at its root.

set -uo pipefail

PROJECTS_ROOT="/opt/projects"
BRANCH="main"
LOG_FILE="/var/log/homelab-git-deploy.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ ! -d "$PROJECTS_ROOT" ]; then
  log "ERROR: PROJECTS_ROOT '$PROJECTS_ROOT' does not exist"
  exit 1
fi

for project_dir in "$PROJECTS_ROOT"/*/; do
  project_dir="${project_dir%/}"
  project_name="$(basename "$project_dir")"

  if [ ! -d "$project_dir/.git" ]; then
    continue
  fi

  cd "$project_dir" || continue

  if ! git fetch origin "$BRANCH" >> "$LOG_FILE" 2>&1; then
    log "ERROR: $project_name — git fetch failed"
    continue
  fi

  LOCAL_HEAD=$(git rev-parse HEAD)
  REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")

  if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
    continue
  fi

  log "$project_name — new commit detected ($LOCAL_HEAD -> $REMOTE_HEAD), deploying..."

  if ! git pull origin "$BRANCH" >> "$LOG_FILE" 2>&1; then
    log "ERROR: $project_name — git pull failed"
    continue
  fi

  if [ -f "docker-compose.yml" ] || [ -f "compose.yml" ]; then
    if docker compose up -d --build >> "$LOG_FILE" 2>&1; then
      log "$project_name — deployed OK"
    else
      log "ERROR: $project_name — docker compose up failed"
    fi
  else
    log "$project_name — pulled, but no docker-compose.yml/compose.yml found, skipping rebuild"
  fi
done
