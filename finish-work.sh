#!/bin/bash

# Configuration
MAIN_BRANCH="main"
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

# Automatically stage and commit changes
handle_changes() {
    local current_branch=$1
    
    # Show current changes
    log_info "Current changes:"
    git status

    # Stage all changes
    log_info "Staging all changes..."
    git add .
    log_success "Changes staged successfully"

    # Show staged changes
    log_info "Staged changes:"
    git status

    # Get default commit message based on changed files
    local default_msg="Updated:"
    local changed_files=$(git diff --cached --name-only)
    for file in $changed_files; do
        default_msg="$default_msg\n- $file"
    done

    # Show default commit message and allow modification
    echo -e "\nDefault commit message:"
    echo -e "$default_msg"
    read -p "Press Enter to use this message or type a new one: " custom_msg

    # Use custom message if provided, otherwise use default
    if [ -z "$custom_msg" ]; then
        echo -e "$default_msg" | git commit -F -
    else
        git commit -m "$custom_msg"
    fi

    log_success "Changes committed successfully"
}

# Main workflow
main() {
    check_git_repo
    load_config

    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    log_info "Finishing work on branch: $CURRENT_BRANCH"
    
    # Handle changes automatically
    handle_changes "$CURRENT_BRANCH"
    
    # Push changes
    log_info "Pushing changes to remote..."
    git push -u origin "$CURRENT_BRANCH"
    
    # Handle merge
    read -p "Do you want to merge into $MAIN_BRANCH? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Merging into $MAIN_BRANCH..."
        git checkout "$MAIN_BRANCH"
        git pull origin "$MAIN_BRANCH"
        git merge "$CURRENT_BRANCH"
        git push origin "$MAIN_BRANCH"
        
        # Branch cleanup
        read -p "Delete $CURRENT_BRANCH locally and remotely? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git branch -d "$CURRENT_BRANCH"
            git push origin --delete "$CURRENT_BRANCH"
            log_success "Branch $CURRENT_BRANCH deleted"
        fi
    fi
    
    log_success "Work completed successfully!"
}

# Run the main workflow
main