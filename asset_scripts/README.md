## Setup

Ensure Python 3.x is installed on your system.

## Required data
Add engine_strings directory and spells2.csv to this directory

## Usage

### Automated Build (Recommended)

The easiest way to build spells is using the provided Makefile:

```bash
# Navigate to the asset_scripts directory
cd asset_scripts

# Build everything (complete workflow)
make

# Or see all available options
make help
```

The Makefile will automatically:
1. Check that required files exist
2. Build descriptions.json from engine_strings
3. Generate GDScript files from CSV
4. Apply manual tweaks to generated spells
5. Create and install the spellbook to shared_assets/spells

### Common Makefile Commands

```bash
make all          # Build complete spellbook (default)
make descriptions # Build descriptions.json only
make gdscripts    # Generate GDScript files only
make tweaks       # Apply manual tweaks to generated spells
make tweaks-dry   # Preview what manual tweaks would be applied
make spellbook    # Create final spellbook only
make clean        # Remove generated files
make status       # Show build status
make validate     # Validate generated spellbook
```

### Manual Tweaks System

The build system includes a powerful manual tweaks system that allows you to make persistent modifications to generated spells that survive rebuild cycles.

**Quick Start:**
```bash
# See what manual tweaks are available
make status

# Preview tweaks without applying them
make tweaks-dry

# Apply manual tweaks to generated spells
make tweaks
```

**Three types of manual tweaks:**
- **Overrides**: Complete spell replacements (`manual_tweaks/overrides/`)
- **Patches**: Targeted field modifications (`manual_tweaks/patches/`)
- **Hooks**: Custom post-processing scripts (`manual_tweaks/hooks/`)

See `MANUAL_TWEAKS_GUIDE.md` for detailed usage instructions and examples.

### Manual Usage (Advanced)

To run the scripts manually, navigate to the asset_scripts directory and execute:

To build descriptions.json from engine_string
```bash
python3 parse_descriptions.py engine_strings
```

To build spells in this directory (requires `descriptions.json` and `spells2.csv`)
```bash
python3 csv_2_gdspells.py
```

To convert generated spell scripts json and install them to shared_assets/spells
```bash
python3 generate_spellbook.py --source_dir ./spell_scripts
```

Note: The script automatically installs the spellbook to the correct location (../src/shared_assets/spells) relative to the asset_scripts directory.

To apply manual tweaks to generated spells:
```bash
python3 apply_manual_tweaks.py
```

## Manual Tweaks Scripts

`apply_manual_tweaks.py`
Main script for applying manual overrides, patches, and hooks to generated spells

`manual_tweaks_config.json`
Configuration file for the manual tweaks system

## Helper scripts
`spell_template.py`
This is the gd script template

`spell_utils.py`
This is where helper function to convert and compute values go

`lookups.py`
Data tables as python dictionaries for enums and such


