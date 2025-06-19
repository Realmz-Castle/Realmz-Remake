#!/usr/bin/env python3

"""
Download MinGW Runtime DLLs for Windows OpenMPT Fix
This script downloads the required MinGW runtime DLLs from official sources
and places them in the correct location for Windows builds.
"""

import sys
import os
import urllib.request
import urllib.error
import tempfile
import zipfile
import shutil
from pathlib import Path

# Configuration
MINGW_DLLS_NEEDED = [
    "libgcc_s_seh-1.dll",
    "libstdc++-6.dll"
]

# URL for MinGW-w64 runtime DLLs (using a reliable source)
MINGW_DOWNLOAD_URL = "https://github.com/niXman/mingw-builds-binaries/releases/download/12.2.0-rt_v10-rev2/x86_64-12.2.0-release-posix-seh-msvcrt-rt_v10-rev2.7z"

RUNTIME_DIR = "src/addons/godot-openmpt/bin/runtime"

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

def check_project_structure():
    """Check if we're in the correct project directory"""
    if not Path("src/project.godot").exists():
        print_error("src/project.godot not found. Please run this script from the Realmz-Remake root directory.")
        return False

    if not Path("src/addons/godot-openmpt").exists():
        print_error("OpenMPT addon not found. Please install the OpenMPT addon first.")
        return False

    return True

def check_existing_dlls():
    """Check if DLLs already exist"""
    runtime_path = Path(RUNTIME_DIR)
    existing_dlls = []

    for dll in MINGW_DLLS_NEEDED:
        dll_path = runtime_path / dll
        if dll_path.exists():
            existing_dlls.append(dll)

    return existing_dlls

def download_file(url, destination):
    """Download a file from URL to destination with progress"""
    try:
        print_status(f"Downloading {os.path.basename(destination)}...")

        def progress_hook(block_num, block_size, total_size):
            if total_size > 0:
                percent = min(100, (block_num * block_size * 100) // total_size)
                print(f"\rProgress: {percent}%", end='', flush=True)

        urllib.request.urlretrieve(url, destination, progress_hook)
        print()  # New line after progress
        return True
    except urllib.error.URLError as e:
        print()  # New line after progress
        print_error(f"Failed to download {url}: {e}")
        return False

def extract_7z_archive(archive_path, extract_to):
    """Extract 7z archive using py7zr if available, otherwise provide instructions"""
    try:
        import py7zr

        print_status("Extracting 7z archive...")
        with py7zr.SevenZipFile(archive_path, mode='r') as archive:
            archive.extractall(path=extract_to)
        return True

    except ImportError:
        print_error("py7zr module not found. Please install it with:")
        print("  pip install py7zr")
        print()
        print("Alternatively, you can:")
        print(f"1. Install 7-Zip and extract {archive_path} manually")
        print(f"2. Look for the required DLLs in the extracted mingw64/bin directory")
        print(f"3. Copy them to {RUNTIME_DIR}/")
        return False
    except Exception as e:
        print_error(f"Failed to extract archive: {e}")
        return False

def find_dlls_in_directory(search_dir):
    """Recursively find required DLLs in a directory"""
    found_dlls = {}
    search_path = Path(search_dir)

    for dll in MINGW_DLLS_NEEDED:
        # Search recursively for the DLL
        for dll_path in search_path.rglob(dll):
            if dll_path.is_file():
                found_dlls[dll] = dll_path
                break

    return found_dlls

def copy_dlls(dll_paths, destination_dir):
    """Copy DLLs to destination directory"""
    destination = Path(destination_dir)
    destination.mkdir(parents=True, exist_ok=True)

    for dll_name, dll_path in dll_paths.items():
        dest_path = destination / dll_name
        shutil.copy2(dll_path, dest_path)
        print_success(f"Copied {dll_name}")

def provide_manual_instructions():
    """Provide manual download instructions"""
    print_warning("Automatic download failed. Here are manual instructions:")
    print()
    print("1. Go to: https://github.com/niXman/mingw-builds-binaries/releases")
    print("2. Download the latest x86_64-*-release-posix-seh-msvcrt-*.7z file")
    print("3. Extract the archive using 7-Zip")
    print("4. Navigate to the mingw64/bin directory in the extracted files")
    print("5. Copy these files to your project:")
    print()

    for dll in MINGW_DLLS_NEEDED:
        print(f"   {dll} → {RUNTIME_DIR}/{dll}")

    print()
    print("6. Verify the DLLs are in place and export your Windows build")

def main():
    """Main function"""
    print_status("MinGW Runtime DLL Downloader for Realmz-Remake")
    print_status("=" * 50)

    # Check project structure
    if not check_project_structure():
        sys.exit(1)

    # Check if DLLs already exist
    existing_dlls = check_existing_dlls()
    if existing_dlls:
        print_warning(f"Found existing DLLs: {', '.join(existing_dlls)}")
        if len(existing_dlls) == len(MINGW_DLLS_NEEDED):
            response = input("All DLLs already exist. Overwrite? [y/N]: ").strip().lower()
            if response not in ['y', 'yes']:
                print_status("Keeping existing DLLs. Exiting.")
                return

    # Create runtime directory
    runtime_path = Path(RUNTIME_DIR)
    runtime_path.mkdir(parents=True, exist_ok=True)
    print_success(f"Created runtime directory: {runtime_path}")

    # Download the archive
    with tempfile.TemporaryDirectory() as temp_dir:
        archive_path = os.path.join(temp_dir, "mingw-w64.7z")

        print_status("Downloading MinGW-w64 runtime archive...")
        if not download_file(MINGW_DOWNLOAD_URL, archive_path):
            provide_manual_instructions()
            sys.exit(1)

        # Extract the archive
        extract_dir = os.path.join(temp_dir, "extracted")
        if not extract_7z_archive(archive_path, extract_dir):
            provide_manual_instructions()
            sys.exit(1)

        # Find the required DLLs
        print_status("Looking for required DLLs...")
        found_dlls = find_dlls_in_directory(extract_dir)

        if len(found_dlls) != len(MINGW_DLLS_NEEDED):
            missing = set(MINGW_DLLS_NEEDED) - set(found_dlls.keys())
            print_error(f"Could not find all required DLLs. Missing: {', '.join(missing)}")
            provide_manual_instructions()
            sys.exit(1)

        # Copy DLLs to runtime directory
        print_status("Copying DLLs to runtime directory...")
        copy_dlls(found_dlls, RUNTIME_DIR)

    # Verify the installation
    print_status("Verifying installation...")
    verification_failed = False
    for dll in MINGW_DLLS_NEEDED:
        dll_path = runtime_path / dll
        if dll_path.exists():
            size = dll_path.stat().st_size
            print_success(f"✓ {dll} ({size:,} bytes)")
        else:
            print_error(f"✗ {dll} missing")
            verification_failed = True

    if verification_failed:
        print_error("Installation verification failed!")
        sys.exit(1)

    print()
    print_success("✅ MinGW runtime DLLs successfully installed!")
    print()
    print("Next steps:")
    print("1. The export presets have already been updated to include these DLLs")
    print("2. Export your Windows build - the DLLs will be included automatically")
    print("3. Test the build on a Windows machine to verify Error 126 is fixed")
    print()
    print("Files installed:")
    for dll in MINGW_DLLS_NEEDED:
        print(f"  - {RUNTIME_DIR}/{dll}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        print_status("Download cancelled by user.")
        sys.exit(0)
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        sys.exit(1)
