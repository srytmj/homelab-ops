# Services Registry

> Every running service should have an entry here. Update when adding, removing, or changing a service.

## Infrastructure

| Service | Purpose | Port | Config file |
|---|---|---|---|
| Traefik / NPM | Reverse proxy + auto SSL | 80, 443 | `configs/traefik/` |
| Portainer | Container management GUI | 9000 | `configs/docker-compose/portainer.yml` |
| PostgreSQL (shared) | Multi-database for all projects | 5432 (internal only) | `configs/docker-compose/postgres-redis.yml` |
| Redis (shared) | Caching, per-project key prefix | 6379 (internal only) | `configs/docker-compose/postgres-redis.yml` |
| CapRover | Mini hosting panel — lets friends self-deploy their own web apps (git push → auto build/deploy), auto SSL, per-app resource limits | 3000 (admin) | Deployed after base homelab is stable, see roadmap.md. Requires Docker Swarm mode. |
| MySQL/MariaDB (CapRover-only) | Database for friends'-apps hosted via CapRover | via CapRover One-Click App | **Separate from the shared PostgreSQL/Redis above** — different trust boundary, friends' app code isn't the user's own |

## Web Projects

### Domain: whitearchive.my.id

| Project | Repo | Domain | Port | Notes |
|---|---|---|---|---|
| malas | [srytmj/malas](https://github.com/srytmj/malas) | whitearchive.my.id (subpath/subdomain TBD) | - | Manga library system — tracks reading progress, aggregates latest chapters from multiple sources, manages personal manga collection. Inspired by Kenmei/AniList/MyAnimeList. |
| whitearchive | [srytmj/whitearchive](https://github.com/srytmj/whitearchive) | whitearchive.my.id | - | - |
| sso.whitearchive | [srytmj/sso.whitearchive](https://github.com/srytmj/sso.whitearchive) | sso.whitearchive.my.id (assumed) | - | Likely an auth/SSO dependency of whitearchive — confirm deploy order (SSO probably needs to be up before whitearchive) |
| pore-js | [srytmj/pore-js](https://github.com/srytmj/pore-js) | whitearchive.my.id (subpath/subdomain TBD) | - | Custom reader tied into the `malas` project ecosystem — not a general-purpose library like Kavita. Confirmed both are deployed: Kavita is the standalone generic manga/comic server, pore-js is the reader integrated with `malas`. |

### Domain: suryatmaja.dev

| Project | Repo | Domain | Port | Notes |
|---|---|---|---|---|
| portfolio | [srytmj/portofolio](https://github.com/srytmj/portofolio) | suryatmaja.dev | - | **Only public-facing service** — exposed via Cloudflare Tunnel, not Tailscale-only like everything else. Now also contains the **blog** (previously its own `srytmj.github.io` repo — see below, that's no longer deployed separately). Has a hidden page that itself IS the dashboard (custom-built, replaces the separate Homepage/gethomepage.dev plan) — lists hrefs to every homelab service by its Tailscale subdomain, an easter egg only the owner can actually reach. Re-fetch this repo before assuming its current contents/structure — it's actively evolving in its own Claude Code session. |
| cloud-computing-docs | [srytmj/cloud-computing-docs](https://github.com/srytmj/cloud-computing-docs) | subdomain of suryatmaja.dev (TBD) | - | **Not yet built** — repo/web app doesn't exist yet, deploy later once created |
| ~~srytmj.github.io (blog)~~ | [srytmj/srytmj.github.io](https://github.com/srytmj/srytmj.github.io) | N/A — not deployed separately | - | **Not deployed as its own service.** Blog content now lives inside the `portfolio` repo instead — see the `portfolio` entry above. If this changes, re-check the `portfolio` repo for current state before assuming this is still accurate. |
| homelab-sentinel | [srytmj/homelab-sentinel](https://github.com/srytmj/homelab-sentinel) | N/A (Discord bot, no domain) | - | Monitoring bot, see roadmap — not a web app; grouped under this domain's account only for repo ownership, not actually served here |

| ... | | | | (fill in as more are deployed — 10 personal projects total planned) |

## Media Stack

| Service | Purpose | Port | Data location |
|---|---|---|---|
| Jellyfin | Movie/TV/anime streaming + music library (accessed via Feishin/foobar2000 as client, not Jellyfin web UI) | 8096 | `/mnt/hdd-music/jellyfin/music`, `/mnt/hdd-media/jellyfin/{movies,tv,anime}` |
| Nextcloud | File sync/storage | 8080 | `/mnt/hdd-cloud/nextcloud` |
| Kavita | Manga/comic reader | 5000 | `/mnt/hdd-media/kavita/manga` |

## Monitoring

> Overlap check: 5 tools touch "monitoring" — each is scoped to a distinct concern to avoid
> duplication. See the boundary notes below before adding alerting to more than one.

| Service | Purpose | Port | Scope (to avoid overlap) |
|---|---|---|---|
| Uptime Kuma | Uptime/availability monitoring | 3001 | HTTP/TCP endpoint checks (web projects, media stack) + built-in alert integrations |
| Netdata / Glances | Resource monitoring | - | Deep host-level metrics (CPU/RAM/disk/network) — the raw data source, not an alerting tool |
| Scrutiny | HDD health monitoring (S.M.A.R.T.) | - | Drive-specific: Power-On Hours, Reallocated Sectors, temperature, historical SMART trends + failure-prediction alerts — distinct from Netdata's general resource metrics and not an uptime/container tool |
| Homelable | Infra topology visualizer | - | Visual network/rack diagram + live status overlay — a *map*, not an alert/history system |
| homelab-sentinel (Discord bot) | Docker container-level monitoring + Discord alerts | - | Container health/resource specifically (things Uptime Kuma's URL/TCP checks can't see) — owns Discord notifications so Uptime Kuma's own alert integration isn't also wired to Discord in parallel |

## Other Self-Hosted Apps

| Service | Purpose | Notes |
|---|---|---|
| Syncthing | Continuous P2P file sync between specific devices | Different from Nextcloud: no central "cloud" browsing/share-links, just keeps folders in sync across devices (including this server) |
| Nextcloud | File storage + sharing (cloud-drive style) | Central storage, share links, web/mobile access — the "cloud" experience; not redundant with Syncthing (different sync model, see above) |
| Shiori | Bookmark manager | - |
| YOURLS | URL shortener | - |
| n8n | Workflow automation | - |
| Alexandrie | Self-hosted notes / knowledge base | - |
| Vaultwarden | Password manager (lightweight Bitwarden-compatible server) | Community rewrite in Rust — NOT the official `bitwarden/server`, which is much heavier |
| Firefly III | Personal finance / budgeting tracker | - |
| Home Assistant | Home automation | Deploy once the smart power plug (HA-compatible) arrives |
| Reclip | Self-hosted media downloader (yt-dlp wrapper, web UI) | - |
| LibreSpeed | Self-hosted internet/LAN speed test (open-source Speedtest alternative) | Lightweight (PHP+JS), useful for testing PC↔Homelab LAN speed and WAN speed without relying on a third-party server |
| VaultS3 | Lightweight S3-compatible object storage | Lives on HDD-Cloud (`/mnt/hdd-cloud/vaults3/`) alongside Nextcloud — both are part of the "S3 / Google Drive alternative" storage drive |
| FileWizard | File converter / OCR / transcription web UI | Run on-demand only, not a standing container — Whisper transcription is CPU-heavy |
| Databasus | PostgreSQL backup (PITR, restore verification, notifications) | Candidate to **replace** `scripts/backup.sh`'s Postgres piece, not run alongside it — avoid running two backup mechanisms against the same DB |
| qBittorrent | Torrent client (web UI) | Deployed **without a VPN wrapper** (Gluetun) for now — user's own cost/risk trade-off, see decisions.md. Public IP is exposed to torrent swarms as a result. |

## Automation Scripts

> Status: scripts + systemd units are written and committed, but NOT yet deployed —
> docker-host doesn't exist yet (see `docs/roadmap.md`). Deploy steps in
> `configs/systemd/README.md` once the LXC/VM is up.

| Script | Purpose | Schedule | Unit files |
|---|---|---|---|
| `scripts/backup.sh` | Dumps shared PostgreSQL + copies `configs/` to `/mnt/external-storage/backups/<timestamp>`, prunes backups older than 30 days | Daily at 03:00 (+random delay up to 5min) | `configs/systemd/homelab-backup.service` + `.timer` |
| `scripts/health-check.sh` | Checks expected containers are running; auto-restarts any that are down (one restart attempt), logs to `/var/log/homelab-health-check.log` | Every 5 minutes | `configs/systemd/homelab-health-check.service` + `.timer` |
| `scripts/git-auto-deploy.sh` | Polls each project under `/opt/projects/*` for new commits on `main`; on change, `git pull` + `docker compose up -d --build`. Polling instead of a GitHub webhook because the server has no public-facing endpoint (Tailscale-only). Logs to `/var/log/homelab-git-deploy.log` | Every 5 minutes | `configs/systemd/homelab-git-deploy.service` + `.timer` |
