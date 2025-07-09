#!/bin/bash

# =============================================================================
# Development Environment Credentials Configuration
# =============================================================================
# This script helps configure all API keys, tokens, and credentials
# Run with: chmod +x configure-credentials.sh && ./configure-credentials.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration file
CREDS_FILE="$HOME/.devbox-credentials"

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

pause_for_input() {
    echo -e "${CYAN}$1${NC}"
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Create credentials tracking file
touch "$CREDS_FILE"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         🔐 DEVELOPMENT CREDENTIALS CONFIGURATION             ║
║                                                              ║
║    Secure setup of API keys, tokens, and configurations     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo
echo -e "${BLUE}This script will help you configure:${NC}"
echo "• Git and GitHub authentication"
echo "• AWS credentials and profiles"
echo "• Claude/Anthropic API keys"
echo "• Database connections"
echo "• MCP server configurations"
echo "• Security tool configurations"
echo

pause_for_input "Ready to configure your development credentials?"

# =============================================================================
# Git Configuration
# =============================================================================

echo
echo -e "${PURPLE}═══ GIT CONFIGURATION ═══${NC}"

if ! grep -q "GIT_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global core.editor "code --wait"
    
    success "Git configured for $git_username <$git_email>"
    echo "GIT_CONFIGURED=true" >> "$CREDS_FILE"
else
    info "Git already configured - skipping"
fi
