.PHONY: infra-init infra-up cluster-up stack-up validate up down clean status

USE_CASE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
OPENTOFU_DIR := $(USE_CASE_DIR)/opentofu
GENERATED_DIR := $(USE_CASE_DIR)/generated
SCRIPTS_DIR := $(USE_CASE_DIR)/scripts
TOFU_BIN ?= $(shell if command -v tofu >/dev/null 2>&1; then echo tofu; elif command -v terraform >/dev/null 2>&1; then echo terraform; fi)

export PRODUCTIVE_K3S_REPO ?= $(abspath $(USE_CASE_DIR)/../../../productive-k3s)
export PRODUCTIVE_K3S_SOURCE ?= local
export PRODUCTIVE_K3S_VERSION ?=
export PRODUCTIVE_K3S_RELEASE_REPO ?= jemacchi/productive-k3s
export TOFU_BIN

infra-init:
	@test -n "$(TOFU_BIN)" || { echo "tofu or terraform is required"; exit 1; }
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) init

infra-up: infra-init
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) apply -auto-approve
	$(SCRIPTS_DIR)/refresh-generated-artifacts.sh

cluster-up:
	$(SCRIPTS_DIR)/cluster-up.sh

stack-up:
	$(SCRIPTS_DIR)/bootstrap-stack.sh

validate:
	$(SCRIPTS_DIR)/validate-cluster.sh

up: infra-up cluster-up validate

down: infra-init
	$(TOFU_BIN) -chdir=$(OPENTOFU_DIR) destroy -auto-approve

clean:
	rm -f $(GENERATED_DIR)/cluster.json
	rm -f $(GENERATED_DIR)/hosts.yml
	rm -f $(GENERATED_DIR)/nodes.env
	rm -f $(GENERATED_DIR)/server-token.txt
	rm -f $(GENERATED_DIR)/server-url.txt
	rm -rf $(GENERATED_DIR)/logs
	rm -rf $(OPENTOFU_DIR)/.terraform
	rm -f $(OPENTOFU_DIR)/.terraform.lock.hcl
	rm -f $(OPENTOFU_DIR)/terraform.tfstate
	rm -f $(OPENTOFU_DIR)/terraform.tfstate.backup

status:
	@if [ -f "$(GENERATED_DIR)/cluster.json" ]; then \
		PRODUCTIVE_K3S_SOURCE="$$(jq -r '.productive_k3s.source // empty' "$(GENERATED_DIR)/cluster.json")" \
		PRODUCTIVE_K3S_VERSION="$$(jq -r '.productive_k3s.version // empty' "$(GENERATED_DIR)/cluster.json")" \
		PRODUCTIVE_K3S_RELEASE_REPO="$$(jq -r '.productive_k3s.release_repo // empty' "$(GENERATED_DIR)/cluster.json")" \
		$(SCRIPTS_DIR)/refresh-generated-artifacts.sh; \
	else \
		$(SCRIPTS_DIR)/refresh-generated-artifacts.sh; \
	fi
	@cat $(GENERATED_DIR)/cluster.json
