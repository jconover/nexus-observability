# NexusObservability

Shared monitoring stack for the Nexus product family. Runs Prometheus, Grafana, and Alertmanager (plus optional NVIDIA DCGM exporter) on the `monitoring` Docker network. Scrapes targets from other stacks by attaching Prometheus to their networks.

## Quick start

```bash
make start        # prometheus + grafana + alertmanager
make start-gpu    # also brings up dcgm-exporter for GPU metrics
make health
```

URLs:
- Prometheus: <http://localhost:9090>
- Grafana: <http://localhost:3001> (admin/admin)
- Alertmanager: <http://localhost:9093>

## Architecture

Prometheus is attached to two Docker networks:

| Network | Purpose |
|---|---|
| `monitoring` | Default network for this stack (prometheus, grafana, alertmanager talk to each other) |
| `nexus-ai` | Shared external network with `nexus-cortex`; lets prometheus scrape `rag-backend:8000` |

Both networks are external (declared with `external: true`). The `make start` target auto-creates them on first run.

## Adding new scrape targets

For services in another stack:

1. Ensure the target is on a network prometheus can reach. Either:
   - Put it on `nexus-ai` (already attached)
   - Add a new external network and join prometheus to it in `docker-compose.yml`
2. Add a scrape job in `monitoring/prometheus/prometheus.yml` using the **container name** (not service name — container names resolve across networks, service names don't).
3. Reload prometheus: `curl -X POST http://localhost:9090/-/reload`

## Configuration

| File | Purpose |
|---|---|
| `monitoring/prometheus/prometheus.yml` | Scrape targets, alerting routing |
| `monitoring/prometheus/alerts.yml` | Alert rules |
| `monitoring/alertmanager/alertmanager.yml` | Alert routing + receivers (Slack/email/PagerDuty) |
| `monitoring/grafana/dashboards/` | JSON dashboards (auto-provisioned) |
| `monitoring/grafana/provisioning/` | Datasource + dashboard provisioning config |

## Override admin credentials

Set `GRAFANA_ADMIN_USER` and `GRAFANA_ADMIN_PASSWORD` in a local `.env` file before `make start`.
