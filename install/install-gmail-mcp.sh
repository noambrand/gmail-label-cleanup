#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# One-time setup for the full Gmail MCP server (ArtyMcLabin/Gmail-MCP-Server,
# npm @artymclabin/gmail-mcp). Gives your assistant real Gmail FILTERS and
# 50-at-a-time labelling, which the built-in Gmail connectors cannot do.
#
# Nothing is uploaded anywhere except to Google. The server runs locally.
# Read INSTALL.md in this folder first if anything below is unclear.
# ---------------------------------------------------------------------------
set -u

KEYS_DIR="$HOME/.gmail-mcp"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo
echo "=========================================================="
echo "  Gmail MCP server - one-time setup"
echo "=========================================================="
echo

# --- 0. Node check ---------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
  echo "  Node.js is not installed, and this server needs it."
  echo "  Install Node 18 or newer from https://nodejs.org and run this again."
  exit 1
fi

# --- 1. OAuth client file --------------------------------------------------
echo "[1/4] Your Google OAuth client file."
echo
echo "  You need the JSON you downloaded from Google Cloud when you created an"
echo "  OAuth 2.0 client of type \"Desktop app\". See INSTALL.md if you have not"
echo "  made one yet."
echo

if [ -f "$HERE/gcp-oauth.keys.json" ]; then
  KEYS_SRC="$HERE/gcp-oauth.keys.json"
  echo "  Found gcp-oauth.keys.json next to this installer. Using it."
else
  printf "  Drag that JSON file into this window and press Enter\n  (or paste its full path): "
  read -r KEYS_SRC
  # strip surrounding quotes a drag-and-drop may have added
  KEYS_SRC="${KEYS_SRC%\"}"; KEYS_SRC="${KEYS_SRC#\"}"
  KEYS_SRC="${KEYS_SRC%\'}"; KEYS_SRC="${KEYS_SRC#\'}"
fi

if [ ! -f "$KEYS_SRC" ]; then
  echo
  echo "  Could not find that file. Nothing was changed. Run this again."
  exit 1
fi

mkdir -p "$KEYS_DIR"
cp -f "$KEYS_SRC" "$KEYS_DIR/gcp-oauth.keys.json" || {
  echo "  Could not copy the client file into $KEYS_DIR."
  exit 1
}
echo "  done."

# --- 2. Enable the Gmail API ----------------------------------------------
API_URL="https://console.cloud.google.com/apis/library/gmail.googleapis.com"
echo
echo "[2/4] Switching the Gmail API on for that Google Cloud project."
echo "  A browser page opens. Click the blue ENABLE button."
echo "  If it already says MANAGE, it is on and there is nothing to do."
echo
if command -v open >/dev/null 2>&1; then open "$API_URL"
elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$API_URL" >/dev/null 2>&1
else echo "  Open this yourself: $API_URL"
fi
printf "  When that is done, come back here and press Enter."
read -r _

# --- 3. Sign in ------------------------------------------------------------
echo
echo "[3/4] Google sign-in."
echo "  A browser tab opens. Choose the account whose mail you want sorted,"
echo "  click \"Continue\" past the unverified-app warning (it is your own app),"
echo "  then Allow."
echo
if ! npx -y @artymclabin/gmail-mcp auth; then
  echo
  echo "  Sign-in did not complete. The usual cause is that your Google address"
  echo "  is not listed under \"Test users\" on the OAuth consent screen."
  echo "  Add it there, then run this installer again."
  exit 1
fi

# --- 4. Register with Claude Code -----------------------------------------
echo
echo "[4/4] Registering the server with Claude Code as \"gmail-full\"..."
if command -v claude >/dev/null 2>&1; then
  claude mcp add -s user gmail-full -- npx -y @artymclabin/gmail-mcp
else
  echo
  echo "  Claude Code is not on your PATH, so this step was skipped."
  echo "  Sign-in above still succeeded. Add the server to your MCP client by"
  echo "  hand using the JSON snippet at the bottom of INSTALL.md."
fi

echo
echo "=========================================================="
echo "  Done."
echo
echo "  RESTART your assistant now. The new tools are not visible"
echo "  in the session that installed them."
echo "=========================================================="
echo
