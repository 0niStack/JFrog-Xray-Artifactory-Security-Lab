#!/usr/bin/env bash
# Builds the sample website images, pushes them to Artifactory (Xray scans on push),
# then prints the Xray scan summary for each image.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
REGISTRY="${REGISTRY:-localhost:8082}"
TAG="${TAG:-1.0.0}"
export REGISTRY TAG
BASE="http://localhost:8082"

echo "$JF_ADMIN_PASSWORD" | docker login "$REGISTRY" -u "$JF_ADMIN_USER" --password-stdin
docker compose -f sample-site/docker-compose.yml build
for img in sample-app sample-web; do
  docker push "$REGISTRY/docker-local/$img:$TAG"
done

echo ">> Waiting for Xray to index/scan (60s)..."; sleep 60
for img in sample-app sample-web; do
  echo; echo "=== $img:$TAG ==="
  out=$(curl -fsS -u "$JF_ADMIN_USER:$JF_ADMIN_PASSWORD" -H "Content-Type: application/json" \
    -X POST "$BASE/xray/api/v1/summary/artifact" \
    -d "{\"paths\":[\"default/docker-local/$img/$TAG/manifest.json\"]}")
  if command -v jq >/dev/null; then
    echo "$out" | jq '[.artifacts[0].issues[]?.severity] | group_by(.) | map({(.[0]): length}) | add'
  else
    echo "$out"
  fi
done
echo; echo "Full report: $BASE -> Xray -> Scans List -> Repositories -> docker-local"
