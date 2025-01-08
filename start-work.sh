#!/bin/bash

# Configuration
MAIN_BRANCH="main"
DEFAULT_BRANCH_PREFIX="feature"
CONFIG_FILE="$HOME/.git_workflow_config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handling
set -euo pipefail
trap 'echo -e "${RED}Error: Script failed on line $LINENO${NC}"' ERR

# Helper Functions
log_success() {
    echo -e "${GREEN}✔ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}"
        exit 1
    fi
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Loaded configuration from $CONFIG_FILE"
    fi
}

create_branch_name() {
    local prefix="$1"
    local date_suffix="$(date +%Y-%m-%d)"
    local counter=1
    local branch_name="${prefix}/${date_suffix}"
    
    while git show-ref --verify --quiet "refs/heads/$branch_name" || \
          git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; do
        branch_name="${prefix}/${date_suffix}-${counter}"
        ((counter++))
    done
    
    echo "$branch_name"
}

# Main workflow
main() {
    check_git_repo
    load_config

    log_info "Starting new work day..."
    
    # Update main branch
    log_info "Updating $MAIN_BRANCH branch..."
    git checkout "$MAIN_BRANCH"
    git pull origin "$MAIN_BRANCH"
    
    # Create new branch
    TODAY_BRANCH=$(create_branch_name "$DEFAULT_BRANCH_PREFIX")
    log_info "Creating new branch: $TODAY_BRANCH"
    git checkout -b "$TODAY_BRANCH"
    
    # Success message
    log_success "Ready to start working!"
    echo "You are now on branch: $TODAY_BRANCH"
    echo "When you're done working, run: ./finish-work.sh"
}

# Run the main workflow
main