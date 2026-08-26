# Changelog

> Every meaningful change gets one entry here, newest on top. Keep it short: date, what changed, why (if not obvious).

## 2026-08-26
- Automation mode: added `scripts/git-auto-deploy.sh` — polls each project under `/opt/projects/*` every 5min for new commits on `main`, auto `git pull` + `docker compose up -d --build`. Chose polling over a GitHub webhook since the server has no public endpoint (Tailscale-only, see decisions.md). Added `configs/systemd/homelab-git-deploy.service` + `.timer`. Not yet deployed — same as the other automation, waiting on docker-host to exist.
- Automation mode: finalized `scripts/backup.sh` (daily PG dump + config backup, 30-day retention) and `scripts/health-check.sh` (now auto-restarts down containers instead of just warning). Added systemd unit/timer files under `configs/systemd/` for both, plus a deploy README. Not yet deployed — docker-host LXC/VM doesn't exist yet, so this is prep work ahead of the roadmap's Proxmox/docker-host setup step.
- Repo initialized. Planning phase — hardware chosen (M920q), storage strategy decided (external USB enclosure for 4x 2.5" HDD + extra SSD). No server setup has happened yet.
