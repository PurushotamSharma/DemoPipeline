#!/bin/bash

# Colors for log messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${YELLOW}→ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }

# Function to generate commit messages based on changes
generate_commit_message() {
    local changed_files
    changed_files=$(git diff --cached --name-only)
    local features=()

    while IFS= read -r file; do
        if [[ $file =~ [Ll]ogin ]]; then
            features+=("Login functionality")
        fi
        if [[ $file =~ [Ss]ignup ]]; then
            features+=("Signup functionality")
        fi
        if [[ $file =~ [Aa]uth ]]; then
            features+=("Authentication")
        fi
        if [[ $file =~ [Pp]rofile ]]; then
            features+=("User profile")
        fi
        if [[ $file =~ [Dd]ashboard ]]; then
            features+=("Dashboard")
        fi
        if [[ $file =~ [Nn]av ]]; then
            features+=("Navigation")
        fi
    done <<< "$changed_files"

    # Remove duplicates
    features=($(echo "${features[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # Generate commit message title
    local commit_title
    if [ ${#features[@]} -gt 0 ]; then
        commit_title="Update: ${features[*]}"
    else
        if echo "$changed_files" | grep -q "\.js\|\.jsx\|\.ts\|\.tsx"; then
            commit_title="Update: Code changes"
        elif echo "$changed_files" | grep -q "\.css\|\.scss"; then
            commit_title="Update: Styles"
        elif echo "$changed_files" | grep -q "\.yml"; then
            commit_title="Update: Configuration"
        else
            commit_title="Update: General changes"
        fi
    fi

    # Add changed files as a detailed list
    local commit_details=""
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            commit_details+="\n- Modified $file"
        fi
    done <<< "$changed_files"

    echo -e "$commit_title\n$commit_details"
}

# Main workflow
clear
current_branch=$(git rev-parse --abbrev-ref HEAD)
log_info "Working on branch: $current_branch"

# Stage all changes
git add .
log_info "Staged all changes."

# Generate and display commit message
commit_message=$(generate_commit_message)
log_info "Generated commit message:"
echo -e "${BLUE}${commit_message}${NC}"

# Allow user to modify commit message or accept the generated one
read -p "Do you want to modify the commit message? (y/n): " modify_message
if [[ $modify_message =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please enter the new commit message:${NC}"
    read -r new_commit_message
    commit_message="$new_commit_message"
fi

# Commit changes
git commit -m "$commit_message"
log_success "Changes committed."

# Push changes to the current branch
git push -u origin "$current_branch"
log_success "Changes pushed to origin/$current_branch."

# Handle merge to the main branch
read -p "Do you want to merge to the main branch? (y/n): " do_merge
if [[ $do_merge =~ ^[Yy]$ ]]; then
    log_info "Switching to main branch."
    git checkout main
    git pull origin main
    log_info "Merging branch $current_branch into main."
    git merge "$current_branch"
    git push origin main
    log_success "Branch $current_branch merged into main and pushed."

    # Optional: Delete the current branch after merging
    read -p "Do you want to delete the branch $current_branch? (y/n): " do_delete
    if [[ $do_delete =~ ^[Yy]$ ]]; then
        git branch -d "$current_branch"
        git push origin --delete "$current_branch"
        log_success "Branch $current_branch deleted locally and remotely."
    fi
fi

log_success "Done!"
