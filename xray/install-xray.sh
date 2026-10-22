#!/usr/bin/env bash
# Downloads JFrog's official Xray docker-compose installer, runs its config wizard,
# and starts Xray. Run AFTER Artifactory is healthy and licensed.
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
: "${XRAY_VERSION:?Set XRAY_VERSION in .env (see docs/02-install.md)}"

DIR=xray/installer
URL="https://releases.jfrog.io/artifactory/jfrog-xray/xray-compose/${XRAY_VERSION}/jfrog-xray-${XRAY_VERSION}-compose.tar.gz"
mkdir -p "$DIR"

if [ ! -f "$DIR/config.sh" ]; then
  echo ">> Downloading $URL"
  tmp=$(mktemp)
  if ! curl -fL "$URL" -o "$tmp"; then
    echo "Download failed. Download the *-compose.tar.gz manually from JFrog and extract it into $DIR" >&2
    exit 1
  fi
  tar -xzf "$tmp" -C "$DIR" --strip-components=1
  rm -f "$tmp"
fi

cat <<MSG

>> The Xray wizard (config.sh) will ask for values. Use:
   JFrog URL (jfrogUrl) : http://${HOST_IP}:8082
   Join key             : ${JOIN_KEY}
   Database             : bundled PostgreSQL is fine for a lab
   (Answer the remaining prompts with defaults, or see the installer's README.)

MSG
( cd "$DIR" && ./config.sh )

if docker compose version >/dev/null 2>&1; then DC="docker compose"; else DC="docker-compose"; fi
cd "$DIR"
FILES="-f docker-compose.yaml"
for f in docker-compose-postgres.yaml docker-compose-rabbitmq.yaml; do
  if [ -f "$f" ]; then
    read -rp "Include $f (bundled service)? [Y/n] " a
    [[ "${a:-Y}" =~ ^[Yy] ]] && FILES="$FILES -f $f"
  fi
done
echo ">> $DC -p xray $FILES up -d"
$DC -p xray $FILES up -d
echo "Xray is starting. Follow logs: $DC -p xray logs -f"
