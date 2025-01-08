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
log_info "Starting new work day..."

# Update main branch
log_info "Updating main branch..."
git checkout main
git pull origin main

# Show existing branches
echo -e "\n${YELLOW}Today's branches:${NC}"
git branch | grep "$(date +%Y-%m-%d)" || echo "No branches for today"

# Get branch type
echo -e "\n${BLUE}Branch type (f/b/h/r/c):${NC}"
echo "f = feature"
echo "b = bugfix"
echo "h = hotfix"
echo "r = release"
echo "c = custom"
read -p "> " branch_type

# Convert branch type
case $branch_type in
    "f"|"F") prefix="feature" ;;
    "b"|"B") prefix="bugfix" ;;
    "h"|"H") prefix="hotfix" ;;
    "r"|"R") prefix="release" ;;
    "c"|"C")
        read -p "Enter custom type: " custom_type
        prefix=$custom_type
        ;;
    *) prefix="feature" ;;
esac

# Get description
echo -e "\n${BLUE}Enter task description:${NC}"
read -p "> " description

# Clean description (remove spaces and special characters)
clean_description=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')

# Create branch name
branch_name="${prefix}/$(date +%Y-%m-%d)"
if [ -n "$clean_description" ]; then
    branch_name="${branch_name}-${clean_description}"
fi

# Create branch
echo -e "\n${YELLOW}Creating branch: $branch_name${NC}"
git checkout -b "$branch_name"

# Final instructions
echo -e "\n${GREEN}Ready to work!${NC}"
echo "You are on branch: $branch_name"
echo "Run ./finish-work.sh when done"