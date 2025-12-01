#!/usr/bin/env python3
"""
Generate CoachGuru app icon (1024x1024 PNG) for Google Play Store
"""

from PIL import Image, ImageDraw, ImageFont
import math

def create_coachguru_icon():
    # Create 1024x1024 image
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (simplified - using solid color for now)
    # In a real implementation, you'd create a proper gradient
    draw.rectangle([0, 0, size, size], fill=(11, 45, 92, 255))  # #0B2D5C
    
    # Add gradient effect by drawing diagonal overlay
    for i in range(size):
        alpha = int(255 * (i / size))
        color = (14, 95, 216, alpha)  # #0E5FD8 with varying alpha
        draw.line([(0, i), (i, 0)], fill=color)
    
    # Draw CG monogram
    try:
        # Try to use a system font
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 200)
    except:
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 200)
        except:
            font = ImageFont.load_default()
    
    # Draw white CG text
    text = "CG"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    # Draw orange tactic arrow
    arrow_color = (255, 176, 0, 255)  # #FFB000
    
    # Arrow path
    arrow_points = [
        (700, 300), (800, 300), (780, 280), (820, 320),
        (780, 360), (800, 340), (700, 340)
    ]
    draw.polygon(arrow_points, fill=arrow_color)
    
    # Arrow circle
    draw.ellipse([735, 305, 765, 335], fill=arrow_color)
    
    # Save the image
    img.save('coachguru_app_icon_1024.png', 'PNG')
    print("CoachGuru app icon generated: coachguru_app_icon_1024.png")

if __name__ == "__main__":
    create_coachguru_icon()
