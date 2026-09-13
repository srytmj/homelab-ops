# Roadmap

> What's planned, not what exists yet. Move items to CHANGELOG.md once done, and update architecture.md accordingly.

## Now

- [x] Pick and order hardware: Lenovo M710q (i7-7700, 32GB RAM), LM418 + M.2-SATA adapter, Seagate Barracuda 2TB HDD + external dock, Enhance ENP-2320 PSU + 24-pin jumper + Molex-to-SATA cables, TP-Link TL-LS1005G switch — no dedicated router this round (see decisions.md for actual cart prices)
- [x] Buy: HDD-Media (1TB, 2.5") and HDD-Cloud (1TB, 3.5") — purchased, exact model/price to log later
- [x] Source a multi-bay dock/enclosure for HDD-Media + HDD-Cloud — purchased, exact model/price to log later
- [ ] Source a small mount/dock solution for HDD-Backup (WD Blue 320GB) — the 4th drive, beyond the original 3-drive dock plan
- [ ] Physically assemble: OS SSD (M.2 SATA) into internal 2.5" bay via adapter; LM418 into M.2 slot; all 4 HDDs (Music/Media/Cloud/Backup) wired to LM418's SATA ports (4 of 5 used) into their dock(s); docks powered by the Enhance ENP-2320 (with 24-pin jumper installed so it powers on without a motherboard) via Molex-to-SATA cables; 3 reused PC fans wired to the PSU's spare Molex outputs for dock cooling; route cables through open backplate, cover RAM opening with magnetic mesh
- [x] Install Proxmox VE on M710q — done 2026-09-11, `pve.suryatmaja.dev` (192.168.18.224). Note: installed CPU verified as i5-7500 (4C/4T), not the purchased i7-7700 (4C/8T) — see architecture.md, unresolved discrepancy.
- [x] Create docker-host LXC (Ubuntu Server 24.04) — done 2026-09-11, LXC 100 (192.168.18.225), `nesting=1,keyctl=1` enabled, Docker Engine + Compose installed and verified
- [x] Mount all 3 active HDDs: `/mnt/hdd-music/`, `/mnt/hdd-media/`, `/mnt/hdd-cloud/` (ext4, permanent in `/etc/fstab`, staging cleaned, music relocated to `/mnt/hdd-music/jellyfin/music`). HDD-Backup (WD Blue 320GB) awaiting 4th dock solution.
- [x] Deploy Nginx Proxy Manager — done 2026-09-11, chosen over Traefik (user preference — GUI-first). First proxy host added: `portainer.home.arpa` → Portainer.
- [x] Deploy shared PostgreSQL + Redis — done 2026-09-11
- [ ] Deploy first batch of the 10 web projects — **started 2026-09-11: `portfolio` deployed** (`yorha-portfolio` container, port 3080, on docker-host) and `whitearchive` on `apps-host` (LXC 101). `malas`, `sso.whitearchive`, `pore-js` pending.
- [x] Set up Samba share on `/mnt/hdd-cloud/shared/` for Windows File Explorer network access (include `wsdd` daemon so it auto-discovers and appears directly under "Network" in Windows 10/11 Explorer without manual IP entry) — done 2026-09-12
- [x] Add hidden dashboard page to the existing `portfolio` repo — done (built in a separate Claude Code session).
- [x] Set up Cloudflare Tunnel (`cloudflared`) to expose `portfolio`, `dash`, `nextcloud`, `kavita` publicly — done 2026-09-12.

## Next

- [x] Deploy media stack: Jellyfin (movies/TV/anime + music), Nextcloud, Kavita — done, all mapped to real HDDs.
- [x] Set up Tailscale for remote access — done 2026-09-11, docker-host joined tailnet `srytmj.github` as `100.89.249.96` / `docker-host.taila813af.ts.net`.
- [x] Homelab Cockpit deployed on port 8050 — replaces Uptime Kuma, Netdata, Homelable, and absorbed container watchdog / git deploy flows.
- [x] Set up rclone & restic on docker-host (LXC 100) — done 2026-09-13.
- [x] Update `scripts/backup.sh` to target `/mnt/hdd-music/backups` fallback + rclone sync to Google Drive — done 2026-09-13.
- [ ] Connect rclone OAuth to Google Drive (idle 5TB, AI Pro) — headless OAuth setup pending.
- [ ] homelab-sentinel: Telegram bot (Python, `python-telegram-bot`) — consolidates monitoring alerts + interactive queries + whitelisted management + short QnA (Gemini API free tier). Needs: Telegram bot token (@BotFather), Gemini API key (AI Studio).
- [x] T3 Code ([pingdotgg/t3code](https://github.com/pingdotgg/t3code)) — deployed 2026-09-12 on port 9001.
- [x] Deploy Syncthing (file sync) — done, see CHANGELOG 2026-09-11 (13)
- [x] Deploy n8n (workflow automation) — done, see CHANGELOG 2026-09-11 (13)
- [x] Deploy Vaultwarden (password manager) — done, see CHANGELOG 2026-09-11 (13)
- [ ] Deploy Home Assistant (once the smart power plug with HA support arrives)
- [x] Deploy Reclip (self-hosted media downloader, yt-dlp wrapper with web UI) — done 2026-09-12, see services.md
- [x] Deploy LibreSpeed (self-hosted speed test) — done, see CHANGELOG 2026-09-11 (13)
- [ ] Deploy VaultS3 (lightweight S3-compatible object storage) — waiting for cross-drive placement.
- [x] Deploy qBittorrent (torrent client, web UI) — done 2026-09-12, see services.md
- [ ] Deploy SnapOtter — self-hosted file-processing toolkit (200+ tools: convert/compress/OCR/transcribe across image/video/audio/PDF).
- [ ] (no hosting needed) CodeFlow — single-HTML architecture-map tool.

## After base homelab is up and stable

- [ ] Deploy CapRover — mini hosting panel for friends to self-deploy their own CRUD web apps (~15 apps planned).
- [ ] Deploy MySQL/MariaDB via CapRover's One-Click Apps catalog, dedicated to the friends'-apps pool.
- [ ] Extend Cloudflare Tunnel for CapRover apps.

## Later / Ideas

- [ ] k3s sandbox environment (separate LXC, for learning Kubernetes — not for production)
- [ ] VLAN isolation between homelab and personal devices
- [ ] Jellyfin hardware transcode setup if a GPU-capable device becomes available
