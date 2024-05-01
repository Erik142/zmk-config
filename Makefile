VERBOSE ?= 0

ifneq ($(VERBOSE),0)
	Q := $(empty)
else
	Q := @
endif

ZMK_CONFIG_DIR = $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BASE_DIR = $(realpath $(dir $(abspath $(ZMK_CONFIG_DIR))))

export HOST_MODULES_DIR ?= $(BASE_DIR)/zmk-modules

SCRIPTS_DIR = $(ZMK_CONFIG_DIR)/scripts
ZMK_DIR ?= $(BASE_DIR)/zmk
ZMK_HELPERS_DIR ?= $(HOST_MODULES_DIR)/zmk-helpers
BUILD_DIR ?= $(BASE_DIR)/zmk-build
LOG_DIR ?= $(BASE_DIR)/zmk-logs

ZMK_URL ?= https://github.com/urob/zmk.git
ZMK_BRANCH ?= main

ZMK_HELPERS_URL ?= https://github.com/urob/zmk-helpers.git
ZMK_HELPERS_BRANCH ?= v2

define create_dir
	$(Q)if [ ! -e $(1) ] || [ ! -d $(1) ]; then rm -rf $(1) && mkdir -p $(1); fi
endef

define clone_repo
	$(Q)$(call create_dir,$(shell dirname $(1)))
	$(Q)if [ ! -e $(1)/.git ] || [ ! -d $(1)/.git ]; then cd $(1) && git clone $(2); fi
endef

define update_repo
	$(Q)git -C $(1) fetch --all --force
	$(Q)git -C $(1) pull --rebase origin $(2)
endef

define get_zephyr_version
	ZEPHYR_VERSION ?= $(shell cat $(ZMK_DIR)/.devcontainer/Dockerfile | head -1 | cut -d: -f2)
endef

.PHONY: all
all: build

.PHONY: build
build:
ifneq ($(VERBOSE),0)
	$(Q)echo "ZMK_CONFIG_DIR = $(ZMK_CONFIG_DIR)"
	$(Q)echo "BASE_DIR = $(BASE_DIR)"
	$(Q)echo "ZMK_DIR = $(ZMK_DIR)"
	$(Q)echo "BUILD_DIR = $(BUILD_DIR)"
endif
	$(Q)$(call create_dir,$(BUILD_DIR))
	$(Q)$(call clone_repo,$(ZMK_HELPERS_DIR),$(ZMK_HELPERS_URL))
	$(Q)$(call clone_repo,$(ZMK_DIR),$(ZMK_HELPERS_URL))
	$(Q)$(call update_repo,$(ZMK_DIR),$(ZMK_BRANCH))
	$(Q)$(call update_repo,$(ZMK_HELPERS_DIR),$(ZMK_HELPERS_BRANCH))
	$(Q)$(eval $(call get_zephyr_version))
	$(Q)$(SCRIPTS_DIR)/zmk_build.sh --no-multithread -v $(ZEPHYR_VERSION) --host-zmk-dir $(ZMK_DIR) --host-config-dir $(ZMK_CONFIG_DIR) -o $(BUILD_DIR) -- -p
