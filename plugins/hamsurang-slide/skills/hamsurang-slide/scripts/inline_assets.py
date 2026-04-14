#!/usr/bin/env python3
import base64
import sys
from pathlib import Path


def svg_to_data_uri(svg_path: Path) -> str:
    data = svg_path.read_bytes()
    b64 = base64.b64encode(data).decode()
    return f"data:image/svg+xml;base64,{b64}"


def svg_to_inline(svg_path: Path) -> str:
    return svg_path.read_text(encoding="utf-8").strip()


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <input.html> <images_dir>")
        sys.exit(1)

    html_path = Path(sys.argv[1])
    images_dir = Path(sys.argv[2])

    html = html_path.read_text(encoding="utf-8")

    replacements = {
        "{{LOGO_DATA_URI}}": ("logo.svg", svg_to_data_uri),
        "{{LOGO_WHITE_DATA_URI}}": ("logo-white.svg", svg_to_data_uri),
        "{{MOUNTAIN_SVG_INLINE}}": ("mountain.svg", svg_to_inline),
        "{{MOUNTAIN_WHITE_SVG_INLINE}}": ("mountain-white.svg", svg_to_inline),
    }

    for placeholder, (filename, converter) in replacements.items():
        filepath = images_dir / filename
        if filepath.exists() and placeholder in html:
            html = html.replace(placeholder, converter(filepath))
            print(f"  Replaced {placeholder} from {filename}")
        elif placeholder in html:
            print(f"  WARNING: {filename} not found, {placeholder} left as-is")

    html_path.write_text(html, encoding="utf-8")
    print(f"Done: {html_path}")


if __name__ == "__main__":
    main()
