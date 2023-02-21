.PHONY: setup apply

all: setup apply

setup:
	kubectl apply -f setup/namespace.yaml
	kubectl apply -f $(wildcard setup/cnpg-*.yaml)

apply:
	kubectl apply -k .
