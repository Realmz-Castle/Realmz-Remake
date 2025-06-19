# Windows OpenMPT DLL Fix Guide

## Problem
When running the Realmz Remake on Windows, you may encounter this error:
```
ERROR: Can't open dynamic library: addons/godot-openmpt/bin/libgdmpt-windows.debug.64.dll. 
Error: Error 126: The specified module could not be found.
```

This happens because the OpenMPT library was compiled with MinGW-w64 and requires specific runtime DLLs that aren't installed on most Windows systems by default.

## Root Cause
The OpenMPT DLL depends on these MinGW runtime libraries:
- `libgcc_s_seh-1.dll` - GCC runtime library
- `libstdc++-6.dll` - C++ standard library

## Solutions

### Solution 1: Bundle Runtime DLLs (Recommended for Developers)

1. **Download the required DLLs:**
   - Get them from a MinGW-w64 installation or download from:
   - https://github.com/niXman/mingw-builds-binaries/releases
   - Extract `libgcc_s_seh-1.dll` and `libstdc++-6.dll` from the x86_64 package

2. **Create runtime directory:**
   ```bash
   mkdir -p src/addons/godot-openmpt/bin/runtime
   ```

3. **Copy the DLLs to the runtime directory:**
   ```
   src/addons/godot-openmpt/bin/runtime/
   ├── libgcc_s_seh-1.dll
   └── libstdc++-6.dll
   ```

4. **Update export_presets.cfg** - Add these lines to the Windows export section under `file_customization/include_binaries=`:
   ```
   "res://addons/godot-openmpt/bin/runtime/libgcc_s_seh-1.dll",
   "res://addons/godot-openmpt/bin/runtime/libstdc++-6.dll"
   ```

### Solution 2: For End Users (Quick Fix)

Windows users can install one of these to get the required runtime libraries:

**Option A: Visual Studio Build Tools (Recommended)**
1. Download Visual Studio Build Tools: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
2. Install with C++ build tools
3. This provides compatible runtime libraries

**Option B: MinGW-w64**
1. Download from: https://www.mingw-w64.org/downloads/
2. Install the x86_64 version
3. Add the `bin` directory to your system PATH

**Option C: MSYS2 (Advanced users)**
1. Install MSYS2: https://www.msys2.org/
2. Run: `pacman -S mingw-w64-x86_64-gcc`
3. Add `C:\msys64\mingw64\bin` to system PATH

### Solution 3: Direct DLL Placement

If you have access to the required DLLs, you can place them directly in the game's directory alongside the executable.

## Auto-Fix Script

Run the provided Python script to automatically set up the runtime DLLs:

```bash
cd Realmz-Remake
python3 fix_windows_openmpt.py
```

This script will:
1. Check for existing MinGW installations
2. Create the runtime directory structure
3. Update export presets automatically
4. Provide download instructions if needed

## Verification

After applying the fix:

1. **For Developers:** Export a Windows build and check that the runtime DLLs are included
2. **For Users:** Try running the game - the OpenMPT error should be resolved
3. **Test:** Load a game that uses tracker music formats (.mod, .s3m, .xm, .it files)

## Alternative: Use Visual C++ Built Version

If the MinGW version continues to cause issues, consider requesting a Visual C++ compiled version of the OpenMPT addon, which would have fewer runtime dependencies.

## Common Issues

### Still Getting Error 126?
- Ensure you have the correct 64-bit versions of the DLLs
- Check that Windows Defender isn't blocking the DLLs
- Try running as administrator once to register the libraries

### DLLs Not Found During Export?
- Check that the paths in export_presets.cfg are correct
- Ensure the DLLs exist in the runtime directory
- Verify the export preset is including all resources

### Performance Issues?
- Use the release version DLLs instead of debug versions
- The debug versions have additional overhead

## Technical Details

- **Error 126**: "The specified module could not be found" - means dependencies are missing
- **MinGW-w64**: GNU Compiler Collection for Windows
- **OpenMPT**: Open ModPlug Tracker - library for playing tracker music formats
- **Godot 4.3**: This project uses Godot 4.3 with GDExtension system

## Support

If you continue to have issues:
1. Check that your Windows system is up to date
2. Try on a different Windows machine to isolate the issue
3. Check the Godot OpenMPT addon repository for updates
4. Consider using alternative audio formats (OGG, MP3) as a fallback