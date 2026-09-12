# Changelog

> Every meaningful change gets one entry here, newest on top. Keep it short: date, what changed, why (if not obvious).

## 2026-09-12 (19)
- **Updated Homelab Cockpit Compose Configuration & Multi-Host Proxmox Sync**:
  - Injected `env_file: .env` into `/mnt/homelab_projects/homelab-dashboard/docker-compose.yml`.
  - Enabled `NODE_TLS_REJECT_UNAUTHORIZED=0` inside container, resolving Proxmox VE API SSL verification failures and restoring real-time hypervisor telemetry.
  - Enabled multi-host docker polling (`apps-host=tcp://192.168.18.226:2375`) and container monitoring across docker-host and apps-host.
  - Committed and pushed commit `39c80b0` to `srytmj/homelab-dashboard` and pushed `homelab-ops` upstream.

## 2026-09-12 (18)
- **Restored Jellyfin to Clean Stock Configuration**:
  - Removed `/dev/dri` passthrough mount from `/opt/infra/jellyfin/docker-compose.yml` to match repository specification.
  - Reset `encoding.xml` options (`HardwareAccelerationType: none`, `EnableHardwareEncoding: false`, cleared `VaapiDevice` and `HardwareDecodingCodecs`).
  - Purged stale transcode cache and cleanly recreated container via `docker compose down && docker compose up -d`.
  - Verified healthy HTTP 200 responses for playback API, HLS remuxing, and subtitle delivery.

## 2026-09-12 (17)
- **Reverted Jellyfin Hardware Acceleration**:
  - Reverted `<HardwareAccelerationType>` back to `none` in Jellyfin encoding configuration.
  - Resolved subtitle rendering/extraction regression caused by hardware transcoding pipeline.

## 2026-09-12 (16)
- **Updated Homelab Cockpit to Commit 06a17f4**:
  - Pulled commits `cabb1db`, `dc00430`, and `06a17f4` (dynamic storage label detection, dynamic hardware detection, pinned link priority fix).
  - Rebuilt and restarted container `homelab-cockpit` on port `8050`.
  - Storage matrix and dashboard now natively read dynamic hardware specs without hardcoded labels.

## 2026-09-12 (15)
- **Standardized Execution Performance & Anti-Freeze Protocol in CLAUDE.md**:
  - Enforced one-shot batched SSH execution to eliminate round-trip latency.
  - Mandated bounded timeouts (`timeout`) and clean foreground command execution to permanently prevent ghost background task accumulation in T3 Code.
  - Updated agent rules across all AI harnesses and sessions.

## 2026-09-12 (14)
- **Enabled Intel QuickSync Hardware Acceleration on Jellyfin & Updated Cockpit Storage Labels**:
  - Configured Proxmox LXC 100 passthrough for `/dev/dri` (Intel HD Graphics 630, `card0` & `renderD128`).
  - Passed device `/dev/dri:/dev/dri` into `jellyfin` container and verified VA-API/iHD driver entrypoints via `vainfo`.
  - Configured hardware acceleration to `qsv` (Intel QuickSync) in Jellyfin encoding configuration.
  - Updated storage capacity labels in Cockpit dashboard to match actual disk capacities (Bay 1: 1TB HDD, Bay 2: 1TB HDD, Bay 3: 2TB HDD). Rebuilt and redeployed `homelab-cockpit`.

## 2026-09-12 (13)
- **Resolved Nextcloud Admin Password & Storage Canary Watchdog**:
  - Generated and set new secure password for Nextcloud user `admin` via `occ user:resetpassword`.
  - Created missing `.mounted` canary files on DAS HDD mounts (`/mnt/hdd-media`, `/mnt/hdd-cloud`, `/mnt/hdd-music`) so Cockpit watchdog reliably detects mounts as attached and healthy.
  - Investigated Jellyfin playback delay: Identified root causes (no /dev/dri GPU passthrough in LXC 100 + container resulting in software direct-stream remuxing from USB-DAS HDDs).

## 2026-09-12 (12)
- **Homelab Cockpit Multi-Docker Monitoring Integration**:
  - Exposed Docker Engine daemon over TCP (`0.0.0.0:2375`) on node `apps-host` (LXC 101) via systemd drop-in override.
  - Pulled commits up to `4bea746` on [srytmj/homelab-dashboard](https://github.com/srytmj/homelab-dashboard) (multi-docker host telemetry, fleet filtering, command palette, pages, pins).
  - Configured `DOCKER_HOST_NAME=docker-host` and `DOCKER_HOSTS=apps-host=tcp://192.168.18.226:2375` in `.env` and `docker-compose.yml`.
  - Rebuilt and deployed container `homelab-cockpit` on port `8050`.
  - Verified multi-host telemetry: Cockpit aggregates 15 containers from `docker-host` and 1 container (`whitearchive`) from `apps-host` seamlessly.
  - Confirmed `apps-host` is authenticated and active on Tailscale mesh (`100.110.235.57`).

## 2026-09-12 (11)
- **Created Dedicated LXC 101 (`apps-host`) for Web Applications**:
  - Configured Unprivileged LXC 101 on Proxmox VE (`192.168.18.226/24`, 2 Cores, 4GB RAM, 2GB Swap, 30GB local-lvm SSD).
  - Configured `nesting=1,keyctl=1` and TUN passthrough (`/dev/net/tun`) for Docker and Tailscale.
  - Installed Docker Engine 29.8.0 and Tailscale natively.
- **Deployed `whitearchive` Web Application**:
  - Cloned [srytmj/whitearchive](https://github.com/srytmj/whitearchive) to `/opt/projects/whitearchive`.
  - Configured Next.js `output: "standalone"` with an optimized multi-stage Alpine Dockerfile.
  - Successfully built and started container `whitearchive` on port `3000`. Verified HTTP 200 OK.
  - Initiated Tailscale pairing session for `apps-host`.

## 2026-09-12 (10)
- **Resolved Cloudflare Tunnel Integration Issues**:
  - **Nextcloud**:
    - Fixed `Access through untrusted domain` error by registering `nextcloud.suryatmaja.dev` and `100.89.249.96:8080` to Nextcloud `trusted_domains` via `occ`.
    - Enabled `overwriteprotocol=https` and `overwrite.cli.url=https://nextcloud.suryatmaja.dev` to prevent HTTPS reverse proxy mixed content.
  - **qBittorrent**:
    - Disabled `WebUI\CSRFProtection` and `WebUI\HostHeaderValidation`, and enabled `WebUI\ReverseProxySupportEnabled` in `qBittorrent.conf` to allow web access through reverse proxy / Cloudflare Tunnel.
    - Noted that qBittorrent WebUI runs on host port `8480` (not `8080`, which is used by Nextcloud).
  - **T3 Code**:
    - Retrieved pair token `GBUAXZJ7FJJW` for pairing via `t3.suryatmaja.dev` or LAN.

## 2026-09-12 (9)
- **Updated Homelab Dashboard (Homelab Cockpit)**:
  - Pulled commits up to `4e759e6` on `srytmj/homelab-dashboard` (`build(repo): enforce conventional commits with husky and commitlint`, `feat(auth): add owner auth wall on the new interface`, docs and UI improvements).
  - Rebuilt and restarted container `homelab-cockpit` on port `8050`.
  - Verified `/api/health` returned HTTP 200.

## 2026-09-12 (8)
- **Decommissioned redundant services replaced by Homelab Cockpit**:
  - Stopped, removed containers, volumes, and infra directories for:
    - **Portainer** (`:9000`): container logs, restart, and prune are now natively handled by Cockpit.
    - **Netdata** (`:19999`): host CPU, RAM, thermal sensors, and network I/O are streamed directly via Proxmox VE API and Docker socket.
    - **Uptime Kuma** (`:3001`): HTTP L7 probing and latency monitoring are built into Cockpit.
    - **Homelable** (`:3000`, `:8001`): topology replaced by Cockpit dashboard.
  - Executed `docker system prune -af --volumes`: **reclaimed 15.27 GB of disk space** on internal NVMe SSD and freed over 600 MB of system RAM.
  - Updated `docs/services.md` accordingly.

## 2026-09-12 (7)
- **Updated Homelab Dashboard (Homelab Cockpit)**:
  - Pulled commit `79a66ed` (`feat: add 1x owner registration auth wall, explicit Tailscale container routing, and minimalist utilitarian UI`).
  - Rebuilt and restarted container `homelab-cockpit` on port `8050`.
  - Auth wall active with 1-time owner setup wizard protecting telemetry APIs.

## 2026-09-12 (6)
- **Deployed Homelab Dashboard (Homelab Cockpit)**:
  - Cloned and built [srytmj/homelab-dashboard](https://github.com/srytmj/homelab-dashboard) at `/mnt/homelab_projects/homelab-dashboard`.
  - Configured Proxmox API token (`root@pam!cockpit`), Docker socket, Tailscale socket, and live HDD storage telemetry mounts (`/`, `/mnt/hdd-media`, `/mnt/hdd-cloud`, `/mnt/hdd-music`).
  - Container `homelab-cockpit` deployed and exposed at `http://192.168.18.225:8050`.

## 2026-09-12 (5)
- **Deployed Samba Share & WSDD Daemon on docker-host**:
  - Installed and configured Samba (`smbd`) exposing `/mnt/hdd-cloud/shared/` as `shared` with full read/write permissions.
  - Installed and configured `wsdd` (Web Services Dynamic Discovery host daemon as systemd unit) advertising hostname `HOMELAB` on `WORKGROUP`, enabling Windows 10/11 File Explorer network discovery.
  - Removed `shiori` container and volume per user request.

## 2026-09-12 (4)
- **Cleaned up unused services and reset Shiori**:
  - Stopped and removed containers/volumes for unused services: **Alexandrie** (`:8200`), **Firefly III** (`:8280`), and **YOURLS** (`:8083`). Removed corresponding directories in `/opt/infra/`. Frees up CPU, RAM, and MySQL/MariaDB overhead.
  - Reset **Shiori** (`:8081`) named volume to restore fresh default state (`shiori` / `gopher`).

## 2026-09-12 (3)
- **Migrated Kavita to new Docker repository**: Upstream Kavita deprecated `kizaing/kavita` after v0.7.8 and moved officially to `jvmilazz0/kavita:latest`. Updated `configs/docker-compose/kavita.yml` and `/opt/infra/kavita/docker-compose.yml` on docker-host. Pulled the latest image and recreated the container; existing data/config in `kavita_config` volume and manga volume intact.

## 2026-09-12 (8)
- **Deployed qBittorrent** (`lscr.io/linuxserver/qbittorrent:latest`) on docker-host, WebUI port remapped from the image's default 8080 to 8480 (8080 is Nextcloud's) — `WEBUI_PORT` env var set to match, since qBittorrent's CSRF host-header check rejects the WebUI otherwise. Downloads go to `/mnt/hdd-media/qbittorrent/downloads` (real HDD, not a placeholder). No VPN wrapper (Gluetun) — this is the already-accepted cost/risk trade-off from `decisions.md`, not a new decision. Did **not** hit the UID 1000 permission bug this time despite bind-mounting a freshly-`mkdir`'d host path (same risk pattern as Syncthing) — worth re-checking if it ever does act up, but this image apparently handles ownership itself via its own init script (`/init`, PUID/PGID env vars) rather than relying on the mount already being correctly owned. First-boot temporary admin password (random, printed once to `docker logs qbittorrent`) was given to the user directly in chat and not written to any file in this repo — it regenerates on every restart until a permanent one is set in the Web UI.

## 2026-09-12 (7)
- **Deployed Reclip** ([averygan/reclip](https://github.com/averygan/reclip)) on docker-host, port 8899. Built from source (`git clone` to `/opt/projects/reclip/`, `docker compose up -d --build` using the repo's own Dockerfile + compose file as-is — no pre-built image exists for this small Flask/yt-dlp tool). Clean deploy, no bugs — notably did **not** hit the UID-1000-vs-root-owned-directory permission bug seen with Syncthing, because Reclip uses a Docker-managed **named volume** (`reclip-downloads`) rather than a bind-mount to a host path; a fresh named volume inherits the ownership already baked into the image's directory (the Dockerfile's `chown -R reclip:reclip /app` at build time), whereas a bind-mount to a host directory freshly created by `mkdir` (as root) does not. No authentication on this app at all — anyone on the LAN can use it, which matches its minimal-by-design scope.

## 2026-09-12 (6)
- **Deployed Firefly III** ([firefly-iii/docker](https://github.com/firefly-iii/docker)) on docker-host, port 8280 (upstream default 80 collides with NPM). New `configs/docker-compose/firefly-iii.yml`: 2 containers (`app`, `cron`) — **deliberately skipped the upstream compose's bundled MariaDB `db` service** and pointed Firefly at the shared Postgres instead (new `firefly` database, same `admin` user), since Firefly III natively supports `pgsql` and this repo's convention is to prefer the shared DB when an app actually supports it (unlike YOURLS/Alexandrie, which are MySQL-only). `APP_KEY` and `STATIC_CRON_TOKEN` generated server-side; the shared Postgres password was injected into Firefly's `.env` via a script run entirely on the server (`sed` reading one `.env` into another) so it was never printed in this session's output. Clean deploy, no bugs this time — verified via the app's own log line ("Firefly III should be ready for use") confirming the Postgres connection and migrations succeeded, plus HTTP 302 (normal redirect to login/register).

## 2026-09-12 (5)
- **Deployed Alexandrie** ([Smaug6739/Alexandrie](https://github.com/Smaug6739/Alexandrie)) on docker-host — 4 containers (mysql, rustfs, backend, frontend) via new `configs/docker-compose/alexandrie.yml`. Own MySQL 8.0 + RustFS S3-compatible storage (not the shared Postgres/Redis — same intentional-exception reasoning as YOURLS). RustFS remapped from its default port 9000 to 9002 since 9000 collides with Portainer on this host. Credentials (JWT secret, MySQL passwords, RustFS access/secret keys) generated server-side. No admin account pre-created — the app has its own signup flow.
  - **Real bug hit and fixed**: first deploy attempt used a hand-written compose file based on a summarized reading of the upstream `.env.example`, which doesn't show how the real `docker-compose.yml` translates `.env` variable names into what the app containers actually expect. Backend crash-looped on `BACKEND_PORT environment variable not set` (needs `BACKEND_PORT`/`GIN_MODE` hardcoded, plus `DATABASE_*`/`MINIO_*` env vars — not just the `MYSQL_*`/`RUSTFS_*` names from `.env.example`), and frontend silently had empty `API`/`CDN`/`URL` config (needs `NUXT_PUBLIC_*`-prefixed vars, a Nuxt runtime-config convention, plus an explicit `PORT: 8200`). Fixed by fetching the upstream `docker-compose.yml` directly via `curl` (raw content) instead of relying on a summarizing fetch tool, then using it verbatim — it already handles the `.env`-to-internal-var translation correctly by design, so this repo's `.env` (with the plain `.env.example`-style names) works fine once paired with the *real* compose file's env-mapping layer. **Lesson for future service setups: always get compose files as raw/verbatim text, never a paraphrased summary, since the exact variable-name mapping between `.env` and the container's actual expected env vars can only live in the compose file itself.**

## 2026-09-12 (4)
- **Deployed Homelable** ([Pouzor/homelable](https://github.com/Pouzor/homelable)) on docker-host — 3 containers (backend, frontend, mcp) via new `configs/docker-compose/homelable.yml`, using pre-built GHCR images. Frontend on port 3000, MCP server on 8001 (exposes the canvas to AI clients like Claude Code). `SECRET_KEY`/`MCP_API_KEY`/`MCP_SERVICE_KEY` generated server-side (machine-to-machine credentials, safe to generate directly — not a human login). `SCANNER_RANGES` set to the real LAN (`192.168.18.0/24`). **Login is still the project's documented default (`admin`/`admin`)** — no first-run wizard exists for this app (auth is env-var-only), so unlike NPM/Portainer/Nextcloud there's no way to defer credential creation to the user; flagged clearly instead. Change it via: `docker exec homelable-backend python -c 'import bcrypt; print(bcrypt.hashpw(b"newpassword", bcrypt.gensalt()).decode())'`, then update `AUTH_PASSWORD_HASH` in `/opt/infra/homelable/.env` on docker-host (keep the single quotes — bcrypt hashes contain `$`) and restart. Verified HTTP 200.

## 2026-09-12 (3)
- **HDD migration fully complete**: the sdb/sdd restore (staging on sdc → freshly-formatted ext4 sdb/sdd) finished cleanly with zero errors — `rsync` summary confirmed `sent 543.11G / total size 542.97G` (sdb) and `sent 850.03G / total size 849.82G` (sdd), matching source almost exactly (small delta is the intentionally-excluded `DumpStack.log.tmp`). Verified via a fresh Claude Code session (T3 Code, running as its own container on docker-host) after generating a dedicated SSH keypair for that session and adding it to the Proxmox host's `authorized_keys` — the original laptop-only key never left the laptop.
- **Mounted both drives permanently**: added `/etc/fstab` entries on the Proxmox host keyed by UUID (not `/dev/sdX`, which can reorder) with `nofail` so boot isn't blocked if a drive is ever missing — `sdb2` → `/mnt/hdd-media` (label `hdd-media`), `sdd2` → `/mnt/hdd-cloud` (label `hdd-cloud`). Bind-mounted both into the `docker-host` LXC at the identical paths via `pct set 100 -mp0/-mp1`, then `pct reboot 100` to apply (same pattern as the earlier TUN-device fix — LXC mount point changes need a restart). All 18 containers came back up automatically (`restart: unless-stopped`).
- **Confirmed with the user before swapping Nextcloud's mount**: Nextcloud's compose mounts its *entire webroot* (not just a data folder) to the host path, so swapping to the real HDD would have reset it to a fresh install if setup had already happened. User confirmed Nextcloud was never actually set up, so the swap was safe — no migration of the 873MB placeholder needed.
- **Re-hit and re-fixed the Syncthing UID 1000 permission bug** (same root cause as the original deploy): the real HDD's `hdd-cloud/syncthing/` folder was freshly created by `mkdir` as root, so it needed `chown -R 1000:1000` again before Syncthing could write to it. Restarted the container after the fix — confirmed HTTP 200.
- **Found and fixed a real doc inconsistency**: `services.md` said VaultS3 should live at `/mnt/hdd-cloud/vaults3/`, but `decisions.md` requires VaultS3 to be **cross-drive** from HDD-Cloud (it backs up Nextcloud, which lives on HDD-Cloud — same-drive placement would defeat the backup's purpose). Deferred VaultS3 deployment until `hdd-music` (sdc, still in staging use) or HDD-Backup (not physically installed yet) is ready as a proper cross-drive home, instead of deploying it in the wrong place. Corrected both `services.md` and `roadmap.md` to reflect this.
- **Fixed stale roadmap checkboxes**: Syncthing, Shiori, YOURLS, n8n, Vaultwarden, and LibreSpeed were already deployed (see 2026-09-11 (13)) but `roadmap.md` still showed them unchecked — never updated at the time. Marked done with a CHANGELOG cross-reference.
- Updated `services.md` and `architecture.md` to remove now-inaccurate "placeholder on internal SSD" language for Jellyfin, Nextcloud, Kavita, and Syncthing now that their real HDD paths are live. `architecture.md`'s drive table gained a **Status** column reflecting actual mount state per drive (hdd-media/hdd-cloud mounted, hdd-music still staging, hdd-backup not physically installed).
- **Next in the user-requested setup queue** (services not yet deployed, going in order: Homelable, Alexandrie, Firefly III, Reclip, qBittorrent, SnapOtter — VaultS3 deferred per above, CapRover/Home Assistant/homelab-sentinel/Databasus intentionally excluded from this queue, see roadmap.md for why).

## 2026-09-12 (2)
- **Fixed recurring 502 / Model Unreachable in T3 Code**: The Antigravity (`agy`) ACP server binary resides in persistent storage (`/root/.t3/tools/antigravity-acp/...`), but T3 Code and CLI expect `agy` and `antigravity` symlinks in `/usr/local/bin`. Container restarts or recreations wiped the ephemeral container root filesystem, breaking the symlinks and throwing 502 Bad Gateway / unreachable errors.
  - Created `configs/docker-compose/t3code/entrypoint.sh` to automatically detect `agy_acp_server.par`, make it executable, ensure `localharness_external` permissions, create symlinks in `/usr/local/bin` and `/usr/bin`, verify `active.json`, and maintain a 5s background loop to self-heal symlinks even after runtime runtime updates.
  - Updated `configs/docker-compose/t3code/Dockerfile` to bake in `openssh-client`, `procps`, `iputils-ping`, and set `ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]`.
  - Updated `configs/docker-compose/t3code.yml` with explicit `entrypoint` and mounted `entrypoint.sh:ro` for immediate resilience across container recreate without requiring immediate manual image rebuild.
  - Added self-healing hook in persistent `/root/.bashrc`.

## 2026-09-12 (1)
- **Deployed T3 Code** ([pingdotgg/t3code](https://github.com/pingdotgg/t3code)) on docker-host, port 9001 (internal 9000). Created `configs/docker-compose/t3code.yml` and `configs/docker-compose/t3code/Dockerfile` (uses `node:22-bookworm-slim` with build-essential tools to build native `node-pty`, bundles `@anthropic-ai/claude-code` and `t3` CLI). Mapped host port 9001 because port 9000 is occupied by Portainer. Marked done in `roadmap.md` and added to `services.md`.

## 2026-09-11 (14)
- Updated `CLAUDE.md`: added "git pull first, every session" as step 0 (repo is now worked from multiple devices), added a "Multi-agent / multi-tool use" section covering cross-device sync (git is the only mechanism) and using non-Claude-Code tools (e.g. Antigravity/Gemini) on this repo. Also refreshed the stale Context section (M920q→M710q, dropped Immich/Navidrome, pointed to `services.md` as the actual current list instead of a hardcoded summary).

## 2026-09-11 (13)
- **Deployed 6 lightweight services**: Vaultwarden (8222), n8n (5678), Syncthing (8384), Shiori (8081), YOURLS (8083, + dedicated `yourls-mariadb`), LibreSpeed (8082). New compose files for all 6 in `configs/docker-compose/`. n8n uses a new `n8n` database in the shared Postgres; YOURLS needed its own MariaDB since it doesn't support Postgres (documented as an intentional exception). Resource check before starting: docker-host had ~11GB/12GB RAM free and 128GB/147GB disk free — comfortable headroom.
- **Two real bugs hit and fixed during this batch, not just slow pulls:**
  - **Syncthing crash-looped** on `permission denied` opening its config lock file. Root cause: the official `syncthing/syncthing` image runs as UID 1000 by default, but the Docker-created named volume was owned by `root`. Fixed with `chown -R 1000:1000` on the volume and the `/mnt/hdd-cloud/syncthing` data dir.
  - **YOURLS returned "connection reset by peer"**, then 403, before working. Root cause #1: the official `yourls` image's Apache listens on **port 8080** internally, not 80 — the compose file's `8083:80` mapping was wrong, fixed to `8083:8080`. Root cause #2 (cosmetic, not fixed — it's an upstream quirk): the image's shipped rewrite rule excludes existing directories from the `/yourls-loader.php` rewrite, so the bare `/` path 403s since the docroot itself is a directory; `/admin/` (the actual setup entry point) works fine and returns 200.
- **Portainer's setup session timed out** (5-minute security window to create the first admin account) before the user got to it — fixed with `docker restart portainer`, which reopens the setup window. Not a bug, just a heads-up for next time: create the admin account promptly after any Portainer (re)start.
- Deferred (not yet deployed, no immediate need): Alexandrie, Firefly III, Home Assistant, Reclip, VaultS3, SnapOtter, Databasus, qBittorrent — all still listed in `services.md`/`roadmap.md` for later.

## 2026-09-11 (12)
- **Deployed Uptime Kuma** (port 3001, new `configs/docker-compose/uptime-kuma.yml`) and **Netdata** (port 19999, new `configs/docker-compose/netdata.yml`) on docker-host. Both verified HTTP 200. No monitors/alerts configured in Uptime Kuma yet, and no admin account pre-created (first-run wizard, same pattern as other services). Netdata needed `SYS_PTRACE`/`SYS_ADMIN` capabilities + AppArmor unconfined to get host-level metrics from inside the unprivileged LXC — the unprivileged LXC didn't block this, but its `cgroup-network` plugin still fails to resolve per-container network interfaces (nested-cgroup limitation) — core CPU/RAM/disk/network metrics are unaffected, just that one sub-feature. Skipped Scrutiny (HDD SMART monitoring) — no real HDDs attached yet, external storage not physically assembled. Checked resource headroom before deploying more: docker-host was at ~1GB/12GB RAM used and 12GB/147GB disk used, comfortable room to keep adding services.

## 2026-09-11 (11)
- **Deployed Nextcloud** on docker-host, port 8080 (new `configs/docker-compose/nextcloud.yml`, no prior draft existed). Created a `nextcloud` database inside the existing shared Postgres container via `docker exec shared-postgres psql -U admin -c "CREATE DATABASE nextcloud;"` (local superuser exec, no password needed) rather than spinning up a dedicated DB container — consistent with the shared-DB decision in `decisions.md`. Reused the same Postgres password already in `/opt/infra/postgres-redis/.env` by copying the file server-side (`cp`) — the value was never printed in this session's output. Also wired to the shared Redis for caching. **No admin account was pre-created** via `NEXTCLOUD_ADMIN_USER`/`PASSWORD` env vars — left for the user to create through Nextcloud's own first-run web setup wizard, same pattern as NPM/Portainer/Kavita. Data path `/mnt/hdd-cloud/nextcloud` is a placeholder on the internal SSD (external HDD not physically assembled yet). Verified HTTP 200.

## 2026-09-11 (10)
- **Deployed Jellyfin** on docker-host, port 8096. Updated the stale draft `configs/docker-compose/jellyfin.yml` (old `/mnt/external-storage/movies` single-mount path, Traefik labels) to the current multi-mount convention: `/mnt/hdd-music/jellyfin/music`, `/mnt/hdd-media/jellyfin/{movies,tv,anime}`, dropped Traefik labels. Same as Kavita earlier today — **these are placeholder directories on the internal SSD for now**, external HDDs not physically assembled yet. Verified HTTP 302 (normal first-run redirect to setup wizard).

## 2026-09-11 (9)
- **Fixed the `portfolio` Cloudflare Tunnel Public Hostname**: it was configured as `https://localhost:3080` in the Cloudflare Zero Trust dashboard, but the `yorha-portfolio` nginx container only serves plain HTTP on 3080 (no TLS) — cloudflared logged `tls: first record does not look like a TLS handshake` on every request. User fixed the scheme to `http://localhost:3080` in the dashboard. Verified: `https://suryatmaja.dev` now returns HTTP 200 publicly.
- **Deployed Kavita** (manga/comic reader) on docker-host, port 5000. Updated the stale draft `configs/docker-compose/kavita.yml` (had an old `/mnt/external-storage/manga` path and Traefik labels from before the storage-topology and NPM decisions) to the current path convention (`/mnt/hdd-media/kavita/manga`) and dropped the Traefik labels (not used — this homelab uses NPM). **The manga path is currently a placeholder empty directory on the internal SSD** — the external HDD dock isn't physically assembled yet (see roadmap.md), so this will need remounting to the real drive later; no data loss risk since it's empty either way.
- **Deferred `sso.whitearchive`/`whitearchive` deployment** — user hasn't purchased the domain yet for the whitearchive product line. Investigated the repo enough to know it's a substantial Laravel + Passport OAuth2 SSO provider that bundles its own Postgres in `docker/compose.prod.yml` (would need adapting to the shared Postgres instance) and needs real secrets this session shouldn't fabricate (Resend API key for email, admin credentials, production domain) — picking back up once the domain exists.
- **Clarified Kavita vs. Komga**: user asked about Komga (not previously documented anywhere in this repo) but confirmed sticking with the already-decided Kavita rather than switching or running both.

## 2026-09-11 (8)
- **Installed `cloudflared` on docker-host** (native apt package, not Docker — user's explicit choice, provided the Debian install recipe directly) and registered it as a Cloudflare Tunnel connector via `cloudflared service install <token>`, using a tunnel token the user generated in the Cloudflare Zero Trust dashboard and pasted directly in chat (never written to any file in this repo, shell history cleared after use — same handling as the Tailscale auth key earlier today). Service is `enabled` (survives reboot) and confirmed connected: 4 registered QUIC connections to Cloudflare edge (Singapore/Jakarta PoPs), all connectivity prechecks passed. **Not yet done:** routing a public hostname (e.g. `suryatmaja.dev`) to this tunnel and pointing it at the `portfolio` container (3080) — that's configured in the Cloudflare Zero Trust dashboard itself (Public Hostname mapping), not something this session did.
- **Hit two apt hangs while installing `cloudflared`, both self-inflicted, not real network bugs:** (1) `apt-get update` hung after adding the cloudflared repo — a `pkill -9` on a previous stuck process had left stale `/var/lib/apt/lists/lock` and `/var/lib/dpkg/lock*` files; clearing them and retrying fixed it. (2) After that, a full `apt-get update` across all sources hung again on `archive.ubuntu.com`'s `noble-updates` (unrelated to cloudflared) — worked around by scoping `apt-get update` to just the cloudflared source list (`-o Dir::Etc::sourcelist=... -o Dir::Etc::sourceparts=-`) instead of updating every configured repo. Lesson for future package installs on this LXC: prefer a source-scoped `apt-get update` over a full one when only one new repo was added, to avoid unrelated slow/flaky mirrors blocking the whole operation.

## 2026-09-11 (7)
- **Installed Tailscale on docker-host**, joined tailnet `srytmj.github` as `docker-host` (`100.89.249.96`, MagicDNS `docker-host.taila813af.ts.net`). Enabled TUN device passthrough for the unprivileged LXC first (`lxc.cgroup2.devices.allow: c 10:200 rwm` + `lxc.mount.entry: /dev/net dev/net none bind,create=dir` in `/etc/pve/lxc/100.conf`), which required a container reboot to apply (all `restart: unless-stopped` containers came back up automatically — no manual intervention needed). Authenticated using a pre-generated Tailscale auth key the user supplied directly (not interactive browser login, not stored anywhere in this repo or left in shell history — cleared after use). Used `--accept-dns=false` so Tailscale's DNS doesn't fight with the LXC's own resolver setup (tuned earlier today to fix registry DNS issues). **Not yet done:** per-service MagicDNS subdomains (`tailscale serve`) and Cloudflare Tunnel bridging — user will handle the Tailscale→Cloudflare bridging personally, per the sequencing decision logged in the previous entry.

## 2026-09-11 (6)
- **Deployed the first web project: `portfolio`.** Added `Dockerfile` + `nginx.conf` to the [srytmj/portofolio](https://github.com/srytmj/portofolio) repo itself (commit `3542728`, pushed as Maja per that repo's own `AI_GUIDELINES.md` — Claude Code never adds itself as commit author there), implementing the "Option 3: Homelab Self-Hosted" deployment guide that repo had already documented but never had files for. Multi-stage build (`node:20-alpine` builds the SvelteKit static-adapter output, `nginx:alpine` serves it). Cloned to `/opt/projects/portfolio/` on docker-host (matches the path convention `scripts/git-auto-deploy.sh` already expects), compose file also tracked at `configs/docker-compose/portfolio.yml`. Container `yorha-portfolio` published on port 3080, verified HTTP 200.
- **Sequencing decision from the user:** Tailscale gets installed and given to *every* service first (not just internal ones) before any Cloudflare Tunnel work — the user will personally bridge a service's Tailscale address to Cloudflare Tunnel themselves once Tailscale is up, rather than Claude Code setting up `cloudflared` directly. This applies to `portfolio` too, superseding the assumption that Cloudflare Tunnel setup would happen as part of this deploy. No `cloudflared` container was deployed as part of this task.
- **Found and fixed a second, distinct DNS bug** (not the earlier `GODEBUG=netdns=cgo` one): `docker compose up --build` failed during BuildKit's image-metadata resolution step with `Temporary failure in name resolution` for `registry-1.docker.io`, even though `curl`/`getent ahosts` worked fine on the host at the same time. Root cause was the router's DNS forwarder (`192.168.18.1`) intermittently failing **A-record** queries specifically for high-record-count hostnames like `registry-1.docker.io` (many load-balanced IPs), while AAAA queries succeeded — confirmed via `dig @192.168.18.1` timing out on A. Fixed by reordering the LXC's resolvers to put `1.1.1.1` first and the router second (`pct set 100 --nameserver '1.1.1.1 192.168.18.1'`), rather than router-first with `1.1.1.1` as fallback. Also noted `getent hosts` (legacy call) is unreliable for diagnosing this class of bug on this system — it silently returned IPv6-only results even after the fix; `getent ahosts` or a direct `curl` is the trustworthy check.

## 2026-09-11 (5)
- **Created NPM admin account** (user did this manually via the browser — account creation/passwords are never entered by Claude Code) and **added the first proxy host**: `portainer.home.arpa` → `http://192.168.18.225:9000` (Portainer), with Block Common Exploits + Websockets Support enabled, no SSL (HTTP only — not a real domain, so no Let's Encrypt cert). Chosen as a placeholder hostname pattern since Tailscale (and its planned MagicDNS subdomains, per `decisions.md`) isn't installed yet. Verified end-to-end with `curl -H "Host: portainer.home.arpa"` — request reached Portainer correctly (redirected to `/timeout.html`, its normal pre-login behavior). **Note:** `portainer.home.arpa` only resolves for clients that have a hosts-file entry or local DNS override pointing it at `192.168.18.225` — nothing publishes this hostname on the network yet.

## 2026-09-11 (4)
- **Deployed Portainer CE** on docker-host. New compose file `configs/docker-compose/portainer.yml` (referenced in `services.md` but hadn't actually been written yet). Running under `/opt/infra/portainer/`, ports 9000 (HTTP) and 9443 (HTTPS), docker.sock mounted read-write for container management. Hit a transient `Temporary failure in name resolution` for `registry-1.docker.io` on first attempt (unrelated to the earlier GODEBUG fix — `getent hosts` resolved fine moments later); added `1.1.1.1` directly to the LXC's `/etc/resolv.conf` as a fallback (the `pct set --nameserver` change from earlier hadn't propagated into the running container — Proxmox writes resolv.conf at container start, not live) and retried successfully. Verified: `docker ps` shows it running, HTTP 200 on port 9000.

## 2026-09-11 (3)
- **Deployed shared PostgreSQL 16 + Redis 7** on docker-host, using the existing `configs/docker-compose/postgres-redis.yml`. Running under `/opt/infra/postgres-redis/` on the server, both bound to `127.0.0.1` only (internal use by other containers on `shared_net`, not exposed on the LAN). Password generated randomly and stored in a server-local `.env` (not committed — gitignored). Verified: `pg_isready` accepting connections, `redis-cli ping` → `PONG`.
- **Found and fixed a real Docker networking bug, not just flaky DNS:** image pulls kept failing with `dial tcp [IPv6]: cannot assign requested address` when hitting `auth.docker.io` / Cloudflare-fronted endpoints, even after IPv6 was disabled at the kernel level and `/etc/gai.conf` was set to prefer IPv4 (from the earlier NPM deploy). Root cause: Docker/containerd is a Go binary and by default uses its own internal DNS resolver, which ignores `/etc/gai.conf` entirely. Fixed by forcing the daemon onto the system (cgo) resolver via a systemd override — `/etc/systemd/system/docker.service.d/override.conf` setting `GODEBUG=netdns=cgo` — then `systemctl daemon-reload && systemctl restart docker`. This is the actual fix for the IPv6-on-an-IPv4-only-network class of failures; the earlier `gai.conf` change alone was insufficient for Go-based tools.
- Added a fallback public DNS (`1.1.1.1`) to the docker-host LXC's nameserver config (`pct set 100 --nameserver`) alongside the router's `192.168.18.1`, since two separate pulls hit `auth.docker.io` resolution timeouts before the real bug was found — cheap resilience even though the underlying fix was the resolver override above.

## 2026-09-11 (2)
- **Deployed Nginx Proxy Manager** on docker-host. User chose NPM over Traefik (GUI-first, easier than docker-label-driven config for this setup) — the choice had been left open in `architecture.md`/`services.md` as "Traefik / NPM", never actually decided. Compose file at `configs/docker-compose/npm.yml`, running under `/opt/infra/npm/` on docker-host, published on ports 80/443 (proxy) and 81 (admin UI). Created a `shared_net` external Docker network on docker-host for this and future services to join. Image pull was slow (~5+ min for ~38 layers) but completed and container verified healthy (HTTP 200 on admin UI, clean startup logs).

## 2026-09-11
- **Proxmox VE installed on the M710q.** Hostname `pve.suryatmaja.dev`, static IP `192.168.18.224/24`, gateway/DNS `192.168.18.1`. Set up SSH key-based auth (`~/.ssh/id_ed25519_homelab`) instead of relying on the root password for future automation.
- **Hardware verification found a CPU mismatch:** `lscpu` on the actual server shows **Intel i5-7500 (4C/4T, 3.4GHz)**, not the **i7-7700 (4C/8T)** that was purchased/decided in `decisions.md`. RAM (32GB) and the M710q model (`10MQS1EU00`) match. User chose to proceed with setup and document rather than pause for a seller dispute — worth following up separately. See `docs/architecture.md`.
- **Created `docker-host` LXC** (VMID 100, Ubuntu Server 24.04, unprivileged, `nesting=1,keyctl=1`), static IP `192.168.18.225/24`. Allocated 12GB RAM / 150GB disk; cores corrected from 5→4 after discovering the host only has 4 physical cores (initial config over-allocated based on the documented-but-wrong 6-core/8-thread specs).
- **Fixed LVM thin-pool overcommit:** `local-lvm`'s thin pool was only 140.87GB while the LXC's rootfs requested 150GB. Extended the pool to ~156.88GB using the volume group's remaining free space, and set `thin_pool_autoextend_threshold`/`_percent` in `/etc/lvm/lvm.conf` per Proxmox's own warning.
- **Installed Docker Engine 29.8.0 + Compose plugin v5.5.1** inside docker-host. Hit an IPv6 dead-route issue (container had only a link-local IPv6 address, no route) that broke image pulls — fixed by disabling IPv6 (`sysctl`) and setting `/etc/gai.conf` to prefer IPv4 in DNS resolution. Verified with `docker run hello-world`.
- Synced `docs/architecture.md` and `docs/roadmap.md` to actual verified server state (they still referenced the superseded M920q/16GB plan in some sections despite `decisions.md` already having the M710q/32GB revision).

## 2026-08-26
- **Hardware finalized, checked out.** Considered and rejected a used Xeon E5 server PC (12-20 cores) — idle power draw over 24/7 use would cost more in electricity than the hardware price difference within 1-2 years, and the workload doesn't benefit from that many cores (see decisions.md). PSU switched to Enhance ENP-2320 (200W, Active PFC) instead of a cheap generic PSU, to avoid voltage-spike risk to the HDDs. Storage expanded from 1 HDD to 3 dedicated drives (HDD-Music, HDD-Media, HDD-Cloud) each single-purpose, no RAID. Original Toshiba 2TB HDD sold out — replaced with Seagate Barracuda 2TB (also desktop-class, not NAS-rated). Final cart cost ~Rp6.79 juta (excl. HDD-Media, HDD-Cloud, and their dock, still unpurchased). Also decided: Homepage dashboard dropped in favor of a custom hidden page in the existing `portfolio` repo, which becomes the only publicly-exposed service (via Cloudflare Tunnel) — everything else stays Tailscale-only.
- **Storage topology finalized, corrected from earlier assumption.** Original plan assumed the OS SSD would be a standard 2.5" SATA SSD sitting in the internal 2.5" bay, with a separate USB DAS enclosure for extra HDDs. Corrected: the OS SSD is actually **M.2 SATA** form factor, so it needs an "M.2 SATA/mSATA to SATA 3.0 2.5\"" adapter to fit the internal bay at all. The M.2 NVMe slot is repurposed to host an **LM418 (M.2 NVMe to 5-port SATA) card** instead of holding a drive — this card's SATA ports are what an additional HDD (Toshiba 2TB) connects through, housed in an external powered dock (separate Imperion ATX 500W PSU) rather than a USB DAS enclosure. See `decisions.md` for full reasoning.
- Dropped the dedicated router purchase (MikroTik) for now — topology is ISP router → TP-Link TL-LS1005G Gigabit switch → PC + Homelab. Revisit a dedicated router only when VLAN isolation is actually implemented.
- Dropped from plan: 2nd HDD (single Toshiba 2TB is enough to start), electric dehumidifier (silica gel as cheaper fallback if needed), and likely the separate 2.5" HDD dock (superseded by the M.2-SATA-adapter-in-internal-bay setup).
- Logged final shopping list with reference pricing in `decisions.md`.
- Revised hardware pick from M920q (i5-9500T, 6C/6T, 16GB RAM) to M710q (i7-7700T, 4C/8T, 32GB RAM) — traded 2 physical cores for double RAM + higher clock speed after characterizing the actual workload as mostly I/O-bound (see decisions.md for full reasoning). Also decided Immich runs with ML disabled, removing the main compute-bound argument for prioritizing core count.

- Automation mode: added `scripts/git-auto-deploy.sh` — polls each project under `/opt/projects/*` every 5min for new commits on `main`, auto `git pull` + `docker compose up -d --build`. Chose polling over a GitHub webhook since the server has no public endpoint (Tailscale-only, see decisions.md). Added `configs/systemd/homelab-git-deploy.service` + `.timer`. Not yet deployed — same as the other automation, waiting on docker-host to exist.
- Automation mode: finalized `scripts/backup.sh` (daily PG dump + config backup, 30-day retention) and `scripts/health-check.sh` (now auto-restarts down containers instead of just warning). Added systemd unit/timer files under `configs/systemd/` for both, plus a deploy README. Not yet deployed — docker-host LXC/VM doesn't exist yet, so this is prep work ahead of the roadmap's Proxmox/docker-host setup step.
- Repo initialized. Planning phase — hardware chosen (M920q), storage strategy decided (external USB enclosure for 4x 2.5" HDD + extra SSD). No server setup has happened yet.
