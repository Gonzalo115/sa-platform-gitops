#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for chart in "$ROOT"/charts/*; do
  helm lint "$chart"
done

helm lint "$ROOT/bootstrap"
helm lint "$ROOT/platform/foundation"
helm lint "$ROOT/platform/data"
helm lint "$ROOT/platform/backup"

helm dependency build "$ROOT/environments/prod"
helm lint --with-subcharts "$ROOT/environments/prod" \
  -f "$ROOT/environments/prod/values-prod.yaml"

rendered="$(mktemp)"
trap 'rm -f "$rendered"' EXIT

helm template sa-platform-prod "$ROOT/environments/prod" \
  -f "$ROOT/environments/prod/values-prod.yaml" \
  --namespace sa-p8 >"$rendered"

[[ "$(grep -c 'kind: Rollout' "$rendered")" -eq 7 ]]
[[ "$(grep -c 'preferredDuringSchedulingIgnoredDuringExecution' "$rendered")" -eq 7 ]]

if grep -q 'kind: SealedSecret' "$rendered"; then
  echo "ERROR: P9 no debe depender de una clave Sealed Secrets del cluster destruido"
  exit 1
fi

if grep -rE '[i]mage:.*:latest' "$ROOT"; then
  echo "ERROR: latest esta prohibido"
  exit 1
fi

if grep -rE '^[[:space:]]*(password|passwd|token|apiKey|secretKey|clientSecret)[[:space:]]*:[[:space:]]*[^ {$]' "$ROOT"; then
  echo "ERROR: posible secreto en texto plano"
  exit 1
fi

echo "Repositorio GitOps validado."
