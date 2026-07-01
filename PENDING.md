# Pending tasks

## Schedule the One Pace downloader via a host cron (DONE)

**Status:** installed on the host crontab (daily at 03:00). The line below is kept here for
reference so it can be re-added if the Pi is rebuilt (the host crontab is not tracked in git).

**Background:** the One Pace downloader used to be triggered by a `chadburn` scheduler container
(named `ofelia`). That never actually worked on this Pi:
- chadburn ran as a non-root user whose docker GID (969) did not match the host's (984), so it got
  `permission denied` on `/var/run/docker.sock`;
- even after fixing the socket permission, chadburn v1.9.1 registered 0 jobs (its label-based job
  discovery did not pick up the `chadburn.job-run.*` labels).

So the download had not run on schedule for weeks. The chadburn/`ofelia` service was removed (along
with its Grafana dashboard and Prometheus scrape job) in favor of a plain host cron, consistent with
how everything else on this Pi is scheduled (deploy, backup, metrics).

**Installed cron line** (`crontab -e` on the Pi):

```cron
# Download new One Pace episodes daily at 03:00
0 3 * * * cd /home/raspi/rpi-services && docker compose run --rm one-pace-downloader >> /home/raspi/rpi-services/one-pace.log 2>&1
```

Run once by hand to test:

```bash
cd ~/rpi-services && docker compose run --rm one-pace-downloader
```
