#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./scripts/release.sh <version>"
  echo "Example: ./scripts/release.sh 4.3.1"
  exit 1
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN is not set"
  exit 1
fi

VERSION=$1
BRANCH="drwl/release-$VERSION"

git checkout main
git pull origin main
git checkout -b "$BRANCH"

echo "$VERSION" > VERSION
github_changelog_generator -u drwl -p annotaterb --token "$GITHUB_TOKEN"
git add VERSION CHANGELOG.md
git commit -m "Release v$VERSION"
git push -u origin HEAD

gh pr create \
  --title "Release v$VERSION" \
  --body "Manually doing releases until an automated solution is put in place." \
  --base main

echo ""
echo "Once the PR is merged:"
echo "  git checkout main && git pull && bundle exec rake release"
