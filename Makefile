SHELL=/bin/bash

# Syncs the deploys scripts for grafana-agent and node-exporter from a local checkout of the private omni repo.
# This should called every time those scripts change to sync latest version to this repo.
# This ensures single source of truth is the omni repo.
OMNI_REPO = ../omni
sync-deploy-scripts:
	@echo "Using OMNI_REPO=$(realpath ${OMNI_REPO})"
	@cp ${OMNI_REPO}/networks/deploy_node_exporter.sh aws/scripts/deploy_node_exporter.sh
	@cp ${OMNI_REPO}/networks/deploy_agent.sh aws/scripts/deploy_agent.sh

.PHONY: sync-deploy-scripts