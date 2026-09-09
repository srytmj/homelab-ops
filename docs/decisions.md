# Decisions Log

> Records WHY something was chosen, so future-you (or Claude Code) doesn't re-litigate settled questions
> without new information. Add a new dated entry whenever a meaningful trade-off is decided.

## 2026-09-09 — Blog merged into `portfolio`, srytmj.github.io repo no longer deployed

Plan changed: the blog is no longer a standalone deployment (superseding the 2026-08-26 "Blog
deployed on homelab" decision below). The `portfolio` repo now contains the blog content
directly, so the separate `srytmj/srytmj.github.io` repo is **not deployed** as its own service
— it's effectively retired from the infrastructure (the GitHub repo itself may still exist, just
isn't part of what gets deployed to the homelab).

**Important for future sessions:** `portfolio` is under active development in its own Claude
Code session and is evolving — re-fetch/re-read that repo before assuming its current state
(structure, routes, whether the blog integration changed again) rather than relying on this
note alone.

## 2026-08-26 — qBittorrent deployed without a VPN wrapper (cost trade-off)

Considered qBittorrent + Gluetun (VPN container, killswitch) as the standard privacy-conscious
self-hosted torrenting setup. Compared Mullvad (~€5/mo flat, all servers P2P-enabled, anonymous
signup) vs ProtonVPN (paid tier needed for P2P — free tier doesn't support it) vs Kaspersky VPN
(deprioritized: Russian jurisdiction/data-retention concerns, US sales ban in 2024, P2P support
unclear/likely restricted on consumer-suite-bundled VPNs).

**Decided: deploy qBittorrent without any VPN for now**, purely a budget call — user chose to
skip the recurring VPN cost. Consequence, discussed and accepted: the homelab's public IP is
directly exposed to torrent swarms (no anonymity layer), which carries real exposure risk
proportional to what's actually downloaded — full responsibility on the user for what content
that entails. Revisit adding Gluetun + Mullvad later if budget allows; the docker-compose
structure should be built so a VPN container can be inserted in front of qBittorrent later
without a rebuild (route qBittorrent's network through a sidecar container from the start, even
if that sidecar isn't a VPN yet).

## 2026-08-26 — Offsite backup (Tier 2) revived: rclone → idle Google Drive 5TB, no added cost

Supersedes the "Tier 2 (offsite) — explicitly deferred" part of the earlier file-data-backup
decision. Offsite backup is no longer deferred, now that an idle Google Drive (AI Pro, 5TB) is
available — this removes the recurring-cost objection that motivated deferring Backblaze B2.

- **Tool: rclone**, connected via Google Drive's official OAuth API — standard, ToS-compliant
  method (not a rate-limit-circumvention scheme; unrelated to the earlier-declined 9router
  request, which pooled multiple accounts to exceed per-account limits). A dedicated Google
  Cloud API client (set up once, free) is used instead of rclone's shared default client, to
  avoid shared rate-limit slowdowns during scheduled syncs.
- **Sync, not live mount** — cold storage should be periodic scheduled sync (new script +
  systemd timer, same pattern as `backup.sh`/`git-auto-deploy.sh`), not a live FUSE mount. A
  live mount is fragile (network-dependent) and unnecessary for data that's rarely accessed.
- **Scope:** Restic backups (DB dumps, config, Nextcloud) get pushed to Google Drive via
  rclone as a Restic backend, on top of the existing local targets (HDD-Backup for DB+config,
  VaultS3 for Nextcloud). Optionally, rarely-accessed media archives could also go here later.
- Backblaze B2 remains a non-priority alternative — no longer needed given the free idle
  capacity already available via Google Drive.

## 2026-08-26 — WD Blue 320GB (idle/owned) assigned as dedicated backup drive; RAID1 for HDD-Cloud considered and deferred

An idle WD Blue 3.5" 320GB HDD (already owned) is assigned as **HDD-Backup**, a dedicated
Restic backup target for `scripts/backup.sh`'s DB dumps + config archives. Physically separate
from HDD-Music/Media/Cloud, so it protects against any of those 3 drives failing — not just
accidental deletion. 320GB is plenty for DB dumps + config with 30-day retention (small,
KB-MB scale, not bulk media).

Also acquired a 2nd 1TB 2.5" HDD, which opened up the option of RAID1-mirroring HDD-Cloud
(pairing the two 1TB drives, one 2.5" one 3.5", to add redundancy for Nextcloud/VaultS3 — the
highest-priority, hardest-to-replace data category). **Deferred, not rejected** — sticking with
the original single-drive-per-category plan (no RAID) for now. The 2nd 1TB 2.5" HDD is an
unallocated spare, available if this gets revisited later.

**Cooling finalized:** the multi-bay dock (for HDD-Media + HDD-Cloud) was bought without a
built-in fan — cooling comes from 3 reused fans salvaged from an old PC instead, all natively
Molex-powered (no adapter needed). 1 fan for the HDD-Music dock, 2 for the multi-bay dock. This
conveniently uses exactly the Enhance ENP-2320's spare 3 Molex outputs (2 are already used by
the Molex-to-SATA splitters). Reasoning for fans at all (vs. none): HDDs running 24/7 need
active airflow — heat is one of the biggest drivers of drive failure, and the cost of reused
fans is zero. Lower RPM from reused fans is fine since HDDs need adequate airflow, not high
static pressure/velocity.

## 2026-08-26 — Drop Immich, use Google Drive for personal photos instead

Immich removed from the media stack entirely (superseding the earlier "Photo management: Immich
with ML disabled" decision). Reasoning: the user doesn't store a large photo collection and is
fine using Google Drive for personal photos instead of self-hosting. `HDD-Media`'s image
category (anime/phone/pc/laptop) becomes a plain unmanaged `images/` folder — no app, no
database, just files organized manually. This also further reduces CPU workload (thumbnail/video
preview generation was one of the moderate background-job CPU consumers identified during the
CPU/workload discussion), though that wasn't the primary reason.

## 2026-08-26 — git-auto-deploy builds run strictly sequentially, never in parallel

Confirmed as an explicit requirement (already the default behavior of the existing
`scripts/git-auto-deploy.sh` — plain bash `for` loop, no backgrounding): when the poller detects
multiple projects with new commits in the same cycle, it builds them **one at a time**, not
concurrently. Reasoning: `docker compose up -d --build` is the single heaviest CPU spike in this
homelab's workload (see the CPU/workload-ranking discussion). On a 4-core box, letting multiple
builds run simultaneously would stack those spikes and degrade every other service's
responsiveness far more than the extra wall-clock time of a sequential queue costs. Added an
explicit comment in the script itself so this isn't accidentally "optimized" into parallel later.

## 2026-08-26 — CapRover for friend-hosted apps, not literal cPanel

Considered building a cPanel-like self-service hosting panel so friends can deploy their own
web apps on the homelab. Rejected literal cPanel/WHM (paid license, not Docker-native, built
for classic shared PHP hosting). Chose **CapRover** instead — self-hosted PaaS, git-push-to-
deploy, Docker-based, web UI, built-in reverse proxy + auto Let's Encrypt SSL, per-app resource
limits.

**Scope clarified during discussion:** target users are known friends only (not the public at
large), and actual use case is ~15 lightweight CRUD apps (school/report assignments) with
low-to-no traffic — not production apps expected to see real visitor load. This significantly
lowers the resource-risk profile from the original "public hosting" framing: estimated total
footprint is ~3-5GB RAM (CapRover control plane + Nginx + 15 light apps), comfortably fits
within the 32GB box. Per-app resource caps (~256-512MB) still set as a cheap safety net against
a runaway/buggy app taking down others, even though real load is expected to be light.

**Guardrails decided:**
- **Separate database instance** for friends' apps (MySQL/MariaDB via CapRover's One-Click Apps
  catalog) — kept isolated from the existing shared PostgreSQL/Redis used by the user's own 10
  projects, since friends' app code is a different trust boundary than the user's own code.
- **Second exception to Tailscale-only access**, alongside the `portfolio` project — friends'
  apps need public reachability for their own visitors/graders to view them. Reuses the same
  Cloudflare Tunnel infrastructure already planned for `portfolio` rather than standing up a
  separate exposure mechanism.
- **Technical note:** CapRover requires Docker Swarm mode, which needs to coexist with the
  existing plain docker-compose setup on the same Docker Engine — generally compatible, but
  worth checking overlay-network behavior during setup since it differs from bridge networking.

**Sequencing:** this is explicitly deferred until after the base homelab (Proxmox, docker-host,
core services) is up and stable — not part of the initial setup push.

## 2026-08-26 — File data backup: local cross-drive Restic → VaultS3, offsite deferred

Addresses the gap noted in the "3 dedicated HDDs" decision below (no backup existed for actual
file content, only for the Postgres DB). Plan:

- **Priority by replaceability**, not backing up everything equally:
  - 🔴 Nextcloud (personal files) — high priority
  - 🟡 Jellyfin (movies/TV/music) and Kavita (manga) — low priority, re-downloadable, skipped for now
  - ~~Immich~~ — dropped from the stack entirely (see the later "Drop Immich" decision above,
    superseding this priority list), personal photos go to Google Drive instead
- **Tier 1 (local, decided now):** Restic snapshots of Nextcloud (once it's online) targeting
  **VaultS3** as the backend. Must be **cross-drive**: Nextcloud lives on HDD-Cloud, so its
  Restic target needs to actually live elsewhere (not another folder on the same physical
  HDD-Cloud drive) for the backup to protect against that drive failing — backing up to the
  *same* physical drive as the source only guards against accidental deletion/corruption, not
  drive failure. Zero additional monthly cost since VaultS3 is already self-hosted.
- **Tier 2 (offsite, e.g. Backblaze B2) — explicitly deferred, not rejected.** Would protect
  against whole-site loss (fire, theft, drive failure without a working local backup at that
  moment) but adds a recurring monthly cost. Skipped for now by choice; revisit once budget
  allows or the file collection grows large enough that the risk feels more concrete.

This backup job is the same `scripts/backup.sh`-style automation already planned in
`roadmap.md`'s "Set up automated backup (Restic)" item — scope is expanded to include Nextcloud
file data, not just the DB.

## 2026-08-26 — FINAL: 3 dedicated HDDs instead of 1 shared drive

Supersedes the single-HDD (`/mnt/hdd2tb/`) storage plan. Final topology is **3 separate,
single-purpose drives**, no RAID/pooling:

- **HDD-Music** (2TB, 3.5", the already-purchased Toshiba drive) — music only, for Jellyfin
- **HDD-Media** (1TB, 2.5", new purchase needed) — movies/TV, manga, images, and anime (both
  video and pictures — anime video goes through Jellyfin like movies/TV, anime images go through
  Immich's External Library like other image categories)
- **HDD-Cloud** (1TB, 3.5", new purchase needed) — Nextcloud + VaultS3

Reasoning: splitting by content category (rather than one pooled drive) means a single drive
failure only takes out that category — e.g. losing HDD-Cloud doesn't touch music or media. No
RAID/redundancy within each drive, consistent with the earlier "single drive, no RAID needed
yet" call — this is now the working assumption across all 3 drives, not just one.

**Open items this creates:**
- **Physical docking:** the original plan only had 1 external 3.5" dock (for HDD-Music via the
  LM418 card). A multi-bay dock/enclosure still needs to be sourced for HDD-Media (2.5") and
  HDD-Cloud (3.5"). LM418 itself has spare SATA ports (5 total, 1 used), so this is a
  docking/enclosure and cabling gap, not a controller-capacity gap. Imperion PSU capacity for
  3 drives vs. 1 should be double-checked when sourcing the new dock, though HDD power draw is
  low enough this is likely a non-issue.
- **No backup for file data:** `scripts/backup.sh`/Databasus cover PostgreSQL only. Nothing yet
  backs up the actual Immich/Nextcloud/Jellyfin file content across these 3 drives — worth
  addressing once they're online, especially for irreplaceable personal data like photos.

## 2026-08-26 — Custom hidden dashboard page in `portfolio`, drop separate Homepage service

Supersedes the earlier "Homepage dashboard + public portfolio with hidden link" decision's
dashboard choice. **No separate Homepage (gethomepage.dev) service is deployed.** Instead, the
existing `portfolio` repo (github.com/srytmj/portofolio) gets a custom-built hidden page that
itself acts as the dashboard — a list of hrefs to every homelab service, each linking to that
service's own **Tailscale subdomain**. Reasoning: portfolio repo is already built and preferred
over standing up a whole extra service just for a launcher page; a custom page is simpler and
fully under the owner's control (styling, trigger mechanism, etc.) than configuring a
third-party tool.

The access-control design from the superseded decision still holds: the portfolio is the
**one exception** to Tailscale-only, exposed publicly via **Cloudflare Tunnel**. Every service
it links to (including this hidden dashboard's targets) resolves only over Tailscale — so even
if the hidden page/trigger is discovered, the linked URLs are unreachable off the tailnet. Each
Tailscale-only service gets its own clean subdomain (via Tailscale MagicDNS/Serve) specifically
so this hidden page has clean per-service hrefs to link to, rather than raw IPs/ports.

## 2026-08-26 — FINAL: storage topology via LM418 + M.2-SATA adapter, no USB DAS enclosure

Supersedes the earlier "External USB enclosure instead of internal expansion" decision — that
plan (4-bay USB DAS enclosure) is dropped. Instead, the M710q/M910q's 2 physical drive slots are
repurposed to fit 2 drives without an external USB enclosure:

- **M.2 slot (NVMe-capable)** hosts an **LM418 card** (M.2 NVMe to 5-port SATA expansion), not a
  drive directly. This is what makes room for an additional HDD beyond the chassis' nominal 1
  M.2 + 1 2.5"-bay limit.
- **Internal 2.5" bay (native SATA)** holds the **OS SSD**, which is physically an **M.2 SATA**
  drive (not standard 2.5"), connected via an "SSD M.2 SATA/mSATA to SATA 3.0 2.5\"" adapter.
  This was a correction from an earlier wrong assumption that the OS SSD was a standard 2.5" or
  M.2 NVMe drive (see CHANGELOG.md) — it's actually M.2 SATA form factor, which is why an adapter
  is needed to fit the native 2.5" bay at all.
- **Additional HDD (Toshiba 2TB 7200RPM 3.5")** connects via the LM418's SATA port #1, physically
  housed in an **external Docking Rak Stand HDD 3.5" (with fan)** sitting outside the case —
  not inside the M710q chassis.
- **Power:** the external HDD dock draws from a **separate Imperion ATX 500W PSU**, not the
  M710q's internal PSU (insufficient capacity for the external dock). Two independent power
  domains.
- **Case modification:** the backplate is left open to route SATA data + power cables from the
  LM418 to the external dock; the remaining opening over the RAM is covered with a magnetic mesh
  panel for basic protection (not a full enclosure fix, but reasonable given the DIY routing).

Reasoning: this reuses the Tiny form factor's existing 2 physical drive slots more creatively
(1 slot repurposed as a SATA-port expansion riser) instead of buying a separate USB enclosure,
at lower cost. Filesystem/RAID decision deferred — starts as a single HDD, no RAID needed until
a second drive is added.

## 2026-08-26 — Skip dedicated router (MikroTik) for now, ISP router + Gigabit switch only

Supersedes the earlier "Hardware purchase finalized" decision's router pick (MikroTik RB750Gr3)
and the later RB941-2nD consideration. **No dedicated router is being deployed for now** —
topology is just: ISP router (house WiFi) → TP-Link TL-LS1005G Gigabit switch → PC + Homelab.

Reasoning: a second router (MikroTik or otherwise) was being considered for network isolation
between homelab and personal devices, but that's a `roadmap.md` "Later/Ideas" item (VLAN
isolation), not a current need — skipped for budget efficiency until actually needed. The
Gigabit switch alone already solves the original problem that motivated a router upgrade
(PC↔Homelab file transfer speed): switch-port-to-switch-port speed isn't limited by the ISP
router's own port speed, so Gigabit transfer works regardless of what router sits upstream.

If/when VLAN isolation is actually implemented, a dedicated router (MikroTik or otherwise)
gets revisited then — not before.

## 2026-08-26 — Items removed from plan (budget efficiency)

- **2nd HDD (2TB, "Sentinel" second-hand):** dropped — one HDD (Toshiba 2TB 7200RPM 3.5", new)
  is enough to start. No RAID/multi-drive redundancy for now; revisit if/when capacity runs out.
- **Electric dehumidifier:** dropped — if humidity turns out to be a real problem once the
  external HDD dock is running, cheaper silica gel packs are the fallback to try first before
  spending on an electric unit.
- **Docking Rak Stand HDD 2.5" (separate from the 3.5" HDD dock):** status unclear, likely not
  needed anymore — the OS SSD (M.2 SATA) now sits in an adapter inside the *internal* 2.5" bay,
  not in a separate external 2.5" dock. Revisit only if a reason to externally dock a 2.5" drive
  comes up later.

## 2026-08-26 — Final shopping list (actual cart prices at checkout)

Supersedes all earlier price estimates — these are the real per-item prices from the final
Shopee cart across multiple sellers, with 2 corrections noted below.

| Item | Price |
|---|---|
| Mini PC M710q, i7-7700 (Gen 7), 32GB RAM, no SSD | Rp4.304.775 |
| HDD Seagate Barracuda 2TB 3.5" (HDD-Music) — desktop-class, not NAS-rated; the originally-planned Toshiba sold out | Rp950.000 |
| Docking Rak Stand HDD 3.5" with fan — HDD-Music | Rp265.000 |
| Enhance ENP-2320 PSU Flex ATX 200W (Active PFC, 20pin + 5x Molex 4pin) | Rp250.000 |
| LM418 M.2 NVMe to 5-port SATA card — **cart had qty 2 by mistake, corrected to qty 1 before checkout** | Rp245.000 |
| SATA to M.2 SATA NGFF converter, with casing (OS SSD adapter for the internal 2.5" bay) | Rp54.999 |
| TP-Link TL-LS1005G Switch Gigabit 5-port | Rp134.800 |
| Hannochs Smart Device 02 Power Strip (power monitoring) | Rp304.400 |
| Kabel Molex to Triple SATA power splitter | Rp24.999 |
| Kabel Molex Female to Dual SATA power splitter | Rp22.999 |
| 24-pin ATX PSU jumper (power-on switch, runs the PSU without a motherboard) | Rp12.999 |
| SATA data cable 6Gbps, x5 | Rp47.500 |
| Vention Cat6A Ethernet cable, 1m | Rp34.176 |
| Kabel LAN server Belden Cat6, 20cm + 70cm + 10cm | Rp43.399 |
| Rak Buku 3 Tingkat | Rp95.000 |
| **Subtotal (merchandise, corrected)** | **~Rp6.790.046** |

Still not purchased/priced: HDD-Media (1TB 2.5"), HDD-Cloud (1TB 3.5"), and a multi-bay
dock/enclosure for those two drives (the single dock above only covers HDD-Music) — see
`roadmap.md`.

(Excludes personal non-homelab items like a laptop holder, and per-item Shopee protection
add-ons/shipping which vary by order.) This replaces both the earlier estimated shopping list
and the PSU-only price update below it.

## 2026-08-26 — PSU switched to Enhance ENP-2320, not the cheap Imperion 500W

Supersedes the Imperion ATX 500W PSU pick from the earlier shopping list. Switched to
**Enhance ENP-2320** (Flex ATX, 200W, Active PFC, Rp250.000) for the external HDD dock's power
supply. Reasoning: cheap/no-name PSUs (like the Imperion at Rp110.808 for a claimed 500W) often
lack real voltage regulation and protections (OVP/OCP/SCP), risking power spikes that damage
HDD controller boards — a real risk, not just caution. Enhance is an established
industrial/server PSU brand (used in some branded NAS units) with Active PFC and full-range
input, trading a inflated-but-unreliable 500W rating for a real, trustworthy 200W — plenty for
3 HDDs' actual draw (~20-60W even at worst-case simultaneous spin-up).

Since this PSU only powers the external dock (no motherboard attached), it needs a **24-pin ATX
jumper** (shorts PS_ON to Ground so the PSU powers on without a motherboard signal — commonly
sold as a "mining PSU jumper/switch") plus Molex-to-SATA power cables for each drive.

## 2026-08-26 — Considered and rejected: used Xeon E5 server PC (12-20 core)

Found several used Xeon E5-2673 V3/V4 and E5-2686 V4 "server PC" listings (12-20 physical
cores, DDR3/DDR4 ECC 32-128GB, Rp4-6.3jt) and considered switching from the M710q i7-7700 pick.
**Rejected, staying with M710q i7-7700.** Reasoning:

- **Idle power draw dominates long-term cost.** These Xeons have 105-145W CPU TDP alone vs.
  the M710q's 65W (later confirmed to be the non-T i7-7700, not the originally-assumed 35W
  i7-7700T — see the CPU correction decision below); full-system idle is still likely 40-100W
  higher on the Xeon side once the X99 board, ECC RAM, and GT610 GPU overhead are counted. At
  24/7 uptime that's still roughly Rp700rb-1 million/year in extra electricity — still enough to
  matter over a few years, even if the gap is smaller than first estimated.
- **More cores/threads give zero benefit here** — same "characterize the workload first"
  principle as the earlier M920q→i7-7700 reversal (see that decision above). The actual
  workload (I/O-bound web apps + direct-play media) doesn't benefit from 12-20 physical cores.
  Confirmed with the user this was a "cheap now" temptation, not a concrete compute need.
- The bundled GT610 GPU is dead weight (no NVENC, Jellyfin already direct-play only) that adds
  idle draw for zero use.
- All the storage-topology planning already done (LM418 riser, M.2-SATA adapter, magnetic mesh
  backplate mod) is specific to the M710q Tiny form factor's constraints — a tower Xeon board
  doesn't need any of it, but switching would mean redoing the whole plan for no workload gain.
- Used decade-old server boards carry more unknown-condition risk (thermal paste, capacitors,
  prior duty cycle) than a mini PC platform, with less certainty they're suited to sustained
  home (non-datacenter-airflow) operation.
- DDR3-64GB-ECC vs DDR4-32GB-non-ECC RAM trade-off (quad-channel bandwidth, ECC data integrity)
  was also weighed — real advantages on the Xeon side, but still bundled with the same power/
  noise/platform downsides above, and 32GB is already sufficient for the actual workload.

## 2026-08-26 — Skip self-hosted AI ops-agent, stick with Claude Code

Considered running a self-hosted AI agent (e.g. OpenHands) on the homelab to handle
planning/automation/maintenance/setup for this repo via a web chat UI, so as not to consume
Claude Code/Pro usage. Decided to skip for now — no GPU on the M710q means a local LLM would be
too weak/slow for this kind of work, and a capable hosted model would still cost per-token
regardless of self-hosting the agent shell. Sticking with Claude Code (this repo's existing
planning/setup/maintenance/automation modes in `CLAUDE.md`) instead. Revisit only if a concrete
need for a always-available, non-Claude-usage ops interface comes up.

## 2026-08-26 — Hardware: Lenovo M920q over other mini PC options

Chose M920q (i5-9500T, 6C/6T) over alternatives (M715q 4C/8T, HP 800 G6 6C/12T, HP 800 G3 4C/8T)
based on:
- Physical core count matters more than thread count for Docker containerization workload
- Best price-per-core among mini PC form factor options at the time
- 16GB RAM sufficient for planned service load (~8-10GB estimated usage, headroom ~6-8GB)

Rejected: 2-core options (M710q i3-7100, Lenovo M910Q i7-7500T) despite higher RAM in some listings —
core count bottleneck outweighs RAM headroom for this workload.

## 2026-08-26 — REVISED: i7-7700 (4C/8T) over M920q i5-9500T (6C/6T)

Supersedes the earlier "Hardware: Lenovo M920q over other mini PC options" decision.
That decision assumed physical core count > thread count for this workload without
first characterizing what the actual workload looks like. After breaking down the
real service list (5 web projects, Discord bot, Jellyfin/Immich/Nextcloud/Kavita,
Tailscale, git-polling auto-deploy, daily backup), the assumption doesn't hold:

**Original reasoning (M920q) was wrong because:**
- It generalized "containerization = needs more physical cores" without checking
  if the workload is actually compute-bound or I/O-bound
- It didn't account for what RAM is used for beyond "just fitting more containers"
  (DB caching, ML memory footprint, avoiding swap)

**Actual workload characterization:**
- 5 web projects (Laravel/Node CRUD) — I/O-bound, not compute-bound
- Jellyfin — negligible CPU if direct play (no transcoding); lossless music streaming
  is essentially free
- Immich — the one clearly compute-heavy service (face/object detection), BUT decided
  separately to disable ML or use Nextcloud Photos instead (see photo-management
  decision below), removing this as a core-count argument
- homelab-sentinel (Discord bot) — long-running, mostly idle, benefits from single-thread
  clock speed when it does act, not from having many physical cores
- git-polling auto-deploy — the only genuinely CPU-intensive spike (build/compile),
  but timing is user-triggered, not concurrent with unpredictable public traffic

**Why i7-7700 (4C/8T, 32GB RAM) fits better:**
- Higher clock speed (3.6GHz base vs 2.2GHz base) benefits I/O-bound + bursty workloads
  more than raw core count does
- 8 threads still covers reasonable concurrency for containers mostly waiting on I/O
- 32GB RAM (vs 16GB) gives real benefit: Postgres/OS page cache, headroom for a future
  k3s sandbox LXC alongside production, and insurance against RAM prices rising further
  ("RAMageddon" — RAM was cheaper to buy in bulk now than to upgrade piecemeal later)
- Price difference to M920q was marginal (~150k), so the RAM/clock advantage outweighed
  giving up 2 physical cores

**Trade-off accepted:** if git-polling build and a traffic spike and (hypothetically)
heavy ML processing all collide at the same moment, 4 cores could bottleneck harder
than 6 cores would. Judged unlikely for a personal homelab with self-triggered deploys.

**Lesson for future decisions:** don't apply a general infra rule of thumb
("more cores = better for Docker") without first listing the actual services and
classifying each as I/O-bound vs compute-bound. The generalization in the original
M920q decision was the root cause of needing this reversal.

## 2026-08-26 — Photo management: Immich with ML disabled

Immich will run with machine-learning features (face recognition, object/scene detection)
disabled. Reasoning: ML inference was the single heaviest CPU-bound workload under
consideration and the main argument for prioritizing physical core count in hardware
selection (see hardware decision above) — disabling it removes that argument and lets the
i7-7700 (4C/8T) pick stand without a compute-bound bottleneck. Core photo backup/gallery
features are unaffected; only smart search/face-grouping are unavailable.

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

## 2026-08-26 — Blog (srytmj.github.io) deployed on homelab, not GitHub Pages

**Superseded 2026-09-09 — see entry below.** The blog is no longer a separate deployment; it's
now part of the `portfolio` repo. Kept here for history.

Despite the `.github.io` naming (which GitHub serves for free), the blog will be deployed on the
homelab like the other web projects instead — reasoning: faster access than GitHub Pages'
default hosting. Served via Traefik/NPM alongside the other 10 personal projects.

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
