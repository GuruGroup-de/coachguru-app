#!/usr/bin/env python3
"""
Create a circular version of the logo for CircleAvatar
Generates a 512x512 circular PNG with no white borders
"""

try:
    from PIL import Image, ImageDraw
    import os
    import sys
except ImportError:
    print("❌ PIL/Pillow not installed. Install with: pip3 install Pillow")
    sys.exit(1)

def create_circular_logo(source_path, output_path, size=512):
    """Create a circular version of the logo"""
    print(f"🎨 Creating circular logo from: {source_path}")
    
    # Open source image
    source_img = Image.open(source_path)
    print(f"   Source size: {source_img.size[0]}×{source_img.size[1]}")
    print(f"   Source mode: {source_img.mode}")
    
    # Convert to RGBA if needed
    if source_img.mode != 'RGBA':
        source_img = source_img.convert('RGBA')
    
    # Resize maintaining aspect ratio to fit within circle
    # Use the smaller dimension to ensure it fits
    min_dimension = min(source_img.size)
    scale_factor = (size * 0.9) / min_dimension  # 90% of circle to leave some padding
    new_width = int(source_img.width * scale_factor)
    new_height = int(source_img.height * scale_factor)
    
    resized = source_img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    print(f"   Resized to: {new_width}×{new_height}")
    
    # Create circular mask
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse([(0, 0), (size, size)], fill=255)
    
    # Create output image with transparent background
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Calculate position to center the resized image
    x = (size - new_width) // 2
    y = (size - new_height) // 2
    
    # Paste resized image centered
    output.paste(resized, (x, y), resized)
    
    # Apply circular mask
    output.putalpha(mask)
    
    # Save
    output.save(output_path, 'PNG', optimize=True)
    print(f"✅ Circular logo saved: {output_path}")
    print(f"   Size: {size}×{size} pixels")
    print(f"   Format: PNG with transparency")
    
    return output

def main():
    source = 'assets/logo/coachguru_logo_raw.png'
    output = 'assets/logo/coachguru_logo_circle.png'
    
    if not os.path.exists(source):
        print(f"❌ Error: Source logo not found: {source}")
        print("   Please ensure assets/logo/coachguru_logo_raw.png exists")
        sys.exit(1)
    
    create_circular_logo(source, output, size=512)
    print("\n✅ Circular logo created successfully!")

if __name__ == "__main__":
    main()

