#!/usr/bin/env python3
"""
Process uploaded app icon and generate all required sizes for Android and iOS
"""

try:
    from PIL import Image, ImageDraw
    import os
    import sys
    import shutil
except ImportError:
    print("❌ PIL/Pillow not installed. Install with: pip3 install Pillow")
    sys.exit(1)

# Colors
NAVY_BLUE = (10, 29, 71)  # #0A1D47

def resize_with_padding(img, target_size, background_color=(255, 255, 255)):
    """Resize image maintaining aspect ratio, add padding if needed"""
    img.thumbnail((target_size, target_size), Image.Resampling.LANCZOS)
    
    # Create new image with target size and background
    new_img = Image.new('RGB', (target_size, target_size), background_color)
    
    # Calculate position to center the image
    x = (target_size - img.width) // 2
    y = (target_size - img.height) // 2
    
    # Paste the resized image centered
    if img.mode == 'RGBA':
        new_img.paste(img, (x, y), img)
    else:
        new_img.paste(img, (x, y))
    
    return new_img

def generate_android_icons(source_icon_path):
    """Generate all Android icon sizes"""
    print("📱 Generating Android icons...")
    
    source_img = Image.open(source_icon_path)
    
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
        print(f"  → Creating mipmap-{density}/ic_launcher.png ({size}×{size})...")
        
        # Resize icon
        resized = resize_with_padding(source_img.copy(), size, NAVY_BLUE)
        
        # Create mipmap directory
        mipmap_dir = f'{base_dir}/mipmap-{density}'
        os.makedirs(mipmap_dir, exist_ok=True)
        
        # Save launcher icon
        resized.save(f'{mipmap_dir}/ic_launcher.png', 'PNG', optimize=True)
        
        # Save round version (same image)
        resized.save(f'{mipmap_dir}/ic_launcher_round.png', 'PNG', optimize=True)
        
        # Generate foreground for adaptive icon (scaled appropriately)
        foreground_size = int(size * 2.25)  # Standard foreground size ratio
        foreground = resize_with_padding(source_img.copy(), foreground_size, (0, 0, 0, 0))
        # Convert to RGBA if needed
        if foreground.mode != 'RGBA':
            foreground = foreground.convert('RGBA')
        foreground.save(f'{mipmap_dir}/ic_launcher_foreground.png', 'PNG', optimize=True)
    
    print("✅ Android icons generated")

def generate_android_adaptive_icons(source_icon_path):
    """Generate Android adaptive icon components"""
    print("📱 Generating Android adaptive icon components...")
    
    source_img = Image.open(source_icon_path)
    
    # Foreground: 432×432
    print("  → Creating foreground.png (432×432)...")
    foreground = resize_with_padding(source_img.copy(), 432, (0, 0, 0, 0))
    if foreground.mode != 'RGBA':
        foreground = foreground.convert('RGBA')
    foreground.save('assets/icon/generated/foreground.png', 'PNG', optimize=True)
    
    # Background: 1080×1080 solid navy
    print("  → Creating background.png (1080×1080)...")
    background = Image.new('RGB', (1080, 1080), NAVY_BLUE)
    background.save('assets/icon/generated/background.png', 'PNG', optimize=True)
    
    # Copy foreground to all mipmap densities
    foreground_sizes = {
        'mdpi': 108,
        'hdpi': 162,
        'xhdpi': 216,
        'xxhdpi': 324,
        'xxxhdpi': 432,
    }
    
    base_dir = 'android/app/src/main/res'
    for density, size in foreground_sizes.items():
        resized_foreground = resize_with_padding(source_img.copy(), size, (0, 0, 0, 0))
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
        print(f"  → Creating {filename} ({size}×{size})...")
        resized = resize_with_padding(source_img.copy(), size, NAVY_BLUE)
        resized.save(f'{ios_dir}/{filename}', 'PNG', optimize=True)
    
    print("✅ iOS icons generated")

def create_android_adaptive_xml():
    """Create Android adaptive icon XML files"""
    print("📱 Creating Android adaptive icon XML files...")
    
    anydpi_dir = 'android/app/src/main/res/mipmap-anydpi-v26'
    os.makedirs(anydpi_dir, exist_ok=True)
    
    # ic_launcher.xml
    ic_launcher_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>'''
    
    with open(f'{anydpi_dir}/ic_launcher.xml', 'w') as f:
        f.write(ic_launcher_xml)
    
    # ic_launcher_round.xml (same content)
    with open(f'{anydpi_dir}/ic_launcher_round.xml', 'w') as f:
        f.write(ic_launcher_xml)
    
    print("✅ Adaptive icon XML files created")

def update_colors_xml():
    """Update or create colors.xml with background color"""
    print("📱 Updating colors.xml...")
    
    colors_file = 'android/app/src/main/res/values/colors.xml'
    os.makedirs(os.path.dirname(colors_file), exist_ok=True)
    
    colors_xml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0A3D91</color>
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

def show_preview_grid(source_icon_path):
    """Show preview of generated icons"""
    print("\n" + "="*60)
    print("📊 ICON PREVIEW GRID")
    print("="*60)
    
    source_img = Image.open(source_icon_path)
    print(f"\nSource Icon: {source_img.size[0]}×{source_img.size[1]} pixels")
    
    print("\n📱 Android Icons:")
    android_sizes = [48, 72, 96, 144, 192]
    for size in android_sizes:
        print(f"  ✓ {size}×{size} (mipmap)")
    
    print("\n🍎 iOS Icons:")
    ios_sizes = [20, 29, 40, 60, 76, 83.5, 1024]
    for size in ios_sizes:
        print(f"  ✓ {size}×{size}")
    
    print("\n📐 Adaptive Icon Components:")
    print("  ✓ Foreground: 432×432")
    print("  ✓ Background: 1080×1080 (solid navy)")
    
    print("\n" + "="*60)

def main():
    """Main processing function"""
    if len(sys.argv) < 2:
        print("Usage: python3 process_uploaded_icon.py <icon_path>")
        print("Example: python3 process_uploaded_icon.py uploaded_icon.png")
        sys.exit(1)
    
    source_icon_path = sys.argv[1]
    
    if not os.path.exists(source_icon_path):
        print(f"❌ Error: Icon file not found: {source_icon_path}")
        sys.exit(1)
    
    print("🎨 Processing uploaded app icon...")
    print(f"📁 Source: {source_icon_path}\n")
    
    # Show preview
    show_preview_grid(source_icon_path)
    
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
    print("\n📋 Next steps:")
    print("  1. Review the generated icons")
    print("  2. Run: flutter clean")
    print("  3. Run: flutter pub get")
    print("  4. Run: cd ios && pod install && cd ..")
    print("  5. Run: flutter build apk --release")

if __name__ == "__main__":
    main()

