| cloud-computing-docs | [srytmj/cloud-computing-docs](https://github.com/srytmj/cloud-computing-docs) | subdomain of suryatmaja.dev (TBD) | - | **Not yet built** — repo/web app doesn't exist yet, deploy later once created |
| ~~srytmj.github.io (blog)~~ | [srytmj/srytmj.github.io](https://github.com/srytmj/srytmj.github.io) | N/A — not deployed separately | - | **Not deployed as its own service.** Blog content now lives inside the `portfolio` repo instead — see the `portfolio` entry above. If this changes, re-check the `portfolio` repo for current state before assuming this is still accurate. |
| homelab-sentinel | [srytmj/homelab-sentinel](https://github.com/srytmj/homelab-sentinel) | N/A (Telegram bot, no domain) | - | Telegram bot (was Discord) — monitoring alerts + interactive queries + management + short QnA. See roadmap and decisions.md. Not a web app. |

| ... | | | | (fill in as more are deployed — 10 personal projects total planned) |

## Media Stack

| Service | Purpose | Port | Data location |
|---|---|---|---|
| Jellyfin | Movie/TV/anime streaming + music library (accessed via Feishin/foobar2000 as client, not Jellyfin web UI) | 8096 | `/mnt/hdd-media/jellyfin/{movies,tv,anime}` (1TB HDD) + `/mnt/hdd-music/jellyfin/music` (2TB HDD, 717GB live collection relocated 2026-09-13). |
| Nextcloud | File sync/storage | 8080 | `/mnt/hdd-cloud/nextcloud` — real HDD (sdd), 779GB free space available. Uses shared Postgres + Redis. |
| Kavita | Manga/comic reader | 5000 | `/mnt/hdd-media/manga-reader` — lightweight optimized WebP library auto-generated and mirrored by `manga-optimizer.service`. |

## Storage & Processing Pipelines

| Service / Daemon | Purpose | Host / Runtime | Data Paths |
|---|---|---|---|
| `manga-optimizer.service` | Real-time filesystem watcher + image optimizer. Detects CBZ files in raw master directory, optimizes heavy archives to WebP (max 2048px width, Q85), hardlinks existing WebP archives (0 disk waste), and mirrors folder hierarchy / renames / moves / deletions. | `docker-host` systemd service (`/usr/local/bin/manga-optimizer.py`) | Ingest/Master: `/mnt/hdd-media/manga-raw` (Samba `\\docker-host\manga`) <br> Target/Reader: `/mnt/hdd-media/manga-reader` |

## Monitoring

> Overlap check: 5 tools touch "monitoring" — each is scoped to a distinct concern to avoid
> duplication. See the boundary notes below before adding alerting to more than one.

| Service | Purpose | Port | Scope (to avoid overlap) |
|---|---|---|---|
| Scrutiny | HDD health monitoring (S.M.A.R.T.) | - | Drive-specific: Power-On Hours, Reallocated Sectors, temperature, historical SMART trends + failure-prediction alerts — distinct from Netdata's general resource metrics and not an uptime/container tool. **Not yet deployed** — needs real HDDs with SMART data, external storage not physically assembled yet. |
| homelab-sentinel (Telegram bot) | Docker container-level monitoring + Telegram alerts, PLUS interactive queries / whitelisted management / short QnA | - | Container health/resource (things Uptime Kuma's URL/TCP checks can't see) — owns Telegram notifications so Uptime Kuma's own alert integration isn't wired to Telegram in parallel. Also the interactive control surface (see decisions.md for the 3-tier capability design + guardrails). |

## Other Self-Hosted Apps
