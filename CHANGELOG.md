# Changelog

> Every meaningful change gets one entry here, newest on top. Keep it short: date, what changed, why (if not obvious).

## 2026-08-26
- **Storage topology finalized, corrected from earlier assumption.** Original plan assumed the OS SSD would be a standard 2.5" SATA SSD sitting in the internal 2.5" bay, with a separate USB DAS enclosure for extra HDDs. Corrected: the OS SSD is actually **M.2 SATA** form factor, so it needs an "M.2 SATA/mSATA to SATA 3.0 2.5\"" adapter to fit the internal bay at all. The M.2 NVMe slot is repurposed to host an **LM418 (M.2 NVMe to 5-port SATA) card** instead of holding a drive — this card's SATA ports are what an additional HDD (Toshiba 2TB) connects through, housed in an external powered dock (separate Imperion ATX 500W PSU) rather than a USB DAS enclosure. See `decisions.md` for full reasoning.
- Dropped the dedicated router purchase (MikroTik) for now — topology is ISP router → TP-Link TL-LS1005G Gigabit switch → PC + Homelab. Revisit a dedicated router only when VLAN isolation is actually implemented.
- Dropped from plan: 2nd HDD (single Toshiba 2TB is enough to start), electric dehumidifier (silica gel as cheaper fallback if needed), and likely the separate 2.5" HDD dock (superseded by the M.2-SATA-adapter-in-internal-bay setup).
- Logged final shopping list with reference pricing in `decisions.md`.
- Revised hardware pick from M920q (i5-9500T, 6C/6T, 16GB RAM) to M710q (i7-7700T, 4C/8T, 32GB RAM) — traded 2 physical cores for double RAM + higher clock speed after characterizing the actual workload as mostly I/O-bound (see decisions.md for full reasoning). Also decided Immich runs with ML disabled, removing the main compute-bound argument for prioritizing core count.

- Automation mode: added `scripts/git-auto-deploy.sh` — polls each project under `/opt/projects/*` every 5min for new commits on `main`, auto `git pull` + `docker compose up -d --build`. Chose polling over a GitHub webhook since the server has no public endpoint (Tailscale-only, see decisions.md). Added `configs/systemd/homelab-git-deploy.service` + `.timer`. Not yet deployed — same as the other automation, waiting on docker-host to exist.
- Automation mode: finalized `scripts/backup.sh` (daily PG dump + config backup, 30-day retention) and `scripts/health-check.sh` (now auto-restarts down containers instead of just warning). Added systemd unit/timer files under `configs/systemd/` for both, plus a deploy README. Not yet deployed — docker-host LXC/VM doesn't exist yet, so this is prep work ahead of the roadmap's Proxmox/docker-host setup step.
- Repo initialized. Planning phase — hardware chosen (M920q), storage strategy decided (external USB enclosure for 4x 2.5" HDD + extra SSD). No server setup has happened yet.
