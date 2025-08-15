# ArgoCD GitOps Repo

This repository contains all Kubernetes manifests and ArgoCD application
definitions for the **Hidmo** environment. Jenkins tests every change against a
k3s cluster before allowing merges so that production infrastructure is never
affected by invalid configuration.

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
- Kafka broker available at the `kafka` service exposes topics for release, build, and notification events

## Kafka Events

A single-node Kafka broker runs inside the cluster and is reachable at the
`kafka` service on port `9092`. The release management service publishes
messages to two topics:

- `release.events.v1` (key: `releaseId`)
- `build.events.v1` (key: `buildId` or `releaseId` for co-partitioning)

The `notifications.outcomes.v1` topic is also created for downstream analytics.

Other services can consume or produce these events by configuring the following
environment variables:

| Variable | Value |
|----------|-------|
| `KAFKA_BOOTSTRAP_SERVERS` | `kafka:9092` |
| `KAFKA_RELEASE_EVENTS_TOPIC` | `release.events.v1` |
| `KAFKA_BUILD_EVENTS_TOPIC` | `build.events.v1` |
| `KAFKA_NOTIFICATIONS_OUTCOMES_TOPIC` | `notifications.outcomes.v1` |

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
| `secret/sonarqube/oidc` | `sonarqube-oidc` | `client-secret` |

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

## Jenkins Pipeline

The repository includes a `Jenkinsfile` that lints and validates all manifests before they reach your real cluster.

1. Create a new **Pipeline** job in Jenkins and point it at this Git repository (select **Pipeline script from SCM**).
2. Ensure the Jenkins agent can run Docker containers so the pipeline can use the `bitnami/kubectl` image to install tools.
3. Configure Jenkins with access to your **k3s** cluster so `kubectl` commands work (usually by providing a kubeconfig credential).
4. Add a GitHub webhook so pushes and pull requests trigger the job.
5. Enable branch protection in GitHub to require the Jenkins build to pass before merging.

The pipeline runs `yamllint`, `kubeconform`, and performs a dry-run deployment using an ephemeral k3s cluster started with `k3d`.

To test locally, run:

```bash
make test
```

## GitHub Repository Settings

Configure the repository on GitHub so Jenkins can enforce quality gates:

1. **Default branch** – set `main` (or your chosen branch) as the default.
2. **Branch protection** – require the Jenkins pipeline to succeed before merging.
3. **Webhooks** – add a webhook pointing to your Jenkins instance so new commits and pull requests trigger builds.
4. **Secrets** – store any credentials Jenkins needs (such as kubeconfig or GitHub tokens) as encrypted secrets in Jenkins, not in the repository.

