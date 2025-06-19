# Manual Windows OpenMPT DLL Fix

If you prefer to fix the Windows OpenMPT DLL issue manually or the automated GitHub workflow isn't available, follow these instructions.

## Problem Summary

Windows builds fail with Error 126 when loading the OpenMPT addon because the required MinGW runtime DLLs are missing:
- `libgcc_s_seh-1.dll` - GCC runtime library
- `libstdc++-6.dll` - C++ standard library

## Prerequisites

You need one of the following installed on Windows:
- **MinGW-w64** (recommended)
- **MSYS2** 
- **Qt with MinGW**
- **Code::Blocks with MinGW**

## Method 1: Using MSYS2 (Recommended)

### Step 1: Install MSYS2
1. Download from https://www.msys2.org/
2. Install to default location (`C:\msys64`)
3. Open MSYS2 terminal and run:
   ```bash
   pacman -S mingw-w64-x86_64-gcc
   ```

### Step 2: Extract DLLs
1. Navigate to your Realmz-Remake project directory
2. Create the runtime directory:
   ```bash
   mkdir -p src/addons/godot-openmpt/bin/runtime
   ```
3. Copy the required DLLs:
   ```bash
   cp /c/msys64/mingw64/bin/libgcc_s_seh-1.dll src/addons/godot-openmpt/bin/runtime/
   cp /c/msys64/mingw64/bin/libstdc++-6.dll src/addons/godot-openmpt/bin/runtime/
   ```

## Method 2: Using MinGW-w64 Direct Installation

### Step 1: Download MinGW-w64
1. Go to https://www.mingw-w64.org/downloads/
2. Download a standalone build (e.g., from winlibs.com)
3. Extract to `C:\mingw64`

### Step 2: Extract DLLs
1. Open Command Prompt in your project directory
2. Create runtime directory:
   ```cmd
   mkdir src\addons\godot-openmpt\bin\runtime
   ```
3. Copy DLLs:
   ```cmd
   copy C:\mingw64\bin\libgcc_s_seh-1.dll src\addons\godot-openmpt\bin\runtime\
   copy C:\mingw64\bin\libstdc++-6.dll src\addons\godot-openmpt\bin\runtime\
   ```

## Method 3: Download Pre-built DLLs

If you can't install MinGW, you can download the DLLs directly:

1. Visit https://github.com/niXman/mingw-builds-binaries/releases
2. Download the latest x86_64 release (e.g., `x86_64-*-release-posix-seh-msvcrt-*.7z`)
3. Extract the archive using 7-Zip
4. Navigate to the `bin` folder inside the extracted directory
5. Copy `libgcc_s_seh-1.dll` and `libstdc++-6.dll` to:
   ```
   src/addons/godot-openmpt/bin/runtime/
   ```

## Step 3: Update Export Presets

Edit `src/export_presets.cfg` and find the Windows export section (usually `[preset.1]` with `name="Windows"`).

Locate the line that starts with `file_customization/include_binaries=PackedStringArray(` and add the runtime DLLs:

**Before:**
```
file_customization/include_binaries=PackedStringArray("res://addons/godot-openmpt/bin/libgdmpt-windows.debug.64.dll", "res://addons/godot-openmpt/bin/libgdmpt-windows.release.64.dll")
```

**After:**
```
file_customization/include_binaries=PackedStringArray("res://addons/godot-openmpt/bin/libgdmpt-windows.debug.64.dll", "res://addons/godot-openmpt/bin/libgdmpt-windows.release.64.dll", "res://addons/godot-openmpt/bin/runtime/libgcc_s_seh-1.dll", "res://addons/godot-openmpt/bin/runtime/libstdc++-6.dll")
```

## Step 4: Verify the Fix

1. **Check files exist:**
   ```bash
   ls -la src/addons/godot-openmpt/bin/runtime/
   ```
   You should see:
   - `libgcc_s_seh-1.dll`
   - `libstdc++-6.dll`

2. **Verify DLL architecture:**
   ```bash
   file src/addons/godot-openmpt/bin/runtime/*.dll
   ```
   Should show "PE32+ executable (DLL) (console) x86-64, for MS Windows"

3. **Test export:**
   - Open Godot
   - Go to Project → Export
   - Export Windows build
   - Check that runtime DLLs are included in the output

## Alternative: PowerShell Script

Save this as `fix_windows_openmpt.ps1` and run it:

```powershell
# Create runtime directory
$runtimeDir = "src\addons\godot-openmpt\bin\runtime"
New-Item -ItemType Directory -Force -Path $runtimeDir

# Common MinGW locations
$mingwPaths = @(
    "C:\msys64\mingw64\bin",
    "C:\mingw64\bin",
    "C:\Qt\Tools\mingw810_64\bin",
    "C:\Qt\Tools\mingw1120_64\bin"
)

$requiredDlls = @("libgcc_s_seh-1.dll", "libstdc++-6.dll")

foreach ($dll in $requiredDlls) {
    $found = $false
    foreach ($path in $mingwPaths) {
        $fullPath = Join-Path $path $dll
        if (Test-Path $fullPath) {
            Copy-Item $fullPath $runtimeDir
            Write-Host "Copied $dll from $path"
            $found = $true
            break
        }
    }
    if (-not $found) {
        Write-Error "Could not find $dll in any MinGW installation"
    }
}

Write-Host "DLL extraction complete. Don't forget to update export_presets.cfg!"
```

## Troubleshooting

### DLLs Not Found
- Ensure you have the x86_64 (64-bit) version of MinGW
- Check that the DLLs are actually in the MinGW bin directory
- Try reinstalling MinGW or MSYS2

### Wrong Architecture
- Make sure you're using 64-bit DLLs for 64-bit Godot builds
- Use `file` command (in Git Bash) to verify DLL architecture

### Export Still Fails
- Verify the export_presets.cfg syntax is correct
- Check that the paths in the export preset are valid
- Try exporting with verbose logging enabled

### Still Getting Error 126
- The user may need Visual C++ Redistributable
- Try placing DLLs directly next to the game executable
- Check Windows Event Viewer for more detailed error information

## Git Integration

Add these files to your repository:
```bash
git add src/addons/godot-openmpt/bin/runtime/
git add src/export_presets.cfg
git commit -m "Add Windows MinGW runtime DLLs for OpenMPT support"
```

Create a `.gitignore` entry if you don't want to track these DLLs:
```
# Optionally ignore runtime DLLs (not recommended)
src/addons/godot-openmpt/bin/runtime/*.dll
```

## Final Notes

- This fix bundles the DLLs with your game, increasing download size slightly (~1-2MB)
- The DLLs are only needed for Windows builds
- Consider testing on a clean Windows system to verify the fix works
- Keep the DLLs updated when updating MinGW versions