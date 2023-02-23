SHELL := /usr/bin/env bash

.PHONY: helmfile config

all: helmfile config

helmfile:
	set -a && source .env && \
	cat helmfile.yaml | envsubst | helmfile apply -f -

config:
	set -a && source .env && \
	kubectl kustomize | envsubst | kubectl apply -f -
