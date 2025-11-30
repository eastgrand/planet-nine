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

## Known Issues

- **Julia port 3000**: Port 3000 is blocked by Node.js/Chromium for security reasons (X11). This only affects running tests **locally on a dev machine**. On a server deployment, port 3000 works fine. If testing locally, you can use `curl` instead of the Node.js test script, or remap Julia to a different port (e.g., 3100).

## License

MIT
