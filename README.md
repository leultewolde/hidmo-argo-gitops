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
- `manifests/postgres/` – Contains a values file for the Bitnami PostgreSQL Helm chart and a `SealedSecret` for credentials.
- `apps/postgres.yaml` – Argo CD application that installs the chart using Helm. The `apps/postgres-secret.yaml` application applies the secret first so credentials exist before the release is deployed.
- PostgreSQL is reachable at `postgres.leultewolde.com` for apps and tools

## Bootstrap

Create a bootstrap ArgoCD `Application` pointing to the `apps/` directory.


## License

This project is licensed under the [MIT License](LICENSE).
