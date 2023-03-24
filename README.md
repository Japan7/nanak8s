# nanak8s

## Join the Japan7 cluster

**[Wireguard](https://www.wireguard.com/install/) support** is required on the node to join the private cluster [innernet](https://github.com/tonarino/innernet).

**Optional inbound rules:** 80/TCP (HTTP), 443/TCP (HTTPS), 6443/TCP (K8s API), 8022/TCP (Forgejo SSH), 8999/TCP (Syncplay).

### Steps

1. **Setup innernet**

Follow the [install instructions](https://github.com/tonarino/innernet#installation), ask your `invitation.toml` and [configure your peer](https://github.com/tonarino/innernet#peer-initialization) with it.

2. **Install K3s**

```sh
curl -sfL https://get.k3s.io |
INSTALL_K3S_CHANNEL=v1.26 \
K3S_TOKEN=<SHARED_SECRET> \
sh -s - server \
--server https://<EXISTING_NODE_IP>:6443 \
--secrets-encryption \
--disable local-storage \
--flannel-iface <INNERNET_INTERFACE> \
--etcd-arg heartbeat-interval=200 \
--etcd-arg election-timeout=1000 \
--etcd-expose-metrics
```

3. **Check Longhorn requirements**

[Some system tools](https://longhorn.io/docs/1.4.1/deploy/install/#installation-requirements) need to be installed on the node so Longhorn, the used block storage system, can work properly.

You can use the following script to check your environment:

```sh
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/scripts/environment_check.sh | bash
```

4. **[Optional] Setup Traefik passthrough**

K3s internal Traefik serves web apps on port 8443 (websecure). You may setup another Traefik outside the K8s cluster with `docker-compose` to passthrough matching incoming requests on ports 80 and 443 to K8s.

- `docker-compose.yml`

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

- `./traefik/dynconfig.yml`

```yaml
tcp:
  routers:
    k8s:
      entryPoints:
        - "websecure"
      rule: "HostSNIRegexp(`<DOMAIN>`, `{subdomain:[a-z0-9.-]+}.<DOMAIN>`)"
      service: "k8s-file"
      tls:
        passthrough: true
  services:
    k8s-file:
      loadBalancer:
        servers:
          - address: "host.docker.internal:8443"
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
--flannel-iface <INNERNET_INTERFACE>
```

### Launch Argo CD

```sh
export SOPS_AGE_KEY=<PRIVATE_KEY>
helmfile apply -f apps/argo-cd/helmfile.yaml -n argocd --set notifications.enabled=false
kubectl apply -f apps/bootstrap.yaml -n argocd
```

This will install Argo CD on the cluster and configure it so it will automatically add and sync the other apps with this repository.
