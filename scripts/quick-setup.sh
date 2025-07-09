#!/bin/bash

# =============================================================================
# Quick Essential Development Setup
# =============================================================================
# For when you just need the core tools fast
# Run with: chmod +x quick-setup.sh && ./quick-setup.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                🚀 QUICK DEVELOPMENT SETUP                   ║
║                                                              ║
║     Essential tools only - ~15 minutes installation         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo
echo -e "${BLUE}This script installs only the essential development tools:${NC}"
echo "• Python, Node.js, Rust"
echo "• VS Code with key extensions"
echo "• Git and GitHub CLI"
echo "• Docker"
echo "• AWS CLI and basic tools"
echo "• Basic security tools"
echo

read -p "Continue with quick setup? (y/N): " -n 1 -r
echoif [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

log "Starting quick setup..."

# System update
log "Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential software-properties-common

# Programming languages
log "Installing Python..."
sudo apt install -y python3 python3-pip python3-venv pipx
pipx ensurepath
pipx install poetry black

log "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn typescript create-react-app

log "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

# Development tools
log "Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update && sudo apt install -y code
log "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh

# Docker
log "Installing Docker..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

# AWS CLI
log "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Basic VS Code extensions
log "Installing essential VS Code extensions..."
code --install-extension ms-python.python
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension rust-lang.rust-analyzer
code --install-extension ms-vscode.vscode-docker
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.vscode-eslint

# Create basic project structure
log "Creating project directories..."
mkdir -p ~/Projects/{python,nodejs,rust,web,aws}

echo
echo -e "${GREEN}🎉 Quick setup completed!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Log out and back in for Docker group membership"
echo "2. Run: source ~/.bashrc"
echo "3. Configure Git and other credentials"
echo "4. For full environment, run: ./install-devbox.sh"
