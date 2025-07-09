# 🚀 Debian Development Environment Installer

[![Build Status](https://github.com/axewerfer/debian-devbox-installer/workflows/Test%20Installation%20Scripts/badge.svg)](https://github.com/axewerfer/debian-devbox-installer/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/axewerfer/debian-devbox-installer)](https://github.com/axewerfer/debian-devbox-installer/issues)
[![GitHub stars](https://img.shields.io/github/stars/axewerfer/debian-devbox-installer)](https://github.com/axewerfer/debian-devbox-installer/stargazers)

A comprehensive automated installer for setting up a complete full-stack development environment on Debian/Ubuntu systems. Perfect for solo developers who need everything from basic programming tools to advanced DevOps, security, and AI integration.

## ⚡ Quick Start

### Option 1: Clone Repository (Recommended)
```bash
# Clone the repository
git clone https://github.com/axewerfer/debian-devbox-installer.git
cd debian-devbox-installer

# Make scripts executable
chmod +x scripts/*.sh

# Full installation (45-60 minutes)
./scripts/install-devbox.sh

# OR quick essentials only (15 minutes)
./scripts/quick-setup.sh

# Configure credentials (after either option)
./scripts/configure-credentials.sh

# Fix any issues
./scripts/troubleshoot.sh
```

### Option 2: Direct Download & Run
```bash
# Quick essentials only (15 minutes)
curl -O https://raw.githubusercontent.com/axewerfer/debian-devbox-installer/main/scripts/quick-setup.sh
chmod +x quick-setup.sh
./quick-setup.sh

# OR full installation (download all scripts first)
wget https://github.com/axewerfer/debian-devbox-installer/archive/refs/heads/main.zip
unzip main.zip
cd debian-devbox-installer-main
chmod +x scripts/*.sh
./scripts/install-devbox.sh
```

## 📋 What Gets Installed

### 🔧 Core Development Tools
- **Programming Languages**: Python 3, Node.js, Rust
- **Package Managers**: pip, npm, yarn, pnpm, cargo, poetry
- **Development Environment**: VS Code with 20+ essential extensions
- **Version Control**: Git, GitHub CLI

### ☁️ Cloud & Infrastructure
- **AWS Tools**: CLI v2, SAM CLI, CDK, Amplify CLI
- **Infrastructure as Code**: Terraform, Ansible, Pulumi
- **Container & Orchestration**: Docker, Kubernetes tools
- **CI/CD**: Jenkins, GitLab Runner, ArgoCD, Flux

### 🔐 Security & Quality
- **Vulnerability Scanning**: Trivy, OWASP ZAP, SonarQube Scanner
- **Code Quality**: ESLint, Prettier, Black, Clippy
- **Secrets Management**: Doppler, SOPS, Vault
- **Dependency Scanning**: Safety, npm audit, cargo audit

### 📊 Monitoring & Observability
- **Metrics**: Prometheus, Grafana, Node Exporter
- **Logging**: ELK Stack, Loki, Vector
- **Performance Testing**: K6, Apache Bench, Wrk
- **Uptime Monitoring**: Uptime Kuma
### 🗄️ Database Support
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis
- **Clients**: DBeaver, CLI tools for all databases
- **Connection Management**: Automatic service setup

### 🤖 AI Integration
- **Claude Code**: Anthropic's agentic coding tool with hooks
- **MCP Servers**: Model Context Protocol for AI-tool integration
- **VS Code AI Extensions**: Copilot Chat, Cline, CodeiumVs, AI Toolkit

### 🌐 Web Development
- **Build Tools**: Webpack, Vite, Parcel, Rollup, ESBuild
- **CSS Tools**: Sass, Less, PostCSS, Tailwind CSS
- **Frameworks**: React, Vue, Angular, Svelte tooling
- **Testing**: Jest, Cypress, Playwright, Puppeteer

## 🎯 Installation Scripts

### 1. **Full Installation** (Recommended)
```bash
./scripts/install-devbox.sh
```

**Duration**: ~45-60 minutes  
**Installs**: Everything listed above  
**Requires**: Manual input for credentials and configuration

### 2. **Quick Setup** (Essentials Only)
```bash
./scripts/quick-setup.sh
```

**Duration**: ~15 minutes  
**Installs**: Python, Node.js, Rust, VS Code, Git, Docker, AWS CLI  
**Good for**: Getting started quickly, minimal setup

### 3. **Credentials Configuration**
```bash
./scripts/configure-credentials.sh
```

**Configures**:
- Git username/email and GitHub authentication
- AWS credentials and profiles
- Anthropic API key (for Claude Code)
- MCP server connections and database connections
