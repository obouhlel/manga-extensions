#!/usr/bin/env bash
# Récupère les nouveautés de keiyoushi (remote "upstream") puis réapplique keep.txt.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [[ -n $(git status --porcelain) ]]; then
    echo "Le dépôt a des modifications non commitées, commite-les d'abord." >&2
    exit 1
fi

git fetch upstream
# Les conflits "modifié/supprimé" sur les extensions retirées sont attendus : prune.sh les règle.
git merge --no-ff --no-commit upstream/main || true

if ! git rev-parse -q --verify MERGE_HEAD >/dev/null; then
    echo "Déjà à jour."
    exit 0
fi

scripts/prune.sh

conflicts=$(git diff --name-only --diff-filter=U)
if [[ -n $conflicts ]]; then
    echo "Conflits à résoudre à la main, puis 'git commit' :" >&2
    echo "$conflicts" >&2
    exit 1
fi

git commit --no-edit
echo "Synchronisé avec upstream/main."
