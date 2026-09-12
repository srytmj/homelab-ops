# Homelab Operations - Instructions for Claude Code & All AI Agents

## Context

This repo manages a homelab server (Lenovo ThinkCentre M710q Tiny — purchased as i7-7700 4C/8T,
but the CPU physically installed verified as i5-7500 4C/4T, unresolved discrepancy, see
`docs/architecture.md` — 32GB RAM). Full current spec and topology: see `docs/architecture.md`.

Server runs Proxmox VE (hypervisor) + Docker (inside 1 Ubuntu LXC, `docker-host`), hosting a
growing list of personal web projects, a media stack (Jellyfin, Nextcloud, Kavita — no Immich,
no Navidrome, both dropped, see `docs/decisions.md`), shared PostgreSQL + Redis, and a large and
growing set of self-hosted tools. **`docs/services.md` is the actual current/planned service
list — this file's summary is not exhaustive, don't rely on it alone.**

## Before doing anything

0. **`git pull` first, every session, before reading anything else or making any change.**
   This repo is worked on from multiple devices (laptop, PC) and potentially multiple AI tools
   in parallel (see "Multi-agent / multi-tool use" below) — local files can be stale the moment
   a session starts. Never trust a file's on-disk state without pulling first.
1. Read `docs/architecture.md` for the current infrastructure state (source of truth for "what exists now")
2. Read `docs/roadmap.md` for planned next steps (source of truth for "what's planned")
3. Read `docs/decisions.md` if unsure why something is configured a certain way (source of truth for "why")
4. Read the last 10-15 entries of `CHANGELOG.md` for recent history (source of truth for "what changed recently")

Never assume the state of the server — always verify via SSH before making changes, since `docs/architecture.md` may lag behind reality if it wasn't updated after a manual change.

## Multi-Agent / Multi-Tool Synchronization Rules

This repo is worked on across multiple devices (laptop, desktop) and multiple AI agents/tools
(Claude Code, Google Antigravity/Gemini, Roo Code, Cursor, Copilot, etc.). There is NO shared runtime
memory between different AI platforms — **git + CHANGELOG.md + docs/*.md is the single source of truth.**

### 🚨 MANDATORY AI AGENT PROTOCOL (ANTI-HALLUCINATION & ANTI-MISINFO):
### ⚡ MANDATORY EXECUTION PERFORMANCE & ANTI-FREEZE RULES:
1. **Never Allow Tool Commands to Hang or Spawn Ghost Background Tasks**:
   - Always set `WaitMsBeforeAsync: 10000` (max sync) or run short-lived commands.
   - For commands that take time (e.g. `docker compose build`, reboot, container restarts), never let SSH hang interactively. Use bounded timeouts (`timeout 30s ...`) or run one-shot scripts that exit cleanly.
   - Never run `pct reboot` over blocking SSH inside the same container being rebooted.
2. **One-Shot Batched SSH Scripts**:
   - Instead of running 10 separate sequential read/check commands, batch inspection and execution into a single, clean Bash heredoc script over SSH.
3. **Keep Output Concise**:
   - Avoid verbose text explanations before or between tool calls. Be direct, factual, and confirm with live status codes.

1. **Mandatory Logging in CHANGELOG.md**:
   - **EVERY SINGLE ACTION** that modifies server config, deploys a container, updates an image, removes a service, changes mounts, or fixes a bug **MUST BE RECORDED IMMEDIATELY** in `CHANGELOG.md` with date, what changed, and rationale.
   - **DO NOT finish a session or transfer work without committing the log entry to Git.**
2. **Never Hallucinate / Guess Server State**:
   - Do NOT assume a service is running, installed, or broken based on outdated chat history or training assumptions.
   - **ALWAYS check live server state first** via SSH (`docker ps`, `systemctl status`, `df -h`, `ls -la`) before taking action or giving advice.
3. **Keep `docs/services.md` and `docs/architecture.md` in Sync**:
   - When a service or storage mount is added, removed, or remapped, immediately update the table in `docs/services.md` or `docs/architecture.md`.
4. **Git Sync Lifecycle**:
   - **Start of Session**: Run `git pull` before reading or modifying anything.
   - **End of Task / Session**: Run `git add .`, commit as user Maja (`git config user.name "Maja" && git config user.email "suryatmaja.dev@gmail.com"`), and push so the next AI agent picks up the exact real-world state.

## Modes of operation

Detect which mode fits the user's request. If ambiguous, ask.

### 1. Planning mode
Two sub-types:

**A. Homelab infrastructure planning**
- Hardware capacity decisions (RAM/storage/CPU sizing, external storage enclosures, etc.)
- Service architecture decisions (which service, why, trade-offs)
- Scaling roadmap (e.g. k3s sandbox, VLAN segmentation, external DAS storage)

**B. Claude Code operational planning (meta-level)**
- Deciding what to automate next (prioritize from `docs/roadmap.md`)
- Flagging when `docs/architecture.md` looks stale vs. actual server state
- Suggesting when a manual recurring task should become a script in `scripts/`

**In planning mode: discuss first, don't execute.** Only write to `docs/decisions.md` and/or `docs/roadmap.md` once something is actually decided. Never touch live server config in this mode.

### 2. Setup mode
When asked to install/configure something new:
1. SSH into the server (connection details in `docs/architecture.md`)
2. Execute the setup
3. Save the resulting docker-compose file to `configs/docker-compose/<service-name>.yml`
4. Update `docs/services.md` with the new service (port, purpose, data location)
5. Update `docs/architecture.md` if the topology changed (new mount point, new container, etc.)
6. Log the change in `CHANGELOG.md`

### 3. Maintenance mode
When asked to check/fix/troubleshoot:
1. SSH in, check logs (`docker logs`, `journalctl`, etc.)
2. Diagnose the issue, explain what's wrong before fixing
3. Ask before making any risky/destructive change (e.g. deleting volumes, restarting production containers during active use)
4. Log the fix in `CHANGELOG.md` once resolved

### 4. Automation mode
When asked to automate a recurring task:
1. Write the script in `scripts/`
2. Set up the cron job or systemd timer for it
3. Document what it does and how it's scheduled in `docs/services.md`
4. Log the addition in `CHANGELOG.md`

## Always

- Log every meaningful change to `CHANGELOG.md`: date, what changed, why (one or two lines is enough)
- Never commit secrets/passwords/API keys to this repo — reference `.env` files (gitignored) instead
- Prefer editing an existing docker-compose file over creating a duplicate service
- When storage paths are involved, remember: OS/Docker/projects/DB metadata live on the internal SSD; bulk media (Immich, Nextcloud, Jellyfin) lives on the external multi-bay HDD enclosure — see `docs/architecture.md` for exact mount paths
- Keep this file (`CLAUDE.md`) itself up to date if the operating conventions change — note that update in `CHANGELOG.md` too
- Git commits in this repo are authored as the user, not Claude — do NOT add a `Co-Authored-By: Claude` trailer to commit messages here
