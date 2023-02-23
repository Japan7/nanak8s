SHELL := /usr/bin/env bash

.PHONY: helmfile system apps

all: helmfile system apps

helmfile:
	set -a && source .env && \
	cat helmfile.yaml | envsubst | helmfile apply -f -

system:
	set -a && source .env && \
	kubectl kustomize system | envsubst | kubectl apply -f -

apps:
	set -a && source .env && \
	kubectl kustomize apps | envsubst | kubectl apply -f -
