#!/usr/bin/env python3
"""Convert subject SVG figures to vector PDF files in a mirrored temp tree."""
from pathlib import Path
import sys

source_root = Path(sys.argv[1]).resolve()
output_root = Path(sys.argv[2]).resolve()
svg_files = sorted(source_root.rglob("*.svg"))
if not svg_files:
    raise SystemExit(0)

try:
    import fitz  # PyMuPDF
except ImportError as exc:
    raise SystemExit(
        "Chyba: pro vektorový převod SVG do PDF je potřeba PyMuPDF "
        "(Python modul fitz). Nainstalujte jej do Pythonu použitého pro build."
    ) from exc

for svg_path in svg_files:
    relative = svg_path.relative_to(source_root)
    pdf_path = output_root / relative.with_suffix(".pdf")
    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        document = fitz.open(svg_path)
        pdf_path.write_bytes(document.convert_to_pdf())
        document.close()
    except Exception as exc:
        raise SystemExit(f"Chyba při převodu SVG {svg_path}: {exc}") from exc
