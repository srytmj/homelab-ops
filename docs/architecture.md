# Architecture - Current State

> This file reflects what EXISTS right now. Update it whenever the actual topology changes.
> Last verified: <fill in date when you actually check the server>

## Hardware

- **Device:** Lenovo ThinkCentre M920q (Tiny form factor)
- **CPU:** Intel Core i5-9500T, 6 cores / 6 threads, 2.2GHz base / 3.7GHz boost
- **RAM:** 16GB DDR4 SO-DIMM 2666MHz (2 slots, check current config: 1x16GB or 2x8GB)
- **Internal storage:**
  - 1x M.2 NVMe SSD 256GB (OS, Docker, projects, DB metadata)
  - 1x 2.5" bay (internal, currently: 2TB HDD, second-hand, SMART 100/100)

## External Storage (DAS - Direct Attached Storage)

> M920q Tiny only has 1 internal 2.5" bay + 1 NVMe slot — physically cannot fit 4 HDDs + 1 extra SSD inside.
> Solution: external USB 3.0 multi-bay enclosure.

- **Enclosure:** <fill in model once purchased, e.g. Orico / ICY BOX / Ugreen 4-bay 2.5" USB 3.0>
- **Drives inside enclosure:**
  - Bay 1: <capacity/model>
  - Bay 2: <capacity/model>
  - Bay 3: <capacity/model>
  - Bay 4: <capacity/model>
- **Extra SSD:** <where it physically lives — internal 2.5" bay, or inside the enclosure too>
- **Filesystem/RAID:** <e.g. individual drives, or software RAID/ZFS pool across them — decide and document in decisions.md>
- **Connection:** USB 3.0 from enclosure to M920q
- **Mount point on host:** `/mnt/external-storage/` (adjust to actual path once set up)

## Virtualization Layer

```
Proxmox VE (bare metal hypervisor)
  └── 1 LXC/VM: "docker-host" (Ubuntu Server 24.04 LTS)
        RAM allocated: ~12GB (of 16GB total)
        CPU allocated: ~5 cores (of 6 total)
        Storage: ~150GB (of 256GB SSD)
```

## Network

- **Router:** MikroTik RB750Gr3 (hEX), 5x Gigabit Ethernet ports
- **Static IP for docker-host:** 192.168.1.10 (adjust to actual)
- **Remote access:** Tailscale (no port forwarding to public internet for personal services)
- **Domain/DNS:** <fill in if using Cloudflare Tunnel + custom domain>

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
| OS, Docker engine, images | Internal NVMe SSD |
| Project code + dependencies | Internal NVMe SSD |
| Database metadata (Postgres/Redis) | Internal NVMe SSD |
| Immich photos/videos | External enclosure (`/mnt/external-storage/immich`) |
| Nextcloud files | External enclosure (`/mnt/external-storage/nextcloud`) |
| Jellyfin media library (movies/TV + music) | External enclosure (`/mnt/external-storage/movies`, `/mnt/external-storage/music`) |
| Kavita manga library | External enclosure or SSD if small (`/mnt/external-storage/manga`) |

**Rule:** never let bulk media default-write to the internal SSD. Always explicitly map Docker volumes to the external enclosure path.

## Internal 2.5" HDD (2TB) — Folder Structure

Mount point (planned): `/mnt/hdd2tb/`

```
/mnt/hdd2tb/
├── immich/
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

## Windows Network Access (SMB/Samba)

Yes — folders on the homelab can be made accessible from Windows File Explorer as a network
share (`\\<docker-host-ip>\shared`), via a Samba service.

- **Planned setup:** Samba running as a container (or host-level `smbd` inside the docker-host
  LXC/VM) exposing `/mnt/hdd2tb/shared/` — and optionally other folders (`immich/`, `nextcloud/`)
  read-only for direct browsing, though app-specific folders are normally managed through their
  own app UI, not manually.
- **Access from Windows:** map network drive to `\\<docker-host-ip>\shared`, or type the path
  directly into File Explorer's address bar.
- **Auth:** local Samba user/password (not tied to any app's own auth) — set up during Setup mode.
- Not yet implemented — this is a planned addition, tracked in `docs/roadmap.md`.
