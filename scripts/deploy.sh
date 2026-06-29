#!/usr/bin/env bash
# =============================================================================
# Pravidhi Deploy Script — SSH + curl one-liner install on remote VPS
# =============================================================================
# Usage:
#   # Deploy to VPS
#   ./scripts/deploy.sh root@194.164.148.37
#
#   # Or with password
#   SSHPASS='your-password' ./scripts/deploy.sh root@194.164.148.37
#
#   # Curl one-liner install (on target machine)
#   curl -fsSL https://pravidhisolutions.in/install.sh | bash
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BOLD='\033[1m'

# ── Config ────────────────────────────────────────────────────────────────────
DOMAIN="pravidhisolutions.in"
REPO="yashas-13/pravidhi"
BRANCH="main"
SSH_HOST="${1:-}"
SSH_PORT="${SSH_PORT:-22}"
SSH_USER="${SSH_USER:-root}"
VPS_USER="${VPS_USER:-root}"
PRAVIDHI_HOME="/root/.pravidhi"

if [ -z "$SSH_HOST" ] && [ "$#" -eq 0 ]; then
    # Default VPS
    SSH_HOST="194.164.148.37"
fi

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Pravidhi Deploy Script v1.0                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ── Help ──────────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Usage:"
    echo "  ./scripts/deploy.sh <host>      Deploy to VPS"
    echo "  ./scripts/deploy.sh --curl      Show curl install commands"
    echo "  ./scripts/deploy.sh --doctor    Run remote doctor"
    echo "  ./scripts/deploy.sh --fix       Run remote doctor --fix"
    echo ""
    echo "Examples:"
    echo "  ./scripts/deploy.sh root@194.164.148.37"
    echo "  SSHPASS='password' ./scripts/deploy.sh root@vps.example.com"
    exit 0
fi

# ── Show curl one-liner ───────────────────────────────────────────────────────
if [ "${1:-}" = "--curl" ]; then
    echo -e "${GREEN}${BOLD}Curl One-Liner Install Commands:${NC}"
    echo ""
    echo -e "${YELLOW}Standard Install:${NC}"
    echo "  bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh)\""
    echo ""
    echo -e "${YELLOW}Direct from domain:${NC}"
    echo "  curl -fsSL https://$DOMAIN/install.sh | bash"
    echo ""
    echo -e "${YELLOW}With doctor fix:${NC}"
    echo "  bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh)\" && pravidhi doctor --fix"
    echo ""
    echo -e "${YELLOW}Remote SSH install:${NC}"
    echo "  ssh root@$SSH_HOST 'bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh)\"'"
    echo ""
    echo -e "${YELLOW}Remote SSH with password:${NC}"
    echo "  sshpass -p 'iAMGENERATED#V1' ssh -o StrictHostKeyChecking=no root@194.164.148.37 'bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh)\"'"
    echo ""
    echo -e "${YELLOW}Full setup on VPS (install + doctor fix + serve):${NC}"
    SSH_CMD="sshpass -p 'iAMGENERATED#V1' ssh -o StrictHostKeyChecking=no root@194.164.148.37"
    echo "  $SSH_CMD 'bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/scripts/install.sh)\" && pravidhi doctor --fix && pravidhi serve --host 0.0.0.0 --port 8642'"
    exit 0
fi

# ── Remote Doctor ─────────────────────────────────────────────────────────────
if [ "${1:-}" = "--doctor" ]; then
    echo -e "${YELLOW}Running remote doctor on $SSH_HOST...${NC}"
    SSH_CMD="sshpass -p 'iAMGENERATED#V1' ssh -o StrictHostKeyChecking=no root@194.164.148.37"
    $SSH_CMD 'pravidhi doctor' 2>/dev/null || {
        echo -e "${YELLOW}Pravidhi not installed. Running install first...${NC}"
        $SSH_CMD 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh)" && pravidhi doctor'
    }
    exit 0
fi

if [ "${1:-}" = "--fix" ]; then
    echo -e "${YELLOW}Running remote doctor --fix on $SSH_HOST...${NC}"
    SSH_CMD="sshpass -p 'iAMGENERATED#V1' ssh -o StrictHostKeyChecking=no root@194.164.148.37"
    $SSH_CMD 'pravidhi doctor --fix 2>&1' 2>/dev/null || {
        echo -e "${YELLOW}Installing and fixing...${NC}"
        $SSH_CMD 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh)" && pravidhi doctor --fix'
    }
    exit 0
fi

# ── Parse SSH Host ────────────────────────────────────────────────────────────
if [[ "$SSH_HOST" =~ ^(.+)@(.+)$ ]]; then
    SSH_USER="${BASH_REMATCH[1]}"
    SSH_HOST="${BASH_REMATCH[2]}"
fi

# ── Deploy to VPS ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Checking SSH access to $SSH_USER@$SSH_HOST:$SSH_PORT...${NC}"

SSHPASS="${SSHPASS:-}"
SSH_CMD="ssh"
if [ -n "$SSHPASS" ]; then
    if command -v sshpass &>/dev/null; then
        SSH_CMD="sshpass -p '$SSHPASS' ssh -o StrictHostKeyChecking=no"
    else
        echo -e "${YELLOW}  sshpass not installed. Install it or use SSH key auth.${NC}"
    fi
fi

# Test connection
if ! eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'echo OK' 2>/dev/null"; then
    echo -e "${RED}  Cannot connect to $SSH_USER@$SSH_HOST${NC}"
    echo -e "${YELLOW}  Try: ssh-copy-id $SSH_USER@$SSH_HOST${NC}"
    echo -e "${YELLOW}  Or:  SSHPASS='password' $0 $SSH_USER@$SSH_HOST${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Connected${NC}"

# Step 2: Install dependencies
echo -e "${YELLOW}[2/5] Installing system dependencies...${NC}"
eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'apt-get update -qq && apt-get install -y -qq python3 python3-pip git curl openssh-client nginx >/dev/null 2>&1 && echo OK'" || true
echo -e "${GREEN}  ✓ Dependencies installed${NC}"

# Step 3: Clone repository
echo -e "${YELLOW}[3/5] Cloning Pravidhi...${NC}"
eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'rm -rf $PRAVIDHI_HOME && git clone --depth 1 --branch $BRANCH https://github.com/$REPO.git $PRAVIDHI_HOME && echo OK'" 2>/dev/null || {
    # If repo already exists, pull
    eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'cd $PRAVIDHI_HOME && git pull --ff-only origin $BRANCH && echo OK'"
}
echo -e "${GREEN}  ✓ Repository cloned${NC}"

# Step 4: Install Python package
echo -e "${YELLOW}[4/5] Installing Python package...${NC}"
eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'cd $PRAVIDHI_HOME && pip install --break-system-packages -q -e \".\" >/dev/null 2>&1 && echo OK'"
echo -e "${GREEN}  ✓ Package installed${NC}"

# Step 5: Start Pravidhi service
echo -e "${YELLOW}[5/5] Starting Pravidhi services...${NC}"

# Create systemd service if systemd is available
eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'if command -v systemctl &>/dev/null; then
    cat > /etc/systemd/system/pravidhi.service << \"EOF\"
[Unit]
Description=Pravidhi Self-Progressive AI Ecosystem
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$PRAVIDHI_HOME
ExecStart=$(which python3) -m gateway.cli serve --host 0.0.0.0 --port 8642
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable pravidhi
    systemctl restart pravidhi
    echo OK
else
    cd $PRAVIDHI_HOME && nohup python3 -m gateway.cli serve --host 0.0.0.0 --port 8642 > $PRAVIDHI_HOME/pravidhi.log 2>&1 &
    echo OK
fi'"

echo -e "${GREEN}  ✓ Services started${NC}"

# Also start cron daemon
eval "$SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'cd $PRAVIDHI_HOME && pravidhi cron start >/dev/null 2>&1 &'"

# Done
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Pravidhi Deployed Successfully!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}API Server:${NC}     http://$SSH_HOST:8642"
echo -e "  ${CYAN}Control UI:${NC}     http://$SSH_HOST:8642/"
echo -e "  ${CYAN}API Docs:${NC}       http://$SSH_HOST:8642/docs"
echo -e "  ${CYAN}Health Check:${NC}   http://$SSH_HOST:8642/health"
echo ""
echo -e "  ${YELLOW}Commands:${NC}"
echo -e "    pravidhi status         — System status"
echo -e "    pravidhi doctor         — Diagnostics"
echo -e "    pravidhi doctor --fix   — Auto-repair"
echo -e "    pravidhi cyber pentest  — Run pentest"
echo -e "    pravidhi cron start     — Start cron daemon"
echo ""

# ── Verify ────────────────────────────────────────────────────────────────────
echo -e "${YELLOW}Verifying deployment...${NC}"
sleep 2
if curl -sf "http://$SSH_HOST:8642/health" >/dev/null 2>&1; then
    echo -e "${GREEN}  ✓ Pravidhi is running on http://$SSH_HOST:8642${NC}"
else
    echo -e "${YELLOW}  ⚠ Could not verify. Check the server manually.${NC}"
    echo -e "${YELLOW}  SSH: $SSH_CMD -p $SSH_PORT $SSH_USER@$SSH_HOST 'systemctl status pravidhi'${NC}"
fi
