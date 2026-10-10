#!/usr/bin/env bash
# Supprime de src/ toutes les extensions qui ne sont pas couvertes par keep.txt.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

keep=$(grep -vE '^[[:space:]]*(#|$)' keep.txt | sed 's:/*[[:space:]]*$::')

to_remove=()
for dir in src/*/*/; do
    ext=${dir%/}
    lang=${ext%/*}
    if ! grep -qxF -e "$lang" -e "$ext" <<<"$keep"; then
        to_remove+=("$ext")
    fi
done

if ((${#to_remove[@]})); then
    printf '%s\0' "${to_remove[@]}" | xargs -0 git rm -r -q -f --ignore-unmatch --
    printf '%s\0' "${to_remove[@]}" | xargs -0 rm -rf --
fi
find src -mindepth 1 -maxdepth 1 -type d -empty -delete

echo "${#to_remove[@]} extension(s) supprimée(s)."
