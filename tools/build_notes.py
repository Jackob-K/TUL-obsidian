#!/usr/bin/env python3
"""Interactive launcher for the shared Markdown-to-PDF build."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


SUBJECT_PATTERN = re.compile(r"^\d{2}_.+$")


def available_subjects(vault_root: Path) -> list[Path]:
    return sorted(
        path
        for path in vault_root.iterdir()
        if path.is_dir()
        and SUBJECT_PATTERN.match(path.name)
        and any(file.is_file() and file.suffix.lower() == ".md" for file in path.iterdir())
    )


def subject_from_path(raw_path: str, vault_root: Path) -> Path:
    path = Path(raw_path).expanduser().resolve()
    if path.is_file():
        path = path.parent

    for candidate in (path, *path.parents):
        if candidate.parent == vault_root and SUBJECT_PATTERN.match(candidate.name):
            return candidate

    raise ValueError(f"Cesta nepatří do složky předmětu v tomto vaultu: {raw_path}")


def note_from_path(raw_path: str, vault_root: Path) -> Path:
    path = Path(raw_path).expanduser()
    if not path.is_absolute():
        path = vault_root / path
    path = path.resolve()

    if not path.is_file() or path.suffix.lower() != ".md":
        raise ValueError(f"Markdown soubor nebyl nalezen: {raw_path}")
    if path.parent.parent != vault_root or not SUBJECT_PATTERN.match(path.parent.name):
        raise ValueError(
            "Poznámka musí ležet přímo ve složce předmětu v tomto vaultu."
        )
    return path


def subfolder_by_name(name: str, subject: Path) -> Path:
    if not name or name in {".", ".."} or Path(name).name != name:
        raise ValueError("Podsložka musí být zadána pouze svým názvem.")
    folder = (subject / name).resolve()
    if folder.parent != subject or not folder.is_dir():
        raise ValueError(f"Podsložka '{name}' nebyla nalezena přímo v {subject.name}.")
    if not any(
        file.is_file() and file.suffix.lower() == ".md" for file in folder.iterdir()
    ):
        raise ValueError(f"Podsložka '{name}' neobsahuje Markdown soubory přímo ve složce.")
    return folder


def subject_by_name(name: str, subjects: list[Path]) -> Path:
    normalized = name.rstrip("/").split("/")[-1]
    for subject in subjects:
        if subject.name == normalized:
            return subject
    raise ValueError(f"Předmět '{name}' nebyl nalezen nebo neobsahuje Markdown soubory.")


def select_subject(subjects: list[Path]) -> Path:
    if not sys.stdin.isatty():
        raise ValueError("Bez interaktivního terminálu zadej předmět jako argument.")

    print("Vyber předmět pro export do PDF:")
    for index, subject in enumerate(subjects, start=1):
        print(f"  {index:2}. {subject.name}")

    while True:
        answer = input("Číslo předmětu (Enter = zrušit): ").strip()
        if not answer:
            raise KeyboardInterrupt
        if answer.isdigit() and 1 <= int(answer) <= len(subjects):
            return subjects[int(answer) - 1]
        print(f"Zadej číslo 1 až {len(subjects)}.")


def build(
    subject: Path,
    vault_root: Path,
    source_file: Path | None = None,
    source_folder: Path | None = None,
) -> None:
    env = os.environ.copy()
    extra_paths = ["/usr/local/bin", "/opt/homebrew/bin", "/Library/TeX/texbin"]
    env["PATH"] = os.pathsep.join(extra_paths + [env.get("PATH", "")])
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    build_script = vault_root / "_shared" / "build" / "build-notes.sh"

    if source_file:
        command = [str(build_script), "--file", str(source_file)]
        print(f"Generuji PDF pro {source_file.name}...")
    elif source_folder:
        command = [str(build_script), subject.name, "--folder", source_folder.name]
        print(f"Generuji PDF pro {subject.name}/{source_folder.name}...")
    else:
        command = [str(build_script), subject.name]
        print(f"Generuji PDF pro {subject.name}...")
    result = subprocess.run(
        command,
        cwd=vault_root,
        env=env,
        check=True,
        capture_output=True,
        text=True,
    )
    output_pdf = result.stdout.strip().splitlines()[-1] if result.stdout.strip() else ""
    if output_pdf:
        print(f"Hotovo: {output_pdf}")
    else:
        print(f"Hotovo: {subject}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Vytvoří PDF poznámky pomocí sdílené TUL/FM šablony."
    )
    parser.add_argument("subject", nargs="?", help="Název složky, např. 11_IRO")
    parser.add_argument(
        "--vault",
        metavar="PATH",
        default=Path.cwd(),
        help="Kořen Obsidian vaultu. Výchozí je aktuální pracovní složka.",
    )
    parser.add_argument(
        "--from-path",
        metavar="PATH",
        help="Určí předmět podle cesty k otevřené poznámce (pro Obsidian).",
    )
    parser.add_argument(
        "--file",
        metavar="PATH",
        help="Exportuje pouze zadaný Markdown soubor ve složce předmětu.",
    )
    parser.add_argument(
        "--folder",
        metavar="NAME",
        help="Exportuje pouze Markdown soubory přímo v podsložce vybraného předmětu.",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="Vypíše dostupné předměty a skončí.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    vault_root = Path(args.vault).expanduser().resolve()
    subjects = available_subjects(vault_root)

    if args.list:
        print("\n".join(subject.name for subject in subjects))
        return 0

    if not subjects:
        print("Chyba: nebyla nalezena žádná předmětová složka s Markdown soubory.", file=sys.stderr)
        return 2

    try:
        selected_modes = sum(bool(value) for value in (args.subject, args.from_path, args.file))
        if selected_modes > 1:
            raise ValueError("Použij pouze jeden z argumentů subject, --from-path nebo --file.")
        if args.folder and not args.subject:
            raise ValueError("Pro export podsložky zadej také název předmětu.")
        if args.folder and args.file:
            raise ValueError("Argumenty --folder a --file nelze kombinovat.")

        source_file = None
        source_folder = None
        if args.file:
            source_file = note_from_path(args.file, vault_root)
            subject = source_file.parent
        elif args.from_path:
            subject = subject_from_path(args.from_path, vault_root)
            if subject not in subjects:
                raise ValueError(
                    f"Předmět '{subject.name}' neobsahuje Markdown soubory přímo ve své složce."
                )
        elif args.subject:
            subject = subject_by_name(args.subject, subjects)
            if args.folder:
                source_folder = subfolder_by_name(args.folder, subject)
        else:
            subject = select_subject(subjects)

        build(subject, vault_root, source_file, source_folder)
        return 0
    except KeyboardInterrupt:
        print("\nExport zrušen.")
        return 130
    except ValueError as error:
        print(f"Chyba: {error}", file=sys.stderr)
        return 2
    except subprocess.CalledProcessError as error:
        print(f"Chyba: generování PDF skončilo s kódem {error.returncode}.", file=sys.stderr)
        return error.returncode or 1


if __name__ == "__main__":
    raise SystemExit(main())
