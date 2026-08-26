# Systemd Timers — Deploy Steps

Once docker-host LXC/VM exists and this repo is cloned onto it at `/opt/homelab-ops`:

```bash
sudo cp configs/systemd/homelab-backup.* configs/systemd/homelab-health-check.* configs/systemd/homelab-git-deploy.* /etc/systemd/system/
sudo chmod +x /opt/homelab-ops/scripts/backup.sh /opt/homelab-ops/scripts/health-check.sh /opt/homelab-ops/scripts/git-auto-deploy.sh
sudo systemctl daemon-reload
sudo systemctl enable --now homelab-backup.timer
sudo systemctl enable --now homelab-health-check.timer
sudo systemctl enable --now homelab-git-deploy.timer
```

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
