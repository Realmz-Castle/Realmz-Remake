## Setup

Ensure Python 3.x is installed on your system.


## Required data
Add engine_strings directory and spells.csv to this directory

## Usage

To run the scripts, navigate to the directory containing the script in your terminal and execute:


To build descriptions.json from engine_string
```bash
python3 parse_descriptions.py engine_strings
```

To convert generated spell scripts json and install them
```bash
python3 generate_spellbook.py
```

To build spells in this directory
Requires `descriptions.json` and `spells.csv`
This is where the template is run and helpers and lookups are used to get values
```bash
python3 csv_2_gdspells.py


## Helper scripts
`spell_template.py`
This is the gd script template

`spell_utils.py`
This is where helper function to convert and compute values go

`lookups.py`
Data tables as python dictionaries for enums and such


