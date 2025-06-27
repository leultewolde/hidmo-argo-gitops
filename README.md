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
- `manifests/postgres/` – Configures the Bitnami PostgreSQL Helm chart and stores a `SealedSecret` for credentials
- `apps/postgres.yaml` – ArgoCD application deploying the PostgreSQL database
- PostgreSQL is reachable at `postgres.leultewolde.com` for apps and tools

## Bootstrap

Create a bootstrap ArgoCD `Application` pointing to the `apps/` directory.
