# Curso IA — n8n + Qdrant RAG Stack

Stack de automatización con IA para construir pipelines RAG (Retrieval-Augmented Generation) usando n8n como orquestador y Qdrant como base de datos vectorial, desplegado en `solvex.site` con SSL.

## Arquitectura

```
Internet
   │
   ▼
nginx (80/443) ──SSL──► n8n (5678, interno)
                              │
                    ┌─────────┴─────────┐
               PostgreSQL           Qdrant
              (persistencia)    (vector DB)
```

nginx termina el SSL con los certificados de Let's Encrypt del host y proxea a n8n. Qdrant solo es accesible desde `localhost` del servidor (no expuesto públicamente).

## Servicios

| Servicio | Imagen | Puerto externo | Descripción |
|----------|--------|----------------|-------------|
| nginx | `nginx:alpine` | 80, 443 | Reverse proxy + SSL termination |
| n8n | `n8nio/n8n:latest` | — (interno) | Orquestador de flujos |
| Qdrant | `qdrant/qdrant:latest` | 127.0.0.1:6333/6334 | Base de datos vectorial |
| PostgreSQL | `postgres:16-alpine` | — (interno) | Persistencia de n8n |

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) v2+
- Certificados Let's Encrypt en el servidor (`/etc/letsencrypt/archive/solvex.site/`)
- Puertos 80 y 443 abiertos en el firewall

## Puesta en marcha

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd curso-ia-n8n

# 2. Crear el archivo de variables de entorno
cp .env.example .env

# 3. Editar .env — como mínimo: POSTGRES_PASSWORD y N8N_ENCRYPTION_KEY
#    Genera la encryption key con:
openssl rand -hex 32

# 4. Preparar directorios y permisos (necesario la primera vez)
sudo bash setup.sh

# 5. Levantar los servicios
docker compose up -d

# 5. Ver logs en tiempo real (opcional)
docker compose logs -f
```

## URLs de acceso

| Servicio | URL |
|----------|-----|
| n8n UI | https://solvex.site |
| Qdrant REST API | http://localhost:6333 (solo desde el servidor) |
| Qdrant Dashboard | http://localhost:6333/dashboard (solo desde el servidor) |

## Conectar n8n con Qdrant

En cualquier nodo **Qdrant Vector Store** de n8n usa:

- **URL**: `http://qdrant:6333` (red interna de Docker)
- **API Key**: dejar vacío si `QDRANT_API_KEY` está en blanco en `.env`

## Renovación de certificados SSL

Cuando Let's Encrypt renueve los certificados (genera `fullchain2.pem`, etc.), actualiza las variables `SSL_CERT_FILE_HOST` y `SSL_KEY_FILE_HOST` en `.env` y recarga nginx:

```bash
docker compose exec nginx nginx -s reload
```

## Estructura del proyecto

```
.
├── docker-compose.yml   # Definición de servicios
├── nginx/
│   └── nginx.conf       # Configuración del reverse proxy SSL
├── .env.example         # Plantilla de variables de entorno
├── .env                 # Variables reales — NO se sube al repo
├── .gitignore
├── n8n_data/            # Datos persistidos de n8n
├── postgres_data/       # Datos persistidos de PostgreSQL
├── qdrant_data/         # Datos persistidos de Qdrant
└── shared/              # Archivos compartidos entre flujos de n8n
```

## Comandos útiles

```bash
# Ver estado de los contenedores
docker compose ps

# Recargar nginx sin downtime (ej. tras renovar certs)
docker compose exec nginx nginx -s reload

# Reiniciar un servicio específico
docker compose restart n8n

# Detener los servicios
docker compose down

# Detener y eliminar volúmenes (borra todos los datos)
docker compose down -v
```

## Variables de entorno

Consulta `.env.example` para la lista completa. Las obligatorias son:

| Variable | Descripción |
|----------|-------------|
| `POSTGRES_PASSWORD` | Contraseña de PostgreSQL |
| `N8N_ENCRYPTION_KEY` | Clave de cifrado de credenciales en n8n (32 bytes hex) |
| `SSL_CERT_FILE_HOST` | Ruta al certificado fullchain en el host |
| `SSL_KEY_FILE_HOST` | Ruta a la clave privada en el host |

> **Importante:** nunca compartas ni subas al repositorio el archivo `.env`.
