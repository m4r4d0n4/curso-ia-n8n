COMPOSE_BASE = docker compose -f docker-compose.yml
COMPOSE_SSL  = $(COMPOSE_BASE) -f docker-compose.ssl.yml
COMPOSE_NOSSL = $(COMPOSE_BASE) -f docker-compose.nossl.yml

.PHONY: ssl nossl down logs ps setup

ssl:
	$(COMPOSE_SSL) up -d

nossl:
	N8N_HOST=localhost N8N_PROTOCOL=http WEBHOOK_URL=http://localhost:5678/ \
	$(COMPOSE_NOSSL) up -d

down:
	$(COMPOSE_SSL) down 2>/dev/null || $(COMPOSE_NOSSL) down

logs:
	$(COMPOSE_BASE) logs -f

ps:
	$(COMPOSE_BASE) ps

setup:
	mkdir -p n8n_data postgres_data qdrant_data shared
	chown -R 1000:1000 n8n_data shared
	@echo "Listo. Usa 'make ssl' o 'make nossl' para arrancar."
