# Decisions Log

> Records WHY something was chosen, so future-you (or Claude Code) doesn't re-litigate settled questions
> without new information. Add a new dated entry whenever a meaningful trade-off is decided.

## 2026-09-13 — Homelab Dashboard absorbs health-check, git auto-deploy, and backup timer; Tailscale serve & Scrutiny dropped

- **Systemd Timers (`health-check.timer`, `git-deploy.timer`, `homelab-backup.timer`) skipped**:
  - The user requested skipping these host-level systemd timers because **Homelab Dashboard (Cockpit)** already handles live container monitoring, health states, and project deploys natively.
  - Backup triggers and scheduling will also be built as a native feature directly into Homelab Dashboard / Cockpit rather than managing background systemd timers.
- **`tailscale serve` & `scrutiny` dropped**:
  - Container health and system metrics are visualized in Homelab Cockpit; drive SMART scrutiny is unnecessary for current scope.
  - Services are reached via Tailscale IP or Cloudflare Tunnel, eliminating the need for `tailscale serve` subdomains.
- **Backup Stack (`rclone` + `restic`) & HDD Music Staging Cleanup**:
  - `rclone` (v1.60.1) and `restic` (v0.16.4) installed on `docker-host` (LXC 100).
  - Cleaned up 1.3 TB of leftover migration staging (`from-sdb`, `from-sdd`) on `/mnt/hdd-music` (`/dev/sdc1`).
  - Relocated ~717 GB of music (`/mnt/hdd-cloud/Music` and `/mnt/hdd-media/Music`) into `/mnt/hdd-music/jellyfin/music`. This dropped HDD-Cloud usage from 90% down to 11% (freeing 779 GB).
  - Updated `scripts/backup.sh` with automatic fallback to `/mnt/hdd-music/backups` and optional offsite sync to `gdrive:homelab-backups` via `rclone`.

## 2026-09-10 — homelab-sentinel moved to Telegram, consolidated + scope expanded

Supersedes the 2026-08-26 "Discord monitoring bot scoped to monitoring only" decision. The bot
(`srytmj/homelab-sentinel` repo, still built in its own Claude Code session) moves from Discord
to **Telegram** (`python-telegram-bot`) and consolidates 4 roles into one bot:

1. **Push alerts** (the original monitoring job — container down, resource thresholds)
2. **Interactive read-only queries** — "disk usage?", "what's running?", "last backup?" — no
   state changes, low risk
3. **Short QnA** — general questions, via **Gemini API free tier** (Google AI Studio). This is
   a real, separate API product — NOT the Google AI Pro consumer subscription (which has no API
   and must not be reverse-engineered), and unrelated to the earlier-declined 9router.
4. **Whitelisted management** — a fixed menu of vetted actions (`/restart <service>`,
   `/deploy <project>`, `/backup-now`, `/logs <service>`), each mapped to a specific safe
   script. Destructive actions require a `/confirm` step.

**Explicitly NOT built:** arbitrary LLM-driven command execution (the "AI ops-agent" idea
already dropped). The bot cannot do anything outside its command whitelist — the LLM only
phrases answers / handles QnA, it does not decide and run shell commands.

**Auth:** the bot only responds to the owner's Telegram user ID (hardcoded allowlist); messages
from anyone else are ignored. Outbound-only connection to Telegram's API, consistent with
Tailscale-only (no inbound port).

**Why consolidate (vs. keeping a separate Discord alert bot + Telegram interactive bot):** one
bot, one codebase, one platform to check. Discord is dropped entirely.
