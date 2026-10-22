#!/usr/bin/env bash
# Creates a docker-local repo, enables Xray indexing on it, and creates a
# security policy + watch so pushed images are scanned and violations reported.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
BASE="http://localhost:8082"
AUTH=(-u "${JF_ADMIN_USER}:${JF_ADMIN_PASSWORD}" -H "Content-Type: application/json")

echo ">> Creating docker-local repository"
curl -fsS "${AUTH[@]}" -X PUT "$BASE/artifactory/api/repositories/docker-local" -d '{
  "key":"docker-local","rclass":"local","packageType":"docker",
  "dockerApiVersion":"V2","xrayIndex":true}' || echo "(repo may already exist)"
echo

echo ">> Indexing docker-local in Xray"
curl -fsS "${AUTH[@]}" -X POST "$BASE/xray/api/v1/binMgr/default/repos" -d '{
  "indexed_repos":[{"name":"docker-local","type":"local","pkg_type":"Docker"}]}' || true
echo

echo ">> Creating security policy"
curl -fsS "${AUTH[@]}" -X POST "$BASE/xray/api/v2/policies" -d '{
  "name":"block-high-and-critical","type":"security",
  "description":"Flag High+ vulnerabilities",
  "rules":[{"name":"high-plus","priority":1,
    "criteria":{"min_severity":"high"},
    "actions":{"block_download":{"active":true,"unscanned":false},
               "fail_build":true,"notify_watch_recipients":false,
               "create_ticket_enabled":false}}]}' || echo "(policy may already exist)"
echo

echo ">> Creating watch"
curl -fsS "${AUTH[@]}" -X POST "$BASE/xray/api/v2/watches" -d '{
  "general_data":{"name":"docker-local-watch","description":"Watch docker-local","active":true},
  "project_resources":{"resources":[{"type":"repository","bin_mgr_id":"default","name":"docker-local","repo_type":"local"}]},
  "assigned_policies":[{"name":"block-high-and-critical","type":"security"}]}' || echo "(watch may already exist)"
echo
echo "Done. Open http://localhost:8082 -> Xray."
