#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for chart in "$ROOT"/charts/*; do
  helm lint "$chart"
done

helm dependency build "$ROOT/environments/prod"
helm lint --with-subcharts "$ROOT/environments/prod" \
  -f "$ROOT/environments/prod/values-prod.yaml"

if grep -rE '[i]mage:.*:latest' "$ROOT"; then
  echo "ERROR: latest esta prohibido"
  exit 1
fi

if grep -rE '^[[:space:]]*(password|passwd|token|apiKey|secretKey|clientSecret)[[:space:]]*:[[:space:]]*[^ {$]' "$ROOT"; then
  echo "ERROR: posible secreto en texto plano"
  exit 1
fi

echo "Repositorio GitOps validado."
