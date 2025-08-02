#!/usr/bin/env bash
set -euo pipefail

# Lint YAML files
if ! command -v yamllint >/dev/null 2>&1; then
  echo "yamllint is not installed" >&2
  exit 1
fi

yamllint manifests apps projects

# Validate manifests
if ! command -v kubeconform >/dev/null 2>&1; then
  echo "kubeconform is not installed" >&2
  exit 1
fi

kubeconform $(find manifests apps projects -name '*.yaml')

# Dry-run deployment using k3d (k3s in Docker)
if command -v k3d >/dev/null 2>&1; then
  k3d cluster create test --wait
  kubectl apply --dry-run=client -k manifests
  k3d cluster delete test
else
  echo "k3d is not installed; skipping dry-run deployment" >&2
  exit 1
fi
