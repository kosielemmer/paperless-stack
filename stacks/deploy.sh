#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Paperless Stack Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$SCRIPT_DIR"

# Source root .env file to get shared variables
if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    source "$ROOT_DIR/.env"
    set +a
    export TIMEZONE NFS_SERVER_IP HOST_IP DOCKER_NETWORK
fi

# Function to check if a container is healthy/running
wait_for_container() {
    local container_name=$1
    local max_wait=60
    local wait_time=0
    
    echo -e "${YELLOW}Waiting for $container_name to be ready...${NC}"
    
    while [ $wait_time -lt $max_wait ]; do
        if docker ps --filter "name=$container_name" --filter "status=running" --format '{{.Names}}' | grep -q "$container_name"; then
            echo -e "${GREEN}✓ $container_name is running${NC}"
            return 0
        fi
        sleep 2
        wait_time=$((wait_time + 2))
    done
    
    echo -e "${RED}✗ Timeout waiting for $container_name${NC}"
    return 1
}

# Step 1: Create network
echo -e "${BLUE}Step 1: Creating shared network${NC}"
if docker network ls | grep -q "paperless-stack"; then
    echo -e "${YELLOW}Network 'paperless-stack' already exists${NC}"
else
    docker network create paperless-stack
    echo -e "${GREEN}✓ Network 'paperless-stack' created${NC}"
fi
echo ""

# Step 2: Deploy core infrastructure
echo -e "${BLUE}Step 2: Deploying core infrastructure${NC}"
echo -e "${YELLOW}Starting postgres, redis, gotenberg, tika...${NC}"

cd postgres && docker compose up -d && cd ..
cd redis && docker compose up -d && cd ..
cd gotenberg && docker compose up -d && cd ..
cd tika && docker compose up -d && cd ..

wait_for_container "postgres"
wait_for_container "redis"
wait_for_container "gotenberg"
wait_for_container "tika"

echo -e "${GREEN}✓ Core infrastructure deployed${NC}"
echo ""
sleep 5

# Step 3: Deploy main application
echo -e "${BLUE}Step 3: Deploying Paperless-ngx${NC}"
cd paperless && docker compose up -d && cd ..

wait_for_container "paperless-ngx"
echo -e "${GREEN}✓ Paperless-ngx deployed${NC}"
echo ""
sleep 5

# Step 4: Deploy AI infrastructure
echo -e "${BLUE}Step 4: Deploying AI infrastructure${NC}"
cd ollama && docker compose up -d && cd ..

wait_for_container "ollama"
echo -e "${GREEN}✓ Ollama deployed${NC}"
echo ""
sleep 5

# Step 5: Deploy AI services
echo -e "${BLUE}Step 5: Deploying AI services${NC}"
echo -e "${YELLOW}Starting open-webui, paperless-ai, paperless-gpt...${NC}"

cd open-webui && docker compose up -d && cd ..
cd paperless-ai && docker compose up -d && cd ..
cd paperless-gpt && docker compose up -d && cd ..

wait_for_container "open-webui"
wait_for_container "paperless-ai"
wait_for_container "paperless-gpt"

echo -e "${GREEN}✓ AI services deployed${NC}"
echo ""
sleep 3

# Step 6: Deploy monitoring
echo -e "${BLUE}Step 6: Deploying monitoring${NC}"
cd dozzle && docker compose up -d && cd ..

wait_for_container "dozzle"
echo -e "${GREEN}✓ Dozzle deployed${NC}"
echo ""

# Final status
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Access your services:${NC}"
echo -e "  Paperless-ngx:  http://localhost:8000"
echo -e "  Open WebUI:     http://localhost:3001"
echo -e "  Paperless-AI:   http://localhost:3000"
echo -e "  Paperless-GPT:  http://localhost:3002"
echo -e "  Dozzle (logs):  http://localhost:8080"
echo ""
echo -e "${YELLOW}Check status:${NC}"
echo -e "  docker ps"
echo ""
echo -e "${YELLOW}View logs:${NC}"
echo -e "  docker logs <container-name>"
echo -e "  Or use Dozzle at http://localhost:8080"
echo ""
