#!/usr/bin/env bash
# For maintainers: copy the skills from their sources, set the version, build one zip per skill and publish the zips on
# the CDN (cdn.smootify.io/skills/<version>/ and /<channel>/, the R2 bucket "smootify").
#
#   scripts/release.sh 2.0.0-beta.2 beta      # a beta
#   scripts/release.sh 2.0.0 latest           # a stable release
#
# Sources: the Figma and audit skills from the Smootify playbook (where their references are generated from the markup
# contract), the custom-script skill from smootify/scripts (the copy Smootify Studio reads). PLAYBOOK and SCRIPTS
# override their paths. Afterwards: commit, tag v<version>, push, and create the GitHub release with dist/*.zip.
set -euo pipefail
VERSION=${1:?version, such as 2.0.0-beta.2}
CHANNEL=${2:-beta}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PLAYBOOK=${PLAYBOOK:-$ROOT/../playbook}
SCRIPTS=${SCRIPTS:-$ROOT/../scripts}
cd "$ROOT"

for k in figma-annotate-smootify figma-to-webflow-smootify smootify-site-audit; do
  rm -rf "skills/$k" && cp -R "$PLAYBOOK/skills/$k" "skills/$k"
done
rm -rf skills/smootify-custom-script && cp -R "$SCRIPTS/skills/smootify-custom-script" skills/smootify-custom-script
find skills -name .DS_Store -delete

node -e '
  const fs = require("fs"); const p = ".claude-plugin/plugin.json";
  const j = JSON.parse(fs.readFileSync(p, "utf8")); j.version = process.argv[1];
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$VERSION"

rm -rf dist && mkdir dist
(cd skills && for k in *; do zip -qr "../dist/$k.zip" "$k" -x '*.DS_Store'; done)

for z in dist/*.zip; do
  for folder in "$VERSION" "$CHANNEL"; do
    npx wrangler r2 object put "smootify/skills/$folder/$(basename "$z")" --file "$z" --content-type application/zip --remote
  done
done
echo "Published $VERSION ($CHANNEL). Now: git commit, git tag v$VERSION, git push --follow-tags, gh release create v$VERSION dist/*.zip"
