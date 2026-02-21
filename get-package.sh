#!/usr/bin/env bash
# Download the latest AsianOdds88 Trading System package for Linux from GitHub Releases.
# Run from the folder where you want the package. Requires: curl.
set -e
REPO="rovidev95/AsianOdds88-Trading-System"
ASSET_NAME="AsianOdds88-Linux.tar.gz"
API="https://api.github.com/repos/$REPO/releases/latest"
echo "Fetching latest release..."
JSON=$(curl -sL -H "Accept: application/vnd.github.v3+json" "$API")
if command -v jq &>/dev/null; then
  URL=$(echo "$JSON" | jq -r --arg n "$ASSET_NAME" '.assets[] | select(.name == $n) | .browser_download_url')
elif command -v python3 &>/dev/null; then
  URL=$(echo "$JSON" | python3 -c "import sys,json; a=json.load(sys.stdin).get('assets',[]); u=[x['browser_download_url'] for x in a if x.get('name')==\"$ASSET_NAME\"]; print(u[0] if u else '')")
else
  URL=$(echo "$JSON" | grep -o "\"browser_download_url\": \"[^\"]*$ASSET_NAME\"" | head -1 | sed 's/.*": "\(.*\)".*/\1/')
fi
if [ -z "$URL" ] || [ "$URL" = "null" ]; then
  echo "Asset '$ASSET_NAME' not found in latest release." >&2
  exit 1
fi
OUT="$ASSET_NAME"
echo "Downloading $URL ..."
curl -sL -o "$OUT" "$URL"
echo "Saved: $OUT"
echo "Extract: tar xzf $OUT, then set license (KETER_LICENSE_KEY or local/.keter_license), copy .env.example to .env, and run ./AsianOdds88/start.sh"
