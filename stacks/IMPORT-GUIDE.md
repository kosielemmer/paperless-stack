# Importing into Arcane

## Prerequisites

1. **Create the shared network first:**
   ```bash
   docker network create paperless-stack
   ```

## Arcane

Arcane works well with this structure because each service is a self-contained directory.

1. Create or verify the external network `paperless-stack` (in Arcane under Networks, or via CLI).
2. For each service, create a new project/stack in Arcane and use the compose file from:
   - `stacks/<service>/docker-compose.yaml`
3. Set the project working directory to the service folder so relative paths resolve:
   - `stacks/<service>/`
4. Load the environment file from the same folder:
   - `stacks/<service>/.env`
5. Deploy in the order listed in [stacks/README.md](README.md).

If you prefer a single import source, you can add this repository as a Git source in Arcane and point each project to the relevant service folder.

## Troubleshooting

### Network Issues
If services can't communicate:
```bash
# Verify network exists
docker network ls | grep paperless-stack

# Check which containers are on the network
docker network inspect paperless-stack
```

### Volume Path Issues
All volume paths are now relative (`./data`, `./consume`, etc.) and should work in most platforms. If you encounter issues, you can convert them to absolute paths based on where you place the stack directory.

### Environment Variables
If .env files aren't loading:
1. Check that the `.env` file exists in the same directory as `docker-compose.yaml`
2. Copy environment variables directly into the platform's interface as a backup
3. Or inline them into the compose file (less secure for sensitive data)

## Health Checks

After deployment, verify services:
```bash
docker ps
docker network inspect paperless-stack
docker logs <container-name>
```

Access web interfaces:
- Paperless: http://localhost:8000
- Open-WebUI: http://localhost:3001
- Paperless-AI: http://localhost:3000
- Paperless-GPT: http://localhost:3002
- Dozzle: http://localhost:8080
