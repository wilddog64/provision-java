SHELL := /bin/bash
export DISABLE_BUNDLER_SETUP := 1

ifeq ($(OS),Windows_NT)
  DEFAULT_KITCHEN_YAML := .kitchen-win.yml
else
  DEFAULT_KITCHEN_YAML := .kitchen.yml
endif

KITCHEN_YAML ?= $(DEFAULT_KITCHEN_YAML)
RBENV_BIN := $(shell command -v rbenv 2>/dev/null)
ifdef RBENV_BIN
  KITCHEN_CMD ?= rbenv exec kitchen
else
  KITCHEN_CMD ?= kitchen
endif

PLATFORMS := win11 ubuntu-2404 rockylinux9
SUITES := default multi upgrade idempotence

# Maximum allowed size for kitchen file transfer (in MB)
MAX_TRANSFER_SIZE_MB := 50

.DEFAULT_GOAL := help

# ============================================================================ 
# Validation Targets
# ============================================================================ 
.PHONY: lint
lint:
	@echo "Running ansible-lint..."
	ansible-lint .

.PHONY: syntax
syntax:
	@echo "Checking playbook syntax..."
	ansible-playbook --syntax-check tests/playbook.yml -i tests/inventory

.PHONY: check
check: lint syntax
	@echo "All validation checks passed."

# ============================================================================

# Utility Targets

# ============================================================================

.PHONY: setup

setup:

	@./scripts/setup.sh all



.PHONY: deps


deps:
	@echo "Installing Ansible collections..."
	ansible-galaxy collection install ansible.windows chocolatey.chocolatey -p ./collections --force

# ============================================================================ 
# Preflight
# ============================================================================ 
# Preflight check: ensure transfer size is reasonable
.PHONY: preflight
preflight:
	@total_kb=$$(du -sk . 2>/dev/null | cut -f1); \
	exclude_kb=0; \
	for dir in .git .direnv .kitchen .vagrant .claude; do \
		if [ -d "$$dir" ]; then \
			dir_kb=$$(du -sk "$$dir" 2>/dev/null | cut -f1); \
			exclude_kb=$$((exclude_kb + dir_kb)); \
		fi; \
	done; \
	size_kb=$$((total_kb - exclude_kb)); \
	size_mb=$$((size_kb / 1024)); \
	echo "Transfer size: $${size_mb}MB (max: $(MAX_TRANSFER_SIZE_MB)MB)"; \
	if [ $$size_mb -gt $(MAX_TRANSFER_SIZE_MB) ]; then \
		echo "ERROR: Transfer size exceeds $(MAX_TRANSFER_SIZE_MB)MB limit!"; \
		echo "Check for large files/directories that should be in ignore_paths:"; \
		du -sh * .* 2>/dev/null | sort -h | tail -10; \
		exit 1; \
	fi

.PHONY: help
help:
	@echo "Available targets (auto KITCHEN_YAML=$(KITCHEN_YAML)):";
	@echo ""
	@echo "Validation:";
	@echo "  lint                # Run ansible-lint";
	@echo "  syntax              # Check playbook syntax";
	@echo "  check               # Run all validation checks";
	@echo "  deps                # Install Ansible collections to ./collections";
	@echo ""
	@echo "Utility:";
	@echo "  list-kitchen-instances  # List all kitchen instances";
	@echo "  destroy-all             # Destroy all kitchen instances";
	@echo "  preflight               # Check transfer size before test/converge";
	@echo ""
	@echo "Quick test (default suite):";
	@$(foreach p,$(PLATFORMS),echo "  test-$(p)           # kitchen test default-$(p)" &&) true
	@echo ""
	@echo "Test specific suite on platform:";
	@$(foreach p,$(PLATFORMS),$(foreach s,$(SUITES),echo "  test-$(s)-$(p)     # kitchen test $(s)-$(p)" &&)) true
	@echo ""
	@echo "Test all suites on a platform:";
	@$(foreach p,$(PLATFORMS),echo "  test-all-$(p)       # Run all test suites on $(p)" &&) true
	@echo ""
	@echo "Converge/Verify/Destroy (default suite):";
	@$(foreach p,$(PLATFORMS),echo "  converge-$(p)       # kitchen converge default-$(p)" &&) true
	@$(foreach p,$(PLATFORMS),echo "  verify-$(p)         # kitchen verify default-$(p)" &&) true
	@$(foreach p,$(PLATFORMS),echo "  destroy-$(p)        # kitchen destroy all $(p) instances" &&) true
	@echo ""
	@echo "Destroy specific suite on platform:";
	@$(foreach p,$(PLATFORMS),$(foreach s,$(SUITES),echo "  destroy-$(s)-$(p)" &&)) true
	@echo ""
	@echo "Vagrant targets (default: Rocky Linux 9):";
	@echo "  vagrant-up              # Start VM";
	@echo "  vagrant-provision       # Run ansible (default: JDK 17,21, active: 21)";
	@echo "  vagrant-destroy         # Destroy VM";
	@echo "  vagrant-ssh             # SSH into VM";
	@echo "  vagrant-multi           # Provision with custom versions";
	@echo "                          # e.g., make vagrant-multi JDK_VERSIONS=11,17,21 JDK_VERSION=17";
	@echo ""
	@echo "Vagrant with specific distro:";
	@echo "  vagrant-ubuntu-up       # Start Ubuntu 24.04 VM";
	@echo "  vagrant-ubuntu-provision";
	@echo "  vagrant-ubuntu-destroy";
	@echo "  vagrant-ubuntu-ssh";
	@echo "  vagrant-rocky-up        # Start Rocky Linux 9 VM";
	@echo "  vagrant-rocky-provision";
	@echo "  vagrant-rocky-destroy";
	@echo "  vagrant-rocky-ssh";
	@echo ""
	@echo "Override KITCHEN_YAML=/path/to/.kitchen.yml when needed."

.PHONY: list-kitchen-instances
list-kitchen-instances:
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) list

.PHONY: destroy-all
destroy-all:
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) destroy

# Test all suites on a platform
define TEST_ALL_SUITES
.PHONY: test-all-$(1)
test-all-$(1): preflight
	@$(foreach s,$(SUITES),echo "=== Testing suite: $(s)-$(1) ===" && KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) test $(s)-$(1) &&) true
endef

# Test specific suite on platform
define KITCHEN_SUITE_PLATFORM_TARGETS
.PHONY: test-$(1)-$(2)
test-$(1)-$(2): preflight
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) test $(1)-$(2)

.PHONY: converge-$(1)-$(2)
converge-$(1)-$(2): preflight
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) converge $(1)-$(2)

.PHONY: verify-$(1)-$(2)
verify-$(1)-$(2):
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) verify $(1)-$(2)

.PHONY: destroy-$(1)-$(2)
destroy-$(1)-$(2):
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) destroy $(1)-$(2)
endef

# Platform-level targets (shortcuts for default suite)
define KITCHEN_PLATFORM_TARGETS
.PHONY: test-$(1)
test-$(1): preflight
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) test default-$(1)

.PHONY: converge-$(1)
converge-$(1): preflight
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) converge default-$(1)

.PHONY: verify-$(1)
verify-$(1):
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) verify default-$(1)

.PHONY: destroy-$(1)
destroy-$(1):
	KITCHEN_YAML=$(KITCHEN_YAML) $(KITCHEN_CMD) destroy '.*-$(1)'
endef

$(foreach platform,$(PLATFORMS),$(eval $(call TEST_ALL_SUITES,$(platform))))
$(foreach platform,$(PLATFORMS),$(eval $(call KITCHEN_PLATFORM_TARGETS,$(platform))))
$(foreach platform,$(PLATFORMS),$(foreach suite,$(SUITES),$(eval $(call KITCHEN_SUITE_PLATFORM_TARGETS,$(suite),$(platform)))))

# Vagrant targets (default: Rocky Linux 9)
.PHONY: vagrant-up vagrant-provision vagrant-destroy vagrant-ssh vagrant-status

vagrant-up:
	vagrant up

vagrant-provision:
	vagrant provision

vagrant-destroy:
	vagrant destroy -f

vagrant-ssh:
	vagrant ssh

vagrant-status:
	vagrant status

# Vagrant with custom JDK versions
# Usage: make vagrant-multi JDK_VERSIONS=11,17,21 JDK_VERSION=17
.PHONY: vagrant-multi
vagrant-multi:
	JDK_VERSIONS=$(JDK_VERSIONS) JDK_VERSION=$(JDK_VERSION) vagrant provision

# Vagrant with Ubuntu
.PHONY: vagrant-ubuntu-up vagrant-ubuntu-provision vagrant-ubuntu-destroy vagrant-ubuntu-ssh

vagrant-ubuntu-up:
	./bin/vagrant-ubuntu up

vagrant-ubuntu-provision:
	./bin/vagrant-ubuntu provision

vagrant-ubuntu-destroy:
	./bin/vagrant-ubuntu destroy -f

vagrant-ubuntu-ssh:
	./bin/vagrant-ubuntu ssh

# Vagrant with Rocky Linux
.PHONY: vagrant-rocky-up vagrant-rocky-provision vagrant-rocky-destroy vagrant-rocky-ssh

vagrant-rocky-up:
	./bin/vagrant-rocky up

vagrant-rocky-provision:
	./bin/vagrant-rocky provision

vagrant-rocky-destroy:
	./bin/vagrant-rocky destroy -f

vagrant-rocky-ssh:
	./bin/vagrant-rocky ssh