#!/usr/bin/env python3
"""Convert SVG and unsupported raster assets into a mirrored temporary tree."""

from pathlib import Path
import shutil
import subprocess
import sys


source_root = Path(sys.argv[1]).resolve()
output_root = Path(sys.argv[2]).resolve()
svg_files = sorted(p for p in source_root.rglob("*") if p.suffix.lower() == ".svg")
heic_files = sorted(
    p for p in source_root.rglob("*") if p.suffix.lower() in {".heic", ".heif"}
)
raster_files = sorted(
    p for p in source_root.rglob("*") if p.suffix.lower() in {".webp", ".tif", ".tiff"}
)


def run(command: list[str], source: Path) -> None:
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        details = (result.stderr or result.stdout).strip()
        if not details:
            details = f"proces skončil kódem {result.returncode}"
        raise SystemExit(f"Chyba při převodu obrázku {source}: {details}")


svg_converter = shutil.which("rsvg-convert")
if svg_files and not svg_converter:
    raise SystemExit(
        "Chyba: pro vektorový převod SVG je potřeba rsvg-convert "
        "(Homebrew: brew install librsvg). Inkscape se nepoužívá."
    )

for svg_path in svg_files:
    relative = svg_path.relative_to(source_root)
    pdf_path = output_root / relative.with_suffix(".pdf")
    pdf_path.parent.mkdir(parents=True, exist_ok=True)
    run(
        [svg_converter, "--format=pdf", f"--output={pdf_path}", str(svg_path)],
        svg_path,
    )

for image_path in heic_files:
    relative = image_path.relative_to(source_root)
    png_path = output_root / relative.with_suffix(".png")
    png_path.parent.mkdir(parents=True, exist_ok=True)
    heif_convert = shutil.which("heif-convert")
    sips = shutil.which("sips")
    if heif_convert:
        run([heif_convert, str(image_path), str(png_path)], image_path)
    elif sips:
        run([sips, "-s", "format", "png", str(image_path), "--out", str(png_path)], image_path)
    else:
        raise SystemExit(
            f"Chyba: převod HEIC vyžaduje heif-convert (Homebrew: brew install libheif) "
            f"nebo funkční sips: {image_path}"
        )
    if not png_path.is_file() or png_path.stat().st_size < 1024:
        raise SystemExit(f"Chyba: HEIC se nepodařilo převést na platný PNG: {image_path}")

if raster_files:
    try:
        from PIL import Image
    except ImportError as exc:
        raise SystemExit(
            "Chyba: převod WebP/TIFF vyžaduje Pillow. "
            "Nainstalujte Python balíčky z requirements.txt."
        ) from exc
    for image_path in raster_files:
        relative = image_path.relative_to(source_root)
        png_path = output_root / relative.with_suffix(".png")
        png_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            with Image.open(image_path) as image:
                image.convert("RGBA" if "A" in image.getbands() else "RGB").save(
                    png_path, format="PNG"
                )
        except Exception as exc:
            raise SystemExit(f"Chyba při převodu obrázku {image_path}: {exc}") from exc
