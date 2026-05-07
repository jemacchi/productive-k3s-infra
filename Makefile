.PHONY: docs-build docs-serve docs-up docs-down docs-clean test-static test-contract test-live test-live-gha-onprem test-matrix test-productive-k3s-infra-cli multipass onprem aws-single-node

USE_CASES := multipass onprem-basic aws-single-node
TESTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/tests
SCRIPTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/scripts
export TELEMETRY_ENABLED ?=
export TELEMETRY_ENDPOINT ?=
export TELEMETRY_MAX_RETRIES ?= 3
export TELEMETRY_CONNECT_TIMEOUT_SECONDS ?= 5
export TELEMETRY_REQUEST_TIMEOUT_SECONDS ?= 10
export TELEMETRY_OUTBOX_DIR ?=
export TELEMETRY_USER_AGENT ?= productive-k3s-infra/matrix

docs-build:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh docs-build

docs-serve:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh docs-serve

docs-up:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh docs-up

docs-down:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh docs-down

docs-clean:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh docs-clean

test-static:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-static

test-contract:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-contract

test-live:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-live

test-live-gha-onprem:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-live-gha-onprem

test-matrix: test-static test-contract test-live

test-productive-k3s-infra-cli:
	$(SCRIPTS_DIR)/productive-k3s-infra-dev.sh test-productive-k3s-infra-cli

multipass:
	$(SCRIPTS_DIR)/productive-k3s-infra.sh multipass up

onprem:
	$(SCRIPTS_DIR)/productive-k3s-infra.sh onprem up

aws-single-node:
	$(SCRIPTS_DIR)/productive-k3s-infra.sh aws-single-node up
