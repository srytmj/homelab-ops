# Services Registry

> Every running service should have an entry here. Update when adding, removing, or changing a service.

## Infrastructure

| Service | Purpose | Port | Config file |
|---|---|---|---|
| Nginx Proxy Manager | Reverse proxy + auto SSL (Let's Encrypt via GUI) | 80, 443 (proxy), 81 (admin UI) | `configs/docker-compose/npm.yml` |
| Portainer | Container management GUI | 9000 (HTTP), 9443 (HTTPS) | `configs/docker-compose/portainer.yml` |
| Tailscale | Remote access mesh VPN, no port forwarding | n/a (WireGuard mesh) | Native apt install on docker-host (not containerized). Node `docker-host` → `100.89.249.96` / `docker-host.taila813af.ts.net`. `--accept-dns=false`. |
| cloudflared | Cloudflare Tunnel connector — outbound-only, publishes services to the internet without opening router ports | n/a (outbound QUIC to Cloudflare edge) | Native apt install on docker-host (systemd service `cloudflared`, `enabled`). Tunnel token set up via Cloudflare Zero Trust dashboard by the user directly — token never stored in this repo. Public hostname routing (which domain → which local port) is configured in the Cloudflare dashboard itself, not tracked here yet. |
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
| portfolio | [srytmj/portofolio](https://github.com/srytmj/portofolio) | suryatmaja.dev | 3080 (internal, container `yorha-portfolio`) | Deployed 2026-09-11 on docker-host (`/opt/projects/portfolio/`, `configs/docker-compose/portfolio.yml`). SvelteKit static build served by nginx:alpine. **Only public-facing service** — exposed via Cloudflare Tunnel, not Tailscale-only like everything else. Now also contains the **blog** (previously its own `srytmj.github.io` repo — see below, that's no longer deployed separately). Has a hidden page that itself IS the dashboard (custom-built, replaces the separate Homepage/gethomepage.dev plan) — lists hrefs to every homelab service by its Tailscale subdomain, an easter egg only the owner can actually reach. Re-fetch this repo before assuming its current contents/structure — it's actively evolving in its own Claude Code session. |
| cloud-computing-docs | [srytmj/cloud-computing-docs](https://github.com/srytmj/cloud-computing-docs) | subdomain of suryatmaja.dev (TBD) | - | **Not yet built** — repo/web app doesn't exist yet, deploy later once created |
| ~~srytmj.github.io (blog)~~ | [srytmj/srytmj.github.io](https://github.com/srytmj/srytmj.github.io) | N/A — not deployed separately | - | **Not deployed as its own service.** Blog content now lives inside the `portfolio` repo instead — see the `portfolio` entry above. If this changes, re-check the `portfolio` repo for current state before assuming this is still accurate. |
| homelab-sentinel | [srytmj/homelab-sentinel](https://github.com/srytmj/homelab-sentinel) | N/A (Telegram bot, no domain) | - | Telegram bot (was Discord) — monitoring alerts + interactive queries + management + short QnA. See roadmap and decisions.md. Not a web app. |

| ... | | | | (fill in as more are deployed — 10 personal projects total planned) |

## Media Stack

| Service | Purpose | Port | Data location |
|---|---|---|---|
| Jellyfin | Movie/TV/anime streaming + music library (accessed via Feishin/foobar2000 as client, not Jellyfin web UI) | 8096 | `/mnt/hdd-media/jellyfin/{movies,tv,anime}` — **real HDD (sdb) mounted 2026-09-12**, contains actual media. `/mnt/hdd-music/jellyfin/music` still points at a placeholder on the internal SSD — hdd-music (sdc) is still in staging, not yet its final drive. |
| Nextcloud | File sync/storage | 8080 | `/mnt/hdd-cloud/nextcloud` — **real HDD (sdd) mounted 2026-09-12**, fresh empty data dir (Nextcloud never set up before the mount swap, confirmed with user, so no data was lost). Uses the shared Postgres container (database `nextcloud`, same `admin` user/password as `postgres-redis.yml`) and shared Redis for caching. No admin account pre-created — first browser visit runs Nextcloud's own setup wizard. |
| Kavita | Manga/comic reader | 5000 | `/mnt/hdd-media/kavita/manga` — **real HDD (sdb) mounted 2026-09-12**, contains actual manga library. |

## Monitoring

> Overlap check: 5 tools touch "monitoring" — each is scoped to a distinct concern to avoid
> duplication. See the boundary notes below before adding alerting to more than one.

| Service | Purpose | Port | Scope (to avoid overlap) |
|---|---|---|---|
| Uptime Kuma | Uptime/availability monitoring | 3001 | HTTP/TCP endpoint checks (web projects, media stack) + built-in alert integrations. **Deployed 2026-09-11.** No monitors configured yet — needs manual setup (add each service as a monitor) plus the admin account (first-run wizard). |
| Netdata | Resource monitoring | 19999 | Deep host-level metrics (CPU/RAM/disk/network) — the raw data source, not an alerting tool. **Deployed 2026-09-11.** Runs with `SYS_PTRACE`/`SYS_ADMIN` + AppArmor unconfined for full metrics visibility from inside the unprivileged LXC — narrower capabilities than a typical bare-metal install, some hardware-level sensors may be unavailable given the container-in-LXC nesting. |
| Scrutiny | HDD health monitoring (S.M.A.R.T.) | - | Drive-specific: Power-On Hours, Reallocated Sectors, temperature, historical SMART trends + failure-prediction alerts — distinct from Netdata's general resource metrics and not an uptime/container tool. **Not yet deployed** — needs real HDDs with SMART data, external storage not physically assembled yet. |
| Homelable | Infra topology visualizer | 3000 (UI), 8001 (MCP) | **Deployed 2026-09-12.** Visual network/rack diagram + live status overlay — a *map*, not an alert/history system. Repo: [Pouzor/homelable](https://github.com/Pouzor/homelable). Scanner range set to `192.168.18.0/24`. Has a Proxmox VE import feature (needs a read-only PVEAuditor API token, not yet configured) and an MCP server for AI clients. **Login is still the documented default `admin`/`admin` — change it immediately** (see CHANGELOG for the bcrypt regen command). |
| homelab-sentinel (Telegram bot) | Docker container-level monitoring + Telegram alerts, PLUS interactive queries / whitelisted management / short QnA | - | Container health/resource (things Uptime Kuma's URL/TCP checks can't see) — owns Telegram notifications so Uptime Kuma's own alert integration isn't wired to Telegram in parallel. Also the interactive control surface (see decisions.md for the 3-tier capability design + guardrails). |

## Other Self-Hosted Apps

| Service | Purpose | Port | Notes |
|---|---|---|---|
| Syncthing | Continuous P2P file sync between specific devices | 8384 (Web UI), 22000 tcp+udp, 21027 udp | Different from Nextcloud: no central "cloud" browsing/share-links, just keeps folders in sync across devices (including this server). **Deployed 2026-09-11.** Sync data at `/mnt/hdd-cloud/syncthing` — **real HDD (sdd) mounted 2026-09-12**, chowned to UID 1000 again after the mount swap (same fix as the original crash-loop, since a fresh root-owned dir was created at the real mount point). Hit a startup crash loop (`permission denied` on its config volume) because the image runs as UID 1000 by default but the Docker-created volume was owned by root — fixed with `chown -R 1000:1000` on the volume + config dir. **No login/auth configured** — the GUI is wide open on the LAN; worth setting a GUI username/password later via Settings. |
| Nextcloud | File storage + sharing (cloud-drive style) | 8080 | Central storage, share links, web/mobile access — the "cloud" experience; not redundant with Syncthing (different sync model, see above) |
| Shiori | Bookmark manager | 8081 | **Deployed 2026-09-11.** No admin account pre-created — first-run creates it via the web UI. |
| YOURLS | URL shortener | 8083 | **Deployed 2026-09-11.** Uses a **dedicated MariaDB** (`yourls-mariadb`), not the shared Postgres — YOURLS only officially supports MySQL/MariaDB. Intentional exception to the shared-DB convention, isolated from CapRover's future MySQL pool too (different trust boundary again). **Known quirk:** the bare root path `/` returns 403 (an upstream image config quirk — its rewrite rule excludes existing directories, and the docroot itself is one) — go straight to `/admin/` for the first-run setup wizard instead. `YOURLS_SITE` is set to a `yourls.home.arpa` placeholder until a real domain exists. |
| n8n | Workflow automation | 5678 | **Deployed 2026-09-11.** Uses the shared Postgres (database `n8n`). `N8N_ENCRYPTION_KEY` generated server-side, never printed or committed. No account pre-created — first-run wizard. |
| Alexandrie | Self-hosted notes / knowledge base | 8200 (UI), 8201 (API), 9002 (RustFS S3), 3307 (MySQL) | **Deployed 2026-09-12.** Repo: [Smaug6739/Alexandrie](https://github.com/Smaug6739/Alexandrie). Has its own MySQL 8.0 + RustFS (S3-compatible storage) — separate from the shared Postgres/Redis, same reasoning as YOURLS. RustFS port remapped from default 9000 to 9002 (9000 collides with Portainer on this host). No admin account pre-created — the app has its own signup page (`CONFIG_DISABLE_SIGNUP=false`), first-run creates it via the web UI. |
| Vaultwarden | Password manager (lightweight Bitwarden-compatible server) | 8222 | Community rewrite in Rust — NOT the official `bitwarden/server`, which is much heavier. **Deployed 2026-09-11.** `SIGNUPS_ALLOWED=true` for now — flip to `false` in `configs/docker-compose/vaultwarden.yml` once accounts are created, per Vaultwarden's own security recommendation. |
| Firefly III | Personal finance / budgeting tracker | - | Not yet deployed |
| Home Assistant | Home automation | - | Deploy once the smart power plug (HA-compatible) arrives |
| Reclip | Self-hosted media downloader (yt-dlp wrapper, web UI) | - | Not yet deployed |
| LibreSpeed | Self-hosted internet/LAN speed test (open-source Speedtest alternative) | 8082 | Lightweight (PHP+JS), useful for testing PC↔Homelab LAN speed and WAN speed without relying on a third-party server. **Deployed 2026-09-11.** No password set on the results/admin page (`PASSWORD` env left empty) — fine for LAN-only use, set one if this ever gets exposed further. |
| VaultS3 | Lightweight S3-compatible object storage | - | **Not yet deployed 2026-09-12** — previous plan to put this at `/mnt/hdd-cloud/vaults3/` contradicts decisions.md's cross-drive backup requirement (VaultS3 backs up Nextcloud, which lives on hdd-cloud). Deferred until hdd-music (sdc) or HDD-Backup is ready as the real cross-drive home. |
| SnapOtter | Self-hosted file-processing toolkit — 200+ tools across image/video/audio/PDF/files (convert, compress, OCR, transcribe). Replaces CloudConvert/Smallpdf/TinyPNG/Otter.ai. | - | Standing service (has its own Redis job queue for background jobs). Bundles its own Postgres 17 + Redis — do NOT wire to the shared instances. Limit concurrent workers since video transcode/OCR are CPU-heavy on the GPU-less M710q. Replaced the earlier FileWizard plan (SnapOtter is the superset). |
| T3 Code | Agent harness control surface for Claude Code, Antigravity/Gemini, etc. | 9001 | Deployed 2026-09-12 via `configs/docker-compose/t3code.yml`. Custom image with `@anthropic-ai/claude-code` + `t3`. Exposed on host port 9001 (internal 9000). |
| Databasus | PostgreSQL backup (PITR, restore verification, notifications) | - | Candidate to **replace** `scripts/backup.sh`'s Postgres piece, not run alongside it — avoid running two backup mechanisms against the same DB |
| qBittorrent | Torrent client (web UI) | - | Deployed **without a VPN wrapper** (Gluetun) for now — user's own cost/risk trade-off, see decisions.md. Public IP is exposed to torrent swarms as a result. |

## Automation Scripts

> Status: scripts + systemd units are written and committed, but NOT yet deployed —
> docker-host doesn't exist yet (see `docs/roadmap.md`). Deploy steps in
> `configs/systemd/README.md` once the LXC/VM is up.

| Script | Purpose | Schedule | Unit files |
|---|---|---|---|
| `scripts/backup.sh` | Dumps shared PostgreSQL + copies `configs/` to `/mnt/external-storage/backups/<timestamp>`, prunes backups older than 30 days | Daily at 03:00 (+random delay up to 5min) | `configs/systemd/homelab-backup.service` + `.timer` |
| `scripts/health-check.sh` | Checks expected containers are running; auto-restarts any that are down (one restart attempt), logs to `/var/log/homelab-health-check.log` | Every 5 minutes | `configs/systemd/homelab-health-check.service` + `.timer` |
| `scripts/git-auto-deploy.sh` | Polls each project under `/opt/projects/*` for new commits on `main`; on change, `git pull` + `docker compose up -d --build`. Polling instead of a GitHub webhook because the server has no public-facing endpoint (Tailscale-only). Logs to `/var/log/homelab-git-deploy.log` | Every 5 minutes | `configs/systemd/homelab-git-deploy.service` + `.timer` |
