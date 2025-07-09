#!/bin/bash

# =============================================================================
# Debian Development Environment Automated Installer
# =============================================================================
# This is the main orchestration script that installs everything in order
# Run with: chmod +x install-devbox.sh && ./install-devbox.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/devbox-install.log"
CONFIG_FILE="$HOME/.devbox-config"

# Create log file
echo "Installation started at $(date)" > "$LOG_FILE"

# Helper functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
    echo "[$(date +'%H:%M:%S')] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
    echo "[$(date +'%H:%M:%S')] WARNING: $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"
    echo "[$(date +'%H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
    exit 1
}

pause_for_input() {
    echo -e "${CYAN}$1${NC}"
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

check_if_installed() {
    local component=$1
    if grep -q "INSTALLED_$component=true" "$CONFIG_FILE" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

mark_installed() {
    local component=$1
    echo "INSTALLED_$component=true" >> "$CONFIG_FILE"
}

# Banner
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           🚀 DEBIAN DEVELOPMENT ENVIRONMENT INSTALLER       ║
║                                                              ║
║     Complete setup for full-stack development with AI       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo
echo -e "${BLUE}This installer will set up a complete development environment including:${NC}"
echo "• Programming languages (Python, Node.js, Rust)"
echo "• Development tools (VS Code, Git, Docker)"
echo "• AWS tools (CLI, SAM, CDK)"
echo "• Security tools (Trivy, OWASP ZAP, SonarQube)"
echo "• Monitoring tools (Prometheus, Grafana)"
echo "• AI integration (Claude Code, MCP servers)"
echo "• And much more..."
echo

pause_for_input "Ready to begin installation?"

# Create config file if it doesn't exist
touch "$CONFIG_FILE"

# =============================================================================
# Phase 1: System Preparation
# =============================================================================

if ! check_if_installed "SYSTEM_PREP"; then
    log "Phase 1: System Preparation"
    
    log "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    
    log "Installing essential build tools..."
    sudo apt install -y curl wget git build-essential software-properties-common \
        apt-transport-https ca-certificates gnupg lsb-release unzip zip \
        tree htop neofetch vim nano jq ripgrep fd-find bat
    
    mark_installed "SYSTEM_PREP"
else
    log "Phase 1: System Preparation - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 2: Programming Languages
# =============================================================================

if ! check_if_installed "PROGRAMMING_LANGUAGES"; then
    log "Phase 2: Installing Programming Languages"
    
    # Python
    log "Installing Python ecosystem..."
    sudo apt install -y python3 python3-pip python3-venv python3-dev pipx
    pipx ensurepath
    pipx install poetry black flake8 mypy bandit safety
    
    # Node.js
    log "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    
    # Global npm packages
    log "Installing global npm packages..."
    sudo npm install -g yarn pnpm create-react-app @tauri-apps/cli typescript \
        webpack webpack-cli vite parcel-bundler rollup esbuild sass less stylus \
        postcss-cli tailwindcss eslint prettier @angular/cli @vue/cli gatsby-cli \
        jest mocha cypress newman @aws-amplify/cli serverless
    
    # Rust
    log "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    rustup component add clippy rustfmt
    rustup target add wasm32-unknown-unknown
    cargo install cargo-lambda cargo-audit
    
    mark_installed "PROGRAMMING_LANGUAGES"
else
    log "Phase 2: Programming Languages - SKIPPED (already installed)"
fi

# Continue with all phases from the original script...
# (The rest of the phases would be included here)

log "Installation completed successfully!"
echo "Installation completed at $(date)" >> "$LOG_FILE"
