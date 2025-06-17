# Makefile for Realmz Spell Building Process
# This automates the entire workflow from source data to final spellbook

# Configuration
PYTHON := python3
ENGINE_STRINGS_DIR := engine_strings
SPELLS_CSV := spells2.csv
DESCRIPTIONS_JSON := descriptions.json
GD_SCRIPTS_DIR := spell_scripts
SPELLBOOK_DIR := ../src/shared_assets/spells
SPELLBOOK_FILE := spells_book.json
SPELLBOOK_PATH := $(SPELLBOOK_DIR)/$(SPELLBOOK_FILE)

# Source files that the build depends on
PYTHON_SOURCES := parse_descriptions.py csv_2_gdspells.py generate_spellbook.py \
                  spell_template.py spell_utils.py build_data.py lookups.py \
                  special_fx_templates.py traits_template.py spellsconvert.py

# Check if required data files exist
ENGINE_STRINGS_EXISTS := $(wildcard $(ENGINE_STRINGS_DIR)/*)
SPELLS_CSV_EXISTS := $(wildcard $(SPELLS_CSV))
SPELLS_TXT_EXISTS := $(wildcard spells.txt)

# Default target
.PHONY: all
all: check-deps $(SPELLBOOK_PATH)

# Help target
.PHONY: help
help:
	@echo "Realmz Spell Building System"
	@echo "============================="
	@echo ""
	@echo "Available targets:"
	@echo "  all           - Build complete spellbook (default)"
	@echo "  descriptions  - Build descriptions.json from engine_strings"
	@echo "  gdscripts     - Generate GDScript files from CSV"
	@echo "  spellbook     - Create final spellbook JSON"
	@echo "  clean         - Remove generated files"
	@echo "  clean-all     - Remove all generated files including spellbook"
	@echo "  check-deps    - Check if required source files exist"
	@echo "  install       - Copy spellbook to shared_assets (alias for spellbook)"
	@echo "  rebuild       - Clean and rebuild everything"
	@echo "  quick         - Quick build without dependency checking"
	@echo "  watch         - Watch for changes and auto-rebuild"
	@echo "  status        - Show build status"
	@echo "  validate      - Validate generated spellbook"
	@echo "  info          - Show file sizes and counts"
	@echo ""
	@echo "Requirements:"
	@echo "  - Python 3.x installed"
	@echo "  - $(ENGINE_STRINGS_DIR)/ directory with engine string files"
	@echo "  - $(SPELLS_CSV) file"

# Check dependencies
.PHONY: check-deps
check-deps:
	@echo "Checking dependencies..."
	@if [ -z "$(ENGINE_STRINGS_EXISTS)" ]; then \
		echo "ERROR: $(ENGINE_STRINGS_DIR) directory is missing or empty"; \
		echo "Please add engine string files to $(ENGINE_STRINGS_DIR)/"; \
		exit 1; \
	fi
	@if [ -z "$(SPELLS_CSV_EXISTS)" ] && [ -z "$(SPELLS_TXT_EXISTS)" ]; then \
		echo "ERROR: Neither $(SPELLS_CSV) nor spells.txt is present"; \
		echo "Please add either the spells CSV file or spells.txt"; \
		exit 1; \
	fi
	@echo "Dependencies OK!"

# Convert spells.txt to spells2.csv
$(SPELLS_CSV): spells.txt spellsconvert.py
	@echo "Converting spells.txt to $(SPELLS_CSV)..."
	$(PYTHON) spellsconvert.py
	@echo "✓ Conversion complete"

# Build descriptions.json from engine_strings
$(DESCRIPTIONS_JSON): $(ENGINE_STRINGS_DIR)/* parse_descriptions.py
	@echo "Building descriptions from engine strings..."
	$(PYTHON) parse_descriptions.py $(ENGINE_STRINGS_DIR)
	@echo "✓ Descriptions built successfully"

# Alias for descriptions
.PHONY: descriptions
descriptions: $(DESCRIPTIONS_JSON)

# Generate GDScript files from CSV
.gdscripts-built: $(DESCRIPTIONS_JSON) $(SPELLS_CSV) $(PYTHON_SOURCES)
	@echo "Generating GDScript files from CSV..."
	@mkdir -p $(GD_SCRIPTS_DIR)
	$(PYTHON) csv_2_gdspells.py
	@echo "✓ GDScript files generated successfully"
	@touch .gdscripts-built

# Alias for gdscripts
.PHONY: gdscripts
gdscripts: .gdscripts-built

# Create final spellbook JSON and install to shared_assets
$(SPELLBOOK_PATH): .gdscripts-built generate_spellbook.py
	@echo "Creating spellbook and installing to shared_assets..."
	@mkdir -p $(SPELLBOOK_DIR)
	$(PYTHON) generate_spellbook.py --source_dir $(GD_SCRIPTS_DIR)
	@echo "✓ Spellbook created and installed at $(SPELLBOOK_PATH)"

# Alias for spellbook/install
.PHONY: spellbook install
spellbook install: $(SPELLBOOK_PATH)

# Clean generated files (keep spellbook)
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(GD_SCRIPTS_DIR)/*
	@rm -f $(DESCRIPTIONS_JSON)
	@rm -f $(SPELLS_CSV)
	@rm -f .gdscripts-built
	@rm -rf __pycache__/
	@echo "✓ Cleaned generated files (spellbook preserved)"

# Clean all files including installed spellbook
.PHONY: clean-all
clean-all: clean
	@echo "Removing installed spellbook..."
	@rm -f $(SPELLBOOK_PATH)
	@echo "✓ All generated files removed"

# Force rebuild everything
.PHONY: rebuild
rebuild: clean all

# Watch for changes and rebuild (requires inotify-tools on Linux)
.PHONY: watch
watch:
	@echo "Watching for changes... (Press Ctrl+C to stop)"
	@while true; do \
		if command -v inotifywait >/dev/null 2>&1; then \
			inotifywait -e modify $(SPELLS_CSV) $(ENGINE_STRINGS_DIR)/* $(PYTHON_SOURCES) 2>/dev/null && make quick; \
		else \
			echo "inotifywait not found. Install inotify-tools for file watching."; \
			echo "Falling back to manual rebuild every 30 seconds..."; \
			sleep 30 && make quick; \
		fi; \
	done

# Show file sizes and counts
.PHONY: info
info:
	@echo "Spell Building Information:"
	@echo "=========================="
	@if [ -f "$(SPELLS_CSV)" ]; then \
		echo "Spells CSV: $$(wc -l < $(SPELLS_CSV)) lines"; \
	fi
	@if [ -d "$(GD_SCRIPTS_DIR)" ]; then \
		echo "GDScript files: $$(find $(GD_SCRIPTS_DIR) -name '*.gd' | wc -l) files"; \
	fi
	@if [ -f "$(SPELLBOOK_PATH)" ]; then \
		echo "Spellbook size: $$(du -h $(SPELLBOOK_PATH) | cut -f1)"; \
	fi
	@if [ -f "$(DESCRIPTIONS_JSON)" ]; then \
		echo "Descriptions size: $$(du -h $(DESCRIPTIONS_JSON) | cut -f1)"; \
	fi

# Quick build without dependency checking (for development)
.PHONY: quick
quick:
	@echo "Quick build (skipping dependency checks)..."
	@mkdir -p $(GD_SCRIPTS_DIR)
	$(PYTHON) csv_2_gdspells.py
	@touch .gdscripts-built
	@mkdir -p $(SPELLBOOK_DIR)
	$(PYTHON) generate_spellbook.py --source_dir $(GD_SCRIPTS_DIR)
	@echo "✓ Quick build complete"

# Development targets
.PHONY: dev-descriptions dev-gdscripts dev-spellbook
dev-descriptions:
	$(PYTHON) parse_descriptions.py $(ENGINE_STRINGS_DIR)

dev-gdscripts:
	$(PYTHON) csv_2_gdspells.py

dev-spellbook:
	$(PYTHON) generate_spellbook.py --source_dir $(GD_SCRIPTS_DIR)

# Show status of build files
.PHONY: status
status:
	@echo "Build Status:"
	@echo "============="
	@if [ -f "$(DESCRIPTIONS_JSON)" ]; then echo "✓ $(DESCRIPTIONS_JSON) exists"; else echo "✗ $(DESCRIPTIONS_JSON) missing"; fi
	@if [ -f ".gdscripts-built" ]; then echo "✓ GDScript files built"; else echo "✗ GDScript files not built"; fi
	@if [ -f "$(SPELLBOOK_PATH)" ]; then echo "✓ Spellbook installed at $(SPELLBOOK_PATH)"; else echo "✗ Spellbook not installed"; fi
	@echo ""
	@echo "Source files:"
	@if [ -n "$(ENGINE_STRINGS_EXISTS)" ]; then echo "✓ Engine strings directory exists"; else echo "✗ Engine strings directory missing"; fi
	@if [ -n "$(SPELLS_CSV_EXISTS)" ]; then echo "✓ $(SPELLS_CSV) exists"; else echo "✗ $(SPELLS_CSV) missing"; fi

# Validate the generated spellbook
.PHONY: validate
validate: $(SPELLBOOK_PATH)
	@echo "Validating spellbook..."
	@if [ -f "$(SPELLBOOK_PATH)" ]; then \
		echo "✓ Spellbook file exists"; \
		if $(PYTHON) -m json.tool "$(SPELLBOOK_PATH)" > /dev/null 2>&1; then \
			echo "✓ Spellbook JSON is valid"; \
		else \
			echo "✗ Spellbook JSON is invalid"; \
			exit 1; \
		fi; \
	else \
		echo "✗ Spellbook file not found"; \
		exit 1; \
	fi