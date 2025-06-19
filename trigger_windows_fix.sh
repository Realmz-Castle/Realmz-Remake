#!/bin/bash

# Trigger Windows OpenMPT Fix Workflow
# This script triggers the GitHub Actions workflow to extract MinGW DLLs for Windows OpenMPT support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from the Realmz-Remake root directory."
    exit 1
fi

# Check if we're in the correct repository
if ! [ -f "src/project.godot" ]; then
    print_error "src/project.godot not found. Please run this script from the Realmz-Remake root directory."
    exit 1
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed."
    print_status "Please install it from: https://cli.github.com/"
    print_status "Or use the GitHub web interface to trigger the workflow manually."
    exit 1
fi

# Check if user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI."
    print_status "Please run: gh auth login"
    exit 1
fi

print_status "Triggering Windows OpenMPT fix workflow..."
print_status "This will extract MinGW runtime DLLs from GitHub Actions runner and commit them to the repository."

# Ask for confirmation unless --force is provided
if [ "$1" != "--force" ]; then
    echo
    read -p "Do you want to continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Aborted by user."
        exit 0
    fi
fi

# Get current branch
current_branch=$(git branch --show-current)
print_status "Current branch: $current_branch"

# Check if there are uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    print_warning "You have uncommitted changes. The workflow will run on the current branch state in the remote repository."
    print_status "Make sure to push your changes if you want them included."
fi

# Ask about force update
echo
print_status "Options:"
echo "1. Normal update (skip if DLLs already exist)"
echo "2. Force update (extract DLLs even if they exist)"
echo

read -p "Select option [1/2]: " -n 1 -r option
echo

force_update="false"
if [ "$option" == "2" ]; then
    force_update="true"
    print_status "Will force update existing DLLs"
else
    print_status "Will skip if DLLs already exist"
fi

# Trigger the workflow
print_status "Triggering workflow 'Fix Windows OpenMPT DLLs' on branch '$current_branch'..."

if gh workflow run fix-windows-openmpt.yml \
    --ref "$current_branch" \
    --field force_update="$force_update"; then
    print_success "Workflow triggered successfully!"
else
    print_error "Failed to trigger workflow."
    exit 1
fi

print_status "Workflow is now running. You can monitor its progress with:"
echo "  gh run watch"
echo "  Or visit: https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/actions"

print_status "The workflow will:"
echo "  1. Extract libgcc_s_seh-1.dll and libstdc++-6.dll from GitHub runner"
echo "  2. Place them in src/addons/godot-openmpt/bin/runtime/"
echo "  3. Update src/export_presets.cfg to include them in Windows builds"
echo "  4. Commit and push the changes automatically"

print_success "Windows OpenMPT fix initiated!"
