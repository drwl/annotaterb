#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./scripts/publish.sh <version>"
  echo "Example: ./scripts/publish.sh 4.3.1"
  exit 1
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN is not set"
  exit 1
fi

VERSION=$1
BRANCH="drwl/changelog-$VERSION"

git checkout main
git pull origin main

bundle exec rake release

git checkout -b "$BRANCH"
github_changelog_generator -u drwl -p annotaterb --token "$GITHUB_TOKEN"
git add CHANGELOG.md
git commit -m "Generate changelog for v$VERSION"
git push -u origin HEAD

gh pr create \
  --title "Generate changelog for v$VERSION" \
  --body "Manually generating changelogs for the time being." \
  --base main
