#!/bin/bash

# Exit immediately on any error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Logging functions
log_info() { echo -e "${YELLOW}→ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# Generate a meaningful commit message based on changed files
generate_commit_message() {
    local changed_files=$(git diff --cached --name-only)
    local features=()
    
    while IFS= read -r file; do
        case "$file" in
            *[Ll]ogin*) features+=("login") ;;
            *[Ss]ignup*) features+=("signup") ;;
            *[Aa]uth*) features+=("authentication") ;;
            *[Pp]rofile*) features+=("user profile") ;;
            *[Dd]ashboard*) features+=("dashboard") ;;
            *[Nn]av*) features+=("navigation") ;;
        esac
    done <<< "$changed_files"
    
    # Remove duplicates and sort features
    features=($(echo "${features[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    # Generate commit message
    local commit_msg=""
    if [ ${#features[@]} -gt 0 ]; then
        commit_msg="update: ${features[*]}"
    else
        # Fallback to generic messages based on file types
        if echo "$changed_files" | grep -qE "\.js$|\.jsx$|\.ts$|\.tsx$"; then
            commit_msg="update: code changes"
        elif echo "$changed_files" | grep -qE "\.css$|\.scss$"; then
            commit_msg="update: styles"
        elif echo "$changed_files" | grep -q "\.yml$"; then
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

# Main Workflow
clear
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Ensure we are not accidentally on the main branch
if [[ "$current_branch" == "main" ]]; then
    log_error "You are on the 'main' branch. Please switch to a feature branch before committing changes."
    exit 1
fi

log_info "Current branch: $current_branch"

# Stage and commit changes
git add .
commit_message=$(generate_commit_message)
git commit -m "$commit_message"
log_success "Changes committed successfully."

# Push changes
git push -u origin "$current_branch"
log_success "Changes pushed to remote branch: $current_branch."

# Merge to main if the user agrees
read -p "Would you like to merge changes to 'main'? (y/n) " do_merge
if [[ $do_merge =~ ^[Yy]$ ]]; then
    git checkout main
    git pull origin main
    git merge "$current_branch"
    git push origin main
    log_success "Merged $current_branch into 'main'."

    # Delete the feature branch if the user agrees
    read -p "Would you like to delete the branch '$current_branch'? (y/n) " do_delete
    if [[ $do_delete =~ ^[Yy]$ ]]; then
        git branch -d "$current_branch"
        git push origin --delete "$current_branch"
        log_success "Deleted branch '$current_branch' locally and remotely."
    fi
fi

log_success "Workflow completed successfully!"
