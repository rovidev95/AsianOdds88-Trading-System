#!/usr/bin/env bash
# AsianOdds88 Trading System - One-command installer (Linux)
# Downloads the latest release from GitHub and extracts it. No source code in the repo.
# Run: curl -sSL https://raw.githubusercontent.com/rovidev95/AsianOdds88-Trading-System/main/install.sh | bash
set -e
REPO="rovidev95/AsianOdds88-Trading-System"
ASSET_NAME="AsianOdds88-Linux.tar.gz"
API="https://api.github.com/repos/$REPO/releases/latest"

echo "AsianOdds88 Trading System - Installer"
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
DEST_DIR="${DEST_DIR:-.}"
echo "Downloading $URL ..."
TMP=$(mktemp -d)
curl -sL -o "$TMP/$ASSET_NAME" "$URL"
echo "Extracting..."
tar xzf "$TMP/$ASSET_NAME" -C "$DEST_DIR"
rm -rf "$TMP"
FOLDER="$DEST_DIR/AsianOdds88"
echo ""
echo "Done. Installed to: $FOLDER"
echo ""
echo "Next steps:"
echo "  1. Put your license: export KETER_LICENSE_KEY=your_jwt  OR  echo 'your_jwt' > $FOLDER/local/.keter_license"
echo "  2. Copy $FOLDER/.env.example to $FOLDER/.env and set EXECUTION_MODE, REDIS_HOST, etc."
echo "  3. Ensure Redis is running (localhost:6379)."
echo "  4. Run: cd $FOLDER && ./start.sh"
echo ""
