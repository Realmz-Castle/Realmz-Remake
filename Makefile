# Project-wide Makefile for Realmz Remake
.DEFAULT_GOAL := help

# Project directories
ASSET_SCRIPTS_DIR := asset_scripts

# Python interpreter
PYTHON := python3

# Version management
.PHONY: bump
bump:
	@if [ -z "$(filter major minor patch,$(wordlist 2,2,$(MAKECMDGOALS)))" ]; then \
		echo "Usage: make bump [major|minor|patch]"; \
		exit 1; \
	fi
	$(PYTHON) $(ASSET_SCRIPTS_DIR)/update_version.py $(wordlist 2,2,$(MAKECMDGOALS))

%:
	@:

# Asset building
.PHONY: spells
spells:
	$(MAKE) -C $(ASSET_SCRIPTS_DIR)

# Help target
.PHONY: help
help:
	@echo "Realmz Remake Makefile"
	@echo "======================"
	@echo ""
	@echo "Version management:"
	@echo "  bump [type]    - Increment version number where type is:"
	@echo "                   major (x.0.0), minor (0.x.0), or patch (0.0.x)"
	@echo ""
	@echo "Asset building:"
	@echo "  spells         - Build spell assets"