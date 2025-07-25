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
  - Sonatype Nexus Repository Pro is reachable at `nexus.leultewolde.com` for storing artifacts via Sonatype's `nxrm-ha` Helm chart
- HashiCorp Vault UI is reachable at `vault.leultewolde.com` for managing secrets
- Argo Image Updater keeps `km-ingredients-service` up to date automatically via git write-back.

## Vault Secrets

Create the following secrets in HashiCorp Vault under the `kv` engine. Argo's Vault Operator will sync them to Kubernetes using the `VaultStaticSecret` resources in this repo.

| Vault path | Kubernetes secret | Keys |
|------------|------------------|------|
| `secret/hidmo/vault-token` | `vault-token` | `VAULT_TOKEN` |
| `secret/hidmo/postgres-credentials` | `postgres-credentials` | `postgres-password`, `username` |
| `secret/postgres/postgres-credentials` | `postgres-credentials` | `postgres-password` |
| `secret/postgres-staging/postgres-credentials` | `postgres-credentials` | `postgres-password` |
| `secret/postgres-systemtest/postgres-credentials` | `postgres-credentials` | `postgres-password` |
| `secret/sonarqube/monitoring` | `sonarqube-monitoring` | `passcode` |
| `secret/sonarqube/oidc` | `sonarqube-oidc` | `secret.properties` |
| `secret/argocd/oidc` | `argocd-secret` | `oidc.keycloak.clientSecret` |

Each namespace also requires a `VaultConnection` named `my-vault-connection` and
a corresponding `VaultAuth` so Vault secrets can be synced. Example connection:

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: my-vault-connection
  namespace: <namespace>
spec:
  address: https://vault.leultewolde.com
  skipTLSVerify: false
```

Example `VaultAuth` referencing that connection:

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: my-vault-connection
  namespace: <namespace>
spec:
  vaultConnectionRef: my-vault-connection
  method: kubernetes
  mount: kubernetes
  kubernetes:
    role: demo
    serviceAccount: default
```
## Bootstrap

Create a bootstrap ArgoCD `Application` pointing to the `apps/` directory.


## License

This project is licensed under the [MIT License](LICENSE).

## Security Notes

The `hidmo-backend` deployment now binds Kong's Admin API to `127.0.0.1` so it
cannot be reached from other pods. Only the proxy ports are exposed via the
`hidmo-backend` service and Ingress.
