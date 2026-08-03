#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SUBJECT="$1"

YEAR=$(date +"%Y")
SUBJECT_TITLE="${SUBJECT#*_}"
SUBJECT_TITLE="${SUBJECT_TITLE//_/ }"
LOCAL_CONFIG="$ROOT/config.md"
DEFAULT_CONFIG="$ROOT/_shared/config/config-template.md"
if [ -f "$LOCAL_CONFIG" ]; then
  CONFIG="$LOCAL_CONFIG"
else
  CONFIG="$DEFAULT_CONFIG"
fi
CONFIG_METADATA=$(mktemp "${TMPDIR:-/tmp}/tul-notes-config.XXXXXX")
trap 'rm -f "$CONFIG_METADATA"' EXIT

case "$SUBJECT" in
  00_Obecne_vedomosti)
    SUBJECT_TITLE="Obecné vědomosti"
    ;;
  01_HPM)
    SUBJECT_TITLE="HPM - hydraulické a pneumatické mechanismy"
    ;;
  02_DR)
    SUBJECT_TITLE="DR - diferenciální rovnice"
    ;;
  03_ELMG)
    SUBJECT_TITLE="ELMG - elektromagnetismus"
    ;;
  04_OPT)
    SUBJECT_TITLE="OPT - optimalizační metody"
    ;;
  05_ESY)
    SUBJECT_TITLE="ESY - elektronické systémy"
    ;;
  06_RBT)
    SUBJECT_TITLE="RBT - robotika"
    ;;
  07_ESV)
    SUBJECT_TITLE="ESV"
    ;;
  08_TD)
    SUBJECT_TITLE="TD - technická diagnostika"
    ;;
  09_AVAS)
    SUBJECT_TITLE="AVAS - autonomní vozidla a asistenční systémy"
    ;;
esac

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Chyba: pandoc není dostupný v PATH." >&2
  echo "Nainstaluj pandoc nebo ho přidej do PATH a spusť skript znovu." >&2
  exit 127
fi

if ! command -v xelatex >/dev/null 2>&1; then
  echo "Chyba: xelatex není dostupný v PATH." >&2
  echo "Nainstaluj MacTeX/BasicTeX nebo přidej xelatex do PATH a spusť skript znovu." >&2
  exit 127
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Chyba: python3 není dostupný v PATH." >&2
  exit 127
fi

python3 "$ROOT/_shared/build/read-notes-config.py" "$CONFIG" "$CONFIG_METADATA"

SUBJECT_CODE="${SUBJECT#*_}"
SUBJECT_CODE="${SUBJECT_CODE%%_*}"
AUTHOR_FILE_PART=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["author-file-part"])' "$CONFIG_METADATA")
OUTPUT_PDF="$ROOT/$SUBJECT/${SUBJECT_CODE}_${AUTHOR_FILE_PART}_notes.pdf"

export TEXINPUTS="$ROOT/_shared/tul//:"
export SUBJECT_PATH="$ROOT/$SUBJECT"
export PYTHONDONTWRITEBYTECODE=1

(
  cd "$ROOT/_shared/tul"
  pandoc \
    --from=markdown-yaml_metadata_block \
    --metadata-file="$ROOT/_shared/metadata/notes.yaml" \
    --metadata-file="$CONFIG_METADATA" \
    --metadata subject-title="$SUBJECT_TITLE" \
    --metadata year="$YEAR" \
    "$ROOT/$SUBJECT"/*.md \
    --resource-path="$ROOT:$ROOT/$SUBJECT:$ROOT/$SUBJECT/Graphs:$ROOT/$SUBJECT/Images" \
    --lua-filter="$ROOT/_shared/filters/wikilinks.lua" \
    --lua-filter="$ROOT/_shared/filters/tables.lua" \
    --lua-filter="$ROOT/_shared/filters/remove-hr.lua" \
    --lua-filter="$ROOT/_shared/filters/svg-to-png.lua" \
    --template="$ROOT/_shared/templates/notes.tex" \
    --pdf-engine=xelatex \
    --pdf-engine-opt=--shell-escape \
    -o "$OUTPUT_PDF"
)

echo "$OUTPUT_PDF"
