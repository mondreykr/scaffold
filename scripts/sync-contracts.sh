#!/usr/bin/env sh
# Sync the factory contracts/ into the scaffold-audit skill's references/.
#
# The audit skill grades a user's docs against the EXACT contract, so it ships a
# verbatim copy of every contract in references/. contracts/ is the master; the
# copies are derived. Direction is one-way (master -> copy), never the reverse.
#
#   scripts/sync-contracts.sh           copy contracts/*.md -> skills/scaffold-audit/references/
#   scripts/sync-contracts.sh --check   verify the copies match the masters; exit 1 on drift; changes nothing
#
# Run --check before committing (and in CI, if there is one): it is the guard that
# keeps the shipped copies from silently drifting from the masters.
set -e
repo="$(cd "$(dirname "$0")/.." && pwd)"
src="$repo/contracts"
dst="$repo/skills/scaffold-audit/references"

if [ "$1" = "--check" ]; then
    rc=0
    for f in "$src"/*.md; do
        name="$(basename "$f")"
        if ! cmp -s "$f" "$dst/$name"; then
            echo "DRIFT: $name differs from contracts/ (run scripts/sync-contracts.sh)"
            rc=1
        fi
    done
    for f in "$dst"/*.md; do
        name="$(basename "$f")"
        [ -f "$src/$name" ] || { echo "STRAY: references/$name has no matching contract"; rc=1; }
    done
    [ "$rc" -eq 0 ] && echo "contracts in sync ($(ls "$src"/*.md | wc -l | tr -d ' ') files)"
    exit "$rc"
fi

mkdir -p "$dst"
cp "$src"/*.md "$dst"/
echo "synced $(ls "$src"/*.md | wc -l | tr -d ' ') contracts -> skills/scaffold-audit/references/"
