# Realmz Remake Project

Remake project of Fantasoft's classic 1994 RPG "Realmz"

[Project Site](https://realmz-castle.github.io)

[Discord](https://discord.gg/MnPfMCZa)

[Tiled (map editor)](https://www.mapeditor.org/)

## Getting Started

You can find latest releases [here](https://github.com/Realmz-Castle/Realmz-Remake/releases).

### Prerequisites

[Godot 4.x](https://godotengine.org/download)
[Git LFS](https://git-lfs.com)

## Music System

The game uses OpenMPT for tracker music playback, supporting a wide variety of formats beyond just MOD files:

### Supported Audio Formats
- **Tracker Formats**: MOD, XM, S3M, IT, MTM, 669, PTM, PSM, UMX, MED, and [many more](OPENMPT_FORMATS.md)
- **Standard Audio**: OGG Vorbis, MP3

### Installing OpenMPT Support
```bash
# Install the godot-openmpt plugin
python3 install_godot_openmpt.py

# Test tracker format support
python3 test_openmpt_formats.py
```

See [OPENMPT_FORMATS.md](OPENMPT_FORMATS.md) for complete format documentation and [INSTALL_GODOT_OPENMPT.md](INSTALL_GODOT_OPENMPT.md) for installation details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on the project structure and the process for submitting pull requests.

## Authors

* **Francisco Biaso** - *Founder*
* **Samuel Rabreau** - *Maintainer*

See also the list of [contributors](https://github.com/Realmz-Castle/Realmz-Remake/graphs/contributors) who participated in this project.

## License

This project has not yet been licensed. 
