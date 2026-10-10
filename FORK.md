# manga-extensions

Fork de [keiyoushi/extensions-source](https://github.com/keiyoushi/extensions-source) qui ne garde
que les sources `fr`, `en` et `all`, pour avoir un ensemble d'extensions plus simple et plus stable.

## Ajouter le dépôt dans l'appli

```
https://github.com/obouhlel/manga-extensions/raw/repo/index.pb
```

La CI (`build_push.yml`) compile les extensions modifiées à chaque push sur `main`, publie les APK
en releases et met à jour la branche `repo`. Les APK sont signés avec ma propre clé : une extension
installée depuis keiyoushi doit être désinstallée avant d'installer la mienne.

Mise en place, une seule fois : `scripts/setup-repo.sh` (clé dans `~/.config/manga-extensions/`,
secrets et variable GitHub, branche `repo`), puis lancer le workflow CI à la main avec
`full_rebuild` :

```sh
gh workflow run build_push.yml -f full_rebuild=true
```

## Choisir les extensions gardées

`keep.txt` liste ce qui est gardé : une langue entière (`src/fr`) ou une seule extension
(`src/fr/animesama`). Après une modification :

```sh
scripts/prune.sh
git commit -am "Tri des extensions"
```

Pour réintégrer une extension supprimée : ajoute-la dans `keep.txt`, puis
`git checkout upstream/main -- src/<lang>/<extension>`.

## Récupérer les mises à jour de keiyoushi

```sh
scripts/sync-upstream.sh
git push
```

Le script fusionne `upstream/main` puis réapplique `keep.txt`, ce qui règle tout seul les conflits
sur les extensions retirées. S'il reste d'autres conflits, il les liste et s'arrête.

## Proposer un correctif à keiyoushi

Les PR partent de `upstream/main`, jamais de `main` (qui a supprimé les autres langues) :

```sh
git fetch upstream
git switch -c fix/xxx upstream/main
# ... corrige, commite ...
git push -u origin fix/xxx
gh pr create --repo keiyoushi/extensions-source --head obouhlel:fix/xxx
```

## Compiler une extension

```sh
JAVA_HOME=/usr/lib/jvm/java-21-openjdk ./gradlew :src:fr:animesama:assembleDebug
```

Nécessite le SDK Android et `local.properties` (`sdk.dir=...`).
