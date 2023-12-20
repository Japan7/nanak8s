# nanak8s

## Join the Japan7 cluster

**[Wireguard](https://www.wireguard.com/install/) support** is required on the node to join the private cluster [innernet](https://github.com/tonarino/innernet).

**Optional inbound rules:** 80/TCP (HTTP), 443/TCP (HTTPS), 6443/TCP (K8s API), 8022/TCP (Forgejo SSH), 8999/TCP (Syncplay).

### Steps

1. **Setup innernet**

Follow the [install instructions](https://github.com/tonarino/innernet#installation), ask your `invitation.toml` and [configure your peer](https://github.com/tonarino/innernet#peer-initialization) with it.

2. **Install K3s**

Edit and put the following configuration in `/etc/rancher/k3s/config.yaml`:

```yaml
server: https://<existing_server_node_innernet_ip>:6443
flannel-iface: <innernet_interface>
token: <shared_secret>
disable:
  - local-storage
secrets-encryption: true
kubelet-arg:
  - eviction-hard=memory.available<0%
  - eviction-soft=memory.available<100Mi,nodefs.available<5Gi,nodefs.inodesFree<5%,imagefs.available<5Gi
  - eviction-soft-grace-period=memory.available=5m,nodefs.available=5m,nodefs.inodesFree=5m,imagefs.available=5m
```

Then run the one-liner to install K3s:

```sh
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=stable sh -s - <node_type>
```

`node_type` is `server` or `agent`.

3. **Longhorn requirements**

Longhorn (block storage) requires some system packages. Please check their [documentation](https://longhorn.io/docs/latest/deploy/install/#installation-requirements) and install them.

4. **[Optional] Setup Traefik passthrough**

K3s internal Traefik serves web apps on port 8443 (websecure). You may setup another Traefik outside the Kubernetes cluster with `docker-compose` to passthrough matching incoming requests on ports 80 and 443.

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
      rule: "HostSNIRegexp(`<domain>`, `{subdomain:[a-z0-9.-]+}.<domain>`)"
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

### Start a new cluster

Save the same configuration file as above without the `server` key and run the following one-liner:

```sh
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=stable sh -s - server --cluster-init
```

### Launch Argo CD

```sh
export SOPS_AGE_KEY=<private_key>
helmfile apply -f apps/argo-cd/helmfile.yaml -n argocd --set notifications.enabled=false
kubectl apply -f apps/bootstrap.yaml -n argocd
```

This will start Argo CD in the cluster and configure it so it will automatically add and sync the other apps of this repository.
