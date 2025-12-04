#!/usr/bin/env python3
"""
Generate favicon files from logo
Creates favicon.ico (48x48) and favicon.png (256x256)
"""

try:
    from PIL import Image
    import os
    import sys
except ImportError:
    print("❌ PIL/Pillow not installed. Install with: pip3 install Pillow")
    sys.exit(1)

def generate_favicons(source_path, output_dir):
    """Generate favicon files"""
    print(f"🎨 Generating favicons from: {source_path}")
    
    # Open source image
    source_img = Image.open(source_path)
    print(f"   Source size: {source_img.size[0]}×{source_img.size[1]}")
    
    # Convert to RGBA if needed
    if source_img.mode != 'RGBA':
        source_img = source_img.convert('RGBA')
    
    # Generate favicon.png (256x256)
    print("  → Creating favicon.png (256×256)...")
    favicon_png = source_img.resize((256, 256), Image.Resampling.LANCZOS)
    favicon_png_path = os.path.join(output_dir, 'favicon.png')
    favicon_png.save(favicon_png_path, 'PNG', optimize=True)
    print(f"   ✅ Saved: {favicon_png_path}")
    
    # Generate favicon.ico (48x48)
    print("  → Creating favicon.ico (48×48)...")
    favicon_ico = source_img.resize((48, 48), Image.Resampling.LANCZOS)
    favicon_ico_path = os.path.join(output_dir, 'favicon.ico')
    
    # Save as ICO format (PIL supports ICO)
    favicon_ico.save(favicon_ico_path, 'ICO', sizes=[(48, 48)])
    print(f"   ✅ Saved: {favicon_ico_path}")
    
    print("\n✅ Favicons generated successfully!")

if __name__ == "__main__":
    source = 'docs/assets/logo/coachguru_logo.png'
    output_dir = 'docs/assets/logo'
    
    if not os.path.exists(source):
        print(f"❌ Error: Source logo not found: {source}")
        sys.exit(1)
    
    generate_favicons(source, output_dir)

