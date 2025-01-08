#!/bin/bash

# Configuration
MAIN_BRANCH="main"
CONFIG_FILE="$HOME/.git_workflow_config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Error handling
set -euo pipefail
trap 'echo -e "${RED}Error: Script failed on line $LINENO${NC}"' ERR

# Helper Functions
log_success() { echo -e "${GREEN}✔ $1${NC}"; }
log_info() { echo -e "${YELLOW}ℹ $1${NC}"; }
log_prompt() { echo -e "${BLUE}➤ $1${NC}"; }

show_commit_template() {
    echo -e "${PURPLE}Commit Message Template:${NC}"
    echo "type: subject"
    echo
    echo "Types:"
    echo "- feat: New feature"
    echo "- fix: Bug fix"
    echo "- docs: Documentation"
    echo "- style: Formatting"
    echo "- refactor: Code restructure"
    echo "- test: Testing"
    echo "- chore: Maintenance"
    echo
    echo "Example: feat: add user authentication system"
}

generate_commit_message() {
    local changed_files=$(git diff --cached --name-only)
    local commit_type
    local commit_subject
    
    # Show template
    show_commit_template
    
    # Show changed files
    echo -e "\n${YELLOW}Changed files:${NC}"
    echo "$changed_files"
    
    # Get commit type
    echo -e "\n${BLUE}Select commit type:${NC}"
    select type in "feat" "fix" "docs" "style" "refactor" "test" "chore" "custom"; do
        if [ -n "$type" ]; then
            commit_type=$type
            break
        fi
    done
    
    # Get commit subject
    read -p "Enter commit subject: " commit_subject
    
    # Create full commit message
    if [ "$commit_type" = "custom" ]; then
        read -p "Enter custom commit message: " custom_msg
        echo "$custom_msg"
    else
        echo "$commit_type: $commit_subject"
    fi
}

handle_changes() {
    local current_branch=$1
    
    # Show current changes
    clear
    log_info "Current changes on branch: $current_branch"
    git status
    
    # Stage changes
    log_info "Staging changes..."
    git add .
    
    # Show staged changes
    git status
    
    # Generate commit message
    local commit_msg=$(generate_commit_message)
    
    # Commit changes
    git commit -m "$commit_msg"
    log_success "Changes committed successfully"
    
    # Show commit
    echo -e "\n${PURPLE}Latest commit:${NC}"
    git log -1 --oneline --color
}

# Main workflow
main() {
    clear
    
    # Load current branch if exists
    if [ -f ".current-branch" ]; then
        source .current-branch
    else
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    fi
    
    log_info "Finishing work on branch: $CURRENT_BRANCH"
    
    # Handle changes
    handle_changes "$CURRENT_BRANCH"
    
    # Push changes
    log_info "Pushing changes to remote..."
    git push -u origin "$CURRENT_BRANCH"
    
    # Show branch status
    echo -e "\n${PURPLE}Branch status:${NC}"
    git log --oneline -n 5 --color
    
    # Handle merge
    log_prompt "Do you want to merge into $MAIN_BRANCH? (y/n): "
    read -p "> " merge_choice
    if [[ $merge_choice =~ ^[Yy]$ ]]; then
        log_info "Merging into $MAIN_BRANCH..."
        git checkout "$MAIN_BRANCH"
        git pull origin "$MAIN_BRANCH"
        git merge "$CURRENT_BRANCH"
        git push origin "$MAIN_BRANCH"
        
        # Branch cleanup
        log_prompt "Delete $CURRENT_BRANCH locally and remotely? (y/n): "
        read -p "> " delete_choice
        if [[ $delete_choice =~ ^[Yy]$ ]]; then
            git branch -d "$CURRENT_BRANCH"
            git push origin --delete "$CURRENT_BRANCH"
            log_success "Branch $CURRENT_BRANCH deleted"
            rm -f .current-branch
        fi
    fi
    
    log_success "Work completed successfully!"
    
    # Show final git status
    echo -e "\n${PURPLE}Final status:${NC}"
    git status
}

main