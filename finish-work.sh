#!/bin/bash

# Colors (only for display, not for messages)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
MAIN_BRANCH="main"

# Functions
log_info() { echo -e "${YELLOW}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }

generate_commit_message() {
    local changed_files=$(git diff --cached --name-only)
    local features=()
    
    # Analyze each changed file for specific features
    while IFS= read -r file; do
        if [[ $file =~ [Ll]ogin ]]; then
            features+=("login")
        fi
        if [[ $file =~ [Ss]ignup ]]; then
            features+=("signup")
        fi
        if [[ $file =~ [Aa]uth ]]; then
            features+=("authentication")
        fi
        if [[ $file =~ [Pp]rofile ]]; then
            features+=("user profile")
        fi
        if [[ $file =~ [Dd]ashboard ]]; then
            features+=("dashboard")
        fi
        if [[ $file =~ [Nn]av ]]; then
            features+=("navigation")
        fi
        if [[ $file =~ [Hh]ome ]]; then
            features+=("home page")
        fi
        if [[ $file =~ [Aa]pi ]]; then
            features+=("API")
        fi
    done <<< "$changed_files"
    
    # Remove duplicates
    features=($(echo "${features[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    # Generate commit title
    local commit_title
    if [ ${#features[@]} -gt 0 ]; then
        commit_title="update:"
        for feature in "${features[@]}"; do
            commit_title+=" $feature"
        done
    else
        if echo "$changed_files" | grep -q "\.js\|\.jsx\|\.ts\|\.tsx"; then
            commit_title="update: feature implementation"
        elif echo "$changed_files" | grep -q "\.css\|\.scss"; then
            commit_title="update: styles"
        elif echo "$changed_files" | grep -q "\.yml"; then
            commit_title="update: configuration"
        elif echo "$changed_files" | grep -q "package.json"; then
            commit_title="update: dependencies"
        else
            commit_title="update: general changes"
        fi
    fi
    
    # Generate file list
    local files_list=""
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            files_list+="\n• $file"
        fi
    done <<< "$changed_files"
    
    # Display message for review
    echo -e "${BLUE}Commit Message Preview:${NC}"
    echo -e "${YELLOW}Title:${NC} $commit_title"
    echo -e "${YELLOW}Files:${NC}$files_list"
    
    # Confirm or modify message
    echo -e "\n${BLUE}Use this message? (y/n)${NC}"
    read -p "> " use_message
    
    if [[ $use_message =~ ^[Yy]$ ]]; then
        # Return clean message without color codes
        echo "$commit_title$files_list"
    else
        echo -e "\n${BLUE}Enter custom message:${NC}"
        read -p "> " custom_msg
        echo "$custom_msg$files_list"
    fi
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

# Generate and apply commit message
commit_message=$(generate_commit_message)

# Clean up the message by removing any remaining color codes
clean_message=$(echo "$commit_message" | sed 's/\x1b\[[0-9;]*m//g')

# Commit with clean message
git commit -m "$clean_message"
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