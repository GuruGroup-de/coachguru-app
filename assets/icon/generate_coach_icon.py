#!/usr/bin/env python3
"""
Generate CoachGuru app icon with coach figure and tactic boards
Design: Navy blue background, white coach, yellow overlays
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import math
    import os
except ImportError:
    print("❌ PIL/Pillow not installed. Install with: pip3 install Pillow")
    exit(1)

# Colors
NAVY_BLUE = (10, 61, 145)  # #0A3D91
WHITE = (255, 255, 255)
GOLD = (247, 164, 7)  # #F7A407
YELLOW = (255, 220, 0)

def draw_coach_figure(draw, center_x, center_y, size):
    """Draw white coach figure silhouette"""
    # Head (circle)
    head_radius = int(size * 0.12)
    draw.ellipse(
        [(center_x - head_radius, center_y - size * 0.5),
         (center_x + head_radius, center_y - size * 0.5 + head_radius * 2)],
        fill=WHITE
    )
    
    # Body (torso - rectangle)
    body_width = int(size * 0.25)
    body_height = int(size * 0.35)
    draw.rectangle(
        [(center_x - body_width // 2, center_y - size * 0.3),
         (center_x + body_width // 2, center_y - size * 0.3 + body_height)],
        fill=WHITE
    )
    
    # Arms (extended)
    arm_width = int(size * 0.08)
    arm_length = int(size * 0.25)
    # Left arm
    draw.rectangle(
        [(center_x - body_width // 2 - arm_length, center_y - size * 0.25),
         (center_x - body_width // 2, center_y - size * 0.25 + arm_width)],
        fill=WHITE
    )
    # Right arm
    draw.rectangle(
        [(center_x + body_width // 2, center_y - size * 0.25),
         (center_x + body_width // 2 + arm_length, center_y - size * 0.25 + arm_width)],
        fill=WHITE
    )
    
    # Legs
    leg_width = int(size * 0.1)
    leg_length = int(size * 0.3)
    # Left leg
    draw.rectangle(
        [(center_x - body_width // 4, center_y - size * 0.3 + body_height),
         (center_x - body_width // 4 + leg_width, center_y - size * 0.3 + body_height + leg_length)],
        fill=WHITE
    )
    # Right leg
    draw.rectangle(
        [(center_x + body_width // 4 - leg_width, center_y - size * 0.3 + body_height),
         (center_x + body_width // 4, center_y - size * 0.3 + body_height + leg_length)],
        fill=WHITE
    )

def draw_tactic_board(draw, x, y, size, color):
    """Draw a tactic board (grid with players)"""
    # Board background (rounded rectangle)
    board_width = int(size * 0.15)
    board_height = int(size * 0.15)
    corner_radius = 4
    
    # Draw rounded rectangle
    draw.rectangle(
        [(x, y), (x + board_width, y + board_height)],
        fill=color, outline=GOLD, width=2
    )
    
    # Draw grid lines
    grid_lines = 3
    for i in range(1, grid_lines):
        # Vertical lines
        line_x = x + (board_width * i // grid_lines)
        draw.line([(line_x, y), (line_x, y + board_height)], fill=GOLD, width=1)
        # Horizontal lines
        line_y = y + (board_height * i // grid_lines)
        draw.line([(x, line_y), (x + board_width, line_y)], fill=GOLD, width=1)
    
    # Draw small player dots
    dot_size = 3
    positions = [
        (x + board_width * 0.2, y + board_height * 0.3),
        (x + board_width * 0.5, y + board_height * 0.2),
        (x + board_width * 0.8, y + board_height * 0.3),
        (x + board_width * 0.3, y + board_height * 0.7),
        (x + board_width * 0.7, y + board_height * 0.7),
    ]
    for pos_x, pos_y in positions:
        draw.ellipse(
            [(pos_x - dot_size, pos_y - dot_size),
             (pos_x + dot_size, pos_y + dot_size)],
            fill=WHITE
        )

def draw_coach_arrow_icon(draw, x, y, size):
    """Draw small coach + arrow icon"""
    icon_size = int(size * 0.08)
    
    # Small coach figure
    coach_x = x
    coach_y = y
    # Head
    head_r = icon_size // 4
    draw.ellipse(
        [(coach_x - head_r, coach_y - icon_size // 2),
         (coach_x + head_r, coach_y - icon_size // 2 + head_r * 2)],
        fill=YELLOW, outline=GOLD, width=1
    )
    # Body
    draw.rectangle(
        [(coach_x - icon_size // 6, coach_y - icon_size // 6),
         (coach_x + icon_size // 6, coach_y + icon_size // 3)],
        fill=YELLOW, outline=GOLD, width=1
    )
    
    # Arrow pointing right
    arrow_x = coach_x + icon_size // 2
    arrow_y = coach_y
    arrow_length = icon_size // 2
    # Arrow line
    draw.line(
        [(arrow_x, arrow_y), (arrow_x + arrow_length, arrow_y)],
        fill=GOLD, width=2
    )
    # Arrow head
    arrow_points = [
        (arrow_x + arrow_length, arrow_y),
        (arrow_x + arrow_length - 4, arrow_y - 3),
        (arrow_x + arrow_length - 4, arrow_y + 3),
    ]
    draw.polygon(arrow_points, fill=GOLD)

def create_full_icon(size=1024):
    """Create the full app icon"""
    img = Image.new('RGB', (size, size), color=NAVY_BLUE)
    draw = ImageDraw.Draw(img)
    
    center_x, center_y = size // 2, size // 2
    
    # Draw main coach figure (centered, large)
    draw_coach_figure(draw, center_x, center_y, size)
    
    # Draw two tactic boards (upper-right)
    board_size = size
    # Top tactic board
    board1_x = int(size * 0.65)
    board1_y = int(size * 0.15)
    draw_tactic_board(draw, board1_x, board1_y, board_size, YELLOW)
    
    # Bottom tactic board (slightly offset)
    board2_x = int(size * 0.72)
    board2_y = int(size * 0.25)
    draw_tactic_board(draw, board2_x, board2_y, board_size, YELLOW)
    
    # Draw coach + arrow icon (lower-right)
    icon_x = int(size * 0.75)
    icon_y = int(size * 0.8)
    draw_coach_arrow_icon(draw, icon_x, icon_y, size)
    
    return img

def create_foreground(size=432):
    """Create foreground for Android adaptive icon"""
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center_x, center_y = size // 2, size // 2
    
    # Draw coach figure (centered)
    draw_coach_figure(draw, center_x, center_y, size)
    
    # Draw tactic boards (upper-right, smaller)
    board_size = size
    board1_x = int(size * 0.65)
    board1_y = int(size * 0.15)
    draw_tactic_board(draw, board1_x, board1_y, board_size, YELLOW)
    
    board2_x = int(size * 0.72)
    board2_y = int(size * 0.25)
    draw_tactic_board(draw, board2_x, board2_y, board_size, YELLOW)
    
    # Draw coach + arrow icon (lower-right)
    icon_x = int(size * 0.75)
    icon_y = int(size * 0.8)
    draw_coach_arrow_icon(draw, icon_x, icon_y, size)
    
    return img

def create_background(size=1080):
    """Create solid navy blue background"""
    return Image.new('RGB', (size, size), color=NAVY_BLUE)

def generate_all_icons():
    """Generate all required icon files"""
    output_dir = 'assets/icon/generated'
    os.makedirs(output_dir, exist_ok=True)
    
    print("🎨 Generating CoachGuru app icons...")
    
    # 1. Full icon 1024x1024
    print("  → Creating full_icon_1024.png...")
    full_icon = create_full_icon(1024)
    full_icon.save(f'{output_dir}/full_icon_1024.png', 'PNG', optimize=True)
    
    # 2. Foreground 432x432
    print("  → Creating foreground.png...")
    foreground = create_foreground(432)
    foreground.save(f'{output_dir}/foreground.png', 'PNG', optimize=True)
    
    # 3. Background 1080x1080
    print("  → Creating background.png...")
    background = create_background(1080)
    background.save(f'{output_dir}/background.png', 'PNG', optimize=True)
    
    # 4. Mipmap icons
    mipmap_sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    
    for density, icon_size in mipmap_sizes.items():
        print(f"  → Creating mipmap-{density}/ic_launcher.png ({icon_size}x{icon_size})...")
        icon = create_full_icon(icon_size)
        mipmap_dir = f'{output_dir}/mipmap-{density}'
        os.makedirs(mipmap_dir, exist_ok=True)
        icon.save(f'{mipmap_dir}/ic_launcher.png', 'PNG', optimize=True)
        # Also create round version
        icon.save(f'{mipmap_dir}/ic_launcher_round.png', 'PNG', optimize=True)
    
    print(f"\n✅ All icons generated in: {output_dir}/")
    return output_dir

if __name__ == "__main__":
    generate_all_icons()

