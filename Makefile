.PHONY: setup apps dashboard

all: setup apps

setup:
	kubectl apply -f setup/

apps:
	kubectl apply -k .

dashboard:
	dashboard/deploy.sh
