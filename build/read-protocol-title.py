#!/usr/bin/env python3
"""Read and safely normalize the optional protocol-title metadata value."""

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


def safe_filename_stem(title: str) -> str:
    title = unicodedata.normalize("NFC", title)
    title = re.sub(r"[\\/:*?\"<>|\x00-\x1f]", "-", title)
    title = re.sub(r"\s+", " ", title).strip(" .")
    title = title.lstrip(".")
    return title


def main() -> int:
    raw_mode = len(sys.argv) == 3 and sys.argv[1] == "--raw"
    if raw_mode:
        source = Path(sys.argv[2])
    elif len(sys.argv) == 2:
        source = Path(sys.argv[1])
    else:
        print(
            f"Použití: {Path(sys.argv[0]).name} [--raw] SOUBOR.md",
            file=sys.stderr,
        )
        return 2

    try:
        result = subprocess.run(
            ["pandoc", "--from=markdown+yaml_metadata_block", "--to=json", str(source)],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        document = json.loads(result.stdout)
        title = metadata_text(document.get("meta", {}).get("protocol-title"))
        if not raw_mode:
            title = safe_filename_stem(title)
            if title in {"", ".", ".."}:
                title = ""
        print(title)
        return 0
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"Chyba při čtení vlastnosti protocol-title: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
