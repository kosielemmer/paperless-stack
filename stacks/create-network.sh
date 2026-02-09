#!/bin/bash

# Create the shared Docker network for all paperless stack services
echo "Creating shared Docker network: paperless-stack..."
docker network create paperless-stack

echo "Network created successfully!"
echo ""
echo "You can now deploy individual stacks using their respective docker-compose.yaml files."
