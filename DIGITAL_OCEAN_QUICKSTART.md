# Planet Nine Base - Digital Ocean Quick Start

Deploy your own Planet Nine Base in under 10 minutes.

## Option 1: One-Line Install (Easiest)

1. Create a Digital Ocean Droplet:
   - **Image:** Ubuntu 22.04 LTS
   - **Size:** Basic $6/mo (1GB RAM) minimum, $12/mo (2GB) recommended
   - **Region:** Any

2. SSH into your droplet:
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

3. Run the installer:
   ```bash
   curl -sSL https://raw.githubusercontent.com/eastgrand/planet-nine/main/install.sh | bash
   ```

4. Wait ~10 minutes for build + bootstrap

5. Done! Your base is running.

---

## Option 2: Manual Install

```bash
# 1. SSH into droplet
ssh root@YOUR_DROPLET_IP

# 2. Install Docker
apt-get update
apt-get install -y docker.io docker-compose-v2

# 3. Clone and setup
mkdir -p ~/planet-nine && cd ~/planet-nine
git clone https://github.com/planet-nine-app/allyabase.git

# 4. Apply Pref bug fix to Dockerfile
cat >> allyabase/deployment/docker/Dockerfile << 'PATCH'

# Fix upstream pref.js syntax error
WORKDIR /usr/src/app/pref/src/server/node
RUN sed -i 's/res.send({preferences}));/res.send({preferences});/' pref.js && \
    sed -i "/import db from '.\/src\/persistence\/db.js';/a import fs from 'fs\/promises';" pref.js
PATCH

# 5. Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  planet-nine:
    build: ./allyabase/deployment/docker
    container_name: planet-nine-base
    restart: unless-stopped
    ports:
      - "3000:3000"
      - "2999:2999"
      - "3002:3002"
      - "3003:3003"
      - "3004:3004"
      - "3005:3005"
      - "3006:3006"
      - "3007:3007"
      - "3011:3011"
      - "7243:7243"
      - "7277:7277"
      - "2525:2525"
    volumes:
      - planet-nine-data:/usr/src/app/data
    environment:
      - LOCALHOST=true
volumes:
  planet-nine-data:
EOF

# 6. Build and run
docker compose build
docker compose up -d

# 7. Wait for bootstrap
sleep 60

# 8. Verify
curl http://localhost:3006/
```

---

## Firewall Setup

Open these ports in Digital Ocean firewall:

| Port | Service | Required |
|------|---------|----------|
| 3006 | Fount (main hub) | Yes |
| 3003 | BDO (storage) | Yes |
| 3004 | Joan (recovery) | Yes |
| 3005 | Addie (payments) | Optional |
| 3002 | Pref (preferences) | Yes |
| 3000 | Julia (messaging) | Yes |
| 2999 | Continuebee | Yes |
| 7243 | Sanora (store) | Optional |
| 7277 | Aretha (products) | Optional |
| 2525 | Minnie (email) | Optional |

**Digital Ocean Firewall:**
1. Go to Networking → Firewalls
2. Create Firewall
3. Add Inbound Rules for ports above (TCP)
4. Apply to your Droplet

---

## Service Ports

| Port | Service | Purpose |
|------|---------|---------|
| 3006 | Fount | Central MAGIC protocol hub |
| 3003 | BDO | Big Dumb Object storage |
| 3002 | Pref | User preferences |
| 3004 | Joan | Account recovery |
| 3005 | Addie | Payment processing |
| 3000 | Julia | P2P messaging |
| 2999 | Continuebee | State verification |
| 3007 | Dolores | Video/media |
| 3011 | Covenant | Contracts |
| 7243 | Sanora | Product storefront |
| 7277 | Aretha | Limited-run products |
| 2525 | Minnie | SMTP email |

---

## Management Commands

```bash
cd ~/planet-nine

# View logs
docker compose logs -f

# View specific service
docker exec planet-nine-base pm2 logs fount

# Restart
docker compose restart

# Stop
docker compose down

# Start
docker compose up -d

# Rebuild (after updates)
docker compose build --no-cache
docker compose up -d
```

---

## Testing

All API requests require Sessionless cryptographic signatures. See `test-all-services.js` for examples.

Quick health check:
```bash
# These should return "Cannot GET /" (means service is running)
curl http://localhost:3006/
curl http://localhost:3003/
curl http://localhost:3002/
```

---

## Troubleshooting

**Services not responding:**
```bash
# Check if container is running
docker ps

# Check logs
docker compose logs

# Restart
docker compose restart
```

**Port already in use:**
```bash
# Find what's using the port
lsof -i :3006

# Kill it or change ports in docker-compose.yml
```

**Out of memory (1GB droplet):**
- Upgrade to 2GB droplet, or
- Reduce services by editing `ecosystem.config.js` inside container

**Julia test fails locally with "fetch failed" or "bad port":**
- Port 3000 is blocked by Node.js/Chromium for security (X11 display server port)
- This only affects local dev machines, not servers
- On a server, Julia works fine on port 3000
- Workaround for local testing: use `curl http://localhost:3000/` instead of the Node.js test

---

## Estimated Costs

| Provider | Spec | Monthly |
|----------|------|---------|
| Digital Ocean | 1GB/1CPU | $6 |
| Digital Ocean | 2GB/1CPU | $12 |
| Digital Ocean | 2GB/2CPU | $18 |

2GB recommended for all services running smoothly.
