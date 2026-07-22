# Project-wide Makefile for Realmz Remake
.DEFAULT_GOAL := help

# Project directories
ASSET_SCRIPTS_DIR := asset_scripts
SRC_DIR := src
ADDONS_DIR := $(SRC_DIR)/addons
BUILD_DIR := $(SRC_DIR)/build

# Python interpreter
PYTHON := python3

# Godot executable
GODOT := /Applications/Godot.app/Contents/MacOS/Godot

# Colors for output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_BLUE := \033[34m
COLOR_YELLOW := \033[33m

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
.PHONY: spells classic-spell-audit classic-damage-spell-scaffold
spells:
	$(MAKE) -C $(ASSET_SCRIPTS_DIR)

classic-spell-audit:
	$(PYTHON) $(ASSET_SCRIPTS_DIR)/audit_classic_spell_parity.py

classic-damage-spell-scaffold:
	$(PYTHON) $(ASSET_SCRIPTS_DIR)/scaffold_classic_damage_spells.py

# Build management
.PHONY: build-mac clean-build
build-mac:
	@printf "$(COLOR_BLUE)Building macOS application...$(COLOR_RESET)\n"
	@if [ ! -f "$(GODOT)" ]; then \
		printf "$(COLOR_YELLOW)⚠ Godot not found at $(GODOT)$(COLOR_RESET)\n"; \
		printf "$(COLOR_YELLOW)Please install Godot or update the GODOT variable in the Makefile$(COLOR_RESET)\n"; \
		exit 1; \
	fi
	@mkdir -p $(BUILD_DIR)/macos
	@printf "$(COLOR_BLUE)Importing project assets...$(COLOR_RESET)\n"
	@cd $(SRC_DIR) && $(GODOT) --import --headless > /dev/null 2>&1
	@printf "$(COLOR_BLUE)Installing build dependencies...$(COLOR_RESET)\n"
	@if ! command -v fileicon >/dev/null 2>&1; then \
		printf "$(COLOR_BLUE)Installing fileicon...$(COLOR_RESET)\n"; \
		brew install fileicon > /dev/null 2>&1; \
	fi
	@printf "$(COLOR_BLUE)Exporting macOS build...$(COLOR_RESET)\n"
	@cd $(SRC_DIR) && $(GODOT) --export-debug macOS --headless > /dev/null 2>&1
	@if [ -f "$(BUILD_DIR)/macos/Realmz-Remake.dmg" ]; then \
		printf "$(COLOR_BLUE)Preparing distribution DMG...$(COLOR_RESET)\n"; \
		cd $(BUILD_DIR)/macos && \
		hdiutil attach Realmz-Remake.dmg > /dev/null 2>&1 && \
		mkdir -p ./temp_dmg_parent && \
		cp -R ./Realmz-Remake ./temp_dmg_parent/ 2>/dev/null || true && \
		ln -s /Applications ./temp_dmg_parent/Applications 2>/dev/null || true && \
		if [ -d "/Volumes/Realmz" ]; then \
			cp -R /Volumes/Realmz/Realmz.app ./temp_dmg_parent/Realmz-Remake/ 2>/dev/null || true; \
			cp /Volumes/Realmz/Realmz.command ./temp_dmg_parent/Realmz-Remake/ 2>/dev/null || true; \
		fi && \
		hdiutil create -volname "Realmz-Remake" -srcfolder ./temp_dmg_parent -ov -format UDZO Realmz-Remake-macos.dmg > /dev/null 2>&1 && \
		hdiutil detach /Volumes/Realmz > /dev/null 2>&1 || true && \
		rm -rf ./temp_dmg_parent && \
		printf "$(COLOR_GREEN)✓ Distribution DMG created: Realmz-Remake-macos.dmg$(COLOR_RESET)\n"; \
		printf "$(COLOR_GREEN)✓ macOS build completed successfully!$(COLOR_RESET)\n"; \
		printf "$(COLOR_GREEN)Build artifacts available at: $(BUILD_DIR)/macos/$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_YELLOW)⚠ Build may have failed - check $(BUILD_DIR)/macos/ directory$(COLOR_RESET)\n"; \
	fi

clean-build:
	@printf "$(COLOR_YELLOW)Cleaning build directory...$(COLOR_RESET)\n"
	@if [ -d "$(BUILD_DIR)" ]; then \
		rm -rf $(BUILD_DIR); \
		printf "$(COLOR_GREEN)✓ Build directory cleaned$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_YELLOW)⚠ Build directory not found$(COLOR_RESET)\n"; \
	fi

# Addon management
.PHONY: install-openmpt clean-openmpt
install-openmpt:
	@printf "$(COLOR_BLUE)Installing Godot OpenMPT addon...$(COLOR_RESET)\n"
	@$(PYTHON) install_godot_openmpt.py --force
	@printf "$(COLOR_GREEN)✓ Godot OpenMPT addon installed$(COLOR_RESET)\n"
clean-openmpt:
	@printf "$(COLOR_YELLOW)Removing Godot OpenMPT addon...$(COLOR_RESET)\n"
	@if [ -d "$(ADDONS_DIR)/godot-openmpt" ]; then \
		rm -rf $(ADDONS_DIR)/godot-openmpt; \
		printf "$(COLOR_GREEN)✓ Godot OpenMPT addon removed$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_YELLOW)⚠ Godot OpenMPT addon not found$(COLOR_RESET)\n"; \
	fi

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
	@echo "  spells          - Build spell assets"
	@echo "  classic-spell-audit - Report remaining Classic spell implementation batches"
	@echo "  classic-damage-spell-scaffold - Draft the audited immediate-damage resources"
	@echo ""
	@echo "Build management:"
	@echo "  build-mac       - Build macOS application (.app and .dmg)"
	@echo "  clean-build     - Clean build directory"
	@echo ""
	@echo "Addon management:"
	@echo "  install-openmpt - Install Godot OpenMPT addon"
	@echo "  install-addons  - Install all required addons"
	@echo "  clean-openmpt   - Remove Godot OpenMPT addon"
	@echo "  clean-addons    - Remove all addons"
	@echo "  check-addons    - List installed addons"
	@echo "  git-status-addons - Check if external addons are tracked by git"
	@echo ""
	@echo "Project setup:"
	@echo "  setup-project   - Complete project setup (installs addons)"
