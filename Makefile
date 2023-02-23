SHELL := /usr/bin/env bash

.PHONY: helm system apps

all: helm system apps

helm:
	helmfile apply

system:
	set -a && source .env && \
	kubectl kustomize system | envsubst | kubectl apply -f -

apps:
	set -a && source .env && \
	kubectl kustomize apps | envsubst | kubectl apply -f -
