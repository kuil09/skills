#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <vendor|community> <skill-name>"
  exit 1
fi

TARGET="$1"
SKILL_NAME="$2"

if [[ ! "$SKILL_NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: skill-name must match ^[a-z0-9-]+$"
  exit 1
fi

case "$TARGET" in
  openai|anthropic|google|meta|microsoft)
    DEST="vendors/$TARGET/skills/$SKILL_NAME"
    ;;
  community)
    DEST="community/skills/$SKILL_NAME"
    ;;
  *)
    echo "Error: target must be one of: openai, anthropic, google, meta, microsoft, community"
    exit 1
    ;;
esac

if [[ -e "$DEST" ]]; then
  echo "Error: destination already exists: $DEST"
  exit 1
fi

mkdir -p "$DEST/agents"
cp templates/skill-starter/SKILL.md "$DEST/SKILL.md"
cp templates/skill-starter/agents/openai.yaml "$DEST/agents/openai.yaml"

sed -i "s/your-skill-name/$SKILL_NAME/g" "$DEST/SKILL.md"
sed -i "s/Your Skill Name/$SKILL_NAME/g" "$DEST/agents/openai.yaml"

echo "Created: $DEST"
