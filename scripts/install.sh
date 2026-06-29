#!/usr/bin/env bash
# =============================================================================
# Pravidhi Install Script — Linux & Termux
# =============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh | bash
#   curl -fsSL https://pravidhisolutions.in/install.sh | bash
#
# Or directly via curl one-liner:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/yashas-13/pravidhi/main/scripts/install.sh)"
# =============================================================================

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
REPO="yashas-13/pravidhi"
BRANCH="main"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.pravidhi}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
PIP_ARGS="${PIP_ARGS:---break-system-packages -q}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Detect OS ────────────────────────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Linux)
            if [ -d "/data/data/com.termux" ] || [ "$(uname -o)" = "Android" ] 2>/dev/null; then
                echo "termux"
            else
                echo "linux"
            fi
            ;;
        Darwin) echo "darwin" ;;
        *)      echo "unknown" ;;
    esac
}

OS=$(detect_os)
ARCH=$(uname -m)

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Pravidhi Installer v0.1          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo -e "${CYAN}  OS:${NC} $OS  ${CYAN}Arch:${NC} $ARCH"
echo ""

# ── Dependencies ──────────────────────────────────────────────────────────────
install_deps() {
    echo -e "${YELLOW}[1/4] Installing system dependencies...${NC}"

    case "$OS" in
        linux)
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -qq && sudo apt-get install -y -qq python3 python3-pip git curl openssh-client >/dev/null 2>&1
            elif command -v apk &>/dev/null; then
                apk add --no-cache python3 py3-pip git curl openssh >/dev/null 2>&1
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm python python-pip git curl openssh >/dev/null 2>&1
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y python3 python3-pip git curl openssh >/dev/null 2>&1
            else
                echo -e "${YELLOW}  Unknown package manager. Install python3, git, curl manually.${NC}"
            fi
            ;;
        termux)
            pkg update -y && pkg install -y python python-pip git curl openssh binutils >/dev/null 2>&1
            ;;
        darwin)
            if command -v brew &>/dev/null; then
                brew install python@3 git curl >/dev/null 2>&1
            fi
            ;;
    esac
    echo -e "${GREEN}  ✓ System dependencies ready${NC}"
}

# ── Clone / Update ────────────────────────────────────────────────────────────
clone_repo() {
    echo -e "${YELLOW}[2/4] Downloading Pravidhi...${NC}"

    if [ -d "$INSTALL_DIR" ]; then
        echo -e "  Updating existing installation..."
        cd "$INSTALL_DIR" && git pull --ff-only origin "$BRANCH" 2>/dev/null || true
    else
        git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$INSTALL_DIR"
        echo -e "  Cloned into $INSTALL_DIR"
    fi
    echo -e "${GREEN}  ✓ Pravidhi downloaded${NC}"
}

# ── Install Python package ────────────────────────────────────────────────────
install_python_pkg() {
    echo -e "${YELLOW}[3/4] Installing Python package...${NC}"
    cd "$INSTALL_DIR"

    # Install core deps
    pip install $PIP_ARGS click rich httpx pydantic pydantic-settings pyyaml fastapi uvicorn python-dotenv sqlalchemy apscheduler python-multipart 2>/dev/null || true

    # Install the package itself
    pip install $PIP_ARGS -e . 2>/dev/null || true

    echo -e "${GREEN}  ✓ Python package installed${NC}"
}

# ── Setup PATH & Symlinks ────────────────────────────────────────────────────
setup_path() {
    echo -e "${YELLOW}[4/4] Setting up PATH...${NC}"

    mkdir -p "$BIN_DIR"

    # Create launcher script
    cat > "$BIN_DIR/pravidhi" << 'LAUNCHER'
#!/usr/bin/env bash
exec python3 -m gateway.cli "$@"
LAUNCHER
    chmod +x "$BIN_DIR/pravidhi"

    # Add to PATH if not already present
    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *)
            shell_rc="${HOME}/.bashrc"
            if [ -n "$ZSH_VERSION" ]; then shell_rc="${HOME}/.zshrc"; fi
            if [ "$OS" = "termux" ]; then shell_rc="${HOME}/.bashrc"; fi
            echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$shell_rc"
            echo -e "  Added $BIN_DIR to PATH in $shell_rc"
            ;;
    esac

    # Create config directory
    mkdir -p "$HOME/.pravidhi"

    echo -e "${GREEN}  ✓ PATH configured${NC}"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    install_deps
    clone_repo
    install_python_pkg
    setup_path

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Pravidhi installed!              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Run ${CYAN}pravidhi doctor${NC} to verify installation"
    echo -e "  Run ${CYAN}pravidhi doctor --fix${NC} to auto-repair any issues"
    echo -e "  Run ${CYAN}pravidhi status${NC} to check system status"
    echo ""
    echo -e "  ${CYAN}Quick start:${NC}"
    echo -e "    pravidhi status"
    echo -e "    pravidhi validate \"test prompt\""
    echo -e "    pravidhi cyber skills \"sql injection\""
    echo ""
    echo -e "  ${YELLOW}Set your API key:${NC}"
    echo -e "    export OPENROUTER_API_KEY='sk-or-v1-...'"
    echo ""
    echo -e "  ${CYAN}https://pravidhisolutions.in${NC}"
}

main "$@"
