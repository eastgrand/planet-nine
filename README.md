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
| 6006 | Fount | Central MAGIC protocol hub |
| 6003 | BDO | Big Dumb Object storage |
| 6002 | Pref | User preferences |
| 6004 | Joan | Account recovery |
| 6005 | Addie | Payment processing |
| 6100 | Julia | P2P messaging |
| 6999 | Continuebee | State verification |
| 6007 | Dolores | Video/media |
| 6011 | Covenant | Contracts |
| 6243 | Sanora | Product storefront |
| 6277 | Aretha | Limited-run products |
| 6525 | Minnie | SMTP email |

## Requirements

- **Linux**: Ubuntu, Debian, Raspberry Pi OS, CentOS, RHEL, Rocky, Fedora, Arch, openSUSE, Alpine
- 1GB RAM minimum (2GB recommended)
- Docker (installed automatically by script)

## Manual Setup

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed manual instructions.

## Testing

```bash
cd ~/planet-nine
npm install
npm run test:all
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
- **Julia**: Uses port 6100 instead of 6000 (blocked by Node.js/browsers)

## License

MIT
