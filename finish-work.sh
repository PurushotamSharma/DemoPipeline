#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
log_info() { echo -e "${YELLOW}→ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }

generate_commit_message() {
    local changed_files=$(git diff --cached --name-only)
    local features=()
    
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
    done <<< "$changed_files"
    
    features=($(echo "${features[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    local commit_msg=""
    if [ ${#features[@]} -gt 0 ]; then
        commit_msg="update: ${features[*]}"
    else
        if echo "$changed_files" | grep -q "\.js\|\.jsx\|\.ts\|\.tsx"; then
            commit_msg="update: code changes"
        elif echo "$changed_files" | grep -q "\.css\|\.scss"; then
            commit_msg="update: styles"
        elif echo "$changed_files" | grep -q "\.yml"; then
            commit_msg="update: configuration"
        else
            commit_msg="update: general changes"
        fi
    fi
    
    # Add changed files as bullet points
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            commit_msg+="\n• $file"
        fi
    done <<< "$changed_files"
    
    echo "$commit_msg"
}

# Main workflow
clear
current_branch=$(git rev-parse --abbrev-ref HEAD)
log_info "Working on: $current_branch"

# Stage and commit
git add .
commit_message=$(generate_commit_message)
git commit -m "$commit_message"
log_success "Changes committed"

# Push changes
git push -u origin "$current_branch"
log_success "Changes pushed"

# Handle merge
read -p "Merge to main? (y/n) " do_merge
if [[ $do_merge =~ ^[Yy]$ ]]; then
    git checkout main
    git pull origin main
    git merge "$current_branch"
    git push origin main
    
    read -p "Delete branch? (y/n) " do_delete
    if [[ $do_delete =~ ^[Yy]$ ]]; then
        git branch -d "$current_branch"
        git push origin --delete "$current_branch"
        log_success "Branch cleaned up"
    fi
fi

log_success "Done!"