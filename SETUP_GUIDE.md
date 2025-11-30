# Planet Nine Setup Guide

A step-by-step guide to running a Planet Nine base from the upstream repositories.

**No steps should be skipped. Follow in order.**

---

## What is a "Base"?

A **base** is an instance of the Planet Nine miniservices running together. Think of it like a Minecraft server - you can run one just for you and your friends, or connect it to other bases.

There are **12 core services** + 1 optional (prof):

| Service | Port | Purpose |
|---------|------|---------|
| julia | 3000 | P2P messaging |
| continuebee | 2999 | State verification |
| pref | 3002 | User preferences (key/value) |
| bdo | 3003 | Big Dumb Object storage |
| joan | 3004 | Account recovery |
| addie | 3005 | Payment processing |
| fount | 3006 | MAGIC protocol, user linking, rewards |
| dolores | 3007 | Video/media storage |
| minnie | 2525 | SMTP email |
| aretha | 7277 | Limited-run products (tickets, rentals) |
| sanora | 7243 | Product hosting (like Gumroad) |
| covenant | 3011 | Contract management |
| prof | 3008 | (Optional) Profile/PII management |

---

## Prerequisites

### Required Software

1. **Git** - to clone repositories
2. **Docker Desktop** (recommended) OR **Node.js 18+** with npm
3. ~2GB disk space

### Check Prerequisites

```bash
# Check Git
git --version
# Should output: git version 2.x.x

# Check Docker (if using Docker method)
docker --version
# Should output: Docker version 2x.x.x

# Check Node.js (if using native method)
node --version
# Should output: v18.x.x or higher

npm --version
# Should output: 9.x.x or higher
```

---

## Step 0: Install Docker (if not installed)

### macOS

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop/
2. Open the downloaded `.dmg` file
3. Drag Docker to Applications
4. Open Docker from Applications
5. Wait for Docker to start (whale icon in menu bar stops animating)

### Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker
```

### Windows

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop/
2. Run the installer
3. Restart your computer when prompted
4. Open Docker Desktop
5. Wait for Docker to start

---

## Step 1: Start Docker

**This step is required before running any docker commands.**

### macOS

```bash
open -a Docker
```

Wait for Docker to fully start:
- The whale icon in the menu bar will stop animating
- Running `docker ps` should work without errors

### Linux

```bash
# Start Docker daemon
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify it's running
sudo systemctl status docker
```

### Windows

1. Open Docker Desktop from Start Menu
2. Wait for "Docker Desktop is running" notification

### Verify Docker is Running

```bash
docker ps
```

If Docker is running, you'll see a table (possibly empty, possibly with existing containers):
```
CONTAINER ID   IMAGE   COMMAND   CREATED   STATUS   PORTS   NAMES
```

If Docker is NOT running, you'll see:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

**Do not proceed until `docker ps` works.**

---

## Step 2: Check for Existing Containers and Ports

Check what containers are already running:

```bash
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Note any ports already in use. Common conflicts:
- Port 5000: Used by macOS AirPlay Receiver
- Ports 3000-3007: May be used by other development projects
- Port 2525: SMTP services

If you have other containers using the default Planet Nine ports (3000-3007, 7243, 7277, 2525), you'll need to use different host ports (see Step 7).

---

## Step 3: Create Project Directory

```bash
mkdir -p ~/code/planet-nine
cd ~/code/planet-nine
```

Verify:
```bash
pwd
# Should output: /Users/yourusername/code/planet-nine (or similar)
```

---

## Step 4: Clone the allyabase Repository

Check if already cloned:
```bash
ls ~/code/planet-nine/allyabase
```

If it shows files (README.md, deployment/, etc.), skip to Step 5.

If not found, clone it:
```bash
cd ~/code/planet-nine
git clone https://github.com/planet-nine-app/allyabase.git
```

Verify:
```bash
ls -la ~/code/planet-nine/allyabase
# Should show README.md, deployment/, bootstrap/, etc.
```

---

## Step 5: Navigate to Docker Directory

```bash
cd ~/code/planet-nine/allyabase/deployment/docker
```

Verify:
```bash
pwd
# Should output: /Users/yourusername/code/planet-nine/allyabase/deployment/docker

ls Dockerfile
# Should output: Dockerfile
```

---

## Step 6: Check for Existing Container

Before building, check if a container with the same name exists:

```bash
docker ps -a | grep planet-nine-base
```

If a container exists and you want to replace it:
```bash
docker rm -f planet-nine-base
```

---

## Step 7: Build the Docker Image

This step takes 5-10 minutes. It will:
- Download Node.js base image
- Clone all 11 service repositories
- Install npm dependencies for each
- Apply patches for upstream bugs (e.g., Pref syntax error)

```bash
docker build -t planet-nine-base -f Dockerfile .
```

**Note the `.` at the end - it's required!**

Wait for the build to complete. You should see:
```
Successfully built xxxxxxxx
Successfully tagged planet-nine-base:latest
```

Verify:
```bash
docker images | grep planet-nine-base
# Should show: planet-nine-base   latest   xxxxxxxx   ...
```

---

## Step 8: Run the Container

### Option A: Default Ports (if no conflicts)

If ports 3000-3007, 2525, 2999, 7243, 7277, 3011 are all free:

```bash
docker run -d \
  --name planet-nine-base \
  -p 3000:3000 \
  -p 2999:2999 \
  -p 3002:3002 \
  -p 3003:3003 \
  -p 3004:3004 \
  -p 3005:3005 \
  -p 3006:3006 \
  -p 3007:3007 \
  -p 2525:2525 \
  -p 7277:7277 \
  -p 7243:7243 \
  -p 3011:3011 \
  planet-nine-base
```

### Option B: Alternate Ports (if you have conflicts)

If you have other services using those ports (e.g., port 5000 is used by macOS AirPlay), use the 6xxx range:

**IMPORTANT:** Port 6000 is blocked by Node.js/Chromium for security reasons (it's used by X11). Use port 6100 for Julia instead.

```bash
docker run -d \
  --name planet-nine-base \
  -p 6100:3000 \
  -p 6999:2999 \
  -p 6002:3002 \
  -p 6003:3003 \
  -p 6004:3004 \
  -p 6005:3005 \
  -p 6006:3006 \
  -p 6007:3007 \
  -p 6525:2525 \
  -p 6277:7277 \
  -p 6243:7243 \
  -p 6011:3011 \
  planet-nine-base
```

### If you get "port already in use" error

1. Remove the failed container:
   ```bash
   docker rm planet-nine-base
   ```

2. Try again with different ports (adjust the host ports as needed)

### Verify container is running

```bash
docker ps | grep planet-nine-base
# Should show planet-nine-base container with status "Up"
```

---

## Step 9: Wait for Bootstrap (Important!)

Services need 30-60 seconds to bootstrap (generate keys, register with each other).

Watch the logs:
```bash
docker logs -f planet-nine-base
```

You'll see PM2 starting services and bootstrap messages. Wait until you see services reporting they're ready.

Press `Ctrl+C` to stop following logs.

---

## Step 10: Verify Services Are Running

Check the container logs to see if services started:

```bash
docker logs --tail 50 planet-nine-base
```

You should see output like:
- "fountUser here looks like: { pubKey: '...', uuid: '...' }"
- "putting { uuid: 'bdo', ... }"
- Services registering with each other

**Note:** Upstream Planet Nine services do NOT have `/health` endpoints. A "Cannot GET /health" response actually means the service IS running - it just doesn't have that route.

To verify a service is responding:

**Default ports:**
```bash
curl http://localhost:3006/    # Should return "Cannot GET /" (Fount is running)
curl http://localhost:3003/    # Should return "Cannot GET /" (BDO is running)
```

**Alternate ports (6xxx):**
```bash
curl http://localhost:6006/    # Should return "Cannot GET /" (Fount is running)
curl http://localhost:6003/    # Should return "Cannot GET /" (BDO is running)
```

If you get "Connection refused", the service isn't running. Check logs and wait longer for bootstrap.

---

## Step 11: Test Creating a User

Planet Nine uses **Sessionless authentication** - all requests must be cryptographically signed. You can't just send raw JSON with curl.

### Create the test script

Create `~/code/planet-nine/package.json`:

```json
{
  "name": "planet-nine-test",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "test": "node test-base.js"
  },
  "dependencies": {
    "sessionless-node": "latest"
  }
}
```

Create `~/code/planet-nine/test-base.js`:

```javascript
#!/usr/bin/env node

/**
 * Simple test script for Planet Nine base
 * Tests Fount user creation with proper Sessionless authentication
 */

import sessionless from 'sessionless-node';

// Change this if using different ports
const FOUNT_URL = process.env.FOUNT_URL || 'http://localhost:6006';

let keys = {};
let keysToReturn = {};

async function testFount() {
  console.log('🔑 Generating Sessionless keypair...');

  keys = await sessionless.generateKeys(
    (k) => { keysToReturn = k; },
    () => { return keysToReturn; }
  );

  console.log('   Public Key:', keys.pubKey);
  console.log('   Private Key:', keys.privateKey.substring(0, 20) + '...');

  console.log('\n📤 Creating user in Fount...');

  const payload = {
    timestamp: new Date().getTime() + '',
    pubKey: keys.pubKey,
  };

  // Sign the message (timestamp + pubKey)
  payload.signature = await sessionless.sign(payload.timestamp + payload.pubKey);

  console.log('   Payload:', JSON.stringify(payload, null, 2));

  const response = await fetch(`${FOUNT_URL}/user/create`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  const result = await response.json();

  if (result.uuid) {
    console.log('\n✅ User created successfully!');
    console.log('   UUID:', result.uuid);
    console.log('   MP:', result.mp);
    console.log('   Experience:', result.experience);
    return result;
  } else {
    console.log('\n❌ Error:', result);
    return null;
  }
}

async function main() {
  console.log('='.repeat(50));
  console.log('Planet Nine Base Test');
  console.log('Fount URL:', FOUNT_URL);
  console.log('='.repeat(50));
  console.log('');

  try {
    const user = await testFount();

    if (user) {
      console.log('\n🎉 Your Planet Nine base is working!');
      console.log('\nYour user credentials (save these):');
      console.log('  UUID:', user.uuid);
      console.log('  Public Key:', user.pubKey);
      console.log('  Private Key:', keys.privateKey);
    }
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.log('\nMake sure the container is running:');
    console.log('  docker ps | grep planet-nine-base');
  }
}

main();
```

### Install dependencies and run test

```bash
cd ~/code/planet-nine
npm install
npm test
```

**If using default ports**, change `FOUNT_URL` in the script to `http://localhost:3006`.

### Expected output

```
==================================================
Planet Nine Base Test
Fount URL: http://localhost:6006
==================================================

🔑 Generating Sessionless keypair...
   Public Key: 03abc123...
   Private Key: d6bfe...

📤 Creating user in Fount...

✅ User created successfully!
   UUID: 727672eb-9e71-40a5-b38b-db1a94d874b0
   MP: 1000
   Experience: 0

🎉 Your Planet Nine base is working!
```

**Important:** Save your private key! This is your identity in Planet Nine. You'll need it to sign future requests.

You should get a response with a UUID.

---

## Step 12: Run Comprehensive Test Suite (Optional)

To test all miniservices at once, use the comprehensive test script.

### Update package.json

Update `~/code/planet-nine/package.json` to include the comprehensive test:

```json
{
  "name": "planet-nine-test",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "test": "node test-base.js",
    "test:all": "node test-all-services.js"
  },
  "dependencies": {
    "sessionless-node": "latest"
  }
}
```

### Create test-all-services.js

Create `~/code/planet-nine/test-all-services.js` (this is a large file - see the full script below):

The test script tests these services:
- **Fount** (Port 6006) - Central MAGIC protocol hub
- **BDO** (Port 6003) - Big Dumb Object storage
- **Pref** (Port 6002) - User preferences (may fail - see Known Issues)
- **Julia** (Port 6100) - P2P messaging
- **Continuebee** (Port 6999) - State verification
- **Joan** (Port 6004) - Account recovery
- **Sanora** (Port 6243) - Product storefront
- **Addie** (Port 6005) - Payment processing
- **Minnie** (Port 6525) - SMTP server

### Run the tests

```bash
cd ~/code/planet-nine
npm run test:all
```

### Expected output

```
╔══════════════════════════════════════════════════╗
║     Planet Nine Miniservices Test Suite          ║
╚══════════════════════════════════════════════════╝

Port Configuration:
  fount        → localhost:6006
  bdo          → localhost:6003
  ...

==================================================
📊 TEST RESULTS SUMMARY
==================================================
  ✅ fount
  ✅ bdo
  ✅ pref
  ✅ julia
  ✅ continuebee
  ✅ sanora
  ✅ joan
  ✅ addie
  ✅ minnie

--------------------------------------------------
  Passed: 9  |  Failed: 0  |  Total: 9
==================================================

🎉 All services are working!
```

### API Signature Formats

Each service has different signature requirements:

| Service | Signature Format | HTTP Method |
|---------|-----------------|-------------|
| Fount | `timestamp + pubKey` | PUT |
| BDO | `timestamp + pubKey + hash` | PUT |
| Pref | `timestamp + pubKey + hash` | PUT |
| Julia | `timestamp + pubKey` + `user` object | PUT |
| Continuebee | `timestamp + pubKey + hash` | POST |
| Joan | `timestamp + hash + pubKey` (different order!) | PUT |
| Sanora | `timestamp + pubKey` | PUT |
| Addie | `timestamp + pubKey` | PUT |

---

## Success!

Your Planet Nine base is now running. All 11 core services are available on localhost.

---

## Management Commands

### View Logs

```bash
# Follow logs in real-time
docker logs -f planet-nine-base

# View last 100 lines
docker logs --tail 100 planet-nine-base
```

### Stop the Base

```bash
docker stop planet-nine-base
```

### Start the Base Again

```bash
docker start planet-nine-base
```

### Restart the Base

```bash
docker restart planet-nine-base
```

### Remove the Container Completely

```bash
docker rm -f planet-nine-base
```

### Rebuild from Scratch

```bash
# Remove old container
docker rm -f planet-nine-base

# Rebuild image (to get latest code)
cd ~/code/planet-nine/allyabase/deployment/docker
docker build -t planet-nine-base -f Dockerfile .

# Run again (use your chosen port mapping - default or 6xxx)
# NOTE: Use 6100 for Julia, NOT 6000 (blocked by Node.js)
docker run -d \
  --name planet-nine-base \
  -p 6100:3000 \
  -p 6999:2999 \
  -p 6002:3002 \
  -p 6003:3003 \
  -p 6004:3004 \
  -p 6005:3005 \
  -p 6006:3006 \
  -p 6007:3007 \
  -p 6525:2525 \
  -p 6277:7277 \
  -p 6243:7243 \
  -p 6011:3011 \
  planet-nine-base
```

---

## Service Port Reference

### Default Ports (Option A)

| Service | Port | Purpose |
|---------|------|---------|
| julia | 3000 | P2P messaging |
| continuebee | 2999 | State verification |
| pref | 3002 | User preferences |
| bdo | 3003 | Object storage |
| joan | 3004 | Account recovery |
| addie | 3005 | Payment processing |
| fount | 3006 | MAGIC protocol (central hub) |
| dolores | 3007 | Video/media storage |
| minnie | 2525 | SMTP email |
| aretha | 7277 | Limited-run products |
| sanora | 7243 | Product hosting |
| covenant | 3011 | Contract management |

### Alternate Ports (Option B - 6xxx range)

| Service | Host Port | Container Port | Notes |
|---------|-----------|----------------|-------|
| julia | 6100 | 3000 | Port 6000 is blocked by Node.js |
| continuebee | 6999 | 2999 | |
| pref | 6002 | 3002 | |
| bdo | 6003 | 3003 | |
| joan | 6004 | 3004 | |
| addie | 6005 | 3005 | |
| fount | 6006 | 3006 | |
| dolores | 6007 | 3007 | |
| minnie | 6525 | 2525 | |
| aretha | 6277 | 7277 | |
| sanora | 6243 | 7243 | |
| covenant | 6011 | 3011 | |

---

## Understanding Bootstrap

When services start, they go through a **bootstrap** process:

1. Generate cryptographic keypair (Sessionless protocol)
2. Register with Fount (create a "user" identity)
3. Register with BDO (for storage)
4. Save credentials locally

Services **retry every 2 seconds** if dependencies aren't ready. This means you can start them all at once - they'll wait for each other.

**First startup takes longer** (~30-60 seconds) while services bootstrap.

---

## Key Environment Variable

`LOCALHOST=true` is set automatically in the Docker container. This tells services to connect to `localhost` instead of `*.allyabase.com` production URLs.

---

## Troubleshooting

### "Cannot connect to the Docker daemon"

Docker is not running. Start Docker Desktop (macOS/Windows) or run `sudo systemctl start docker` (Linux).

### Container starts but services don't respond

Services are still bootstrapping. Wait 60 seconds and try again.

### "ECONNREFUSED" errors

Services are still bootstrapping. Wait 30+ seconds.

### "fetch failed" or "bad port" error in Node.js

Port 6000 is blocked by Node.js and Chromium for security reasons (it's the X11 display server port). If you see this error when testing Julia, ensure you're using port 6100, not 6000.

### "no time like the present" error

Clock sync issue. Run: `ntpdate -s time.nist.gov` or sync your system clock.

### Port already in use

Another service is using the port. Check with:
```bash
lsof -i :3006
```

Stop the conflicting service or use different ports.

### Container keeps restarting

Check logs for errors:
```bash
docker logs planet-nine-base
```

### "auth error" when calling API

This is expected! Planet Nine uses Sessionless authentication. All API requests must be cryptographically signed. Use the test script in Step 11 to make proper authenticated requests.

---

## Optional: Payment Processing (Addie)

To enable real payments, you need to rebuild with environment variables:

```bash
docker run -d \
  --name allyabase \
  -e STRIPE_KEY=sk_live_xxx \
  -e STRIPE_PUBLISHING_KEY=pk_live_xxx \
  -e SQUARE_KEY=xxx \
  -p 3000:3000 \
  ... (rest of ports)
  allyabase
```

Without these, Addie runs in simulation mode.

---

## Optional: Prof Service (PII)

Prof handles personal information (names, emails) separately from core services. It's not included in the default Docker image. To add it, you'd need to modify the Dockerfile or run it separately.

---

## Next Steps

1. Read the [allyabase README](https://github.com/planet-nine-app/allyabase) for API documentation
2. Explore individual service repos for detailed API docs
3. Check `~/code/planet-nine/allyabase/test/` for usage examples
4. See `~/code/planet-nine/allyabase/bootstrap/` for advanced configuration

---

## Alternative: Native Setup (No Docker)

If you prefer not to use Docker, see the Native Setup section below.

### Native Step 1: Clone all service repos

```bash
mkdir -p ~/code/planet-nine/services
cd ~/code/planet-nine/services

git clone https://github.com/planet-nine-app/julia.git
git clone https://github.com/planet-nine-app/continuebee.git
git clone https://github.com/planet-nine-app/pref.git
git clone https://github.com/planet-nine-app/bdo.git
git clone https://github.com/planet-nine-app/joan.git
git clone https://github.com/planet-nine-app/addie.git
git clone https://github.com/planet-nine-app/fount.git
git clone https://github.com/planet-nine-app/dolores.git
git clone https://github.com/planet-nine-app/minnie.git
git clone https://github.com/planet-nine-app/aretha.git
git clone https://github.com/planet-nine-app/sanora.git
git clone https://github.com/planet-nine-app/covenant.git
```

### Native Step 2: Install dependencies

```bash
cd ~/code/planet-nine/services

for service in julia continuebee pref bdo joan addie fount dolores minnie aretha sanora covenant; do
  echo "Installing $service..."
  cd $service/src/server/node
  npm install
  cd ~/code/planet-nine/services
done
```

### Native Step 3: Install PM2

```bash
npm install -g pm2
```

### Native Step 4: Create ecosystem.config.js

Create file `~/code/planet-nine/services/ecosystem.config.js`:

```javascript
module.exports = {
  apps: [
    { name: 'julia', script: './julia/src/server/node/julia.js', env: { LOCALHOST: 'true' } },
    { name: 'continuebee', script: './continuebee/src/server/node/continuebee.js', env: { LOCALHOST: 'true' } },
    { name: 'pref', script: './pref/src/server/node/pref.js', env: { LOCALHOST: 'true' } },
    { name: 'bdo', script: './bdo/src/server/node/bdo.js', env: { LOCALHOST: 'true' } },
    { name: 'joan', script: './joan/src/server/node/joan.js', env: { LOCALHOST: 'true' } },
    { name: 'addie', script: './addie/src/server/node/addie.js', env: { LOCALHOST: 'true' } },
    { name: 'fount', script: './fount/src/server/node/fount.js', env: { LOCALHOST: 'true' } },
    { name: 'dolores', script: './dolores/src/server/node/dolores.js', env: { LOCALHOST: 'true' } },
    { name: 'minnie', script: './minnie/src/server/node/minnie.js', env: { LOCALHOST: 'true' } },
    { name: 'aretha', script: './aretha/src/server/node/aretha.js', env: { LOCALHOST: 'true' } },
    { name: 'sanora', script: './sanora/src/server/node/sanora.js', env: { LOCALHOST: 'true' } },
    { name: 'covenant', script: './covenant/src/server/node/covenant.js', env: { LOCALHOST: 'true' } }
  ]
};
```

### Native Step 5: Start all services

```bash
cd ~/code/planet-nine/services
pm2 start ecosystem.config.js
```

### Native Step 6: Verify

```bash
pm2 status
curl http://localhost:3006/health
```

### Native Management

```bash
pm2 status          # View status
pm2 logs            # View all logs
pm2 logs fount      # View specific service logs
pm2 restart all     # Restart all
pm2 stop all        # Stop all
pm2 delete all      # Remove from PM2
```
