# Roadmap

> What's planned, not what exists yet. Move items to CHANGELOG.md once done, and update architecture.md accordingly.

## Now

- [x] Pick and order hardware: Lenovo M710q (i7-7700T, 32GB RAM, 256GB SSD), MikroTik RB750Gr3, 2TB 2.5" HDD (see decisions.md)
- [ ] Install Proxmox VE on M710q
- [ ] Create docker-host LXC/VM (Ubuntu Server 24.04)
- [ ] Set up external multi-bay USB enclosure for the 4x 2.5" HDD + extra SSD
- [ ] Mount external storage, decide on filesystem/RAID approach (document reasoning in decisions.md)
- [ ] Deploy Traefik/Nginx Proxy Manager
- [ ] Deploy shared PostgreSQL + Redis
- [ ] Deploy first batch of the 10 web projects

- [ ] Set up Samba share on `/mnt/hdd2tb/shared/` for Windows File Explorer network access

## Next

- [ ] Deploy media stack: Jellyfin (movies/TV + music), Immich, Nextcloud, Kavita
- [ ] Set up Tailscale for remote access
- [ ] Set up Uptime Kuma + Netdata/Glances for monitoring
- [ ] Set up automated backup (Restic/Duplicati) for DB + config volumes

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
- [ ] Deploy VaultS3 (lightweight S3-compatible object storage, for apps/backups that want an S3 target without paying for cloud storage)
- [ ] Evaluate Databasus as a replacement for `scripts/backup.sh` — adds PITR + restore verification + notifications (Discord/Slack/Telegram) vs. the current plain pg_dump script
- [ ] (on-demand only, not a standing container) FileWizard — file converter/OCR/transcription web UI, spin up only when needed since Whisper transcription is CPU-heavy
- [ ] (no hosting needed) CodeFlow — single-HTML architecture-map tool, run locally by opening its `index.html`, not deployed to docker-host

## Later / Ideas

- [ ] k3s sandbox environment (separate LXC, for learning Kubernetes — not for production)
- [ ] VLAN isolation between homelab and personal devices
- [ ] Jellyfin hardware transcode setup if a GPU-capable device becomes available
- [ ] CI/CD: GitHub Actions auto-deploy to homelab on push
