#!/bin/bash
set -e

# Crea los directorios de datos si no existen
mkdir -p n8n_data postgres_data qdrant_data shared

# n8n corre como usuario 'node' (UID 1000) dentro del contenedor
chown -R 1000:1000 n8n_data shared

echo "Directorios listos. Puedes arrancar con: docker compose up -d"
