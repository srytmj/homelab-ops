# Systemd Timers — Deploy Steps

docker-host is live (see `docs/architecture.md`) but this repo has not been cloned onto it yet.
Clone it first, then deploy the timers:

```bash
sudo mkdir -p /opt/homelab-ops
sudo chown "$USER" /opt/homelab-ops
git clone https://github.com/srytmj/homelab-ops /opt/homelab-ops
cd /opt/homelab-ops

sudo cp configs/systemd/homelab-backup.* configs/systemd/homelab-health-check.* configs/systemd/homelab-git-deploy.* /etc/systemd/system/
sudo chmod +x /opt/homelab-ops/scripts/backup.sh /opt/homelab-ops/scripts/health-check.sh /opt/homelab-ops/scripts/git-auto-deploy.sh
sudo systemctl daemon-reload
sudo systemctl enable --now homelab-health-check.timer
sudo systemctl enable --now homelab-git-deploy.timer
```

**Hold off on `homelab-backup.timer` for now.** `backup.sh` targets `/mnt/hdd-backup/`, and the 4
HDDs (including HDD-Backup) aren't physically mounted yet (see `docs/roadmap.md`, "Now" section).
Enabling it today would silently write backups to the OS SSD instead of the dedicated backup
drive. Enable it once HDD-Backup is mounted at `/mnt/hdd-backup/`.

Verify:

```bash
systemctl list-timers | grep homelab
journalctl -u homelab-backup.service
journalctl -u homelab-health-check.service
journalctl -u homelab-git-deploy.service
```

`homelab-git-deploy.sh` expects each project to live under `/opt/projects/<name>/` as its own git
repo with a `docker-compose.yml` (or `compose.yml`) at the root, tracking branch `main`. Adjust
`PROJECTS_ROOT`/`BRANCH` at the top of the script if the actual layout differs once the 10 web
projects are deployed.

Adjust `ExecStart` paths in the `.service` files if the repo is cloned somewhere other than `/opt/homelab-ops`.
