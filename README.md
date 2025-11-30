# Planet Nine Base

Run your own Planet Nine Base with one command.

## Quick Start (Digital Ocean / Ubuntu)

```bash
curl -sSL https://raw.githubusercontent.com/eastgrand/planet-nine/main/install.sh | bash
```

This installs Docker, clones the repos, applies bug fixes, and starts all 12 miniservices.

## What's Included

| File | Purpose |
|------|---------|
| `install.sh` | One-line installer for Ubuntu/Debian |
| `docker-compose.yml` | Docker Compose configuration |
| `SETUP_GUIDE.md` | Detailed step-by-step manual setup |
| `DIGITAL_OCEAN_QUICKSTART.md` | Digital Ocean specific guide |
| `test-base.js` | Simple Fount test script |
| `test-all-services.js` | Comprehensive test for all 9 services |

## Services

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

## Requirements

- **Linux**: Ubuntu, Debian, Raspberry Pi OS, CentOS, RHEL, Rocky, Fedora, Arch, openSUSE, Alpine
- 1GB RAM minimum (2GB recommended)
- Docker (installed automatically by script)

## Manual Setup

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed manual instructions.

## Verify Installation

After install, verify all services are working:

```bash
cd ~/planet-nine
npm install
npm run test:all
```

Expected output:
```
╔══════════════════════════════════════════════════╗
║     Planet Nine Miniservices Test Suite          ║
╚══════════════════════════════════════════════════╝

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

Quick health check (no Node.js required):
```bash
# These should return "Cannot GET /" (means service is running)
curl http://localhost:3006/   # Fount
curl http://localhost:3003/   # BDO
curl http://localhost:3002/   # Pref
```

## Management

```bash
cd ~/planet-nine
docker compose logs -f      # View logs
docker compose restart      # Restart
docker compose down         # Stop
docker compose up -d        # Start
```

## Bug Fixes Applied

This repo includes fixes for upstream issues:
- **Pref**: Syntax error fix (`res.send({preferences}));` → `res.send({preferences});`)
- **Pref**: Missing `fs` import added

## Next Steps

Once your base is running, you can:

1. **Create a user identity** - Run `npm run test:all` to create your first Sessionless keypair and UUID
2. **Build a Gateway** - Create apps that connect to your base (see [Gateway Development](#gateway-development))
3. **Add payment processing** - Configure Stripe/Square keys for Addie
4. **Set up a storefront** - Use Sanora to sell digital products

## Gateway Development

A **Gateway** is an app that connects to your Planet Nine base. Examples:
- A game that saves player state (Continuebee)
- An e-commerce site (Sanora + Addie)
- A social app with messaging (Julia)
- A file sharing service (BDO)

### Quick Start Gateway (Node.js)

```javascript
import sessionless from 'sessionless-node';

// Your base URL (replace with your server IP)
const BASE_URL = 'http://YOUR_SERVER_IP:3006';

// Generate keys (save these!)
let keys = {};
const savedKeys = await sessionless.generateKeys(
  (k) => { keys = k; },
  () => keys
);

// Create a user
const timestamp = Date.now().toString();
const signature = await sessionless.sign(timestamp + keys.pubKey);

const response = await fetch(`${BASE_URL}/user/create`, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ timestamp, pubKey: keys.pubKey, signature })
});

const user = await response.json();
console.log('Your UUID:', user.uuid);
```

### Service APIs

| Service | Use Case | Example |
|---------|----------|---------|
| Fount | User creation, MAGIC protocol | Create accounts, link services |
| BDO | Store JSON objects | Save game data, user files |
| Pref | Key-value preferences | User settings, app config |
| Continuebee | State verification | Game saves, session state |
| Julia | P2P messaging | Chat, notifications |
| Joan | Account recovery | Backup/restore identities |
| Addie | Payments | Stripe/Square integration |
| Sanora | Product catalog | Digital goods, subscriptions |

## Development Workflow (Digital Ocean Example)

### Setup

1. **Local machine**: Write and test your Gateway code
2. **Digital Ocean Droplet**: Runs your Planet Nine base
3. **Connect**: Your Gateway talks to the base via HTTP API

### Typical Workflow

```
┌─────────────────┐         ┌─────────────────────────────┐
│  Your Laptop    │   SSH   │  Digital Ocean Droplet      │
│                 │ ──────► │                             │
│  - Write code   │         │  Planet Nine Base           │
│  - Test locally │   API   │  - Fount    :3006           │
│  - Deploy       │ ──────► │  - BDO      :3003           │
│                 │         │  - Pref     :3002           │
└─────────────────┘         │  - etc...                   │
                            └─────────────────────────────┘
```

### Step-by-Step

1. **Develop locally**
   ```bash
   # On your laptop
   mkdir my-gateway && cd my-gateway
   npm init -y
   npm install sessionless-node node-fetch
   ```

2. **Point to your remote base**
   ```javascript
   // config.js
   export const BASE_URL = 'http://YOUR_DROPLET_IP:3006';
   ```

3. **Test against remote base**
   ```bash
   node my-app.js
   ```

4. **Deploy your Gateway** (optional)
   - Deploy to Vercel, Netlify, or same Droplet
   - Your Gateway can run anywhere that can reach the base

### Environment Variables

```bash
# .env for your Gateway
FOUNT_URL=http://YOUR_DROPLET_IP:3006
BDO_URL=http://YOUR_DROPLET_IP:3003
PREF_URL=http://YOUR_DROPLET_IP:3002
# ... etc
```

### Security Notes

- **Firewall**: Only open ports you need (3006 minimum for Fount)
- **HTTPS**: Use a reverse proxy (nginx/Caddy) for production
- **Keys**: Never expose private keys in client-side code
- **Signatures**: All requests must be signed with Sessionless

## Known Issues

- **Julia port 3000**: Port 3000 is blocked by Node.js/Chromium for security reasons (X11). This only affects running tests **locally on a dev machine**. On a server deployment, port 3000 works fine. If testing locally, you can use `curl` instead of the Node.js test script, or remap Julia to a different port (e.g., 3100).

## License

MIT
