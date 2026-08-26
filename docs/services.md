# Services Registry

> Every running service should have an entry here. Update when adding, removing, or changing a service.

## Infrastructure

| Service | Purpose | Port | Config file |
|---|---|---|---|
| Traefik / NPM | Reverse proxy + auto SSL | 80, 443 | `configs/traefik/` |
| Portainer | Container management GUI | 9000 | `configs/docker-compose/portainer.yml` |
| PostgreSQL (shared) | Multi-database for all projects | 5432 (internal only) | `configs/docker-compose/postgres-redis.yml` |
| Redis (shared) | Caching, per-project key prefix | 6379 (internal only) | `configs/docker-compose/postgres-redis.yml` |

## Web Projects

| Project | Domain | Port | Notes |
|---|---|---|---|
| project-1 | project1.yourdomain.dev | - | - |
| project-2 | project2.yourdomain.dev | - | - |
| ... | | | (fill in as deployed) |

## Media Stack

| Service | Purpose | Port | Data location |
|---|---|---|---|
| Jellyfin | Movie/TV streaming | 8096 | External enclosure `/mnt/external-storage/movies` |
| Immich | Photo/video backup | 2283 | External enclosure `/mnt/external-storage/immich` |
| Nextcloud | File sync/storage | 8080 | External enclosure `/mnt/external-storage/nextcloud` |
| Kavita | Manga/comic reader | 5000 | External enclosure `/mnt/external-storage/manga` |
| Navidrome | Music streaming (Hi-Res) | 4533 | External enclosure `/mnt/external-storage/music` |

## Monitoring

| Service | Purpose | Port |
|---|---|---|
| Uptime Kuma | Uptime monitoring | 3001 |
| Netdata / Glances | Resource monitoring | - |

## Automation Scripts

> Status: scripts + systemd units are written and committed, but NOT yet deployed —
> docker-host doesn't exist yet (see `docs/roadmap.md`). Deploy steps in
> `configs/systemd/README.md` once the LXC/VM is up.

| Script | Purpose | Schedule | Unit files |
|---|---|---|---|
| `scripts/backup.sh` | Dumps shared PostgreSQL + copies `configs/` to `/mnt/external-storage/backups/<timestamp>`, prunes backups older than 30 days | Daily at 03:00 (+random delay up to 5min) | `configs/systemd/homelab-backup.service` + `.timer` |
| `scripts/health-check.sh` | Checks expected containers are running; auto-restarts any that are down (one restart attempt), logs to `/var/log/homelab-health-check.log` | Every 5 minutes | `configs/systemd/homelab-health-check.service` + `.timer` |
| `scripts/git-auto-deploy.sh` | Polls each project under `/opt/projects/*` for new commits on `main`; on change, `git pull` + `docker compose up -d --build`. Polling instead of a GitHub webhook because the server has no public-facing endpoint (Tailscale-only). Logs to `/var/log/homelab-git-deploy.log` | Every 5 minutes | `configs/systemd/homelab-git-deploy.service` + `.timer` |
