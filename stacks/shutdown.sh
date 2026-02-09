#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Paperless Stack Shutdown${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to stop a service
stop_service() {
    local service_name=$1
    echo -e "${YELLOW}Stopping $service_name...${NC}"
    cd "$service_name" && docker compose down && cd ..
    echo -e "${GREEN}✓ $service_name stopped${NC}"
}

# Stop in reverse order
echo -e "${BLUE}Step 1: Stopping monitoring${NC}"
stop_service "dozzle"
echo ""

echo -e "${BLUE}Step 2: Stopping AI services${NC}"
stop_service "paperless-gpt"
stop_service "paperless-ai"
stop_service "open-webui"
echo ""

echo -e "${BLUE}Step 3: Stopping AI infrastructure${NC}"
stop_service "ollama"
echo ""

echo -e "${BLUE}Step 4: Stopping main application${NC}"
stop_service "paperless"
echo ""

echo -e "${BLUE}Step 5: Stopping core infrastructure${NC}"
stop_service "tika"
stop_service "gotenberg"
stop_service "redis"
stop_service "postgres"
echo ""

# Ask about network removal
echo -e "${YELLOW}Do you want to remove the 'paperless-stack' network? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    docker network rm paperless-stack 2>/dev/null && echo -e "${GREEN}✓ Network removed${NC}" || echo -e "${YELLOW}Network not found or still in use${NC}"
else
    echo -e "${YELLOW}Network preserved${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Shutdown complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
