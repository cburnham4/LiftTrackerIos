#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXP="$ROOT/marketing/app-store-screenshots/exported-store-screenshots"
OUT="$ROOT/fastlane/screenshots/en-US"
mkdir -p "$OUT"
i=1
for f in "$EXP"/0[1-5]-*-1320x2868.png; do
  cp "$f" "$OUT/iPhone 6.9\" Display-$(printf '%02d' $i).png"
  i=$((i+1))
done
echo "Synced to $OUT"
