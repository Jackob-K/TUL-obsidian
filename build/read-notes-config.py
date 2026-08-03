#!/usr/bin/env python3
"""Convert the editable Markdown configuration to Pandoc JSON metadata."""

from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path


DEFAULTS = {
    "author-name": "Jakub Kočí",
    "author-title": "Bc.",
    "faculty": "FM",
    "programme-code": "N0714A270010",
    "programme-name-cs": "Mechatronika",
    "programme-name-en": "Mechatronics",
    "branch-code": "N0714A270010",
    "branch-name-cs": "Mechatronika",
    "branch-name-en": "Mechatronics",
    "language": "cs",
    "city": "Liberec",
    "use-university-font": False,
}

LANGUAGE_METADATA = {
    "cs": {
        "lang": "cs",
        "babel-language": "czech",
        "tul-english": False,
        "document-label": "Studijní skripta",
        "programme-label": "Studijní program:",
        "branch-label": "Studijní obor:",
        "author-label": "Autor:",
    },
    "en": {
        "lang": "en",
        "babel-language": "english",
        "tul-english": True,
        "document-label": "Study notes",
        "programme-label": "Study programme:",
        "branch-label": "Field of study:",
        "author-label": "Author:",
    },
}

FACULTIES = {"FS", "FT", "FP", "EF", "FA", "FM", "FZS", "CXI"}


def slug(value: object) -> str:
    normalized = unicodedata.normalize("NFKD", str(value))
    ascii_value = normalized.encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^A-Za-z0-9]+", "", ascii_value)


def unquote(value: str) -> str | bool:
    value = value.strip()
    if value.lower() in {"true", "false"}:
        return value.lower() == "true"
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        if value[0] == '"':
            return json.loads(value)
        return value[1:-1].replace("''", "'")
    return value


def read_front_matter(path: Path) -> dict[str, str | bool]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("konfigurační soubor musí začínat YAML hlavičkou mezi ---")

    values: dict[str, str | bool] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return values
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"neplatný řádek konfigurace: {line}")
        key, raw_value = line.split(":", 1)
        values[key.strip()] = unquote(raw_value)

    raise ValueError("konfigurační YAML hlavička není ukončena pomocí ---")


def main() -> int:
    if len(sys.argv) != 3:
        print(f"Použití: {Path(sys.argv[0]).name} CONFIG.md OUTPUT.json", file=sys.stderr)
        return 2

    config_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    try:
        config = DEFAULTS | read_front_matter(config_path)
        language = str(config["language"]).lower()
        if language not in LANGUAGE_METADATA:
            raise ValueError("language musí být 'cs' nebo 'en'")
        config["faculty"] = str(config["faculty"]).upper()
        if config["faculty"] not in FACULTIES:
            raise ValueError(
                "faculty musí být jedna z hodnot: " + ", ".join(sorted(FACULTIES))
            )

        metadata = config | LANGUAGE_METADATA[language]
        metadata["programme-name"] = config[f"programme-name-{language}"]
        metadata["branch-name"] = config[f"branch-name-{language}"]
        metadata["author-file-part"] = slug(
            f"{config['author-title']} {config['author-name']}"
        )
        output_path.write_text(
            json.dumps(metadata, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Chyba konfigurace {config_path}: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
