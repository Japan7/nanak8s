.PHONY: setup apps

all: setup apps

setup:
	kubectl apply -f setup/

apps:
	kubectl apply -k .
