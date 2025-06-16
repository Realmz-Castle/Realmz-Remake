# Project-wide Makefile for Realmz Remake
.DEFAULT_GOAL := help

# Project directories
ASSET_SCRIPTS_DIR := asset_scripts
SRC_DIR := src
ADDONS_DIR := $(SRC_DIR)/addons

# Python interpreter
PYTHON := python3

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
.PHONY: spells
spells:
	$(MAKE) -C $(ASSET_SCRIPTS_DIR)

# Addon management
.PHONY: install-openmpt install-addons clean-openmpt clean-addons setup-project check-addons git-status-addons
install-openmpt:
	@printf "$(COLOR_BLUE)Installing Godot OpenMPT addon...$(COLOR_RESET)\n"
	@$(PYTHON) install_godot_openmpt.py --force
	@printf "$(COLOR_GREEN)✓ Godot OpenMPT addon installed$(COLOR_RESET)\n"

install-addons: install-openmpt
	@printf "$(COLOR_GREEN)✓ All addons installed successfully!$(COLOR_RESET)\n"

clean-openmpt:
	@printf "$(COLOR_YELLOW)Removing Godot OpenMPT addon...$(COLOR_RESET)\n"
	@if [ -d "$(ADDONS_DIR)/godot-openmpt" ]; then \
		rm -rf $(ADDONS_DIR)/godot-openmpt; \
		printf "$(COLOR_GREEN)✓ Godot OpenMPT addon removed$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_YELLOW)⚠ Godot OpenMPT addon not found$(COLOR_RESET)\n"; \
	fi

clean-addons: clean-openmpt
	@printf "$(COLOR_GREEN)✓ All addons cleaned$(COLOR_RESET)\n"

check-addons:
	@printf "$(COLOR_BLUE)Checking installed addons...$(COLOR_RESET)\n"
	@if [ -d "$(ADDONS_DIR)" ]; then \
		printf "$(COLOR_BOLD)Installed addons in $(ADDONS_DIR):$(COLOR_RESET)\n"; \
		ls -la $(ADDONS_DIR)/ | grep ^d | awk '{print "  - " $$9}' | grep -v '^\s*-\s*\.\s*$$' | grep -v '^\s*-\s*\.\.\s*$$'; \
	else \
		printf "$(COLOR_YELLOW)⚠ No addons directory found at $(ADDONS_DIR)$(COLOR_RESET)\n"; \
	fi

setup-project: install-addons
	@printf "$(COLOR_BLUE)Setting up project...$(COLOR_RESET)\n"
	@mkdir -p $(ADDONS_DIR)
	@printf "$(COLOR_GREEN)✓ Project setup complete! Addons installed to $(ADDONS_DIR)$(COLOR_RESET)\n"

git-status-addons:
	@printf "$(COLOR_BLUE)Checking git status for addons...$(COLOR_RESET)\n"
	@if git ls-files | grep -E "src/addons/(godot-openmpt|godot-git-plugin|TilED)" > /dev/null 2>&1; then \
		printf "$(COLOR_YELLOW)⚠ Warning: External addons are being tracked by git:$(COLOR_RESET)\n"; \
		git ls-files | grep -E "src/addons/(godot-openmpt|godot-git-plugin|TilED)"; \
		printf "$(COLOR_YELLOW)Consider running: git rm --cached <addon-path>$(COLOR_RESET)\n"; \
	else \
		printf "$(COLOR_GREEN)✓ No external addons are being tracked by git$(COLOR_RESET)\n"; \
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
