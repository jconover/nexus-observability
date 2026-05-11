.PHONY: help start start-gpu stop restart logs logs-prom logs-grafana health clean

help:
	@echo "NexusObservability (monitoring stack) - Available Commands"
	@echo "=========================================================="
	@echo "start       - Start prometheus, grafana, alertmanager"
	@echo "start-gpu   - Also start dcgm-exporter for NVIDIA GPU metrics"
	@echo "stop        - Stop all services"
	@echo "restart     - Restart all services"
	@echo "logs        - Tail logs from all services"
	@echo "logs-prom   - Tail prometheus logs"
	@echo "logs-grafana - Tail grafana logs"
	@echo "health      - Check service health"
	@echo "clean       - Remove containers AND volumes (DESTRUCTIVE)"

start:
	@docker network inspect monitoring >/dev/null 2>&1 || docker network create monitoring
	@docker network inspect ai-stack >/dev/null 2>&1 || docker network create ai-stack
	docker compose up -d
	@echo ""
	@echo "Monitoring stack started:"
	@echo "  Prometheus:   http://localhost:9090"
	@echo "  Grafana:      http://localhost:3001 (admin/admin)"
	@echo "  Alertmanager: http://localhost:9093"

start-gpu:
	@docker network inspect monitoring >/dev/null 2>&1 || docker network create monitoring
	@docker network inspect ai-stack >/dev/null 2>&1 || docker network create ai-stack
	docker compose --profile gpu-monitoring up -d

stop:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

logs-prom:
	docker compose logs -f prometheus

logs-grafana:
	docker compose logs -f grafana

health:
	@printf "prometheus:   " && (curl -fsS http://localhost:9090/-/healthy && echo "" || echo "DOWN")
	@printf "alertmanager: " && (curl -fsS http://localhost:9093/-/healthy && echo "" || echo "DOWN")
	@printf "grafana:      " && (curl -fsS -o /dev/null -w "%{http_code}\n" http://localhost:3001/api/health || echo "DOWN")

clean:
	docker compose down -v
