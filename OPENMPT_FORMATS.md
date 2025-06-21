# OpenMPT Tracker Format Support

This document describes the tracker music format support in Realmz-Remake using the OpenMPT library.

## Overview

Realmz-Remake uses the **godot-openmpt** plugin to play tracker music files. This provides support for a wide variety of tracker formats beyond just the original MOD format, allowing for more diverse and authentic retro gaming music.

## Supported Formats

The OpenMPT library supports the following tracker formats:

### Common Formats
- **MOD** - ProTracker modules (Amiga)
- **S3M** - Scream Tracker 3 modules (PC)
- **XM** - FastTracker 2 modules (PC)
- **IT** - Impulse Tracker modules (PC)

### Additional Formats
- **MTM** - MultiTracker modules
- **669** - Composer 669 modules
- **PTM** - PolyTracker modules
- **PSM** - Protracker Studio modules
- **UMX** - Unreal Music Container
- **MED** - OctaMED modules (Amiga)
- **DBM** - DigiBooster Pro modules
- **AMS** - Velvet Studio AMS modules
- **DSM** - DSIK modules
- **FAR** - Farandole Composer modules
- **MDL** - Digitrakker modules
- **OKT** - Oktalyzer modules
- **STM** - Scream Tracker 2 modules
- **ULT** - UltraTracker modules
- **J2B** - Jazz Jackrabbit 2 modules
- **MT2** - MadTracker 2 modules
- **IMF** - Imago Orpheus modules
- **GDM** - General DigiMusic modules
- **MPTM** - OpenMPT modules
- **PLM** - DisorderTracker 2 modules

### Compressed Formats
- **MO3** - Compressed modules
- **XPK** - Various compressed formats
- **PP20** - PowerPacker compressed
- **MMCMP** - MO3-style compressed

## How It Works

### Resource Loading
The game automatically detects tracker files in the `Data/Music/` directory and its subdirectories. The `Resources.gd` script has been updated with the `_is_tracker_format()` function that recognizes all supported extensions.

### Music Playback
When a tracker file is played:
1. The file is loaded into memory as binary data
2. An `AudioStreamMPT` object is created
3. The binary data is passed to the OpenMPT library
4. OpenMPT handles format detection and playback automatically
5. Loop mode is enabled for seamless music looping

### Code Implementation
```gdscript
# In Resources.gd - Format detection
func _is_tracker_format(filename: String) -> bool:
    var tracker_extensions = [".mod", ".s3m", ".xm", ".it", ...]
    var filename_lower = filename.to_lower()
    for ext in tracker_extensions:
        if filename_lower.ends_with(ext):
            return true
    return false

# In MusicStreamPlayer.gd - Playback
elif musicdict["type"] == 'mod':
    var file = FileAccess.open(musicdict["path"], FileAccess.READ)
    if file:
        var data = file.get_buffer(file.get_length())
        var stream = AudioStreamMPT.new()
        stream.data = data
        stream.loop_mode = 1
        set_stream(stream)
        play()
```

## Current Music Files

The game currently includes these tracker files:
- `battle.mod` - Battle music (ProTracker format)
- `camp.mod` - Camp music (ProTracker format)
- `cave.mod` - Cave music (ProTracker format)
- `create.mod` - Character creation music (ProTracker format)
- `dungeon.mod` - Dungeon music (ProTracker format)
- `indoor.mod` - Indoor music (ProTracker format)
- `items.mod` - Items menu music (ProTracker format)
- `shop.mod` - Shop music (ProTracker format)
- `temple.mod` - Temple music (ProTracker format)
- `treasure.mod` - Treasure music (ProTracker format)
- `outdoor.mod` - Outdoor music (ProTracker format)
- `nightmare.xm` - Battle music variation (FastTracker 2 format)

## Advantages of Tracker Formats

### File Size
Tracker files are extremely compact compared to PCM audio:
- A typical 3-minute MOD file: 100-500 KB
- Same song as MP3: 3-5 MB
- Same song as OGG: 2-4 MB

### Loop Support
Tracker formats have built-in loop points and can loop seamlessly without gaps or clicks.

### Authentic Sound
Tracker music provides the authentic chiptune/demoscene sound that fits perfectly with retro-style games.

### Pattern-Based Composition
Trackers use pattern-based composition which is ideal for dynamic game music that can adapt to gameplay.

## Adding New Tracker Music

To add new tracker music to the game:

1. **Obtain Tracker Files**:
   - Download from modding communities (ModArchive, etc.)
   - Create your own using trackers like OpenMPT, Milkytracker, etc.
   - Convert existing music using appropriate tools

2. **Place Files**: Put tracker files in the appropriate subdirectory under `src/Data/Music/`
   - `Battle/` - Combat music
   - `Cave/` - Underground areas
   - `Dungeon/` - Indoor dungeons
   - `Forest/` - Forest areas
   - etc.

3. **File Naming**: The filename becomes the music identifier in the game's music system.

4. **Testing**: Use the test script `test_openmpt_formats.py` to verify the files are recognized.

## Troubleshooting

### Format Not Recognized
If a tracker file isn't being loaded:
- Check that the file extension is in the supported list
- Verify the file isn't corrupted
- Ensure the file is actually in a supported format

### Playback Issues
If a tracker file doesn't play correctly:
- Check the Godot console for OpenMPT error messages
- Verify the godot-openmpt plugin is properly installed and enabled
- Test the file in a standalone tracker player to confirm it's valid

### Performance Considerations
- Very complex tracker files with many channels may impact performance
- Most retro-style tracker files should play without issues
- Monitor CPU usage if using many simultaneous tracker streams

## Dependencies

This system requires:
- **godot-openmpt plugin v1.3+** - Provides OpenMPT integration
- **OpenMPT/libopenmpt** - The actual tracker playback library
- **Proper platform binaries** - Windows, Linux, macOS supported

## Testing

Run the included test script to verify format support:
```bash
python3 test_openmpt_formats.py
```

This will:
- Check if the code updates are in place
- Analyze existing music files
- Show which tracker formats are currently in use
- Display all supported formats for reference

## Resources

- [OpenMPT Official Site](https://openmpt.org/) - Tracker software and documentation
- [godot-openmpt Plugin](https://github.com/dkonar/godot-openmpt) - Godot integration
- [ModArchive](https://modarchive.org/) - Large collection of tracker music
- [libopenmpt Documentation](https://lib.openmpt.org/libopenmpt/) - Technical documentation

## License Notes

- OpenMPT/libopenmpt: BSD license
- Individual tracker files: Various licenses (check each file)
- Some formats may have patent or licensing restrictions in certain regions
