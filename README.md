# nanak8s

## Requirements

- [K3s](https://docs.k3s.io/) Lightweight Kubernetes
- [helm](https://helm.sh/) and [helmfile](https://helmfile.readthedocs.io/en/latest/) for chart deployments
- [sops](https://github.com/mozilla/sops) and [age](https://github.com/FiloSottile/age) for secrets

## Join the cluster

```sh
curl -sfL https://get.k3s.io | K3S_TOKEN=<shared_secret> sh -s - server --server https://<domain>:6443
```

## Traefik passthrough

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
      rule: "HostSNIRegexp(`<domain>`, `{subdomain:[a-z.]+}.<domain>`)"
      service: "k8s-web-file"
    k8s-websecure:
      entryPoints:
        - "websecure"
      rule: "HostSNIRegexp(`<domain>`, `{subdomain:[a-z.]+}.<domain>`)"
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
