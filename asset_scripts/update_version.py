#!/usr/bin/env python3

import argparse
import re
from pathlib import Path

def load_version(project_file):
    """Load the current version from the project.godot file."""
    try:
        with open(project_file, 'r') as f:
            content = f.read()
            version_match = re.search(r'config/version="([^"]+)"', content)
            if version_match:
                return version_match.group(1)
            return '0.0.0'
    except FileNotFoundError:
        print(f"Warning: {project_file} not found. Starting with 0.0.0")
        return '0.0.0'

def save_version(project_file, version):
    """Save the version to the project.godot file."""
    try:
        with open(project_file, 'r') as f:
            content = f.read()

        # Check if version line exists
        if 'config/version=' in content:
            # Replace existing version
            new_content = re.sub(
                r'config/version="[^"]+"',
                f'config/version="{version}"',
                content
            )
        else:
            # Add version under [application] section
            new_content = re.sub(
                r'(\[application\]\n)',
                f'\\1config/version="{version}"\n',
                content
            )

        with open(project_file, 'w') as f:
            f.write(new_content)
            
        return True
    except Exception as e:
        print(f"Error saving version: {e}")
        return False

def increment_version(current_version, part):
    """Increment the specified version part (major, minor, or patch)."""
    try:
        major, minor, patch = map(int, current_version.split('.'))
    except ValueError:
        print(f"Error: Invalid version format '{current_version}'. Using 0.0.0")
        major = minor = patch = 0

    if part == 'major':
        major += 1
        minor = 0
        patch = 0
    elif part == 'minor':
        minor += 1
        patch = 0
    elif part == 'patch':
        patch += 1

    return f"{major}.{minor}.{patch}"

def main():
    parser = argparse.ArgumentParser(description='Update version number in project.godot')
    parser.add_argument('part', choices=['major', 'minor', 'patch'],
                       help='Version part to increment')
    parser.add_argument('--project-file', default='../src/project.godot',
                       help='Path to project.godot file')
    
    args = parser.parse_args()
    
    script_dir = Path(__file__).parent
    project_file = script_dir / args.project_file
    
    # Load current version
    current_version = load_version(project_file)
    
    # Increment version
    new_version = increment_version(current_version, args.part)
    
    # Save new version
    if save_version(project_file, new_version):
        print(f"Version updated: {current_version} -> {new_version}")
    else:
        print("Failed to update version")
        exit(1)

if __name__ == "__main__":
    main()