# Godot OpenMPT Installation Guide

This guide explains how to install the Godot OpenMPT addon (v1.3) for your Godot project using the provided installation scripts.

## What is Godot OpenMPT?

Godot OpenMPT is a plugin that adds support for playing tracker music formats (MOD, S3M, XM, IT, etc.) in Godot Engine using the OpenMPT library. Version 1.3 includes support for:

- Windows (x86_64)
- Linux (x86_64 and ARM64)
- macOS (Intel and Apple Silicon)

## Installation Methods

You can install the addon using either the Bash script or the Python script. Both scripts do the same thing, so choose whichever you're more comfortable with.

### Using the Python Script

```bash
# Make sure you're in your Godot project directory
cd /path/to/your/godot/project

# Run the Python installation script
python3 install_godot_openmpt.py
```

## Script Options

The script supports the following options:

- `-h, --help`: Show help message and usage information
- `-f, --force`: Force installation without confirmation prompts

Examples:
```bash
# Show help
python3 install_godot_openmpt.py --help

# Force installation (skip confirmations)
python3 install_godot_openmpt.py --force
```

## What the Script Does

1. **Platform Detection**: Automatically detects your operating system and architecture
2. **Project Validation**: Checks for the presence of `src/project.godot` to ensure you're in the correct directory
3. **Backup**: Creates a backup of any existing godot-openmpt installation
4. **Download**: Downloads the latest release (v1.3) from GitHub
5. **Extract**: Extracts the addon files to the correct location
6. **Install**: Places the addon in your project's `src/addons/godot-openmpt` directory
7. **Verify**: Confirms the installation was successful

## After Installation

Once the installation is complete:

1. Open your Godot project
2. Go to **Project → Project Settings → Plugins**
3. Find "Godot OpenMPT" in the plugin list
4. Enable the plugin by checking the box next to it
5. The plugin is now ready to use!

## Supported File Formats

The Godot OpenMPT plugin supports the following tracker music formats:

- **MOD** - Amiga ProTracker modules
- **S3M** - Scream Tracker 3 modules
- **XM** - FastTracker 2 modules
- **IT** - Impulse Tracker modules
- **MTM** - MultiTracker modules
- **669** - Composer 669 modules
- **PTM** - PolyTracker modules
- **PSM** - Protracker Studio modules
- **UMX** - Unreal Music Container
- **And many more...**

## Usage Example

After enabling the plugin, you can use it in your GDScript:

```gdscript
# Load a tracker music file
var openmpt = OpenMPT.new()
openmpt.load_file("res://music/song.mod")

# Play the music
openmpt.play()

# Control playback
openmpt.set_volume(0.8)
openmpt.set_position(0.0)
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Make sure the script is executable
   ```bash
   chmod +x install_godot_openmpt.py
   ```

2. **Download Fails**: Check your internet connection and firewall settings

3. **Missing Dependencies**: Install required tools:
   - **macOS**: `brew install curl unzip` (if using Homebrew)
   - **Ubuntu/Debian**: `sudo apt install curl unzip`
   - **CentOS/RHEL**: `sudo yum install curl unzip`

4. **Plugin Not Appearing**: Make sure you're in the correct project root directory and that `src/project.godot` exists

### Manual Installation

If the script doesn't work, you can install manually:

1. Download `godot-openmpt-v1.3.zip` from the [GitHub releases page](https://github.com/dkonar/godot-openmpt/releases/tag/v1.3)
2. Extract the zip file
3. Copy the `addons/godot-openmpt` folder to your project's `src/addons/` directory
4. Enable the plugin in Godot's Project Settings

## Platform-Specific Notes

### macOS
- The script automatically detects Intel vs Apple Silicon Macs
- You may need to allow the binaries in System Preferences → Security & Privacy

### Linux
- Both x86_64 and ARM64 architectures are supported
- Make sure you have the required system libraries installed

### Windows
- Use Git Bash, WSL, or install Python to run the script
- The addon includes both debug and release versions of the Windows DLL

## Updating

To update to a newer version of Godot OpenMPT:

1. Run the installation script again
2. The script will automatically backup your current installation
3. The new version will be installed in place of the old one

Or use the Makefile:
```bash
make install-openmpt
```

## Support

If you encounter issues:

1. Check the [Godot OpenMPT GitHub repository](https://github.com/dkonar/godot-openmpt) for documentation
2. Review the [OpenMPT project](https://openmpt.org/) for format-specific information
3. File issues on the GitHub repository if you find bugs

## Makefile Integration

This project includes Makefile targets for easy addon management:

```bash
# Install the addon
make install-openmpt

# Check installed addons
make check-addons

# Remove the addon
make clean-openmpt

# Complete project setup
make setup-project

# Check if external addons are being tracked by git
make git-status-addons
```

## Git Integration

The Godot OpenMPT addon is automatically excluded from version control:

- The addon directory `src/addons/godot-openmpt/` is added to `.gitignore`
- Backup directories created during updates are also ignored
- Use `make git-status-addons` to verify no external addons are being tracked

This ensures that:
- The addon won't be accidentally committed to your repository
- Team members can install their own copy using the installation script
- Updates don't create merge conflicts
- The repository stays clean and focused on your project code

## License

The Godot OpenMPT plugin is released under its own license terms. Please check the plugin's LICENSE file for details. The installation script in this project is provided as-is for convenience.