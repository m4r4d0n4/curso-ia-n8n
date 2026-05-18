# Curso IA — n8n + Qdrant RAG Stack

Stack de automatización con IA para construir pipelines RAG (Retrieval-Augmented Generation) usando n8n como orquestador y Qdrant como base de datos vectorial.

## Servicios

| Servicio | Imagen | Puerto | Descripción |
|----------|--------|--------|-------------|
| n8n | `n8nio/n8n:latest` | 5678 | Orquestador de flujos de trabajo |
| Qdrant | `qdrant/qdrant:latest` | 6333 / 6334 | Base de datos vectorial (REST / gRPC) |
| PostgreSQL | `postgres:16-alpine` | — (interno) | Persistencia de n8n |

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) v2+

## Puesta en marcha

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd curso-ia-n8n

# 2. Crear el archivo de variables de entorno
cp .env.example .env

# 3. Editar .env con tus credenciales
#    Como mínimo: POSTGRES_PASSWORD y N8N_ENCRYPTION_KEY
#    Genera una encryption key con:
openssl rand -hex 32

# 4. Levantar los servicios
docker compose up -d

# 5. Ver logs en tiempo real (opcional)
docker compose logs -f
```

## URLs de acceso

| Servicio | URL |
|----------|-----|
| n8n UI | http://localhost:5678 |
| Qdrant REST API | http://localhost:6333 |
| Qdrant Dashboard | http://localhost:6333/dashboard |

## Conectar n8n con Qdrant

En cualquier nodo **Qdrant Vector Store** de n8n usa:

- **URL**: `http://qdrant:6333` (red interna de Docker)
- **API Key**: dejar vacío si `QDRANT_API_KEY` está en blanco en `.env`

## Estructura del proyecto

```
.
├── docker-compose.yml   # Definición de servicios
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
# Detener los servicios
docker compose down

# Detener y eliminar volúmenes (borra todos los datos)
docker compose down -v

# Ver estado de los contenedores
docker compose ps

# Reiniciar un servicio específico
docker compose restart n8n
```

## Variables de entorno

Consulta `.env.example` para ver todas las variables disponibles con su descripción. Las obligatorias son:

| Variable | Descripción |
|----------|-------------|
| `POSTGRES_PASSWORD` | Contraseña de PostgreSQL |
| `N8N_ENCRYPTION_KEY` | Clave de cifrado de credenciales en n8n (32 bytes hex) |

> **Importante:** nunca compartas ni subas al repositorio el archivo `.env`.
