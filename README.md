# ArgoCD GitOps Repo

This repository manages ArgoCD projects and apps declaratively via GitOps.

## Structure

- `projects/` – ArgoCD `AppProject` definitions
- `apps/` – ArgoCD `Application` definitions
- `manifests/` – Raw Kubernetes resources for workloads
- `manifests/hidmo/backend/` – Backend service exposed at `api.hidmo.leultewolde.com`
  - `microservices/` – Example microservice deployments (micro1, micro2) each
    with jobs to create their database and run Flyway migrations. SQL scripts are
    stored alongside the manifests in `.sql` files.
- `manifests/postgres/` – Holds `values.yaml` for the Bitnami PostgreSQL Helm chart and a `SealedSecret` with the database password.
- `apps/postgres.yaml` – Deploys the chart from the Bitnami repository using that values file. The `apps/postgres-secret.yaml` application syncs the credentials first so the Helm release can succeed.
- PostgreSQL is reachable at `postgres.leultewolde.com` for apps and tools
- SonarQube is reachable at `sonar.leultewolde.com` with persistent storage
- Jenkins is reachable at `jenkins.leultewolde.com` for CI/CD pipelines
- HashiCorp Vault UI is reachable at `vault.leultewolde.com` for managing secrets
- Argo Image Updater keeps `km-ingredients-service` up to date automatically via git write-back.

## Vault Installation

Sync the `vault` application from `apps/vault.yaml` to install the official Helm chart. The server starts sealed and the pod stays unready until you initialize and unseal it.

Initialize Vault (generates unseal keys and a root token):


```bash
kubectl exec -n vault vault-0 -- vault operator init -key-shares=5 -key-threshold=3
```

This prints five unseal keys and a root token. Store them in a safe location.

Unseal the pod (repeat for each unseal key):

```bash
kubectl exec -n vault vault-0 -- vault operator unseal <unseal-key>
```

Repeat the unseal command with at least three keys.

The readiness probes fail until unseal completes.

### Auto Unseal

For production clusters, configure the chart to use a cloud KMS provider so Vault can
unseal itself after restarts.  Specify the required credentials through
`server.extraEnvironmentVars` and add a `seal` block in the Helm values.  For example:

```yaml
server:
  extraEnvironmentVars:
    GOOGLE_REGION: global
    GOOGLE_PROJECT: myproject
  config: |
    seal "gcpckms" {
      project    = "myproject"
      region     = "global"
      key_ring   = "vault-unseal"
      crypto_key = "vault-key"
    }
```

With auto unseal configured, Vault starts ready without manually running `vault operator unseal`.

## Bootstrap

Create a bootstrap ArgoCD `Application` pointing to the `apps/` directory.


## License

This project is licensed under the [MIT License](LICENSE).
