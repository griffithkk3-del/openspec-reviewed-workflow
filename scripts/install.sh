#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 /path/to/target-project" >&2
  exit 1
}

if [ "$#" -ne 1 ]; then
  usage
fi

TARGET_INPUT="$1"

if [ ! -d "$TARGET_INPUT" ]; then
  echo "Target project does not exist: $TARGET_INPUT" >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
TARGET_DIR=$(CDPATH= cd -- "$TARGET_INPUT" && pwd)

SCHEMA_SRC="$REPO_ROOT/openspec/schemas/spec-driven-reviewed"
SKILL_SRC="$REPO_ROOT/.cursor/skills/openspec-review-proposal"
SCHEMA_DEST="$TARGET_DIR/openspec/schemas/spec-driven-reviewed"
SKILL_DEST="$TARGET_DIR/.cursor/skills/openspec-review-proposal"
CONFIG_DEST="$TARGET_DIR/openspec/config.yaml"

if [ ! -d "$SCHEMA_SRC" ]; then
  echo "Missing schema source: $SCHEMA_SRC" >&2
  exit 1
fi

if [ ! -d "$SKILL_SRC" ]; then
  echo "Missing skill source: $SKILL_SRC" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR/openspec/schemas"
rm -rf "$SCHEMA_DEST"
cp -R "$SCHEMA_SRC" "$SCHEMA_DEST"

mkdir -p "$TARGET_DIR/.cursor/skills"
rm -rf "$SKILL_DEST"
cp -R "$SKILL_SRC" "$SKILL_DEST"

mkdir -p "$TARGET_DIR/openspec"

if [ -f "$CONFIG_DEST" ]; then
  TMP_CONFIG=$(mktemp)
  python3 - "$CONFIG_DEST" "$TMP_CONFIG" <<'PY'
from pathlib import Path
import re
import sys

source = Path(sys.argv[1]).read_text()
target = Path(sys.argv[2])

lines = source.splitlines()
updated = []
schema_written = False

for line in lines:
    if re.match(r"^\s*schema\s*:", line):
        if not schema_written:
            updated.append("schema: spec-driven-reviewed")
            schema_written = True
        continue
    updated.append(line)

if not schema_written:
    updated = ["schema: spec-driven-reviewed", ""] + updated

target.write_text("\n".join(updated).rstrip() + "\n")
PY
  mv "$TMP_CONFIG" "$CONFIG_DEST"
else
  cat > "$CONFIG_DEST" <<'EOF'
schema: spec-driven-reviewed
EOF
fi

echo "Installed spec-driven-reviewed workflow into: $TARGET_DIR"
echo "Updated schema default in: $CONFIG_DEST"
