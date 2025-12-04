#!/usr/bin/env python3
"""
Generate PNG from SVG for CoachGuru app icon
Requires: cairosvg or rsvg-convert
"""

import subprocess
import sys
import os

def generate_png_from_svg():
    svg_path = "assets/icon/app_icon.svg"
    png_path = "assets/icon/app_icon.png"
    
    # Try cairosvg first
    try:
        import cairosvg
        cairosvg.svg2png(url=svg_path, write_to=png_path, output_width=1024, output_height=1024)
        print(f"✅ Generated {png_path} using cairosvg")
        return True
    except ImportError:
        pass
    
    # Try rsvg-convert (librsvg)
    try:
        result = subprocess.run(
            ["rsvg-convert", "-w", "1024", "-h", "1024", "-o", png_path, svg_path],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print(f"✅ Generated {png_path} using rsvg-convert")
            return True
    except FileNotFoundError:
        pass
    
    # Try inkscape
    try:
        result = subprocess.run(
            ["inkscape", svg_path, "--export-filename", png_path, "--export-width=1024", "--export-height=1024"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print(f"✅ Generated {png_path} using inkscape")
            return True
    except FileNotFoundError:
        pass
    
    print("❌ No SVG to PNG converter found. Please install one of:")
    print("   - pip install cairosvg")
    print("   - brew install librsvg (for rsvg-convert)")
    print("   - brew install inkscape")
    return False

if __name__ == "__main__":
    if generate_png_from_svg():
        sys.exit(0)
    else:
        sys.exit(1)

