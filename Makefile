SHELL := /usr/bin/env bash

.PHONY: setup apps dashboard

all: setup apps

setup:
	set -a && source .env && \
	for f in setup/*.yaml; do cat $$f | envsubst | kubectl apply -f -; done

apps:
	set -a && source .env && \
	kubectl kustomize | envsubst | kubectl apply -f -

dashboard:
	set -a && source .env && \
	dashboard/deploy.sh
