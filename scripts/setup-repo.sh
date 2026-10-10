#!/usr/bin/env bash
# À lancer une seule fois : clé de signature, secrets GitHub et branche "repo" où la CI publie.
set -euo pipefail

repo=obouhlel/manga-extensions
dir=${XDG_CONFIG_HOME:-$HOME/.config}/manga-extensions
keystore=$dir/signingkey.jks
alias=manga

read -rsp "Mot de passe de la clé de signature : " password
echo

if [[ ! -f $keystore ]]; then
    mkdir -p "$dir"
    keytool -genkeypair -keystore "$keystore" -storetype PKCS12 -alias "$alias" \
        -keyalg RSA -keysize 4096 -validity 36500 -dname "CN=$repo" \
        -storepass "$password" -keypass "$password"
    chmod 600 "$keystore"
fi

# Empreinte attendue par l'appli : SHA-256 du certificat DER, en hexadécimal minuscule.
fingerprint=$(keytool -exportcert -keystore "$keystore" -alias "$alias" -storepass "$password" | sha256sum | cut -d' ' -f1)

base64 -w0 "$keystore" | gh secret set SIGNING_KEY -R "$repo"
gh secret set ALIAS -R "$repo" --body "$alias"
gh secret set KEY_STORE_PASSWORD -R "$repo" --body "$password"
gh secret set KEY_PASSWORD -R "$repo" --body "$password"
gh variable set SIGNING_KEY_FINGERPRINT -R "$repo" --body "$fingerprint"

if ! git ls-remote --exit-code --heads origin repo >/dev/null; then
    tmp=$(mktemp -d)
    git -C "$tmp" init -q -b repo
    echo '{}' >"$tmp/index.json"
    git -C "$tmp" add index.json
    git -C "$tmp" commit -q -m "Initialisation du dépôt d'extensions"
    git -C "$tmp" push -q "$(git remote get-url origin)" repo
    rm -rf "$tmp"
fi

echo "Clé : $keystore"
echo "Empreinte : $fingerprint"
echo "Lien à ajouter dans l'appli : https://github.com/$repo/raw/repo/index.pb"
