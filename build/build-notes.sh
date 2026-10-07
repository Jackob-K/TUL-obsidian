#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

usage() {
  echo "Použití:" >&2
  echo "  $(basename "$0") <SLOŽKA_PŘEDMĚTU>" >&2
  echo "  $(basename "$0") <SLOŽKA_PŘEDMĚTU> --folder <PODSLOŽKA>" >&2
  echo "  $(basename "$0") --file <CESTA_K_POZNÁMCE.md>" >&2
}

SINGLE_FILE=false
SELECTED_FOLDER=""
INPUT_FILE=""

if [ "$#" -eq 1 ] && [ "$1" != "--file" ]; then
  SUBJECT_PATH="$ROOT/$1"
elif [ "$#" -eq 2 ] && [ "$1" = "--file" ]; then
  SINGLE_FILE=true
  case "$2" in
    /*) RAW_INPUT_FILE="$2" ;;
    *) RAW_INPUT_FILE="$ROOT/$2" ;;
  esac

  if [ ! -f "$RAW_INPUT_FILE" ]; then
    echo "Chyba: Markdown soubor neexistuje: $2" >&2
    exit 2
  fi
  case "$RAW_INPUT_FILE" in
    *.md) ;;
    *)
      echo "Chyba: pro export jednoho souboru je podporován pouze soubor .md." >&2
      exit 2
      ;;
  esac

  INPUT_FILE="$(cd "$(dirname "$RAW_INPUT_FILE")" && pwd)/$(basename "$RAW_INPUT_FILE")"
  SUBJECT_PATH="$(dirname "$INPUT_FILE")"
elif [ "$#" -eq 3 ] && [ "$2" = "--folder" ]; then
  SUBJECT_PATH="$ROOT/$1"
  SELECTED_FOLDER="$3"
else
  usage
  exit 2
fi

if [ ! -d "$SUBJECT_PATH" ]; then
  echo "Chyba: složka předmětu neexistuje: $SUBJECT_PATH" >&2
  exit 2
fi

SUBJECT_PATH="$(cd "$SUBJECT_PATH" && pwd)"
if [ "$(dirname "$SUBJECT_PATH")" != "$ROOT" ]; then
  echo "Chyba: předmět musí být složka přímo v kořeni vaultu." >&2
  exit 2
fi

SUBJECT="$(basename "$SUBJECT_PATH")"
case "$SUBJECT" in
  [0-9][0-9]_*) ;;
  *)
    echo "Chyba: složka předmětu musí mít tvar <pořadí>_<KÓD>, například 11_IRO." >&2
    exit 2
    ;;
esac

if [ -n "$SELECTED_FOLDER" ]; then
  case "$SELECTED_FOLDER" in
    */*|.*) echo "Chyba: zadej název přímé podsložky předmětu." >&2; exit 2 ;;
  esac
  EXPORT_PATH="$SUBJECT_PATH/$SELECTED_FOLDER"
  if [ ! -d "$EXPORT_PATH" ]; then
    echo "Chyba: podsložka musí být přímým potomkem předmětu: $SELECTED_FOLDER" >&2
    exit 2
  fi
  EXPORT_PATH="$(cd "$EXPORT_PATH" && pwd -P)"
  if [ "$(dirname "$EXPORT_PATH")" != "$(cd "$SUBJECT_PATH" && pwd -P)" ]; then
    echo "Chyba: podsložka musí být přímým potomkem předmětu: $SELECTED_FOLDER" >&2
    exit 2
  fi
  shopt -s nullglob
  INPUT_FILES=("$EXPORT_PATH"/*.md)
  shopt -u nullglob
  if [ "${#INPUT_FILES[@]}" -eq 0 ]; then
    echo "Chyba: podsložka neobsahuje žádné Markdown soubory: $SELECTED_FOLDER" >&2
    exit 2
  fi
elif [ "$SINGLE_FILE" = false ]; then
  EXPORT_PATH="$SUBJECT_PATH"
  shopt -s nullglob
  INPUT_FILES=("$SUBJECT_PATH"/*.md)
  shopt -u nullglob
  if [ "${#INPUT_FILES[@]}" -eq 0 ]; then
    echo "Chyba: složka předmětu neobsahuje žádné Markdown soubory." >&2
    exit 2
  fi
else
  EXPORT_PATH="$SUBJECT_PATH"
  INPUT_FILES=("$INPUT_FILE")
fi

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
BUILD_METADATA=$(mktemp "${TMPDIR:-/tmp}/tul-notes-build.XXXXXX")
SVG_PDF_DIR=$(mktemp -d "${TMPDIR:-/tmp}/tul-notes-svg-pdf.XXXXXX")
trap 'rm -f "$CONFIG_METADATA" "$BUILD_METADATA"; rm -rf "$SVG_PDF_DIR"' EXIT

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
python3 -c 'import json,sys; json.dump({"subject-title": sys.argv[2], "year": sys.argv[3]}, open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)' "$BUILD_METADATA" "$SUBJECT_TITLE" "$YEAR"

# Convert SVG assets to vector PDFs in a temporary mirrored directory.
# Source SVG files remain untouched.
python3 "$ROOT/_shared/build/convert-svg-to-pdf.py" "$EXPORT_PATH" "$SVG_PDF_DIR"

SUBJECT_CODE="${SUBJECT#*_}"
SUBJECT_CODE="${SUBJECT_CODE%%_*}"
AUTHOR_FILE_PART=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["author-file-part"])' "$CONFIG_METADATA")
if [ "$SINGLE_FILE" = true ]; then
  INPUT_BASENAME="$(basename "$INPUT_FILE")"
  INPUT_STEM="${INPUT_BASENAME%.md}"
  PROTOCOL_TITLE=$(python3 "$ROOT/_shared/build/read-protocol-title.py" "$INPUT_FILE")
  if [ -n "$PROTOCOL_TITLE" ]; then
    OUTPUT_PDF="$SUBJECT_PATH/${PROTOCOL_TITLE}.pdf"
  else
    OUTPUT_PDF="$SUBJECT_PATH/${INPUT_STEM}_TUL.pdf"
  fi
elif [ -n "$SELECTED_FOLDER" ]; then
  FOLDER_FILE_PART=$(python3 -c 'import hashlib,re,sys; original=sys.argv[1]; slug="".join(c if c.isalnum() or c in "-_" else "_" for c in original.strip()); slug=re.sub(r"_+", "_", slug).strip("_-") or "mereni"; print(f"{slug}_{hashlib.sha256(original.encode()).hexdigest()[:8]}")' "$SELECTED_FOLDER")
  PROTOCOL_TITLE_RAW=$(python3 "$ROOT/_shared/build/read-protocol-title.py" --raw "${INPUT_FILES[0]}")
  PROTOCOL_TITLE=$(python3 "$ROOT/_shared/build/read-protocol-title.py" "${INPUT_FILES[0]}")
  if [ -n "$PROTOCOL_TITLE" ]; then
    OUTPUT_PDF="$EXPORT_PATH/${PROTOCOL_TITLE}.pdf"
  else
    OUTPUT_PDF="$EXPORT_PATH/${SUBJECT_CODE}_${FOLDER_FILE_PART}_${AUTHOR_FILE_PART}_notes.pdf"
  fi
  PANDOC_TITLE_OVERRIDE=(--metadata "protocol-title:$PROTOCOL_TITLE_RAW")
else
  OUTPUT_PDF="$SUBJECT_PATH/${SUBJECT_CODE}_${AUTHOR_FILE_PART}_notes.pdf"
fi

export TEXINPUTS="$ROOT/_shared/tul//:"
export SUBJECT_PATH="$EXPORT_PATH"
export SVG_PDF_PATH="$SVG_PDF_DIR"
export PYTHONDONTWRITEBYTECODE=1

(
  cd "$ROOT/_shared/tul"
  pandoc \
    --from=markdown+yaml_metadata_block \
    --metadata-file="$ROOT/_shared/metadata/notes.yaml" \
    --metadata-file="$BUILD_METADATA" \
    --metadata-file="$CONFIG_METADATA" \
    "${INPUT_FILES[@]}" \
    "${PANDOC_TITLE_OVERRIDE[@]}" \
    --resource-path="$ROOT:$SUBJECT_PATH:$SUBJECT_PATH/Graphs:$SUBJECT_PATH/Images:$EXPORT_PATH:$EXPORT_PATH/Graphs:$EXPORT_PATH/Images:$SVG_PDF_DIR" \
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
