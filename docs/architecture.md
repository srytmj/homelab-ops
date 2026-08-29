# Architecture - Current State

> This file reflects what EXISTS right now. Update it whenever the actual topology changes.
> Last verified: <fill in date when you actually check the server>

## Hardware

- **Device:** Lenovo ThinkCentre M710q/M910q (Tiny form factor)
- **CPU:** Intel Core i7-7700, 4 cores / 8 threads
- **RAM:** 32GB DDR4 SO-DIMM (2 slots)
- **M.2 slot:** confirmed NVMe-capable — repurposed to host an expansion card (see storage
  topology below), not used for an OS NVMe drive
- **Internal storage:** see "Storage Topology (FINAL)" below — the OS drive and expansion setup
  are non-standard for this Tiny form factor, worth reading in full before doing hardware work

## Storage Topology (FINAL)

This device's 2 physical drive slots (1x M.2, 1x internal 2.5" bay) are used unconventionally to
get more drives than the chassis nominally supports, without an external USB enclosure:

- **M.2 slot (NVMe-capable) → LM418 card (M.2 NVMe to 5-port SATA expansion card).** The M.2 slot
  doesn't hold a drive directly — it hosts this expansion card, which breaks out to 5 SATA ports
  for additional HDDs.
- **Internal 2.5" bay (native SATA) → "SSD M.2 SATA/mSATA to SATA 3.0 2.5\"" adapter → OS SSD.**
  The OS drive is physically an **M.2 SATA SSD** (not a standard 2.5" SSD), so it needs this
  adapter to plug into the native 2.5" SATA bay. This is the OS/Docker/projects/DB-metadata
  drive.
- **Additional HDD (Toshiba 2TB 7200RPM 3.5") → LM418 port #1 → external Docking Rak Stand HDD
  3.5" (with fan).** Connected via one of the LM418's 5 SATA ports, physically mounted in an
  external drive dock (not inside the M710q chassis) sitting outside the case.
- **Power for the external HDD dock:** separate **Imperion ATX 500W PSU**, not the M710q's
  internal PSU (its capacity isn't enough for the external dock). Two independent power domains:
  internal M710q PSU for the mini PC itself, external ATX PSU just for the HDD dock.
- **Cable routing:** the case backplate is left open to route SATA data + power cables from the
  LM418 out to the external dock. The remaining backplate opening (over the RAM) is covered with
  a magnetic mesh panel for basic dust/physical protection.

**Net effect:** 1 internal M.2-SATA OS SSD (via adapter, in the native 2.5" bay) + 1 external
3.5" HDD (via the LM418 card riser'd off the M.2 slot, in an external powered dock) — 2 drives
total from a chassis that nominally only takes 1+1, without needing a USB DAS enclosure.

- **Filesystem:** single HDD for now (see "Items removed from plan" in `decisions.md`) — no
  RAID/JBOD decision needed until a second HDD is added.
- **Mount point on host:** `/mnt/hdd2tb/` (see folder structure further down this file)

## Virtualization Layer

```
Proxmox VE (bare metal hypervisor)
  └── 1 LXC/VM: "docker-host" (Ubuntu Server 24.04 LTS)
        RAM allocated: ~26GB (of 32GB total)
        CPU allocated: ~3 cores / 6 threads (of 4C/8T total)
        Storage: ~150GB (of 256GB SSD)
```

## Network

```
Router ISP (main house WiFi)
  └── Switch Gigabit: TP-Link TL-LS1005G (5-port)
        └── PC + Homelab (M710q)
```

- **Router:** the ISP's own router — no dedicated MikroTik router deployed for now (see
  `decisions.md`: skipped for budget efficiency, not currently needed).
- **Switch:** TP-Link TL-LS1005G, 5-port Gigabit — added specifically so PC↔Homelab file
  transfer gets full Gigabit speed. This works even though the ISP router's own ports may not
  all be Gigabit, because switch-to-switch-port speed between devices on the same switch isn't
  limited by the router's uplink port speed.
- **MikroTik RB941-2nD (hAP Lite):** originally considered as a second router for network
  isolation, but it's Fast Ethernet (100Mbps) only — and is currently skipped entirely (see
  network decision below), not deployed as a second-layer router either.
- **Static IP for docker-host:** 192.168.1.10 (adjust to actual)
- **Remote access:** Tailscale (no port forwarding to public internet for personal services)
- **Domain/DNS / Cloudflare Tunnel:** **one exception** to the Tailscale-only policy — the
  `portfolio` project is exposed to the public internet via Cloudflare Tunnel (no ports opened
  on the router/firewall). Every other service, including the Homepage dashboard the portfolio
  links to via its hidden button, stays Tailscale-only. See `decisions.md` for the full
  reasoning.

## Services Running (Docker containers on docker-host)

See `docs/services.md` for the full list with ports and data locations.

Summary:
- Reverse proxy: Traefik / Nginx Proxy Manager
- Container management: Portainer
- Shared DB: PostgreSQL (multi-database) + Redis (shared, per-project key prefix)
- 10 personal web projects
- Media stack: Jellyfin (movies/TV + music library), Immich, Kavita, Nextcloud

## Storage Path Convention

| Data type | Location |
|---|---|
| OS, Docker engine, images | OS SSD (M.2 SATA, via adapter in the internal 2.5" bay) |
| Project code + dependencies | OS SSD |
| Database metadata (Postgres/Redis) | OS SSD |
| Immich photos/videos | HDD (`/mnt/hdd2tb/immich`) |
| Nextcloud files | HDD (`/mnt/hdd2tb/nextcloud`) |
| Jellyfin media library (movies/TV + music) | HDD (`/mnt/hdd2tb/jellyfin`) |
| Kavita manga library | HDD (`/mnt/hdd2tb/kavita`) |

**Rule:** never let bulk media default-write to the OS SSD. Always explicitly map Docker volumes to the HDD path.

## HDD (Toshiba 2TB, external dock) — Folder Structure

Mount point (planned): `/mnt/hdd2tb/`

```
/mnt/hdd2tb/
├── immich/
│   ├── upload/           # Immich's own managed storage — photos/videos synced from the phone app; do not reorganize manually, categorize via Albums/Tags in the UI instead
│   └── external/         # External Library source — manually organized, read-only to Immich, for pre-existing collections
│       ├── anime/
│       ├── phone/
│       ├── pc/
│       └── laptop/
├── nextcloud/
├── jellyfin/
│   ├── movies/
│   ├── tv/
│   └── music/           # accessed via Jellyfin's own music library, no separate music server
├── kavita/
│   └── manga/
└── shared/              # ad-hoc file drop, accessed from Windows via SMB
```

Each app-specific folder (`immich/`, `nextcloud/`, etc.) is bind-mounted into its own Docker
container — same pattern as the external-enclosure convention above, just pointed at this HDD
instead. `shared/` is not tied to any container; it's a general-purpose folder for manual file
transfers (see SMB access below).

**Which folders are safe to drop files into manually (via SMB) vs. app-managed only:**

| Folder | Manual file drop via SMB? | Why |
|---|---|---|
| `jellyfin/movies/`, `/tv/`, `/music/` | ✅ Yes — this is the normal workflow | Jellyfin scans the folder for new files; no separate upload step needed |
| `kavita/manga/` | ✅ Yes — this is the normal workflow | Same as Jellyfin — Kavita scans the folder |
| `immich/external/` | ✅ Yes, for pre-existing collections | Read via Immich's External Library feature (see above) |
| `immich/upload/` | ❌ No | Managed by Immich's own database — manually dropped files won't get picked up like Jellyfin/Kavita's scan does; use `external/` instead |
| `nextcloud/` | ❌ No | Has its own internal DB tracking files — must go through Nextcloud's app/web UI/sync client, not direct filesystem copy, or the DB gets out of sync |
| `shared/` | ✅ Yes | General-purpose, not tied to any app |

## Windows Network Access (SMB/Samba)

Yes — folders on the homelab can be made accessible from Windows File Explorer as a network
share, via a Samba service. Multiple shares are planned (not just `shared/`), per the table above:

- **Planned setup:** Samba running as a container (or host-level `smbd` inside the docker-host
  LXC/VM) exposing `shared/` (read-write), plus `jellyfin/movies`, `jellyfin/tv`, `jellyfin/music`,
  `kavita/manga`, and `immich/external` (all read-write, for dropping in media/files) — each as
  its own SMB share or subfolder under one share. `immich/upload/` and `nextcloud/` are **not**
  exposed for direct write, only managed through their own apps.
- **Access from Windows:** map network drive to `\\<docker-host-ip>\<share-name>`, or type the
  path directly into File Explorer's address bar.
- **Auth:** local Samba user/password (not tied to any app's own auth) — set up during Setup mode.
- Not yet implemented — this is a planned addition, tracked in `docs/roadmap.md`.
