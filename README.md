# nanak8s

## Local development

- Install [minikube](https://minikube.sigs.k8s.io/docs/)
- Copy `.env.example` to `.env` and edit it accordingly
- `make all`

## Join the cluster

```
curl -sfL https://get.k3s.io | K3S_TOKEN=<shared_secret> sh -s - server --server https://camp-direct.yuru.moe:6443
```
