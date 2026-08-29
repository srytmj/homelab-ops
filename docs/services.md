# Services Registry

> Every running service should have an entry here. Update when adding, removing, or changing a service.

## Infrastructure

| Service | Purpose | Port | Config file |
|---|---|---|---|
| Traefik / NPM | Reverse proxy + auto SSL | 80, 443 | `configs/traefik/` |
| Portainer | Container management GUI | 9000 | `configs/docker-compose/portainer.yml` |
| Homepage | Personal dashboard/launcher — one page with clickable links to every service; auto-discovers services via Docker labels | 3000 | `configs/docker-compose/homepage.yml` — not container management (Portainer) or a topology map (Homelable), just quick access |
| PostgreSQL (shared) | Multi-database for all projects | 5432 (internal only) | `configs/docker-compose/postgres-redis.yml` |
| Redis (shared) | Caching, per-project key prefix | 6379 (internal only) | `configs/docker-compose/postgres-redis.yml` |

## Web Projects

| Project | Repo | Domain | Port | Notes |
|---|---|---|---|---|
| malas | [srytmj/malas](https://github.com/srytmj/malas) | TBD | - | - |
| homelab-sentinel | [srytmj/homelab-sentinel](https://github.com/srytmj/homelab-sentinel) | N/A (Discord bot, no domain) | - | Monitoring bot, see roadmap — not a web app |
| whitearchive | [srytmj/whitearchive](https://github.com/srytmj/whitearchive) | TBD | - | - |
| srytmj.github.io (blog) | [srytmj/srytmj.github.io](https://github.com/srytmj/srytmj.github.io) | TBD | - | Deployed on homelab instead of GitHub Pages for faster access; served like the other web projects via Traefik/NPM |
| sso.whitearchive | [srytmj/sso.whitearchive](https://github.com/srytmj/sso.whitearchive) | TBD | - | Likely an auth/SSO dependency of whitearchive — confirm deploy order (SSO probably needs to be up before whitearchive) |
| portfolio | [srytmj/portofolio](https://github.com/srytmj/portofolio) | TBD (public) | - | **Only public-facing service** — exposed via Cloudflare Tunnel, not Tailscale-only like everything else. Has a hidden button linking to the Homepage dashboard (Tailscale-only URL) as an easter egg only the owner can actually reach |
| pore-js | [srytmj/pore-js](https://github.com/srytmj/pore-js) | TBD | - | Custom reader tied into the `malas` project ecosystem — not a general-purpose library like Kavita. Confirmed both are deployed: Kavita is the standalone generic manga/comic server, pore-js is the reader integrated with `malas`. |
| ... | | | | (fill in as more are deployed — 10 personal projects total planned) |

## Media Stack

| Service | Purpose | Port | Data location |
|---|---|---|---|
| Jellyfin | Movie/TV streaming + music library (accessed via Feishin/foobar2000 as client, not Jellyfin web UI) | 8096 | External enclosure `/mnt/external-storage/movies`, `/music` |
| Immich | Photo/video backup | 2283 | External enclosure `/mnt/external-storage/immich` |
| Nextcloud | File sync/storage | 8080 | External enclosure `/mnt/external-storage/nextcloud` |
| Kavita | Manga/comic reader | 5000 | External enclosure `/mnt/external-storage/manga` |

## Monitoring

> Overlap check: 4 tools touch "monitoring" — each is scoped to a distinct concern to avoid
> duplication. See the boundary notes below before adding alerting to more than one.

| Service | Purpose | Port | Scope (to avoid overlap) |
|---|---|---|---|
| Uptime Kuma | Uptime/availability monitoring | 3001 | HTTP/TCP endpoint checks (web projects, media stack) + built-in alert integrations |
| Netdata / Glances | Resource monitoring | - | Deep host-level metrics (CPU/RAM/disk/network) — the raw data source, not an alerting tool |
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
| VaultS3 | Lightweight S3-compatible object storage | Not yet wired to any app — available as an S3 target if something later needs one (e.g. backup destination), not consumed by Nextcloud/Immich which use local volumes |
| FileWizard | File converter / OCR / transcription web UI | Run on-demand only, not a standing container — Whisper transcription is CPU-heavy |
| Databasus | PostgreSQL backup (PITR, restore verification, notifications) | Candidate to **replace** `scripts/backup.sh`'s Postgres piece, not run alongside it — avoid running two backup mechanisms against the same DB |

## Automation Scripts

> Status: scripts + systemd units are written and committed, but NOT yet deployed —
> docker-host doesn't exist yet (see `docs/roadmap.md`). Deploy steps in
> `configs/systemd/README.md` once the LXC/VM is up.

| Script | Purpose | Schedule | Unit files |
|---|---|---|---|
| `scripts/backup.sh` | Dumps shared PostgreSQL + copies `configs/` to `/mnt/external-storage/backups/<timestamp>`, prunes backups older than 30 days | Daily at 03:00 (+random delay up to 5min) | `configs/systemd/homelab-backup.service` + `.timer` |
| `scripts/health-check.sh` | Checks expected containers are running; auto-restarts any that are down (one restart attempt), logs to `/var/log/homelab-health-check.log` | Every 5 minutes | `configs/systemd/homelab-health-check.service` + `.timer` |
| `scripts/git-auto-deploy.sh` | Polls each project under `/opt/projects/*` for new commits on `main`; on change, `git pull` + `docker compose up -d --build`. Polling instead of a GitHub webhook because the server has no public-facing endpoint (Tailscale-only). Logs to `/var/log/homelab-git-deploy.log` | Every 5 minutes | `configs/systemd/homelab-git-deploy.service` + `.timer` |
