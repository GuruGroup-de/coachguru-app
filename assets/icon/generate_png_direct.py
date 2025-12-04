#!/usr/bin/env python3
"""
Generate PNG icon directly using PIL/Pillow
Creates: assets/icon/app_icon.png (1024x1024)
Modern design: White football + rising analytics bars on blue gradient
"""

try:
    from PIL import Image, ImageDraw, ImageFilter
    import math
except ImportError:
    print("❌ PIL/Pillow not installed. Install with: pip3 install Pillow")
    exit(1)

def draw_rounded_rectangle(draw, xy, radius, fill=None, outline=None, width=1):
    """Draw rounded rectangle (fallback for older PIL)"""
    x1, y1, x2, y2 = xy
    # Draw main rectangle
    draw.rectangle([(x1 + radius, y1), (x2 - radius, y2)], fill=fill, outline=outline, width=width)
    draw.rectangle([(x1, y1 + radius), (x2, y2 - radius)], fill=fill, outline=outline, width=width)
    # Draw rounded corners
    for corner in [(x1 + radius, y1 + radius, radius), (x2 - radius, y1 + radius, radius),
                   (x1 + radius, y2 - radius, radius), (x2 - radius, y2 - radius, radius)]:
        cx, cy, r = corner
        draw.ellipse([(cx - r, cy - r), (cx + r, cy + r)], fill=fill, outline=outline, width=width)

def create_app_icon():
    size = 1024
    corner_radius = 220
    
    # Create image with gradient background
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw gradient background
    for y in range(size):
        # Interpolate between #005FFF and #00D1FF
        ratio = y / size
        r1, g1, b1 = 0x00, 0x5F, 0xFF
        r2, g2, b2 = 0x00, 0xD1, 0xFF
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        color = (r, g, b, 255)
        draw.rectangle([(0, y), (size, y+1)], fill=color)
    
    # Create mask for rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    # Draw rounded rectangle in mask
    mask_draw.rectangle([(0, 0), (size, size)], fill=255)
    # Apply rounded corners by drawing circles at corners
    for corner in [(corner_radius, corner_radius), (size - corner_radius, corner_radius),
                   (corner_radius, size - corner_radius), (size - corner_radius, size - corner_radius)]:
        cx, cy = corner
        # Clear corners
        for angle in range(0, 360, 5):
            for r in range(corner_radius):
                x = int(cx + r * math.cos(math.radians(angle)))
                y = int(cy + r * math.sin(math.radians(angle)))
                if 0 <= x < size and 0 <= y < size:
                    dist = math.sqrt((x - cx)**2 + (y - cy)**2)
                    if dist > corner_radius:
                        mask.putpixel((x, y), 0)
    
    # Draw white football (simplified modern design)
    center_x, center_y = size // 2, 360
    ball_radius = 160
    
    # Main circle outline
    draw.ellipse(
        [(center_x - ball_radius, center_y - ball_radius),
         (center_x + ball_radius, center_y + ball_radius)],
        outline='white', width=22
    )
    
    # Pentagon pattern (top center)
    pentagon_points = []
    for i in range(5):
        angle = math.radians(90 + i * 72)
        x = center_x + 120 * math.cos(angle)
        y = center_y - 120 * math.sin(angle)
        pentagon_points.append((x, y))
    draw.polygon(pentagon_points, fill='white')
    
    # Hexagon patterns
    # Left hexagon
    hex_left = [
        (center_x - 70, center_y - 35),
        (center_x - 105, center_y - 15),
        (center_x - 105, center_y + 25),
        (center_x - 70, center_y + 45),
        (center_x - 35, center_y + 25),
        (center_x - 35, center_y - 15),
    ]
    draw.polygon(hex_left, fill='white')
    
    # Right hexagon
    hex_right = [
        (center_x + 70, center_y - 35),
        (center_x + 105, center_y - 15),
        (center_x + 105, center_y + 25),
        (center_x + 70, center_y + 45),
        (center_x + 35, center_y + 25),
        (center_x + 35, center_y - 15),
    ]
    draw.polygon(hex_right, fill='white')
    
    # Bottom hexagon
    hex_bottom = []
    for i in range(6):
        angle = math.radians(270 + i * 60)
        x = center_x + 90 * math.cos(angle)
        y = center_y + 90 * math.sin(angle)
        hex_bottom.append((x, y))
    draw.polygon(hex_bottom, fill='white')
    
    # Center cross lines for depth
    draw.line([(center_x - 90, center_y - 50), (center_x + 90, center_y + 50)],
              fill='white', width=12)
    draw.line([(center_x + 90, center_y - 50), (center_x - 90, center_y + 50)],
              fill='white', width=12)
    
    # Analytics bars (rising chart)
    bar_y_base = 700
    bar_width = 70
    bar_radius = 12
    
    # Bar 1 (left - shortest: 60px)
    bar1_height = 60
    bar1_x = center_x - 140
    draw_rounded_rectangle(
        draw,
        (bar1_x, bar_y_base - bar1_height, bar1_x + bar_width, bar_y_base),
        bar_radius, fill='white'
    )
    
    # Bar 2 (center - medium: 100px)
    bar2_height = 100
    bar2_x = center_x - 35
    draw_rounded_rectangle(
        draw,
        (bar2_x, bar_y_base - bar2_height, bar2_x + bar_width, bar_y_base),
        bar_radius, fill='white'
    )
    
    # Bar 3 (right - tallest: 130px)
    bar3_height = 130
    bar3_x = center_x + 70
    draw_rounded_rectangle(
        draw,
        (bar3_x, bar_y_base - bar3_height, bar3_x + bar_width, bar_y_base),
        bar_radius, fill='white'
    )
    
    # Subtle base line
    draw.line([(center_x - 180, bar_y_base), (center_x + 180, bar_y_base)],
              fill='white', width=6)
    
    # Apply rounded corner mask
    img.putalpha(mask)
    
    # Convert to RGB for final output (remove alpha for compatibility)
    final_img = Image.new('RGB', (size, size), color='#005FFF')
    final_img.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
    
    # Save PNG
    output_path = 'assets/icon/app_icon.png'
    final_img.save(output_path, 'PNG', optimize=True)
    print(f"✅ Generated {output_path} (1024x1024)")
    print(f"   File size: {os.path.getsize(output_path) / 1024:.1f} KB")
    return True

if __name__ == "__main__":
    import os
    create_app_icon()
