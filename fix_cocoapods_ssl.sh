#!/bin/bash
set -e

echo "🔧 Reinstalling CA certificates..."
brew reinstall ca-certificates

echo "🔐 Setting SSL cert paths..."
export SSL_CERT_FILE=$(brew --prefix)/etc/ca-certificates/cert.pem
export SSL_CERT_DIR=$(brew --prefix)/etc/ca-certificates/certs

echo "📂 Navigating to iOS folder..."
cd ~/Documents/Projects/coachguru_3_0/ios

echo "🧹 Cleaning CocoaPods cache and lock files..."
pod deintegrate || true
rm -rf Pods Podfile.lock

echo "📦 Updating CocoaPods repo..."
pod repo update || true

echo "🔁 Installing pods with trusted SSL..."
sudo SSL_CERT_FILE=$(brew --prefix)/etc/ca-certificates/cert.pem pod install --repo-update

echo "✅ Pods successfully installed!"

echo "🚀 Building Flutter iOS (no codesign)..."
cd ..
flutter clean
flutter pub get
flutter build ios --no-codesign

echo "🎉 Done! Your iOS project is ready."

