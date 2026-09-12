#!/usr/bin/env bash
# Run this locally after extracting the source ZIP. Git handles your own login.
set -euo pipefail
cd "$(dirname "$0")/.."
target_repo="https://github.com/Judithandprey/hackthon-project.git"
if [ ! -d .git ]; then
  git init -b main
fi
if [ "$(git branch --show-current)" != "main" ]; then
  echo "Please switch this project to its main branch before publishing."
  exit 1
fi
if git remote get-url origin >/dev/null 2>&1; then
  if [ "$(git remote get-url origin)" != "$target_repo" ]; then
    echo "This directory points to a different repository. Stopping without pushing."
    exit 1
  fi
else
  git remote add origin "$target_repo"
fi
git add -- .
if ! git diff --cached --quiet; then
  git -c user.name="Yisha Tang" -c user.email="298976586+Judithandprey@users.noreply.github.com" commit -m "Build CS169 Rails hackathon portal"
fi
git push -u origin main
