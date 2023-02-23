SHELL := /usr/bin/env bash

.PHONY: helmfile system japan7

all: helmfile system japan7

helmfile:
	set -a && source .env && \
	cat helmfile.yaml | envsubst | helmfile apply -f -

system:
	set -a && source .env && \
	kubectl kustomize system | envsubst | kubectl apply -f -

japan7:
	set -a && source .env && \
	kubectl kustomize japan7 | envsubst | kubectl apply -f -
