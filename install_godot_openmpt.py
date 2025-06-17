#!/usr/bin/env python3

"""
Godot OpenMPT v1.3 Installation Script
This script downloads and installs the godot-openmpt addon for Godot projects
"""

import sys
import platform
import urllib.request
import urllib.error
import zipfile
import shutil
import tempfile
import argparse
from pathlib import Path
from datetime import datetime

# Configuration
ADDON_NAME = "godot-openmpt"
VERSION = "v1.3.1"
DOWNLOAD_URL = f"https://github.com/dkonar/godot-openmpt/releases/download/{VERSION}/godot-openmpt-{VERSION}.zip"
SRC_DIR = "src"

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def print_status(message):
    """Print info message with color"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")

def print_success(message):
    """Print success message with color"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")

def print_warning(message):
    """Print warning message with color"""
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")

def print_error(message):
    """Print error message with color"""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

def detect_platform():
    """Detect the current platform and architecture"""
    system = platform.system().lower()
    machine = platform.machine().lower()

    if system == "darwin":
        if machine in ["arm64", "aarch64"]:
            return "darwin-arm64"
        else:
            return "darwin-x64"
    elif system == "linux":
        if machine in ["arm64", "aarch64"]:
            return "linux-arm64"
        else:
            return "linux-x64"
    elif system == "windows":
        return "windows-x64"
    else:
        return "unknown"

def download_file(url, output_path):
    """Download a file from URL to output_path"""
    try:
        print_status(f"Downloading from {url}...")
        with urllib.request.urlopen(url) as response:
            with open(output_path, 'wb') as out_file:
                shutil.copyfileobj(response, out_file)
        return True
    except urllib.error.URLError as e:
        print_error(f"Failed to download file: {e}")
        return False
    except Exception as e:
        print_error(f"Unexpected error during download: {e}")
        return False

def check_existing_installation(target_dir):
    """Check if a valid installation already exists"""
    target_path = Path(target_dir)
    plugin_cfg = target_path / "plugin.cfg"

    if target_path.exists() and plugin_cfg.exists():
        print_status(f"Found existing installation at: {target_dir}")
        return True
    return False

def is_cache_restored_installation(target_dir):
    """Check if installation was restored from cache (has valid structure)"""
    target_path = Path(target_dir)
    plugin_cfg = target_path / "plugin.cfg"

    # Check for key files that indicate a complete installation
    if (target_path.exists() and
        plugin_cfg.exists() and
        any(target_path.glob("**/*.dll")) or any(target_path.glob("**/*.so")) or any(target_path.glob("**/*.dylib"))):
        return True
    return False

def remove_existing_installation(target_dir):
    """Remove existing installation if it exists"""
    target_path = Path(target_dir)

    if target_path.exists() and any(target_path.iterdir()):
        print_warning(f"Existing installation found. Removing: {target_dir}")
        shutil.rmtree(target_path)
        print_success("Existing installation removed.")

def extract_addon(zip_path, temp_dir):
    """Extract the addon from zip file"""
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        return True
    except zipfile.BadZipFile:
        print_error("Downloaded file is not a valid zip archive.")
        return False
    except Exception as e:
        print_error(f"Failed to extract archive: {e}")
        return False

def find_addon_directory(temp_dir):
    """Find the addon directory in extracted files"""
    temp_path = Path(temp_dir)

    # Check common locations
    possible_paths = [
        temp_path / "addons" / ADDON_NAME,
        temp_path / ADDON_NAME,
        temp_path / ADDON_NAME / ADDON_NAME,  # Handle nested structure
    ]

    for path in possible_paths:
        if path.exists() and (path / "plugin.cfg").exists():
            return str(path)

    # Search for plugin.cfg in any subdirectory
    for plugin_cfg in temp_path.rglob("plugin.cfg"):
        return str(plugin_cfg.parent)

    return None

def verify_installation(target_dir, platform_info):
    """Verify the installation and show platform-specific information"""
    target_path = Path(target_dir)
    plugin_cfg = target_path / "plugin.cfg"

    if not plugin_cfg.exists():
        print_error("Installation verification failed. plugin.cfg not found.")
        return False

    print_success(f"Godot OpenMPT {VERSION} has been successfully installed!")
    print_status(f"Location: {target_dir}")

    # Show platform-specific binaries
    print_status(f"Available binaries for your platform ({platform_info}):")

    binary_patterns = {
        "darwin": "*darwin*.dylib",
        "linux": "*linux*.so",
        "windows": "*windows*.dll"
    }

    platform_key = platform_info.split("-")[0]
    if platform_key in binary_patterns:
        pattern = binary_patterns[platform_key]
        # Look for binaries in root directory and subdirectories
        binaries = list(target_path.glob(pattern)) + list(target_path.glob(f"**/{pattern}"))

        if binaries:
            for binary in binaries:
                stat = binary.stat()
                size_mb = stat.st_size / (1024 * 1024)
                relative_path = binary.relative_to(target_path)
                print(f"  - {relative_path} ({size_mb:.1f} MB)")
        else:
            print_warning(f"No {platform_key} binaries found in the addon.")

    print()
    print_status("Next steps:")
    print("1. Open your Godot project")
    print("2. Go to Project -> Project Settings -> Plugins")
    print("3. Find 'Godot OpenMPT' and enable it")
    print("4. The plugin should now be ready to use")

    return True

def install_addon(force=False):
    """Main installation function"""
    print_status(f"Starting Godot OpenMPT {VERSION} installation...")

    # Detect platform
    platform_info = detect_platform()
    print_status(f"Detected platform: {platform_info}")

    if platform_info == "unknown":
        print_error("Unsupported platform. This addon supports Windows, Linux, and macOS.")
        return False

    # Check if we're in a Godot project directory (look for src/project.godot)
    if not Path(SRC_DIR).exists():
        print_error(f"{SRC_DIR} directory not found. Make sure you're in the project root.")
        return False

    if not Path(SRC_DIR, "project.godot").exists():
        print_warning(f"project.godot not found in {SRC_DIR} directory.")
        if not force:
            response = input("Are you sure you want to continue? (y/N): ").strip().lower()
            if response not in ['y', 'yes']:
                print_status("Installation cancelled.")
                return False

    # Setup directories
    addons_dir = Path(SRC_DIR, "addons")
    target_dir = addons_dir / ADDON_NAME

    print_status("Creating directories...")
    addons_dir.mkdir(exist_ok=True)

    # Check if valid installation already exists (cache hit)
    if check_existing_installation(target_dir):
        if is_cache_restored_installation(target_dir):
            # This is likely a cache hit with complete installation
            print_success(f"Godot OpenMPT {VERSION} restored from cache and appears complete.")
            if not force:
                verify_installation(target_dir, platform_info)
                return True
            else:
                print_status("Cache restored but --force specified. Proceeding with fresh download...")
        else:
            # Incomplete installation found
            if not force:
                print_warning(f"Incomplete installation found at {target_dir}")
                print_status("Use --force to reinstall if needed.")
                return False
            else:
                print_status("Incomplete installation found, --force specified. Proceeding with reinstall...")

    # Remove existing installation
    remove_existing_installation(target_dir)

    # Create temporary directory for download and extraction
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        zip_path = temp_path / f"godot-openmpt-{VERSION}.zip"

        # Download the addon
        if not download_file(DOWNLOAD_URL, zip_path):
            print_error("Failed to download the addon. Please check your internet connection and try again.")
            return False

        print_success("Download completed.")

        # Extract the addon
        print_status("Extracting addon...")
        if not extract_addon(zip_path, temp_dir):
            return False

        # Find the addon directory
        addon_source_dir = find_addon_directory(temp_dir)
        if not addon_source_dir:
            print_error("Could not find the addon directory in the extracted files.")
            return False

        # Move to target directory
        print_status(f"Installing addon to {target_dir}...")
        shutil.move(addon_source_dir, target_dir)

        # Verify installation
        if not verify_installation(target_dir, platform_info):
            return False

    return True

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description=f"Install Godot OpenMPT {VERSION} addon for Godot projects",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
This script will:
  - Download Godot OpenMPT from GitHub
  - Install it to the ./addons directory
  - Remove any existing installation
        """)

    parser.add_argument('-f', '--force',
                       action='store_true',
                       help='Force installation (skip confirmations and reinstall even if cached)')

    args = parser.parse_args()

    try:
        success = install_addon(force=args.force)
        if success:
            print_success("Installation complete!")
            sys.exit(0)
        else:
            sys.exit(1)
    except KeyboardInterrupt:
        print_error("\nInstallation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
