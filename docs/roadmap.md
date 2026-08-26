# Roadmap

> What's planned, not what exists yet. Move items to CHANGELOG.md once done, and update architecture.md accordingly.

## Now

- [x] Pick and order hardware: Lenovo M920q (i5-9500T, 16GB RAM, 256GB SSD), MikroTik RB750Gr3, 2TB 2.5" HDD (see decisions.md)
- [ ] Install Proxmox VE on M920q
- [ ] Create docker-host LXC/VM (Ubuntu Server 24.04)
- [ ] Set up external multi-bay USB enclosure for the 4x 2.5" HDD + extra SSD
- [ ] Mount external storage, decide on filesystem/RAID approach (document reasoning in decisions.md)
- [ ] Deploy Traefik/Nginx Proxy Manager
- [ ] Deploy shared PostgreSQL + Redis
- [ ] Deploy first batch of the 10 web projects

## Next

- [ ] Deploy media stack: Jellyfin, Immich, Nextcloud, Kavita, Navidrome
- [ ] Set up Tailscale for remote access
- [ ] Set up Uptime Kuma + Netdata/Glances for monitoring
- [ ] Set up automated backup (Restic/Duplicati) for DB + config volumes

- [ ] Discord bot (Python, discord.py) for server monitoring — status/alerts for containers & resource usage; built in a separate Claude Code session, not this repo's setup flow

## Later / Ideas

- [ ] k3s sandbox environment (separate LXC, for learning Kubernetes — not for production)
- [ ] VLAN isolation between homelab and personal devices
- [ ] Evaluate RAM upgrade to 32GB if usage gets tight
- [ ] Jellyfin hardware transcode setup if a GPU-capable device becomes available
- [ ] CI/CD: GitHub Actions auto-deploy to homelab on push
