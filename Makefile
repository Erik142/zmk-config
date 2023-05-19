MAKEFILE_DIR = $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SCRIPTS_DIR = $(MAKEFILE_DIR)/scripts

.PHONY: all
all: build

.PHONY: build
build:
	$(SCRIPTS_DIR)/zmk_build.sh -v 3.2 --host-zmk-dir /Users/erikwahlberger/Projekt/zmk/zmk --host-config-dir /Users/erikwahlberger/Projekt/zmk/zmk-config -o /Users/erikwahlberger/Projekt/zmk/firmware-build -- -p
