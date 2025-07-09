#!/bin/bash

# =============================================================================
# Script Validation Tool
# =============================================================================
# Validates all bash scripts for syntax errors before committing
# Run with: chmod +x validate-scripts.sh && ./validate-scripts.sh

echo "🔍 Validating all bash scripts for syntax errors..."
echo

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Function to check a script
check_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")
    
    if bash -n "$script_path" 2>/dev/null; then
        echo -e "${GREEN}✅ $script_name - Syntax OK${NC}"
    else
        echo -e "${RED}❌ $script_name - Syntax ERROR${NC}"
        echo -e "${YELLOW}Error details:${NC}"
        bash -n "$script_path"
        ((ERRORS++))
    fi
}

# Check all shell scripts
echo "Checking scripts in scripts/ directory:"
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        check_script "$script"
    fi
done

echo

# Check if any validation scripts exist in other directories
if [ -d "tests" ]; then
    echo "Checking scripts in tests/ directory:"
    for script in tests/*.sh; do
        if [ -f "$script" ]; then
            check_script "$script"
        fi
    done
    echo
fi

# Summary
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 All scripts passed validation!${NC}"
    echo "✅ Ready to commit and push"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS script(s) with syntax errors${NC}"
    echo "🔧 Please fix the errors before committing"
    exit 1
fi
