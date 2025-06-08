# Makefile Guide for Realmz Spell Building

This guide explains how to use the Makefile system to automate the spell building process.

## Quick Start

```bash
# Navigate to asset_scripts directory
cd asset_scripts

# Build everything
make

# See all available commands
make help
```

## Common Commands

| Command | Description |
|---------|-------------|
| `make` or `make all` | Build complete spellbook (full workflow) |
| `make help` | Show all available commands |
| `make status` | Show current build status |
| `make clean` | Remove generated files (keeps spellbook) |
| `make rebuild` | Clean and rebuild everything |

## Build Process

The Makefile automates this workflow:

1. **Check Dependencies** - Verifies required files exist
2. **Build Descriptions** - `engine_strings/` → `descriptions.json`
3. **Generate GDScripts** - `spells2.csv` + `descriptions.json` → `spell_scripts/*.gd`
4. **Create Spellbook** - `spell_scripts/*.gd` → `../src/shared_assets/spells/spells_book.json`

## Individual Steps

```bash
make descriptions    # Step 2 only
make gdscripts      # Step 3 only  
make spellbook      # Step 4 only
```

## Development Commands

```bash
make quick          # Fast build, skip dependency checks
make validate       # Check if generated spellbook is valid JSON
make info           # Show file counts and sizes
make watch          # Auto-rebuild on file changes (Linux only)
```

## Troubleshooting

### Missing Dependencies
```bash
make check-deps     # Verify required files exist
```

Required files:
- `engine_strings/` directory with engine string files
- `spells2.csv` file

### Build Issues
```bash
make clean          # Remove generated files
make rebuild        # Clean and rebuild from scratch
```

### Validation
```bash
make validate       # Check if spellbook JSON is valid
make status         # See what's built/missing
```

## File Locations

- **Source Data**: `asset_scripts/`
  - `engine_strings/` - Engine string files
  - `spells2.csv` - Spell definitions
  
- **Generated Files**: `asset_scripts/`
  - `descriptions.json` - Parsed descriptions
  - `spell_scripts/*.gd` - Individual spell scripts
  
- **Final Output**: 
  - `src/shared_assets/spells/spells_book.json` - Complete spellbook

## Dependencies

- Python 3.x
- All Python helper scripts in `asset_scripts/`
- Make (usually pre-installed on macOS/Linux)

## Advanced Usage

### Custom Paths
```bash
# Override default CSV file
make SPELLS_CSV=custom_spells.csv

# Override Python interpreter
make PYTHON=python3.9
```

### Parallel Builds
The Makefile handles dependencies correctly, so you can safely run:
```bash
make -j4    # Use 4 parallel jobs (faster on multi-core systems)
```

## Tips

- Use `make status` to see what needs rebuilding
- Use `make quick` during development to skip checks
- Use `make clean` between major changes
- The spellbook is automatically installed to the correct Godot location