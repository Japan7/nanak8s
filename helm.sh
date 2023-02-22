#!/bin/sh
helm repo update

# kubernetes-dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install \
    kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --namespace kubernetes-dashboard --create-namespace

# longhorn
helm repo add longhorn https://charts.longhorn.io
helm upgrade --install \
    longhorn longhorn/longhorn \
    --namespace longhorn-system --create-namespace

# cloudnative-pg
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install \
    cnpg cnpg/cloudnative-pg \
    --namespace cnpg-system --create-namespace
