.PHONY: preflight cluster-up stack-up validate up status clean

.EXPORT_ALL_VARIABLES:

USE_CASE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
GENERATED_DIR := $(USE_CASE_DIR)/generated
SCRIPTS_DIR := $(USE_CASE_DIR)/scripts
ONPREM_ENV_FILE ?= $(USE_CASE_DIR)/onprem.env

-include $(ONPREM_ENV_FILE)

PRODUCTIVE_K3S_REPO ?= $(abspath $(USE_CASE_DIR)/../../../productive-k3s)
PRODUCTIVE_K3S_SOURCE ?= local
PRODUCTIVE_K3S_VERSION ?=
PRODUCTIVE_K3S_RELEASE_REPO ?= jemacchi/productive-k3s
ONPREM_CLUSTER_NAME ?= productive-k3s-onprem
ONPREM_BASE_DOMAIN ?= k3s.lab.internal
ONPREM_RANCHER_HOST ?= rancher.$(ONPREM_BASE_DOMAIN)
ONPREM_REGISTRY_HOST ?= registry.$(ONPREM_BASE_DOMAIN)
ONPREM_SSH_USER ?= ubuntu
ONPREM_SSH_PORT ?= 22

preflight:
	$(SCRIPTS_DIR)/preflight.sh

cluster-up:
	$(SCRIPTS_DIR)/cluster-up.sh

stack-up:
	$(SCRIPTS_DIR)/bootstrap-stack.sh

validate:
	$(SCRIPTS_DIR)/validate-cluster.sh

up: preflight cluster-up validate

status:
	@server_ip="$(ONPREM_SERVER_IP)"; \
	agent_ips="$(ONPREM_AGENT_IPS)"; \
	source_mode="$(PRODUCTIVE_K3S_SOURCE)"; \
	source_version="$(PRODUCTIVE_K3S_VERSION)"; \
	release_repo="$(PRODUCTIVE_K3S_RELEASE_REPO)"; \
	cluster_name="$(ONPREM_CLUSTER_NAME)"; \
	base_domain="$(ONPREM_BASE_DOMAIN)"; \
	rancher_host="$(ONPREM_RANCHER_HOST)"; \
	registry_host="$(ONPREM_REGISTRY_HOST)"; \
	if [ -z "$$server_ip" ] && [ -f "$(GENERATED_DIR)/cluster.json" ]; then \
		server_ip="$$(jq -r '.server.ipv4 // empty' "$(GENERATED_DIR)/cluster.json")"; \
		agent_ips="$$(jq -r '.agents[].ipv4' "$(GENERATED_DIR)/cluster.json" | tr '\n' ' ')"; \
		source_mode="$$(jq -r '.productive_k3s.source // empty' "$(GENERATED_DIR)/cluster.json")"; \
		source_version="$$(jq -r '.productive_k3s.version // empty' "$(GENERATED_DIR)/cluster.json")"; \
		release_repo="$$(jq -r '.productive_k3s.release_repo // empty' "$(GENERATED_DIR)/cluster.json")"; \
		cluster_name="$$(jq -r '.cluster_name // empty' "$(GENERATED_DIR)/cluster.json")"; \
		base_domain="$$(jq -r '.base_domain // empty' "$(GENERATED_DIR)/cluster.json")"; \
		rancher_host="$$(jq -r '.rancher_host // empty' "$(GENERATED_DIR)/cluster.json")"; \
		registry_host="$$(jq -r '.registry_host // empty' "$(GENERATED_DIR)/cluster.json")"; \
	fi; \
	ONPREM_SERVER_IP="$$server_ip" \
	ONPREM_AGENT_IPS="$$agent_ips" \
	PRODUCTIVE_K3S_SOURCE="$$source_mode" \
	PRODUCTIVE_K3S_VERSION="$$source_version" \
	PRODUCTIVE_K3S_RELEASE_REPO="$$release_repo" \
	ONPREM_CLUSTER_NAME="$$cluster_name" \
	ONPREM_BASE_DOMAIN="$$base_domain" \
	ONPREM_RANCHER_HOST="$$rancher_host" \
	ONPREM_REGISTRY_HOST="$$registry_host" \
	$(SCRIPTS_DIR)/refresh-generated-artifacts.sh
	@cat $(GENERATED_DIR)/cluster.json

clean:
	rm -f $(GENERATED_DIR)/cluster.json
	rm -f $(GENERATED_DIR)/hosts.yml
	rm -f $(GENERATED_DIR)/nodes.env
	rm -f $(GENERATED_DIR)/server-token.txt
	rm -f $(GENERATED_DIR)/server-url.txt
	rm -rf $(GENERATED_DIR)/logs
