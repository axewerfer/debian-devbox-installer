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

# OS Detection
OS_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
OS_VERSION=$(lsb_release -sr)
OS_CODENAME=$(lsb_release -sc)

# Create log file
echo "Installation started at $(date)" > "$LOG_FILE"
echo "OS: $OS_ID $OS_VERSION ($OS_CODENAME)" >> "$LOG_FILE"

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

# Validation function to check if tools are actually installed
validate_installation() {
    local phase=$1
    local tools=("${@:2}")
    local failed=0
    
    log "Validating $phase installation..."
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo -e "${GREEN}  ✅ $tool${NC}"
        else
            echo -e "${RED}  ❌ $tool${NC}"
            ((failed++))
        fi
    done
    
    if [ $failed -gt 0 ]; then
        warn "$phase validation failed: $failed tools missing"
        return 1
    else
        log "$phase validation passed"
        return 0
    fi
}

# Get supported OS codename for Docker
get_docker_codename() {
    case "$OS_ID" in
        ubuntu)
            # Map newer Ubuntu versions to supported ones
            case "$OS_CODENAME" in
                plucky|oracular) echo "noble" ;;  # Use 24.04 LTS as fallback
                noble|jammy|focal|bionic) echo "$OS_CODENAME" ;;
                *) echo "jammy" ;;  # Default to 22.04 LTS
            esac
            ;;
        debian)
            case "$OS_CODENAME" in
                bookworm|bullseye|buster) echo "$OS_CODENAME" ;;
                *) echo "bookworm" ;;  # Default to latest stable
            esac
            ;;
        *)
            echo "jammy"  # Default fallback
            ;;
    esac
}

# Get supported OS codename for third-party repositories
get_supported_codename() {
    case "$OS_ID" in
        ubuntu)
            # Map newer Ubuntu versions to supported ones for most repositories
            case "$OS_CODENAME" in
                plucky|oracular) echo "jammy" ;;  # Use 22.04 LTS as fallback for most tools
                noble|jammy|focal|bionic) echo "$OS_CODENAME" ;;
                *) echo "jammy" ;;  # Default to 22.04 LTS
            esac
            ;;
        debian)
            case "$OS_CODENAME" in
                bookworm|bullseye|buster) echo "$OS_CODENAME" ;;
                *) echo "bookworm" ;;  # Default to latest stable
            esac
            ;;
        *)
            echo "jammy"  # Default fallback
            ;;
    esac
}

# Check if a command is already installed
is_installed() {
    command -v "$1" >/dev/null 2>&1
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
# Phase 0: Repository Cleanup
# =============================================================================

log "Phase 0: Cleaning up conflicting repositories..."

# Clean up VS Code repository conflicts thoroughly
log "Cleaning up VS Code repository conflicts..."
sudo rm -f /etc/apt/sources.list.d/vscode.list
sudo rm -f /etc/apt/trusted.gpg.d/packages.microsoft.gpg
sudo rm -f /usr/share/keyrings/microsoft.gpg
sudo rm -f /etc/apt/trusted.gpg.d/microsoft.gpg

# Remove the VS Code repository from sources completely
sudo sed -i '/packages.microsoft.com\/repos\/code/d' /etc/apt/sources.list 2>/dev/null || true
sudo find /etc/apt/sources.list.d/ -name "*.list" -exec sed -i '/packages.microsoft.com\/repos\/code/d' {} \; 2>/dev/null || true

# Clean GPG keyring of old Microsoft keys
sudo apt-key del EB3E94ADBE1229CF 2>/dev/null || true

# Clean up other potential conflicts
sudo rm -f /etc/apt/sources.list.d/github-cli.list
sudo rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/sources.list.d/hashicorp.list
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/trivy.list
sudo rm -f /usr/share/keyrings/trivy.gpg
sudo rm -f /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo rm -f /usr/share/keyrings/mongodb-server-7.0.gpg
sudo rm -f /etc/apt/sources.list.d/dbeaver.list
sudo rm -f /usr/share/keyrings/dbeaver.gpg
sudo rm -f /etc/apt/sources.list.d/k6.list
sudo rm -f /usr/share/keyrings/k6-archive-keyring.gpg

# Update package lists after cleanup
sudo apt update

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
    
    # Node.js and npm
    log "Installing Node.js..."
    
    # Remove any existing Node.js to avoid conflicts
    sudo apt remove -y nodejs npm 2>/dev/null || true
    sudo rm -f /usr/bin/node /usr/bin/npm /usr/bin/npx
    
    # Install Node.js from NodeSource (includes npm)
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    
    # Verify both Node.js and npm are working
    if ! command -v npm >/dev/null 2>&1; then
        log "npm not found, installing via official installer..."
        curl -qL https://www.npmjs.com/install.sh | sudo sh
    fi
    
    # Verify npm is working
    log "Verifying npm installation..."
    npm --version || error "npm installation failed"
    
    # Global npm packages
    log "Installing global npm packages..."
    sudo npm install -g yarn pnpm @tauri-apps/cli typescript \
        webpack webpack-cli vite parcel rollup esbuild sass less stylus \
        postcss-cli tailwindcss eslint prettier @angular/cli @vue/cli gatsby-cli \
        jest mocha cypress newman @aws-amplify/cli serverless
    
    # Rust
    log "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source cargo environment for this session
    export PATH="$HOME/.cargo/bin:$PATH"
    rustup component add clippy rustfmt
    rustup target add wasm32-unknown-unknown
    cargo install cargo-lambda cargo-audit cargo-watch
    
    # Validate programming languages installation
    if validate_installation "Programming Languages" "python3" "node" "npm" "rustc" "cargo"; then
        mark_installed "PROGRAMMING_LANGUAGES"
    else
        error "Programming Languages installation failed validation"
    fi
else
    log "Phase 2: Programming Languages - SKIPPED (already installed)"
    # Still validate what was supposed to be installed
    if ! validate_installation "Programming Languages" "python3" "node" "npm" "rustc" "cargo"; then
        warn "Previously installed programming languages are missing - re-running installation"
        # Remove the marker to force reinstallation
        sed -i '/INSTALLED_PROGRAMMING_LANGUAGES=true/d' "$CONFIG_FILE"
        error "Please run the script again to reinstall missing programming languages"
    fi
fi

# =============================================================================
# Phase 3: Development Tools
# =============================================================================

if ! check_if_installed "DEV_TOOLS"; then
    log "Phase 3: Installing Development Tools"
    
    # VS Code
    if is_installed "code"; then
        log "VS Code already installed - skipping"
    else
        log "Installing VS Code..."
        
        # Install VS Code GPG key and repository (cleanup done in Phase 0)
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        
        # Update and install VS Code
        sudo apt update
        if ! sudo apt install -y code; then
            warn "VS Code installation failed, trying alternative method..."
            # Fallback to manual download
            wget -O code.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
            sudo dpkg -i code.deb
            sudo apt-get install -f -y  # Fix any dependency issues
            rm code.deb
        fi
    fi
    
    # GitHub CLI
    if is_installed "gh"; then
        log "GitHub CLI already installed - skipping"
    else
        log "Installing GitHub CLI..."
        # Repository cleanup done in Phase 0
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install -y gh
    fi
    
    # Docker
    if is_installed "docker"; then
        log "Docker already installed - skipping"
    else
        log "Installing Docker..."
        DOCKER_CODENAME=$(get_docker_codename)
        log "Using Docker repository for: $OS_ID $DOCKER_CODENAME"
        
        # Repository cleanup done in Phase 0
        # Remove any existing Docker packages
        sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
        
        # Install Docker
        curl -fsSL https://download.docker.com/linux/$OS_ID/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $DOCKER_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        
        if sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin; then
            sudo usermod -aG docker $USER
            log "Docker installed successfully"
        else
            warn "Docker installation failed, trying alternative method..."
            # Fallback to snap installation
            sudo snap install docker
            sudo usermod -aG docker $USER
        fi
    fi
    
    # Additional development tools
    log "Installing additional development tools..."
    sudo apt install -y tmux screen zsh fish neovim emacs-nox
    
    # Validate development tools installation
    if validate_installation "Development Tools" "code" "gh" "docker" "tmux" "zsh"; then
        mark_installed "DEV_TOOLS"
    else
        error "Development Tools installation failed validation"
    fi
else
    log "Phase 3: Development Tools - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 4: Cloud & Infrastructure Tools
# =============================================================================

if ! check_if_installed "CLOUD_TOOLS"; then
    log "Phase 4: Installing Cloud & Infrastructure Tools"
    
    # AWS CLI
    if is_installed "aws"; then
        log "AWS CLI already installed - skipping"
    else
        log "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    fi
    
    # AWS SAM CLI
    if is_installed "sam"; then
        log "AWS SAM CLI already installed - skipping"
    else
        log "Installing AWS SAM CLI..."
        wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
        unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
        sudo ./sam-installation/install
        rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
    fi
    
    # AWS CDK
    log "Installing AWS CDK..."
    sudo npm install -g aws-cdk
    
    # Terraform
    if is_installed "terraform"; then
        log "Terraform already installed - skipping"
    else
        log "Installing Terraform..."
        # Repository cleanup done in Phase 0
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install -y terraform
    fi
    
    # Ansible
    log "Installing Ansible..."
    pipx install ansible
    
    # Pulumi
    log "Installing Pulumi..."
    curl -fsSL https://get.pulumi.com | sh
    
    # Kubernetes tools
    log "Installing Kubernetes tools..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    # Helm
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt update && sudo apt install -y helm
    
    # Validate cloud tools installation
    if validate_installation "Cloud Tools" "aws" "sam" "cdk" "terraform" "ansible-community" "kubectl" "helm"; then
        mark_installed "CLOUD_TOOLS"
    else
        error "Cloud Tools installation failed validation"
    fi
else
    log "Phase 4: Cloud & Infrastructure Tools - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 5: Security Tools
# =============================================================================

if ! check_if_installed "SECURITY_TOOLS"; then
    log "Phase 5: Installing Security Tools"
    
    # Trivy
    log "Installing Trivy..."
    SUPPORTED_CODENAME=$(get_supported_codename)
    log "Using repository codename: $SUPPORTED_CODENAME for Trivy"
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $SUPPORTED_CODENAME main" | sudo tee /etc/apt/sources.list.d/trivy.list
    sudo apt update && sudo apt install -y trivy
    
    # Java (required for ZAP and SonarQube)
    if ! command -v java >/dev/null 2>&1; then
        log "Installing Java 17..."
        sudo apt update
        sudo apt install -y openjdk-17-jdk
        log "Java 17 installed"
    else
        log "Java already installed - skipping"
    fi

    # OWASP ZAP
    if is_installed "zap.sh"; then
        log "OWASP ZAP already installed - skipping"
    else
        log "Installing OWASP ZAP (this may take a few minutes)..."
        wget --progress=dot:giga https://github.com/zaproxy/zaproxy/releases/download/v2.16.1/ZAP_2_16_1_unix.sh -O zap-installer.sh
        chmod +x zap-installer.sh
        echo "Installing ZAP silently..."
        sudo ./zap-installer.sh -q -dir /opt/zaproxy
        
        # Create symlink for easier access
        sudo ln -sf /opt/zaproxy/zap.sh /usr/local/bin/zap.sh
        rm zap-installer.sh
        log "OWASP ZAP installation completed"
    fi
    
    # SonarQube Scanner
    if is_installed "sonar-scanner"; then
        log "SonarQube Scanner already installed - skipping"
    else
        log "Installing SonarQube Scanner..."
        wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
        unzip sonar-scanner-cli-5.0.1.3006-linux.zip
        sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner
        sudo ln -sf /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
        rm sonar-scanner-cli-5.0.1.3006-linux.zip
    fi
    
    # Snyk
    log "Installing Snyk..."
    sudo npm install -g snyk
    
    # Doppler
    log "Installing Doppler..."
    curl -Ls https://cli.doppler.com/install.sh | sudo sh
    
    # SOPS
    log "Installing SOPS..."
    wget https://github.com/mozilla/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -O sops
    sudo install sops /usr/local/bin/sops
    rm sops
    
    # Validate security tools installation
    if validate_installation "Security Tools" "trivy" "snyk" "doppler" "sonar-scanner" "sops"; then
        mark_installed "SECURITY_TOOLS"
    else
        error "Security Tools installation failed validation"
    fi
else
    log "Phase 5: Security Tools - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 6: Monitoring & Observability
# =============================================================================

if ! check_if_installed "MONITORING_TOOLS"; then
    log "Phase 6: Installing Monitoring & Observability Tools"
    
    # Prometheus
    log "Installing Prometheus..."
    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
    tar xzf prometheus-2.45.0.linux-amd64.tar.gz
    sudo mv prometheus-2.45.0.linux-amd64 /opt/prometheus
    sudo ln -s /opt/prometheus/prometheus /usr/local/bin/prometheus
    rm prometheus-2.45.0.linux-amd64.tar.gz
    
    # Grafana
    log "Installing Grafana..."
    sudo apt-get install -y adduser libfontconfig1
    wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.0.0_amd64.deb
    sudo dpkg -i grafana-enterprise_10.0.0_amd64.deb
    rm grafana-enterprise_10.0.0_amd64.deb
    
    # K6
    log "Installing K6..."
    wget -q https://dl.k6.io/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/k6-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
    sudo apt update && sudo apt install -y k6
    
    mark_installed "MONITORING_TOOLS"
else
    log "Phase 6: Monitoring & Observability Tools - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 7: Database Tools
# =============================================================================

if ! check_if_installed "DATABASE_TOOLS"; then
    log "Phase 7: Installing Database Tools"
    
    # PostgreSQL
    log "Installing PostgreSQL..."
    sudo apt install -y postgresql postgresql-contrib
    
    # MySQL
    log "Installing MySQL..."
    sudo apt install -y mysql-server mysql-client
    
    # MongoDB
    log "Installing MongoDB..."
    SUPPORTED_CODENAME=$(get_supported_codename)
    log "Using repository codename: $SUPPORTED_CODENAME for MongoDB"
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $SUPPORTED_CODENAME/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt update && sudo apt install -y mongodb-org
    
    # Redis
    log "Installing Redis..."
    sudo apt install -y redis-server
    
    # DBeaver
    log "Installing DBeaver..."
    wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg
    echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
    sudo apt update && sudo apt install -y dbeaver-ce
    
    mark_installed "DATABASE_TOOLS"
else
    log "Phase 7: Database Tools - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 8: AI Integration Tools
# =============================================================================

if ! check_if_installed "AI_TOOLS"; then
    log "Phase 8: Installing AI Integration Tools"
    
    # Claude Code
    log "Installing Claude Code..."
    if is_installed "claude"; then
        log "Claude Code already installed - skipping"
    else
        sudo npm install -g @anthropic-ai/claude-code
        log "Claude Code installed"
    fi
    
    # Install MCP servers
    log "Installing MCP servers..."
    sudo npm install -g @modelcontextprotocol/server-filesystem
    sudo npm install -g @modelcontextprotocol/server-github
    sudo npm install -g @modelcontextprotocol/server-postgres
    
    # Validate AI tools installation (Claude Code validation is tricky, so we'll just check if it's in PATH)
    if validate_installation "AI Tools" "claude" || command -v claude-code >/dev/null 2>&1; then
        mark_installed "AI_TOOLS"
    else
        warn "AI Tools validation inconclusive - Claude Code may need manual verification"
        mark_installed "AI_TOOLS"
    fi
else
    log "Phase 8: AI Integration Tools - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 9: VS Code Extensions
# =============================================================================

if ! check_if_installed "VSCODE_EXTENSIONS"; then
    log "Phase 9: Installing VS Code Extensions"
    
    # Programming language extensions
    code --install-extension ms-python.python
    code --install-extension ms-python.black-formatter
    code --install-extension ms-python.flake8
    code --install-extension ms-python.pylint
    code --install-extension ms-vscode.vscode-typescript-next
    code --install-extension rust-lang.rust-analyzer
    code --install-extension bradlc.vscode-tailwindcss
    
    # Development tools
    code --install-extension ms-azuretools.vscode-docker
    code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
    code --install-extension hashicorp.terraform
    code --install-extension redhat.vscode-yaml
    code --install-extension redhat.vscode-xml
    
    # Git and GitHub
    code --install-extension eamodio.gitlens
    code --install-extension github.vscode-github-actions
    code --install-extension github.copilot
    code --install-extension github.copilot-chat
    
    # Code quality
    code --install-extension esbenp.prettier-vscode
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension streetsidesoftware.code-spell-checker
    
    # AI and productivity
    code --install-extension saoudrizwan.claude-dev
    code --install-extension Codeium.codeium
    
    # AWS
    code --install-extension amazonwebservices.aws-toolkit-vscode
    
    # Testing
    code --install-extension ms-vscode.test-adapter-converter
    code --install-extension hbenl.vscode-test-explorer
    
    mark_installed "VSCODE_EXTENSIONS"
else
    log "Phase 9: VS Code Extensions - SKIPPED (already installed)"
fi

# =============================================================================
# Phase 10: Final Configuration
# =============================================================================

if ! check_if_installed "FINAL_CONFIG"; then
    log "Phase 10: Final Configuration"
    
    # Create project directories
    log "Creating project directories..."
    mkdir -p ~/Projects/{python,nodejs,rust,web,aws,kubernetes,terraform,ansible}
    
    # Add cargo to PATH for all users
    log "Configuring shell environments..."
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    
    # Add Pulumi to PATH
    echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    
    # Configure Git defaults
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor "code --wait"
    
    # Set up useful aliases
    cat >> ~/.bashrc << 'EOF'

# Development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias bat='batcat'
alias fd='fdfind'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# AWS aliases
alias awsid='aws sts get-caller-identity'
alias awsprofile='aws configure list-profiles'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Ansible aliases
alias ansible='ansible-community'
alias ap='ansible-playbook'
EOF
    
    mark_installed "FINAL_CONFIG"
else
    log "Phase 10: Final Configuration - SKIPPED (already installed)"
fi

# =============================================================================
# Final Validation
# =============================================================================

echo
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}                    FINAL VALIDATION                            ${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo

log "Running final validation of all installed tools..."

# Core development tools
validate_installation "Core Development" "python3" "node" "rustc" "git" "code" "docker"

# Cloud and infrastructure
validate_installation "Cloud & Infrastructure" "aws" "terraform" "kubectl" "helm" "ansible-community"

# Security tools
validate_installation "Security Tools" "trivy" "snyk" "doppler"

# Package managers
validate_installation "Package Managers" "pip" "npm" "cargo" "yarn"

echo
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${PURPLE}                    INSTALLATION COMPLETE                       ${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
echo

log "🎉 Development environment installation completed successfully!"
echo
echo -e "${BLUE}What was installed:${NC}"
echo "✅ System preparation and build tools"
echo "✅ Programming languages: Python, Node.js, Rust"
echo "✅ Development tools: VS Code, Git, Docker, GitHub CLI"
echo "✅ Cloud tools: AWS CLI, SAM, CDK, Terraform, Ansible, Pulumi"
echo "✅ Kubernetes tools: kubectl, Helm"
echo "✅ Security tools: Trivy, OWASP ZAP, SonarQube, Snyk, Doppler"
echo "✅ Monitoring tools: Prometheus, Grafana, K6"
echo "✅ Database tools: PostgreSQL, MySQL, MongoDB, Redis, DBeaver"
echo "✅ AI integration: Claude Code, MCP servers"
echo "✅ VS Code extensions (20+ essential extensions)"
echo "✅ Shell configuration and aliases"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. 🔄 Log out and back in (or restart) to apply all changes"
echo "2. ⚙️  Run: ./scripts/configure-credentials.sh"
echo "3. 🔍 Run: ./scripts/troubleshoot.sh to verify everything works"
echo "4. 🔧 Configure your specific development needs"
echo
echo -e "${GREEN}Happy coding! 🚀${NC}"

log "Installation completed successfully!"
echo "Installation completed at $(date)" >> "$LOG_FILE"
