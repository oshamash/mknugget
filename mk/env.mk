# General helper to know where we are at
MKFILE_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

# Default values for environment variables
ROOT ?= $(shell cd ${MKFILE_DIR} && git rev-parse --show-toplevel)

MAKE := make
