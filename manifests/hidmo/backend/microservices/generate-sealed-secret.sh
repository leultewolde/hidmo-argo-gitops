#!/bin/bash

# === CONFIG ===
SECRET_NAME="postgres-credentials"
SOURCE_NAMESPACE="hidmo"           # Where the original secret exists
TARGET_NAMESPACE="hidmo"            # Where you want to apply the SealedSecret
OUTPUT_FILE="secret.yaml"
SCOPE="namespace-wide"             # Options: strict | namespace-wide | cluster-wide

# === VALIDATION ===
echo "🔍 Checking if secret '$SECRET_NAME' exists in namespace '$SOURCE_NAMESPACE'..."
if ! kubectl get secret "$SECRET_NAME" -n "$SOURCE_NAMESPACE" &>/dev/null; then
  echo "❌ Secret '$SECRET_NAME' not found in namespace '$SOURCE_NAMESPACE'"
  exit 1
fi

# === SEAL THE SECRET ===
echo "🔐 Sealing secret for namespace '$TARGET_NAMESPACE' with scope '$SCOPE'..."
kubectl get secret "$SECRET_NAME" -n "$SOURCE_NAMESPACE" -o yaml \
| kubeseal --format=yaml --scope "$SCOPE" \
| sed "s/namespace: $SOURCE_NAMESPACE/namespace: $TARGET_NAMESPACE/" \
> "$OUTPUT_FILE"

echo "✅ SealedSecret saved to $OUTPUT_FILE"
