# Roadmap

> What's planned, not what exists yet. Move items to CHANGELOG.md once done, and update architecture.md accordingly.

## Now

- [x] Pick and order hardware: Lenovo M710q (i7-7700, 32GB RAM), LM418 + M.2-SATA adapter, Seagate Barracuda 2TB HDD + external dock, Enhance ENP-2320 PSU + 24-pin jumper + Molex-to-SATA cables, TP-Link TL-LS1005G switch — no dedicated router this round (see decisions.md for actual cart prices)
- [x] Buy: HDD-Media (1TB, 2.5") and HDD-Cloud (1TB, 3.5") — purchased, exact model/price to log later
- [x] Source a multi-bay dock/enclosure for HDD-Media + HDD-Cloud — purchased, exact model/price to log later
- [ ] Source a small mount/dock solution for HDD-Backup (WD Blue 320GB) — the 4th drive, beyond the original 3-drive dock plan
- [ ] Physically assemble: OS SSD (M.2 SATA) into internal 2.5" bay via adapter; LM418 into M.2 slot; all 4 HDDs (Music/Media/Cloud/Backup) wired to LM418's SATA ports (4 of 5 used) into their dock(s); docks powered by the Enhance ENP-2320 (with 24-pin jumper installed so it powers on without a motherboard) via Molex-to-SATA cables; 3 reused PC fans wired to the PSU's spare Molex outputs for dock cooling; route cables through open backplate, cover RAM opening with magnetic mesh
- [ ] Install Proxmox VE on M710q (LXC, not VM, for docker-host — enable `nesting=1` container feature)
- [ ] Create docker-host LXC (Ubuntu Server 24.04)
- [ ] Mount all 4 HDDs: `/mnt/hdd-music/`, `/mnt/hdd-media/`, `/mnt/hdd-cloud/`, `/mnt/hdd-backup/` (each single drive, no RAID — see decisions.md). Spare 1TB 2.5" HDD stays unallocated for now.
- [ ] Deploy Traefik/Nginx Proxy Manager
- [ ] Deploy shared PostgreSQL + Redis
- [ ] Deploy first batch of the 10 web projects
- [ ] Give each Tailscale-only service its own subdomain (Tailscale MagicDNS/Serve) so the portfolio's hidden dashboard page can link to clean per-service hrefs

- [ ] Set up Samba share on `/mnt/hdd-cloud/shared/` for Windows File Explorer network access
- [x] Add hidden dashboard page to the existing `portfolio` repo — done (built in a separate Claude Code session); URLs still need to be filled in with real Tailscale subdomains once services are actually deployed
- [ ] Set up Cloudflare Tunnel to expose `portfolio` publicly — the one exception to Tailscale-only (see decisions.md)

## Next

- [ ] Deploy media stack: Jellyfin (movies/TV/anime + music), Nextcloud, Kavita
- [ ] Set up Tailscale for remote access
- [ ] Set up Uptime Kuma + Netdata/Glances + Scrutiny (HDD S.M.A.R.T. health monitoring) for monitoring
- [ ] Set up automated backup (Restic): DB dumps + config → **HDD-Backup** (WD Blue 320GB, physically separate dedicated drive); Nextcloud file data → **VaultS3**, cross-drive from HDD-Cloud (see decisions.md — must not target the same physical drive as the source). Offsite (Backblaze B2) deferred for now.
- [ ] Update `scripts/backup.sh` to target `/mnt/hdd-backup/` instead of the old external-enclosure path

- [ ] Discord bot (Python, discord.py) for server monitoring — status/alerts for containers & resource usage; built in a separate Claude Code session, not this repo's setup flow

- [ ] Deploy Syncthing (file sync)
- [ ] Deploy Shiori (bookmark manager)
- [ ] Deploy YOURLS (URL shortener)
- [ ] Deploy n8n (workflow automation)
- [ ] Deploy Alexandrie (self-hosted knowledge base / notes)
- [ ] Deploy Vaultwarden (password manager — lightweight community rewrite, NOT the official bitwarden/server which is heavier)
- [ ] Deploy Firefly III (personal finance/budgeting tracker)
- [ ] Deploy Home Assistant (once the smart power plug with HA support arrives)
- [ ] Deploy Homelable (self-hosted infra visualizer — network diagram + live health-check status, complements Uptime Kuma/homelab-sentinel)
- [ ] Deploy Reclip (self-hosted media downloader, yt-dlp wrapper with web UI)
- [ ] Deploy LibreSpeed (self-hosted speed test, for checking PC↔Homelab LAN speed and WAN speed)
- [ ] Deploy VaultS3 (lightweight S3-compatible object storage, for apps/backups that want an S3 target without paying for cloud storage)
- [ ] Evaluate Databasus as a replacement for `scripts/backup.sh` — adds PITR + restore verification + notifications (Discord/Slack/Telegram) vs. the current plain pg_dump script
- [ ] (on-demand only, not a standing container) FileWizard — file converter/OCR/transcription web UI, spin up only when needed since Whisper transcription is CPU-heavy
- [ ] (no hosting needed) CodeFlow — single-HTML architecture-map tool, run locally by opening its `index.html`, not deployed to docker-host

## After base homelab is up and stable

- [ ] Deploy CapRover — mini hosting panel for friends to self-deploy their own CRUD web apps (~15 apps planned, school/report assignments, low/no traffic — not public production apps). Requires Docker Swarm mode alongside the existing docker-compose setup. Set conservative per-app resource caps (~256-512MB each) as a safety net even though actual load is expected to be light.
- [ ] Deploy MySQL/MariaDB via CapRover's One-Click Apps catalog, dedicated to the friends'-apps pool — **separate instance from the existing shared PostgreSQL/Redis** used by the user's own 10 projects, since these are a different trust boundary
- [ ] Extend the Cloudflare Tunnel (already set up for `portfolio`) to also expose each friend's CapRover-hosted app publicly — second exception to Tailscale-only, same tunnel infrastructure reused

## Later / Ideas

- [ ] k3s sandbox environment (separate LXC, for learning Kubernetes — not for production)
- [ ] VLAN isolation between homelab and personal devices
- [ ] Jellyfin hardware transcode setup if a GPU-capable device becomes available
- [ ] CI/CD: GitHub Actions auto-deploy to homelab on push
- [ ] Explore T3 Code ([pingdotgg/t3code](https://github.com/pingdotgg/t3code)) — deploy on docker-host, Tailscale-only access, lets mobile/web/desktop control Claude Code (or other agent CLI) sessions remotely using existing subscriptions. Quality-of-life only — doesn't reduce Claude usage/billing, not a replacement for the AI ops-agent idea that was already dropped.
