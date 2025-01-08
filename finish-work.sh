#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
MAIN_BRANCH="main"

# Functions
log_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Start workflow
clear

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
log_info "Completing work on: $current_branch"

# Show status
echo -e "\n${YELLOW}Current changes:${NC}"
git status

# Stage changes
git add .
log_success "Changes staged"

# Commit type
echo -e "\n${BLUE}Commit type:${NC}"
echo "f = feature"
echo "b = bugfix"
echo "d = docs"
echo "r = refactor"
echo "s = style"
read -p "> " commit_type

# Convert commit type
case $commit_type in
    "f"|"F") prefix="feat" ;;
    "b"|"B") prefix="fix" ;;
    "d"|"D") prefix="docs" ;;
    "r"|"R") prefix="refactor" ;;
    "s"|"S") prefix="style" ;;
    *) prefix="feat" ;;
esac

# Get commit message
echo -e "\n${BLUE}Enter commit message:${NC}"
read -p "> " message

# Create commit
git commit -m "$prefix: $message"
log_success "Changes committed"

# Push changes
git push -u origin "$current_branch"
log_success "Changes pushed"

# Offer merge
echo -e "\n${BLUE}Merge to main? (y/n)${NC}"
read -p "> " do_merge

if [[ $do_merge =~ ^[Yy]$ ]]; then
    git checkout main
    git pull origin main
    git merge "$current_branch"
    git push origin main
    
    # Offer branch deletion
    echo -e "\n${BLUE}Delete branch? (y/n)${NC}"
    read -p "> " do_delete
    
    if [[ $do_delete =~ ^[Yy]$ ]]; then
        git branch -d "$current_branch"
        git push origin --delete "$current_branch"
        log_success "Branch deleted"
    fi
fi

log_success "Work completed!"