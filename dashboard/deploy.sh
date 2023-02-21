#!/bin/sh
# https://docs.k3s.io/installation/kube-dashboard

DIR=$(dirname "$0")

k3s kubectl delete ns kubernetes-dashboard
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
k3s kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml -f $DIR/dashboard.admin-user.yml -f $DIR/dashboard.admin-user-role.yml

kubectl apply -f $DIR/ingress.yaml
