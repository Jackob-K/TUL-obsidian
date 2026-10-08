#!/usr/bin/env python3
"""Read protocol title or output filename metadata from a Markdown note."""

from __future__ import annotations

import json
import re
import subprocess
import sys
import unicodedata
from pathlib import Path


def inline_text(value: object) -> str:
    if not isinstance(value, dict):
        return ""

    kind = value.get("t")
    content = value.get("c")
    if kind == "Str":
        return str(content)
    if kind in {"Space", "SoftBreak", "LineBreak"}:
        return " "
    if kind == "Code" and isinstance(content, list) and len(content) > 1:
        return str(content[1])
    if isinstance(content, list):
        return "".join(inline_text(item) for item in content)
    return ""


def metadata_text(value: object) -> str:
    if not isinstance(value, dict):
        return ""
    kind = value.get("t")
    content = value.get("c")
    if kind == "MetaString":
        return str(content)
    if kind == "MetaInlines" and isinstance(content, list):
        return "".join(inline_text(item) for item in content)
    return ""


def safe_filename_stem(value: str, remove_pdf_extension: bool = False) -> str:
    value = unicodedata.normalize("NFC", value)
    value = re.sub(r"[\\/:*?\"<>|\x00-\x1f]", "-", value)
    value = re.sub(r"\s+", " ", value).strip(" .")
    value = value.lstrip(".")
    if remove_pdf_extension and value.lower().endswith(".pdf"):
        value = value[:-4].rstrip(" .")
    return value


def main() -> int:
    raw_mode = len(sys.argv) == 3 and sys.argv[1] == "--raw"
    filename_mode = len(sys.argv) == 3 and sys.argv[1] == "--filename"
    if raw_mode or filename_mode:
        source = Path(sys.argv[2])
    elif len(sys.argv) == 2:
        source = Path(sys.argv[1])
    else:
        print(
            f"Použití: {Path(sys.argv[0]).name} [--raw|--filename] SOUBOR.md",
            file=sys.stderr,
        )
        return 2

    field = "protocol-filename" if filename_mode else "protocol-title"
    try:
        result = subprocess.run(
            ["pandoc", "--from=markdown+yaml_metadata_block", "--to=json", str(source)],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        document = json.loads(result.stdout)
        value = metadata_text(document.get("meta", {}).get(field))
        if not raw_mode:
            value = safe_filename_stem(value, remove_pdf_extension=filename_mode)
            if value in {"", ".", ".."}:
                value = ""
        print(value)
        return 0
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"Chyba při čtení vlastnosti {field}: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
