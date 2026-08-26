# Homelab Operations - Instructions for Claude Code

## Context

This repo manages a homelab server (Lenovo ThinkCentre M920q Tiny, i5-9500T 6C/6T, 16GB RAM).
Full current spec and topology: see `docs/architecture.md`.

Server runs Proxmox VE (hypervisor) + Docker (inside 1 Ubuntu LXC/VM), hosting:
- 10 personal web projects (Laravel/Node)
- Media stack: Jellyfin, Immich, Kavita, Navidrome, Nextcloud
- Shared PostgreSQL + Redis

## Before doing anything

1. Read `docs/architecture.md` for the current infrastructure state (source of truth for "what exists now")
2. Read `docs/roadmap.md` for planned next steps (source of truth for "what's planned")
3. Read `docs/decisions.md` if unsure why something is configured a certain way (source of truth for "why")
4. Read the last 10-15 entries of `CHANGELOG.md` for recent history (source of truth for "what changed recently")

Never assume the state of the server — always verify via SSH before making changes, since `docs/architecture.md` may lag behind reality if it wasn't updated after a manual change.

## Modes of operation

Detect which mode fits the user's request. If ambiguous, ask.

### 1. Planning mode
Two sub-types:

**A. Homelab infrastructure planning**
- Hardware capacity decisions (RAM/storage/CPU sizing, external storage enclosures, etc.)
- Service architecture decisions (which service, why, trade-offs)
- Scaling roadmap (e.g. k3s sandbox, VLAN segmentation, external DAS storage)

**B. Claude Code operational planning (meta-level)**
- Deciding what to automate next (prioritize from `docs/roadmap.md`)
- Flagging when `docs/architecture.md` looks stale vs. actual server state
- Suggesting when a manual recurring task should become a script in `scripts/`

**In planning mode: discuss first, don't execute.** Only write to `docs/decisions.md` and/or `docs/roadmap.md` once something is actually decided. Never touch live server config in this mode.

### 2. Setup mode
When asked to install/configure something new:
1. SSH into the server (connection details in `docs/architecture.md`)
2. Execute the setup
3. Save the resulting docker-compose file to `configs/docker-compose/<service-name>.yml`
4. Update `docs/services.md` with the new service (port, purpose, data location)
5. Update `docs/architecture.md` if the topology changed (new mount point, new container, etc.)
6. Log the change in `CHANGELOG.md`

### 3. Maintenance mode
When asked to check/fix/troubleshoot:
1. SSH in, check logs (`docker logs`, `journalctl`, etc.)
2. Diagnose the issue, explain what's wrong before fixing
3. Ask before making any risky/destructive change (e.g. deleting volumes, restarting production containers during active use)
4. Log the fix in `CHANGELOG.md` once resolved

### 4. Automation mode
When asked to automate a recurring task:
1. Write the script in `scripts/`
2. Set up the cron job or systemd timer for it
3. Document what it does and how it's scheduled in `docs/services.md`
4. Log the addition in `CHANGELOG.md`

## Always

- Log every meaningful change to `CHANGELOG.md`: date, what changed, why (one or two lines is enough)
- Never commit secrets/passwords/API keys to this repo — reference `.env` files (gitignored) instead
- Prefer editing an existing docker-compose file over creating a duplicate service
- When storage paths are involved, remember: OS/Docker/projects/DB metadata live on the internal SSD; bulk media (Immich, Nextcloud, Jellyfin) lives on the external multi-bay HDD enclosure — see `docs/architecture.md` for exact mount paths
- Keep this file (`CLAUDE.md`) itself up to date if the operating conventions change — note that update in `CHANGELOG.md` too
- Git commits in this repo are authored as the user, not Claude — do NOT add a `Co-Authored-By: Claude` trailer to commit messages here
