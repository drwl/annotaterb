#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./scripts/release.sh <version>"
  echo "Example: ./scripts/release.sh 4.3.1"
  exit 1
fi

VERSION=$1
BRANCH="drwl/release-$VERSION"

git checkout main
git pull origin main
git checkout -b "$BRANCH"

echo "$VERSION" > VERSION
git add VERSION
git commit -m "Bump version to v$VERSION"
git push -u origin HEAD

gh pr create \
  --title "Bump version to v$VERSION" \
  --body "Manually doing releases until an automated solution is put in place." \
  --base main

echo ""
echo "Once the PR is merged, run: ./scripts/publish.sh $VERSION"
