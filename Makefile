VERBOSE ?= 0

ifneq ($(VERBOSE),0)
	Q := $(empty)
else
	Q := @
endif

ZMK_CONFIG_DIR = $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BASE_DIR = $(realpath $(dir $(abspath $(ZMK_CONFIG_DIR))))

SCRIPTS_DIR = $(ZMK_CONFIG_DIR)/scripts
ZMK_DIR ?= $(BASE_DIR)/zmk
BUILD_DIR ?= $(BASE_DIR)/zmk-build
LOG_DIR ?= $(BASE_DIR)/zmk-logs
export HOST_MODULES_DIR ?= $(BASE_DIR)/zmk-modules

ZMK_URL ?= https://github.com/urob/zmk.git
ZMK_BRANCH ?= main

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
	$(Q)if [ ! -e $(BUILD_DIR) ] || [ ! -d $(BUILD_DIR) ]; then rm -rf $(BUILD_DIR) && mkdir -p $(BUILD_DIR); fi
	$(Q)if [ ! -e $(LOG_DIR) ] || [ ! -d $(LOG_DIR) ]; then rm -rf $(LOG_DIR) && mkdir -p $(LOG_DIR); fi
	$(Q)if [ ! -e $(HOST_MODULES_DIR) ] || [ ! -d $(HOST_MODULES_DIR) ]; then rm -rf $(HOST_MODULES_DIR) && mkdir -p $(HOST_MODULES_DIR); fi
	$(Q)if [ ! -e $(ZMK_DIR) ] || [ ! -d $(ZMK_DIR) ]; then rm -rf $(ZMK_DIR) && cd $(BASE_DIR) && git clone $(ZMK_URL); fi
	$(Q)git -C $(ZMK_DIR) fetch --all --force
	$(Q)git -C $(ZMK_DIR) pull --rebase origin $(ZMK_BRANCH)
	$(Q)$(SCRIPTS_DIR)/zmk_build.sh --no-multithread -v 3.5 --host-zmk-dir $(ZMK_DIR) --host-config-dir $(ZMK_CONFIG_DIR) -o $(BUILD_DIR) -- -p
