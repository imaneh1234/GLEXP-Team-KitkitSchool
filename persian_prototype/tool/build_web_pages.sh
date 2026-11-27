#!/usr/bin/env bash
# Builds the web version for GitHub Pages and copies it to /docs at the
# repository root (GitHub Pages: Settings → Pages → branch + /docs).
#
# --no-web-resources-cdn puts everything the app needs on our own site, so
# nothing is loaded from Google's servers: faster where those are slow or
# blocked, and it keeps working offline once opened.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO_NAME="GLEXP-Team-KitkitSchool"
flutter build web --release --no-web-resources-cdn --base-href "/${REPO_NAME}/"
rm -rf ../docs
cp -r build/web ../docs
find ../docs -name "*.symbols" -delete   # debug symbols, not needed to run
touch ../docs/.nojekyll   # serve every file exactly as built
echo "Web version copied to ../docs"
