# Decisions Log

> Records WHY something was chosen, so future-you (or Claude Code) doesn't re-litigate settled questions
> without new information. Add a new dated entry whenever a meaningful trade-off is decided.

## 2026-08-26 — Hardware: Lenovo M920q over other mini PC options

Chose M920q (i5-9500T, 6C/6T) over alternatives (M715q 4C/8T, HP 800 G6 6C/12T, HP 800 G3 4C/8T)
based on:
- Physical core count matters more than thread count for Docker containerization workload
- Best price-per-core among mini PC form factor options at the time
- 16GB RAM sufficient for planned service load (~8-10GB estimated usage, headroom ~6-8GB)

Rejected: 2-core options (M710q i3-7100, Lenovo M910Q i7-7500T) despite higher RAM in some listings —
core count bottleneck outweighs RAM headroom for this workload.

## 2026-08-26 — Storage: External USB enclosure instead of internal expansion

M920q Tiny form factor has only 1 internal 2.5" bay + 1 M.2 NVMe slot. Physically cannot fit
4x 2.5" HDD + 1 extra SSD internally. Decided on external USB 3.0 multi-bay enclosure (DAS)
rather than switching to a larger PC or separate NAS device, to keep the single-device setup.

## 2026-08-26 — Shared database instead of per-project database containers

One shared PostgreSQL container (multi-database) and one shared Redis container (per-project
key prefix + DB number) instead of one DB container per project. Reasoning: RAM savings
(~200-500MB overhead per DB instance would be wasted 10x over) outweigh the isolation benefit
for personal/low-traffic projects.

## 2026-08-26 — Defer external storage/enclosure decision, prioritize base homelab first

Belum finalisasi pilihan enclosure (2-bay vs 4-bay) dan strategi RAID/JBOD — masih riset harga
dan spek (lihat opsi ORICO 6228US3-C 2-bay vs 9948RU3/NS400RU3/WS400RU3 4-bay di percakapan
planning). Diputuskan untuk menunda keputusan ini dan fokus dulu ke instalasi Proxmox VE +
docker-host LXC/VM (item pertama di roadmap "Now"), supaya homelab inti jalan duluan sebelum
tenggelam di riset storage yang belum mendesak. Storage eksternal baru digarap begitu ada
kebutuhan nyata / drive sudah di tangan.

## 2026-08-26 — Hardware purchase finalized: mini PC, router, HDD

Final pick untuk kick-off homelab:
- **Mini PC:** Lenovo M920q, i5-9500T 6C/6T, RAM 16GB, SSD 256GB — Rp4.150.000
- **Router:** MikroTik RB750Gr3 (hEX, gigabit ports) — Rp1.228.881
- **HDD:** 2TB 2.5" (second, SMART 100/100) — Rp900.000

Router dipilih gigabit (RB750Gr3) alih-alih model Fast Ethernet (RB941/RB750r2) supaya
transfer file LAN antara homelab dan device lain nggak dibottleneck di 100Mbps.

## 2026-08-26 — Discord monitoring bot scoped to monitoring only, no chat QnA via Claude Pro

Planned a Discord bot (Python, discord.py) for server monitoring (container/resource status,
alerts) — deployed as its own container on docker-host, outbound-only connection to Discord's
API (no inbound port needed, consistent with Tailscale-only access). Code will be written in a
separate Claude Code session, not as part of this repo's setup flow.

Chat QnA feature (asking Claude questions via the bot) dropped from scope for now: it would need
a Claude API key (console.anthropic.com, pay-per-token billing) — a Claude Pro subscription is
for personal use via claude.ai and isn't meant for programmatic/bot integration, so it can't be
reused here. Revisit if/when a dedicated API key is set up.

## 2026-08-26 — Music via Jellyfin, drop Navidrome

Consolidated music into Jellyfin's own music library instead of running a separate Navidrome
container. Access via third-party clients (Feishin — native Jellyfin API support; foobar2000 —
via a Subsonic-bridge plugin) rather than Jellyfin's web UI for music. Reasoning: one fewer
always-on service saves RAM on a 16GB box, and the client-side app covers most of what a
dedicated music server (Navidrome) would add. Trade-off: Jellyfin's own music features
(scrobbling, smart playlists) are weaker than Navidrome's, mostly offset by the client app.

## 2026-08-26 — Auto-deploy via git polling, not GitHub webhook

For auto-deploying the 10 web projects on push, chose a systemd-timer poll loop
(`scripts/git-auto-deploy.sh`, every 5 min: `git fetch` + compare HEAD, `git pull` +
`docker compose up -d --build` on change) over a GitHub webhook receiver. A webhook would need
a public-facing endpoint on the server, which conflicts with the Tailscale-only access decision
below — no ports forwarded to the public internet. Trade-off accepted: up to ~5min deploy delay
instead of instant push-to-deploy.

## 2026-08-26 — Remote access via Tailscale, not port forwarding

Chose Tailscale VPN mesh over traditional port forwarding for accessing homelab services
remotely. Reasoning: avoids exposing services directly to the public internet, works
regardless of whether the ISP uses CGNAT, and simplifies access to internal-only tools
(SMB/NFS shares) that shouldn't be public anyway.
