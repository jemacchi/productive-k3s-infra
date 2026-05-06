.PHONY: docs-build docs-serve docs-up docs-down docs-clean test-static test-contract test-live test-live-gha-onprem test-matrix

USE_CASES := multipass onprem-basic aws-single-node
TESTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/tests
export TELEMETRY_ENABLED ?=
export TELEMETRY_ENDPOINT ?=
export TELEMETRY_MAX_RETRIES ?= 3
export TELEMETRY_CONNECT_TIMEOUT_SECONDS ?= 5
export TELEMETRY_REQUEST_TIMEOUT_SECONDS ?= 10
export TELEMETRY_OUTBOX_DIR ?=
export TELEMETRY_USER_AGENT ?= productive-k3s-infra/matrix

docs-build:
	./docs/build.sh

docs-serve:
	./docs/serve.sh

docs-up:
	./docs/serve.sh --background

docs-down:
	./docs/clean.sh

docs-clean:
	./docs/clean.sh

test-static:
	$(TESTS_DIR)/run-matrix.sh static $(USE_CASES)
	bash -n $(TESTS_DIR)/live-onprem-basic-github-host.sh

test-contract:
	$(TESTS_DIR)/run-matrix.sh contract $(USE_CASES)

test-live:
	$(TESTS_DIR)/run-matrix.sh live $(USE_CASES)

test-live-gha-onprem:
	$(TESTS_DIR)/live-onprem-basic-github-host.sh

test-matrix: test-static test-contract test-live
