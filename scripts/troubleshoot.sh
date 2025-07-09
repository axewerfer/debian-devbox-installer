#!/bin/bash

# =============================================================================
# Development Environment Troubleshooting Script
# =============================================================================
# Diagnoses and fixes common issues with the development environment
# Run with: chmod +x troubleshoot.sh && ./troubleshoot.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Counters
ISSUES_FOUND=0
ISSUES_FIXED=0

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((ISSUES_FOUND++))
}

error() {
    echo -e "${RED}❌ $1${NC}"
    ((ISSUES_FOUND++))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

fix() {
    echo -e "${BLUE}🔧 $1${NC}"
    ((ISSUES_FIXED++))
}

check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        success "$name is installed"
        return 0
    else
        error "$name is not installed"
        return 1
    fi
}

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║               🔧 DEVELOPMENT ENVIRONMENT                     ║
║                    TROUBLESHOOTING                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo
echo -e "${BLUE}This script will diagnose and fix common development environment issues.${NC}"
echo

# =============================================================================
# System Health Check
# =============================================================================

echo -e "${PURPLE}═══ SYSTEM HEALTH CHECK ═══${NC}"

# Check disk space
echo "Checking disk space..."
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 90 ]; then
    error "Disk usage is ${disk_usage}% - consider cleaning up"
else
    success "Disk usage is ${disk_usage}% - OK"
fi

# =============================================================================
# Core Tools Check
# =============================================================================

echo
echo -e "${PURPLE}═══ CORE TOOLS CHECK ═══${NC}"

check_command "python3" "Python"
check_command "node" "Node.js"
check_command "rustc" "Rust"
check_command "git" "Git"
check_command "docker" "Docker"
check_command "code" "VS Code"
check_command "aws" "AWS CLI"

echo
echo -e "${PURPLE}═══ TROUBLESHOOTING SUMMARY ═══${NC}"
echo

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 No issues found! Your development environment looks healthy.${NC}"
else
    echo -e "${YELLOW}📊 Found $ISSUES_FOUND potential issues.${NC}"
    echo -e "${BLUE}Run the main installer to fix missing tools: ./install-devbox.sh${NC}"
fi

echo -e "${GREEN}✅ Troubleshooting completed!${NC}"
