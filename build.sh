#!/usr/bin/env bash
# Build adblock-hosts module zip from the latest StevenBlack unified hosts list.
# Output: dist/adblock-hosts.zip, dist/update.json, dist/hosts.sha256, CHANGELOG.md
set -euo pipefail
cd "$(dirname "$0")"
OWNER_REPO="${GITHUB_REPOSITORY:-gurupungx2-lgtm/adblock-hosts}"
RAW="https://raw.githubusercontent.com/${OWNER_REPO}/main"
SRC_URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

mkdir -p dist build/system/etc
curl -sSL --retry 3 -o build/hosts_src "$SRC_URL"

LIST_DATE=$(grep -m1 '^# Date:' build/hosts_src | sed 's/^# Date: //; s/ (UTC)//')
{
  echo "127.0.0.1 localhost"
  echo "::1 localhost"
  grep -E '^0\.0\.0\.0 ' build/hosts_src | grep -v '^0\.0\.0\.0 0\.0\.0\.0$' | sed 's/[[:space:]]*#.*$//' | awk '{print $1" "$2}'
} > build/system/etc/hosts
N=$(grep -c '^0\.0\.0\.0 ' build/system/etc/hosts)
SHA=$(sha256sum build/system/etc/hosts | cut -d' ' -f1)

# Skip rebuild if list unchanged (keeps versionCode stable)
if [ -f dist/hosts.sha256 ] && [ "$(cat dist/hosts.sha256)" = "$SHA" ] && [ "${FORCE:-0}" != "1" ]; then
  echo "unchanged ($N domains) - nothing to do"; exit 0
fi

# versionCode = YYYYMMDD + 3-hour slot (0-7) -> always increases, even for same-day rebuilds. e.g. 202611035
SLOT=$(( 10#$(date -u +%H) / 3 ))
VCODE="$(date -u +%Y%m%d)${SLOT}"
VER="v$(date -u +%Y.%m.%d)"; [ "$SLOT" != "0" ] && VER="${VER}.${SLOT}"

cat > build/module.prop <<PROP
id=adblock_hosts
name=Adblock Hosts (systemless)
version=${VER}
versionCode=${VCODE}
author=gurupungx2-lgtm
description=Systemless hosts blocking ads, trackers, phishing for ALL apps (StevenBlack unified ${LIST_DATE}, ${N} domains). Auto-updates weekly. Toggle off in KernelSU to revert.
updateJson=${RAW}/dist/update.json
PROP
cp module/post-fs-data.sh build/post-fs-data.sh; chmod 755 build/post-fs-data.sh

rm -f dist/adblock-hosts.zip
( cd build && zip -q -r ../dist/adblock-hosts.zip module.prop post-fs-data.sh system )
echo "$SHA" > dist/hosts.sha256

cat > dist/update.json <<JSON
{
  "version": "${VER}",
  "versionCode": ${VCODE},
  "zipUrl": "${RAW}/dist/adblock-hosts.zip",
  "changelog": "${RAW}/CHANGELOG.md"
}
JSON

{ echo "## ${VER}  (list: ${LIST_DATE} UTC)"; echo "- ${N} blocked domains (StevenBlack unified)"; echo; cat CHANGELOG.md 2>/dev/null || true; } > CHANGELOG.tmp
mv CHANGELOG.tmp CHANGELOG.md
echo "built ${VER} (${VCODE}) - ${N} domains"
