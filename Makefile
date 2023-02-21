.PHONY: setup dashboard apps

all: setup dashboard apps

setup:
	kubectl apply -f setup/

dashboard:
	dashboard/deploy.sh

apps:
	kubectl apply -k .
