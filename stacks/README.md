# Paperless Stack - Separated Services

This directory contains individual Docker Compose stacks for each service in the Paperless ecosystem. Each service is fully self-contained with its own compose file, environment configuration, and data directories.

## Directory Structure

Each service directory contains:
- `docker-compose.yaml` - Service configuration
- `.env` - Environment variables
- `data/` - Persistent data (where applicable)
- Service-specific directories (e.g., `consume/`, `prompts/`)

Example structure:
```
stacks/
├── paperless/
│   ├── docker-compose.yaml
│   ├── .env
│   ├── data/
│   ├── media/
│   ├── export/
│   └── consume/
└── postgres/
    ├── docker-compose.yaml
    ├── .env
    └── data/
```

## Network Setup

Before deploying any service, create the shared network:

```bash
chmod +x create-network.sh
./create-network.sh
```

Or manually:
```bash
docker network create paperless-stack
```

## Deployment Order

For proper functionality, deploy services in this order:

### 1. Core Infrastructure (can be deployed in parallel)
- `postgres/` - PostgreSQL database
- `redis/` - Redis cache
- `gotenberg/` - Document conversion service
- `tika/` - Text extraction service

### 2. Main Application
- `paperless/` - Paperless-ngx main service (depends on postgres, redis, gotenberg, tika)

### 3. AI Infrastructure
- `ollama/` - Local LLM service

### 4. AI Services (depend on ollama and paperless)
- `open-webui/` - LLM interaction interface
- `paperless-ai/` - AI features for Paperless
- `paperless-gpt/` - GPT integration for Paperless

### 5. Monitoring (optional)
- `dozzle/` - Log viewer

## Deploying Individual Services

Navigate to any service directory and use docker compose:

```bash
cd stacks/postgres
docker compose up -d
```

## Stopping Services

```bash
cd stacks/postgres
docker compose down
```

## Service Ports

- **Paperless-ngx**: http://localhost:8000
- **Open-WebUI**: http://localhost:3001
- **Paperless-AI**: http://localhost:3000
- **Paperless-GPT**: http://localhost:3002
- **Dozzle**: http://localhost:8080

## Environment Files

Each service has its `.env` file in its own stack directory:
- `stacks/<service>/.env`

All environment files have been pre-configured and are located alongside their respective `docker-compose.yaml` files. You can edit them directly in each stack directory before deployment.

## Using with Container Management Tools

### Arcane
1. Create the `paperless-stack` network (Networks in Arcane or via CLI)
2. Create a project per service using `stacks/<service>/docker-compose.yaml`
3. Set the project working directory to `stacks/<service>/`
4. Load `stacks/<service>/.env`
5. Deploy in the order listed above

## Migrating from Combined Setup

If you're migrating from an original combined `compose.yaml`:

1. Stop all services:
   ```bash
   docker compose down
   ```

2. Create the network:
   ```bash
   cd stacks
   ./create-network.sh
   ```

3. Deploy services in the order specified above from their respective directories:
   ```bash
   cd postgres
   docker compose up -d
   cd ../redis
   docker compose up -d
   # ... etc
   ```

Your data is now contained within each service's stack directory for easy portability.

## Removing the Network

If you need to remove the network (all services must be stopped first):

```bash
docker network rm paperless-stack
```
