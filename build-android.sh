#!/bin/zsh

echo "🏗  Building CoachGuru APK..."

# Clean the project
echo ""
echo "📦 Cleaning project..."
flutter clean

# Get dependencies
echo ""
echo "📥 Getting dependencies..."
flutter pub get

# Build the Android release APK
echo ""
echo "🔨 Building release APK..."
flutter build apk --release

# Check if build was successful
if [ $? -ne 0 ]; then
  echo ""
  echo "❌ Build failed!"
  exit 1
fi

# Create folder on Desktop
echo ""
echo "📁 Creating output directory..."
mkdir -p ~/Desktop/CoachGuru_APK

# Copy the generated APK
echo ""
echo "📋 Copying APK to Desktop..."
cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/CoachGuru_APK/CoachGuru.apk

# Check if copy was successful
if [ $? -eq 0 ]; then
  echo ""
  echo "✅ APK created on Desktop → CoachGuru_APK/CoachGuru.apk"
  echo ""
  echo "📊 APK Size: $(du -h ~/Desktop/CoachGuru_APK/CoachGuru.apk | cut -f1)"
else
  echo ""
  echo "❌ Failed to copy APK!"
  exit 1
fi

