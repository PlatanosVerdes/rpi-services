# Monitoring and muninn

Monitoring is one label away: a container carrying `prometheus.probe: "http://<name>:<port>/<path>"`
is probed every 15s by the blackbox exporter over there, and shows up in the Service probes
dashboard and in the "Service not answering" alert. Nothing to add on the rpi-homeserver side. A
service that serves no HTTP (the bot, the one-off downloader) has no label: for those, liveness is
the container running.

A bot that exposes its stats at `/bot-stats` on an unpublished port, carries
`muninn.stats: "http://<name>:<port>/bot-stats"` and joins the internal `muninn` network shows up on
[muninn](https://github.com/PlatanosVerdes/muninn).
