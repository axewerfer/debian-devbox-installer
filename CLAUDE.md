# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Debian Development Environment Installer - a collection of bash scripts that automate the setup of a comprehensive development environment on Debian/Ubuntu systems. The project installs programming languages, development tools, cloud infrastructure, security scanners, monitoring solutions, and AI integration tools.

## Key Commands

### Testing and Validation
```bash
# Validate all bash scripts for syntax errors
./scripts/validate-scripts.sh

# Run GitHub Actions tests locally (requires act)
act -j test-quick-setup
act -j lint-scripts

# Test script syntax with ShellCheck
find scripts/ -name "*.sh" -exec shellcheck {} \;
```

### Installation Scripts
```bash
# Full installation (45-60 minutes)
./scripts/install-devbox.sh

# Quick essentials installation (15 minutes)
./scripts/quick-setup.sh

# Configure credentials after installation
./scripts/configure-credentials.sh

# Diagnose and fix common issues
./scripts/troubleshoot.sh
```

## Project Architecture

### Directory Structure
- `/scripts/` - Main installation and utility scripts
  - `install-devbox.sh` - Full installation orchestrator
  - `quick-setup.sh` - Minimal installation for essentials
  - `configure-credentials.sh` - Post-install credential setup
  - `troubleshoot.sh` - Diagnostic and repair utility
  - `validate-scripts.sh` - Pre-commit validation tool

### Configuration Management
- Installation state tracked in `~/.devbox-config` (created by installer)
- Credentials stored in `~/.devbox-credentials` (created by configure-credentials.sh)
- Scripts use marker-based tracking to avoid reinstalling components

### Testing Strategy
- GitHub Actions workflow tests on Ubuntu 22.04 and 24.04
- Shell scripts validated with bash -n syntax checking
- ShellCheck linting for all bash scripts
- Manual testing recommended on fresh Debian 12/Ubuntu installations

### Script Design Patterns
- All scripts use color-coded output (RED, GREEN, YELLOW, BLUE, PURPLE, CYAN)
- Logging to `~/devbox-install.log` for debugging
- Error handling with `set -e` and helper functions (log, warn, error)
- Installation tracking with check_if_installed/mark_installed functions
- User interaction points with pause_for_input function

## Important Implementation Notes

1. **Script Execution Order**: The main install-devbox.sh orchestrates multiple installation phases. Each phase checks if already completed to support resume functionality.

2. **Credential Handling**: The configure-credentials.sh script handles sensitive data (API keys, tokens). Never commit credentials to the repository.

3. **Cross-Platform Support**: Scripts target Debian/Ubuntu but test on multiple versions. Use package manager detection for compatibility.

4. **Error Recovery**: The troubleshoot.sh script diagnoses common issues like missing dependencies, PATH problems, and service failures.

5. **Validation Requirements**: Always run validate-scripts.sh before committing to catch syntax errors early.