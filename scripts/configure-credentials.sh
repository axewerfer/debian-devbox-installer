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

# =============================================================================
# GitHub Authentication
# =============================================================================

echo
echo -e "${PURPLE}═══ GITHUB AUTHENTICATION ═══${NC}"

if ! grep -q "GITHUB_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    echo "Setting up GitHub CLI authentication..."
    echo
    echo "Options:"
    echo "1. Authenticate with browser (recommended)"
    echo "2. Authenticate with personal access token"
    echo "3. Skip GitHub authentication"
    echo
    read -p "Choose an option (1-3): " github_choice
    
    case $github_choice in
        1)
            gh auth login -w
            success "GitHub CLI authenticated"
            echo "GITHUB_CONFIGURED=true" >> "$CREDS_FILE"
            ;;
        2)
            echo "Create a token at: https://github.com/settings/tokens"
            echo "Required scopes: repo, workflow, read:org"
            read -s -p "Enter your GitHub personal access token: " gh_token
            echo
            echo "$gh_token" | gh auth login --with-token
            success "GitHub CLI authenticated with token"
            echo "GITHUB_CONFIGURED=true" >> "$CREDS_FILE"
            ;;
        3)
            warn "Skipping GitHub authentication"
            ;;
    esac
else
    info "GitHub already configured - skipping"
fi

# =============================================================================
# AWS Configuration
# =============================================================================

echo
echo -e "${PURPLE}═══ AWS CONFIGURATION ═══${NC}"

if ! grep -q "AWS_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    echo "Configure AWS credentials?"
    echo "1. Yes - I have AWS credentials"
    echo "2. Skip AWS configuration"
    echo
    read -p "Choose an option (1-2): " aws_choice
    
    if [ "$aws_choice" = "1" ]; then
        aws configure
        success "AWS CLI configured"
        echo "AWS_CONFIGURED=true" >> "$CREDS_FILE"
        
        # Optional: Configure additional profiles
        read -p "Configure additional AWS profiles? (y/n): " add_profiles
        if [ "$add_profiles" = "y" ]; then
            while true; do
                read -p "Enter profile name (or press Enter to finish): " profile_name
                if [ -z "$profile_name" ]; then
                    break
                fi
                aws configure --profile "$profile_name"
                success "AWS profile '$profile_name' configured"
            done
        fi
    else
        warn "Skipping AWS configuration"
    fi
else
    info "AWS already configured - skipping"
fi

# =============================================================================
# Claude/Anthropic API Configuration
# =============================================================================

echo
echo -e "${PURPLE}═══ CLAUDE/ANTHROPIC API CONFIGURATION ═══${NC}"

if ! grep -q "ANTHROPIC_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    echo "Configure Anthropic API key for Claude Code?"
    echo "Get your API key from: https://console.anthropic.com/settings/keys"
    echo
    echo "1. Yes - Configure API key"
    echo "2. Skip Anthropic configuration"
    echo
    read -p "Choose an option (1-2): " anthropic_choice
    
    if [ "$anthropic_choice" = "1" ]; then
        read -s -p "Enter your Anthropic API key: " api_key
        echo
        
        # Add to shell profile
        echo "export ANTHROPIC_API_KEY='$api_key'" >> ~/.bashrc
        echo "export ANTHROPIC_API_KEY='$api_key'" >> ~/.zshrc 2>/dev/null || true
        
        # Set for current session
        export ANTHROPIC_API_KEY="$api_key"
        
        success "Anthropic API key configured"
        echo "ANTHROPIC_CONFIGURED=true" >> "$CREDS_FILE"
    else
        warn "Skipping Anthropic configuration"
    fi
else
    info "Anthropic API already configured - skipping"
fi

# =============================================================================
# Database Connections
# =============================================================================

echo
echo -e "${PURPLE}═══ DATABASE CONNECTIONS ═══${NC}"

if ! grep -q "DATABASES_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    echo "Configure database connections?"
    echo "1. PostgreSQL"
    echo "2. MySQL"
    echo "3. MongoDB"
    echo "4. Redis"
    echo "5. Skip database configuration"
    echo
    echo "Select databases to configure (comma-separated, e.g., 1,2,3):"
    read -p "> " db_choices
    
    if [ "$db_choices" != "5" ]; then
        # PostgreSQL
        if [[ "$db_choices" == *"1"* ]]; then
            echo
            echo "PostgreSQL Configuration:"
            read -p "Host (default: localhost): " pg_host
            pg_host=${pg_host:-localhost}
            read -p "Port (default: 5432): " pg_port
            pg_port=${pg_port:-5432}
            read -p "Database name: " pg_db
            read -p "Username: " pg_user
            read -s -p "Password: " pg_pass
            echo
            
            # Create .pgpass file
            echo "$pg_host:$pg_port:$pg_db:$pg_user:$pg_pass" >> ~/.pgpass
            chmod 600 ~/.pgpass
            
            success "PostgreSQL connection configured"
        fi
        
        # MySQL
        if [[ "$db_choices" == *"2"* ]]; then
            echo
            echo "MySQL Configuration:"
            read -p "Host (default: localhost): " mysql_host
            mysql_host=${mysql_host:-localhost}
            read -p "Port (default: 3306): " mysql_port
            mysql_port=${mysql_port:-3306}
            read -p "Username: " mysql_user
            read -s -p "Password: " mysql_pass
            echo
            
            # Create .my.cnf
            cat > ~/.my.cnf << EOF
[client]
host=$mysql_host
port=$mysql_port
user=$mysql_user
password=$mysql_pass
EOF
            chmod 600 ~/.my.cnf
            
            success "MySQL connection configured"
        fi
        
        # MongoDB
        if [[ "$db_choices" == *"3"* ]]; then
            echo
            echo "MongoDB Configuration:"
            read -p "Connection string (mongodb://...): " mongo_uri
            
            # Add to shell profile
            echo "export MONGODB_URI='$mongo_uri'" >> ~/.bashrc
            echo "export MONGODB_URI='$mongo_uri'" >> ~/.zshrc 2>/dev/null || true
            
            success "MongoDB connection configured"
        fi
        
        # Redis
        if [[ "$db_choices" == *"4"* ]]; then
            echo
            echo "Redis Configuration:"
            read -p "Host (default: localhost): " redis_host
            redis_host=${redis_host:-localhost}
            read -p "Port (default: 6379): " redis_port
            redis_port=${redis_port:-6379}
            read -s -p "Password (leave empty if none): " redis_pass
            echo
            
            # Add to shell profile
            echo "export REDIS_URL='redis://${redis_pass:+:$redis_pass@}$redis_host:$redis_port'" >> ~/.bashrc
            echo "export REDIS_URL='redis://${redis_pass:+:$redis_pass@}$redis_host:$redis_port'" >> ~/.zshrc 2>/dev/null || true
            
            success "Redis connection configured"
        fi
        
        echo "DATABASES_CONFIGURED=true" >> "$CREDS_FILE"
    else
        warn "Skipping database configuration"
    fi
else
    info "Databases already configured - skipping"
fi

# =============================================================================
# MCP Server Configuration
# =============================================================================

echo
echo -e "${PURPLE}═══ MCP SERVER CONFIGURATION ═══${NC}"

if ! grep -q "MCP_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    echo "Configure MCP (Model Context Protocol) servers?"
    echo "1. Yes - Configure MCP servers"
    echo "2. Skip MCP configuration"
    echo
    read -p "Choose an option (1-2): " mcp_choice
    
    if [ "$mcp_choice" = "1" ]; then
        # Create MCP config directory
        mkdir -p ~/.config/claude-desktop
        
        # Initialize config if it doesn't exist
        if [ ! -f ~/.config/claude-desktop/config.json ]; then
            echo '{"mcpServers": {}}' > ~/.config/claude-desktop/config.json
        fi
        
        echo
        echo "Available MCP servers:"
        echo "1. Filesystem server (file operations)"
        echo "2. GitHub server (repository operations)"
        echo "3. PostgreSQL server (database operations)"
        echo "4. Web server (web browsing)"
        echo
        echo "Select servers to configure (comma-separated, e.g., 1,2,3):"
        read -p "> " mcp_servers
        
        # Note: This is a simplified version. In reality, you'd need to:
        # 1. Install the MCP servers (npm packages)
        # 2. Configure each server with appropriate settings
        # 3. Update the Claude Desktop config.json
        
        info "MCP server configuration requires manual setup"
        info "See: https://modelcontextprotocol.io/docs/tools/desktop"
        
        echo "MCP_CONFIGURED=partial" >> "$CREDS_FILE"
    else
        warn "Skipping MCP configuration"
    fi
else
    info "MCP already configured - skipping"
fi

# =============================================================================
# Security Tools Configuration
# =============================================================================

echo
echo -e "${PURPLE}═══ SECURITY TOOLS CONFIGURATION ═══${NC}"

if ! grep -q "SECURITY_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    echo "Configure security tools?"
    echo "1. SonarQube token"
    echo "2. Snyk authentication"
    echo "3. Doppler CLI login"
    echo "4. Skip security configuration"
    echo
    echo "Select tools to configure (comma-separated, e.g., 1,2,3):"
    read -p "> " sec_choices
    
    if [ "$sec_choices" != "4" ]; then
        # SonarQube
        if [[ "$sec_choices" == *"1"* ]]; then
            echo
            echo "SonarQube Configuration:"
            read -p "SonarQube server URL: " sonar_url
            read -s -p "SonarQube token: " sonar_token
            echo
            
            # Add to shell profile
            echo "export SONAR_HOST_URL='$sonar_url'" >> ~/.bashrc
            echo "export SONAR_TOKEN='$sonar_token'" >> ~/.bashrc
            
            success "SonarQube configured"
        fi
        
        # Snyk
        if [[ "$sec_choices" == *"2"* ]]; then
            echo
            echo "Authenticating with Snyk..."
            snyk auth
            success "Snyk authenticated"
        fi
        
        # Doppler
        if [[ "$sec_choices" == *"3"* ]]; then
            echo
            echo "Authenticating with Doppler..."
            doppler login
            success "Doppler authenticated"
        fi
        
        echo "SECURITY_CONFIGURED=true" >> "$CREDS_FILE"
    else
        warn "Skipping security tools configuration"
    fi
else
    info "Security tools already configured - skipping"
fi

# =============================================================================
# Summary
# =============================================================================

echo
echo -e "${PURPLE}═══ CONFIGURATION SUMMARY ═══${NC}"
echo

# Check what was configured
configured_items=0

if grep -q "GIT_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    success "Git configuration"
    ((configured_items++))
fi

if grep -q "GITHUB_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    success "GitHub authentication"
    ((configured_items++))
fi

if grep -q "AWS_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    success "AWS credentials"
    ((configured_items++))
fi

if grep -q "ANTHROPIC_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    success "Anthropic API key"
    ((configured_items++))
fi

if grep -q "DATABASES_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    success "Database connections"
    ((configured_items++))
fi

if grep -q "MCP_CONFIGURED" "$CREDS_FILE" 2>/dev/null; then
    success "MCP servers (partial)"
    ((configured_items++))
fi

if grep -q "SECURITY_CONFIGURED=true" "$CREDS_FILE" 2>/dev/null; then
    success "Security tools"
    ((configured_items++))
fi

echo
echo -e "${GREEN}✅ Configuration complete! $configured_items components configured.${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Restart your terminal or run: source ~/.bashrc"
echo "2. Test your configurations with: ./scripts/troubleshoot.sh"
echo "3. For sensitive credentials, consider using a secrets manager"
echo
echo -e "${YELLOW}Note: Credentials are stored in:${NC}"
echo "• ~/.devbox-credentials (tracking file)"
echo "• ~/.bashrc (environment variables)"
echo "• Tool-specific config files (~/.aws, ~/.pgpass, etc.)"
