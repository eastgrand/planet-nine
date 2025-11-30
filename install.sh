#!/bin/bash
#
# Planet Nine Base - One-Click Installer
# Works on: Ubuntu 20.04+, Debian 11+, Digital Ocean Droplets
#
# Usage: curl -sSL https://raw.githubusercontent.com/eastgrand/planet-nine/main/install.sh | bash
#

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║       Planet Nine Base Installer                 ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Cannot detect OS. This script supports Ubuntu/Debian.${NC}"
    exit 1
fi

echo -e "${GREEN}Detected OS: $OS${NC}"
echo ""

# Step 1: Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Installing Docker...${NC}"

    case $OS in
        ubuntu|debian)
            $SUDO apt-get update
            $SUDO apt-get install -y ca-certificates curl gnupg

            $SUDO install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            $SUDO chmod a+r /etc/apt/keyrings/docker.gpg

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

            $SUDO apt-get update
            $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;

        centos|rhel|rocky|almalinux)
            $SUDO yum install -y yum-utils
            $SUDO yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            $SUDO yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            $SUDO systemctl start docker
            $SUDO systemctl enable docker
            ;;

        fedora)
            $SUDO dnf -y install dnf-plugins-core
            $SUDO dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            $SUDO dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            $SUDO systemctl start docker
            $SUDO systemctl enable docker
            ;;

        arch|manjaro)
            $SUDO pacman -Sy --noconfirm docker docker-compose
            $SUDO systemctl start docker
            $SUDO systemctl enable docker
            ;;

        opensuse*|sles)
            $SUDO zypper install -y docker docker-compose
            $SUDO systemctl start docker
            $SUDO systemctl enable docker
            ;;

        alpine)
            $SUDO apk add --no-cache docker docker-compose
            $SUDO rc-update add docker boot
            $SUDO service docker start
            ;;

        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            echo "Please install Docker manually: https://docs.docker.com/engine/install/"
            exit 1
            ;;
    esac

    # Add current user to docker group
    if [ "$EUID" -ne 0 ]; then
        $SUDO usermod -aG docker $USER
        echo -e "${YELLOW}Added $USER to docker group. You may need to log out and back in.${NC}"
    fi

    echo -e "${GREEN}Docker installed successfully!${NC}"
else
    echo -e "${GREEN}Docker already installed.${NC}"
fi

# Step 2: Create project directory
INSTALL_DIR="${HOME}/planet-nine"
echo ""
echo -e "${YELLOW}Installing to: $INSTALL_DIR${NC}"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Step 3: Clone allyabase if not present
if [ ! -d "allyabase" ]; then
    echo ""
    echo -e "${YELLOW}Cloning Planet Nine allyabase...${NC}"
    git clone https://github.com/planet-nine-app/allyabase.git
else
    echo -e "${GREEN}allyabase already cloned.${NC}"
fi

# Step 4: Apply Pref fix to Dockerfile
echo ""
echo -e "${YELLOW}Applying upstream bug fixes...${NC}"

DOCKERFILE="$INSTALL_DIR/allyabase/deployment/docker/Dockerfile"

# Check if fix already applied
if ! grep -q "Fix upstream pref.js" "$DOCKERFILE"; then
    # Insert the fix after pref npm install
    sed -i '/WORKDIR \/usr\/src\/app\/pref\/src\/server\/node/,/RUN npm install/{
        /RUN npm install/a\
\
# Fix upstream pref.js syntax error: extra parenthesis and missing fs import\
RUN sed -i '"'"'s/res.send({preferences}));/res.send({preferences});/'"'"' pref.js \&\& \\\
    sed -i "/import db from '"'"'.\/src\/persistence\/db.js'"'"';/a import fs from '"'"'fs\/promises'"'"';" pref.js
    }' "$DOCKERFILE"
    echo -e "${GREEN}Pref fix applied.${NC}"
else
    echo -e "${GREEN}Pref fix already applied.${NC}"
fi

# Step 5: Create docker-compose.yml
echo ""
echo -e "${YELLOW}Creating docker-compose.yml...${NC}"

cat > "$INSTALL_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  planet-nine:
    build:
      context: ./allyabase/deployment/docker
      dockerfile: Dockerfile
    container_name: planet-nine-base
    restart: unless-stopped
    ports:
      - "6100:3000"   # Julia - P2P messaging
      - "6999:2999"   # Continuebee - State verification
      - "6002:3002"   # Pref - User preferences
      - "6003:3003"   # BDO - Object storage
      - "6004:3004"   # Joan - Account recovery
      - "6005:3005"   # Addie - Payment processing
      - "6006:3006"   # Fount - MAGIC protocol
      - "6007:3007"   # Dolores - Video/media
      - "6011:3011"   # Covenant - Contracts
      - "6243:7243"   # Sanora - Storefront
      - "6277:7277"   # Aretha - Limited products
      - "6525:2525"   # Minnie - SMTP
    volumes:
      - planet-nine-data:/usr/src/app/data
    environment:
      - LOCALHOST=true
      - NODE_ENV=production

volumes:
  planet-nine-data:
EOF

echo -e "${GREEN}docker-compose.yml created.${NC}"

# Step 6: Build and start
echo ""
echo -e "${YELLOW}Building Planet Nine Base (this takes 5-10 minutes)...${NC}"
echo ""

cd "$INSTALL_DIR"
$SUDO docker compose build

echo ""
echo -e "${YELLOW}Starting Planet Nine Base...${NC}"
$SUDO docker compose up -d

# Step 7: Wait for bootstrap
echo ""
echo -e "${YELLOW}Waiting 60 seconds for services to bootstrap...${NC}"
sleep 60

# Step 8: Verify
echo ""
echo -e "${YELLOW}Verifying services...${NC}"

if curl -s http://localhost:6006/ | grep -q "Cannot GET"; then
    echo -e "${GREEN}✅ Fount is running on port 6006${NC}"
else
    echo -e "${RED}❌ Fount may not be running${NC}"
fi

if curl -s http://localhost:6003/ | grep -q "Cannot GET"; then
    echo -e "${GREEN}✅ BDO is running on port 6003${NC}"
else
    echo -e "${RED}❌ BDO may not be running${NC}"
fi

if curl -s http://localhost:6002/ | grep -q "Cannot GET"; then
    echo -e "${GREEN}✅ Pref is running on port 6002${NC}"
else
    echo -e "${RED}❌ Pref may not be running${NC}"
fi

# Done!
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║       Installation Complete!                     ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Your Planet Nine Base is running at:"
echo ""
echo "  Fount (main):  http://$(hostname -I | awk '{print $1}'):6006"
echo "  BDO:           http://$(hostname -I | awk '{print $1}'):6003"
echo "  Pref:          http://$(hostname -I | awk '{print $1}'):6002"
echo "  Joan:          http://$(hostname -I | awk '{print $1}'):6004"
echo "  Addie:         http://$(hostname -I | awk '{print $1}'):6005"
echo "  Sanora:        http://$(hostname -I | awk '{print $1}'):6243"
echo ""
echo "Management commands:"
echo "  cd ~/planet-nine"
echo "  docker compose logs -f      # View logs"
echo "  docker compose restart      # Restart"
echo "  docker compose down         # Stop"
echo "  docker compose up -d        # Start"
echo ""
echo -e "${YELLOW}Note: Open ports 6002-6007, 6011, 6100, 6243, 6277, 6525, 6999 in your firewall.${NC}"
echo ""
