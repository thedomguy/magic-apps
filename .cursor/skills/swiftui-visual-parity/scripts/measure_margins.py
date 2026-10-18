#!/usr/bin/env python3
"""Estimate content margins for a dark calculator-style screenshot.

Finds the largest near-black region and reports distance from image edges to
non-background content. Optional --ref prints a simple delta.

Usage:
  python3 measure_margins.py app.png
  python3 measure_margins.py app.png --ref stock.png
"""
from __future__ import annotations

import argparse
import struct
import zlib
import sys
from pathlib import Path


def _load_png_rgba(path: Path):
    """Minimal PNG reader (8-bit RGBA or RGB). Avoids Pillow dependency."""
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"not a PNG: {path}")
    pos = 8
    width = height = None
    bits = color = None
    idat = b""
    while pos < len(data):
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        pos += 4
        ctype = data[pos : pos + 4]
        pos += 4
        chunk = data[pos : pos + length]
        pos += length
        pos += 4  # crc
        if ctype == b"IHDR":
            width, height, bits, color = struct.unpack(">IIBB", chunk[:10])
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"IEND":
            break
    if width is None:
        raise SystemExit(f"bad PNG: {path}")
    if bits != 8 or color not in (2, 6):
        raise SystemExit(f"need 8-bit RGB/RGBA PNG: {path}")
    raw = zlib.decompress(idat)
    bpp = 3 if color == 2 else 4
    stride = width * bpp + 1
    rows = []
    for y in range(height):
        start = y * stride
        if raw[start] != 0:
            raise SystemExit("unsupported PNG filter (need None/0)")
        row = raw[start + 1 : start + stride]
        pixels = []
        for x in range(width):
            i = x * bpp
            r, g, b = row[i], row[i + 1], row[i + 2]
            pixels.append((r, g, b))
        rows.append(pixels)
    return width, height, rows


def _is_bg(rgb, thresh: int) -> bool:
    r, g, b = rgb
    return r <= thresh and g <= thresh and b <= thresh


def margins(path: Path, thresh: int = 18):
    w, h, rows = _load_png_rgba(path)
    content = [
        (x, y)
        for y in range(h)
        for x in range(w)
        if not _is_bg(rows[y][x], thresh)
    ]
    if not content:
        raise SystemExit(f"no content found (all near-black?): {path}")
    xs = [p[0] for p in content]
    ys = [p[1] for p in content]
    left, right = min(xs), w - 1 - max(xs)
    top, bottom = min(ys), h - 1 - max(ys)
    return {
        "path": str(path),
        "width": w,
        "height": h,
        "left_px": left,
        "right_px": right,
        "top_px": top,
        "bottom_px": bottom,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("image", type=Path)
    ap.add_argument("--ref", type=Path)
    ap.add_argument("--thresh", type=int, default=18)
    args = ap.parse_args()
    app = margins(args.image, args.thresh)
    print(
        f"app: {app['width']}x{app['height']}  "
        f"L{app['left_px']} R{app['right_px']} T{app['top_px']} B{app['bottom_px']} px"
    )
    if args.ref:
        ref = margins(args.ref, args.thresh)
        print(
            f"ref: {ref['width']}x{ref['height']}  "
            f"L{ref['left_px']} R{ref['right_px']} T{ref['top_px']} B{ref['bottom_px']} px"
        )
        print(
            "delta (app-ref) px: "
            f"L{app['left_px'] - ref['left_px']} "
            f"R{app['right_px'] - ref['right_px']} "
            f"T{app['top_px'] - ref['top_px']} "
            f"B{app['bottom_px'] - ref['bottom_px']}"
        )
        if (app["width"], app["height"]) != (ref["width"], ref["height"]):
            print(
                "note: different resolutions — compare ratios or capture at same size",
                file=sys.stderr,
            )


if __name__ == "__main__":
    main()
