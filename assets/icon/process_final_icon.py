#!/usr/bin/env python3
"""
Process final uploaded app icon - EXACT image, no redesign
Generates all Android and iOS icon sizes
"""

try:
    from PIL import Image, ImageDraw
    import os
    import sys
    import shutil
except ImportError:
    print("❌ PIL/Pillow not installed. Install with: pip3 install Pillow")
    sys.exit(1)

# Background color from icon
NAVY_BLUE = (10, 29, 71)  # #0A1D47

def resize_with_padding(img, target_size, background_color=None):
    """Resize image maintaining aspect ratio, add padding if needed"""
    # If no background specified, try to extract from image or use transparent
    if background_color is None:
        # Try to get background color from corners
        corners = [
            img.getpixel((0, 0)),
            img.getpixel((img.width-1, 0)),
            img.getpixel((0, img.height-1)),
            img.getpixel((img.width-1, img.height-1))
        ]
        # Use most common corner color as background
        background_color = max(set(corners), key=corners.count)
        if isinstance(background_color, int):
            background_color = (background_color, background_color, background_color)
        if len(background_color) == 4:  # RGBA
            background_color = background_color[:3]
    
    # Resize maintaining aspect ratio
    img.thumbnail((target_size, target_size), Image.Resampling.LANCZOS)
    
    # Create new image with target size
    if img.mode == 'RGBA':
        new_img = Image.new('RGBA', (target_size, target_size), (*background_color, 255))
    else:
        new_img = Image.new('RGB', (target_size, target_size), background_color)
    
    # Calculate position to center the image
    x = (target_size - img.width) // 2
    y = (target_size - img.height) // 2
    
    # Paste the resized image centered
    if img.mode == 'RGBA':
        new_img.paste(img, (x, y), img.split()[3] if len(img.split()) > 3 else img)
    else:
        new_img.paste(img, (x, y))
    
    return new_img

def extract_background_color(img):
    """Extract background color from image corners"""
    corners = [
        img.getpixel((0, 0)),
        img.getpixel((img.width-1, 0)),
        img.getpixel((0, img.height-1)),
        img.getpixel((img.width-1, img.height-1))
    ]
    # Get most common color
    if all(isinstance(c, tuple) for c in corners):
        # For RGB/RGBA tuples
        corner_colors = [c[:3] if len(c) > 3 else c for c in corners]
        background_color = max(set(corner_colors), key=corner_colors.count)
    else:
        background_color = max(set(corners), key=corners.count)
    
    return background_color

def generate_android_icons(source_icon_path):
    """Generate all Android icon sizes"""
    print("📱 Generating Android icons...")
    
    source_img = Image.open(source_icon_path)
    bg_color = extract_background_color(source_img)
    
    # Android mipmap sizes
    android_sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    
    base_dir = 'android/app/src/main/res'
    
    for density, size in android_sizes.items():
        print(f"  → mipmap-{density}/ic_launcher.png ({size}×{size})...")
        
        # Resize icon with original background
        resized = resize_with_padding(source_img.copy(), size, bg_color)
        
        # Create mipmap directory
        mipmap_dir = f'{base_dir}/mipmap-{density}'
        os.makedirs(mipmap_dir, exist_ok=True)
        
        # Save launcher icon
        resized.save(f'{mipmap_dir}/ic_launcher.png', 'PNG', optimize=True)
        
        # Save round version (same image)
        resized.save(f'{mipmap_dir}/ic_launcher_round.png', 'PNG', optimize=True)
    
    print("✅ Android icons generated")

def generate_android_adaptive_icons(source_icon_path):
    """Generate Android adaptive icon components"""
    print("📱 Generating Android adaptive icon components...")
    
    source_img = Image.open(source_icon_path)
    bg_color = extract_background_color(source_img)
    
    # Foreground: 432×432 (scaled from uploaded icon)
    print("  → Creating foreground.png (432×432)...")
    foreground = resize_with_padding(source_img.copy(), 432, None)  # Use transparent/auto background
    if foreground.mode != 'RGBA':
        foreground = foreground.convert('RGBA')
    os.makedirs('assets/icon/generated', exist_ok=True)
    foreground.save('assets/icon/generated/foreground.png', 'PNG', optimize=True)
    
    # Background: 1080×1080 solid navy
    print("  → Creating background.png (1080×1080)...")
    background = Image.new('RGB', (1080, 1080), NAVY_BLUE)
    background.save('assets/icon/generated/background.png', 'PNG', optimize=True)
    
    # Copy foreground to all mipmap densities for adaptive icons
    foreground_sizes = {
        'mdpi': 108,
        'hdpi': 162,
        'xhdpi': 216,
        'xxhdpi': 324,
        'xxxhdpi': 432,
    }
    
    base_dir = 'android/app/src/main/res'
    for density, size in foreground_sizes.items():
        resized_foreground = resize_with_padding(source_img.copy(), size, None)
        if resized_foreground.mode != 'RGBA':
            resized_foreground = resized_foreground.convert('RGBA')
        mipmap_dir = f'{base_dir}/mipmap-{density}'
        os.makedirs(mipmap_dir, exist_ok=True)
        resized_foreground.save(f'{mipmap_dir}/ic_launcher_foreground.png', 'PNG', optimize=True)
    
    print("✅ Adaptive icon components generated")

def generate_ios_icons(source_icon_path):
    """Generate all iOS icon sizes"""
    print("🍎 Generating iOS icons...")
    
    source_img = Image.open(source_icon_path)
    bg_color = extract_background_color(source_img)
    
    # iOS icon sizes
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024,
    }
    
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(ios_dir, exist_ok=True)
    
    for filename, size in ios_sizes.items():
        print(f"  → {filename} ({size}×{size})...")
        resized = resize_with_padding(source_img.copy(), size, bg_color)
        resized.save(f'{ios_dir}/{filename}', 'PNG', optimize=True)
    
    print("✅ iOS icons generated")

def create_android_adaptive_xml():
    """Create Android adaptive icon XML files"""
    print("📱 Creating Android adaptive icon XML files...")
    
    anydpi_dir = 'android/app/src/main/res/mipmap-anydpi-v26'
    os.makedirs(anydpi_dir, exist_ok=True)
    
    xml_content = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>'''
    
    with open(f'{anydpi_dir}/ic_launcher.xml', 'w') as f:
        f.write(xml_content)
    
    with open(f'{anydpi_dir}/ic_launcher_round.xml', 'w') as f:
        f.write(xml_content)
    
    print("✅ Adaptive icon XML files created")

def update_colors_xml():
    """Update or create colors.xml with background color"""
    print("📱 Updating colors.xml...")
    
    colors_file = 'android/app/src/main/res/values/colors.xml'
    os.makedirs(os.path.dirname(colors_file), exist_ok=True)
    
    colors_xml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0A1D47</color>
</resources>'''
    
    with open(colors_file, 'w') as f:
        f.write(colors_xml)
    
    print("✅ colors.xml updated")

def create_ios_contents_json():
    """Create iOS Contents.json file"""
    print("🍎 Creating iOS Contents.json...")
    
    contents_json = '''{
  "images" : [
    {
      "filename" : "Icon-App-20x20@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-29x29@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-40x40@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-76x76@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-76x76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-App-1024x1024@1x.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}'''
    
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(ios_dir, exist_ok=True)
    
    with open(f'{ios_dir}/Contents.json', 'w') as f:
        f.write(contents_json)
    
    print("✅ Contents.json created")

def delete_existing_icons():
    """Delete existing icons before generating new ones"""
    print("🗑️  Cleaning existing icons...")
    
    # Delete Android mipmap folders
    android_res = 'android/app/src/main/res'
    if os.path.exists(android_res):
        for item in os.listdir(android_res):
            if item.startswith('mipmap-'):
                path = os.path.join(android_res, item)
                if os.path.isdir(path):
                    shutil.rmtree(path)
                    print(f"  → Deleted {path}")
    
    # Delete iOS AppIcon.appiconset contents (keep folder, delete PNGs)
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    if os.path.exists(ios_dir):
        for item in os.listdir(ios_dir):
            if item.endswith('.png'):
                path = os.path.join(ios_dir, item)
                os.remove(path)
                print(f"  → Deleted {path}")
    
    print("✅ Existing icons cleaned")

def show_preview_table(source_icon_path):
    """Show preview table of all generated icons"""
    source_img = Image.open(source_icon_path)
    
    print("\n" + "="*70)
    print("📊 ICON GENERATION PREVIEW TABLE")
    print("="*70)
    print(f"\n📁 Source Icon: {source_icon_path}")
    print(f"   Size: {source_img.size[0]}×{source_img.size[1]} pixels")
    print(f"   Mode: {source_img.mode}")
    
    print("\n📱 ANDROID ICONS")
    print("-" * 70)
    print(f"{'Density':<12} {'Size':<12} {'Files':<20} {'Location'}")
    print("-" * 70)
    android_sizes = [
        ('mdpi', 48, 'ic_launcher.png, ic_launcher_round.png, ic_launcher_foreground.png'),
        ('hdpi', 72, 'ic_launcher.png, ic_launcher_round.png, ic_launcher_foreground.png'),
        ('xhdpi', 96, 'ic_launcher.png, ic_launcher_round.png, ic_launcher_foreground.png'),
        ('xxhdpi', 144, 'ic_launcher.png, ic_launcher_round.png, ic_launcher_foreground.png'),
        ('xxxhdpi', 192, 'ic_launcher.png, ic_launcher_round.png, ic_launcher_foreground.png'),
    ]
    for density, size, files in android_sizes:
        print(f"{density:<12} {size}×{size:<6} {files:<20} mipmap-{density}/")
    
    print("\n📱 ANDROID ADAPTIVE ICONS")
    print("-" * 70)
    print("Component          Size        Location")
    print("-" * 70)
    print("foreground.png     432×432     assets/icon/generated/")
    print("background.png     1080×1080   assets/icon/generated/")
    print("ic_launcher.xml     -          mipmap-anydpi-v26/")
    print("ic_launcher_round.xml -        mipmap-anydpi-v26/")
    
    print("\n🍎 iOS ICONS")
    print("-" * 70)
    print(f"{'Filename':<30} {'Size':<12} {'Scale'}")
    print("-" * 70)
    ios_sizes = [
        ('Icon-App-20x20@1x.png', 20, '1x'),
        ('Icon-App-20x20@2x.png', 40, '2x'),
        ('Icon-App-20x20@3x.png', 60, '3x'),
        ('Icon-App-29x29@1x.png', 29, '1x'),
        ('Icon-App-29x29@2x.png', 58, '2x'),
        ('Icon-App-29x29@3x.png', 87, '3x'),
        ('Icon-App-40x40@1x.png', 40, '1x'),
        ('Icon-App-40x40@2x.png', 80, '2x'),
        ('Icon-App-40x40@3x.png', 120, '3x'),
        ('Icon-App-60x60@2x.png', 120, '2x'),
        ('Icon-App-60x60@3x.png', 180, '3x'),
        ('Icon-App-76x76@1x.png', 76, '1x'),
        ('Icon-App-76x76@2x.png', 152, '2x'),
        ('Icon-App-83.5x83.5@2x.png', 167, '2x'),
        ('Icon-App-1024x1024@1x.png', 1024, '1x'),
    ]
    for filename, size, scale in ios_sizes:
        print(f"{filename:<30} {size}×{size:<6} {scale}")
    
    print("\n" + "="*70)
    print("✅ All icons will be generated with EXACT uploaded image")
    print("   • No redesign or cropping")
    print("   • Centered on square canvas")
    print("   • Original background preserved")
    print("   • High quality (LANCZOS resampling)")
    print("="*70 + "\n")

def main():
    """Main processing function"""
    if len(sys.argv) < 2:
        print("Usage: python3 process_final_icon.py <icon_path>")
        print("Example: python3 process_final_icon.py uploaded_icon.png")
        sys.exit(1)
    
    source_icon_path = sys.argv[1]
    
    if not os.path.exists(source_icon_path):
        print(f"❌ Error: Icon file not found: {source_icon_path}")
        sys.exit(1)
    
    print("🎨 Processing FINAL app icon...")
    print(f"📁 Source: {source_icon_path}\n")
    
    # Show preview table
    show_preview_table(source_icon_path)
    
    # Delete existing icons
    delete_existing_icons()
    
    # Create generated directory
    os.makedirs('assets/icon/generated', exist_ok=True)
    
    # Generate all icons
    generate_android_icons(source_icon_path)
    generate_android_adaptive_icons(source_icon_path)
    generate_ios_icons(source_icon_path)
    create_android_adaptive_xml()
    update_colors_xml()
    create_ios_contents_json()
    
    print("\n✅ All icons generated and installed!")
    print("\n📋 Next steps - Run these commands:")
    print("  flutter clean")
    print("  rm -rf ios/Pods ios/Podfile.lock ios/Runner.xcworkspace")
    print("  flutter pub get")
    print("  cd ios && pod install && cd ..")
    print("  flutter build apk --release")

if __name__ == "__main__":
    main()

