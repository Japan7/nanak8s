# nanak8s

## Join the cluster

[**Wireguard**](https://www.wireguard.com/install/) support on the node is required. You need to join the cluster [innernet](https://github.com/tonarino/innernet).

**Optional inbound rules:** 80/TCP (HTTP), 443/TCP (HTTPS), 6443/TCP (K8s)

```sh
# Install K3s
curl -sfL https://get.k3s.io |
INSTALL_K3S_CHANNEL=latest \
K3S_TOKEN=<SHARED_SECRET> \
sh -s - server \
--server https://<SERVER_HOST>:6443 \
--secrets-encryption \
--disable local-storage \
--flannel-iface <WIREGUARD_INTERFACE> \

# Check Longhorn requirements
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.4.0/scripts/environment_check.sh | bash
```

## Bootstrapping

### Requirements

- [K3s](https://docs.k3s.io/) - Lightweight Kubernetes
- [helm](https://helm.sh/) and [helmfile](https://helmfile.readthedocs.io/en/latest/) for chart deployments
- [sops](https://github.com/mozilla/sops) and [age](https://github.com/FiloSottile/age) for secrets management

Run `helmfile init` to install the required helm plugins.

### Edit secrets

```sh
SOPS_AGE_KEY=<PRIVATE_KEY> helm secrets edit <something.sops.yaml>
```

### Start the cluster

```sh
curl -sfL https://get.k3s.io |
INSTALL_K3S_CHANNEL=latest \
K3S_TOKEN=<SHARED_SECRET> \
sh -s - server \
--cluster-init \
--secrets-encryption \
--disable local-storage \
--flannel-iface <WIREGUARD_INTERFACE> \
```

### Setup Argo CD

```sh
SOPS_AGE_KEY=<PRIVATE_KEY> helmfile apply -f apps/argo-cd/helmfile.yaml --set notifications.enabled=false
kubectl apply -f apps/bootstrap.yaml
```

This will install Argo CD on the cluster and configure it so it will automatically add and sync the other apps with this repository.

## Traefik passthrough

K3s internal Traefik will serve web apps on ports 8000 and 8443. You may setup another Traefik outside the K8s cluster with docker-compose to passthrough matching incoming requests on ports 80 and 443 to K8s.

### `docker-compose.yml`

```yaml
services:
  traefik:
    image: traefik:latest
    command:
      - --providers.docker=true
      - --providers.file.directory=/config
      - --entrypoints.web.address=:80
      - --entrypoints.web.http.redirections.entryPoint.to=websecure
      - --entrypoints.web.http.redirections.entryPoint.scheme=https
      - --entrypoints.websecure.address=:443
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik:/config
    restart: unless-stopped
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

### `./traefik/dynconfig.yml`

```yaml
tcp:
  routers:
    k8s-web:
      entryPoints:
        - "web"
      rule: "HostSNIRegexp(`<DOMAIN>`, `{subdomain:[a-z.]+}.<DOMAIN>`)"
      service: "k8s-web-file"
    k8s-websecure:
      entryPoints:
        - "websecure"
      rule: "HostSNIRegexp(`<DOMAIN>`, `{subdomain:[a-z.]+}.<DOMAIN>`)"
      service: "k8s-websecure-file"
      tls:
        passthrough: true
  services:
    k8s-web-file:
      loadBalancer:
        servers:
          - address: "host.docker.internal:8000"
    k8s-websecure-file:
      loadBalancer:
        servers:
          - address: "host.docker.internal:8443"
```
