#!/bin/bash
# Vercel install script for Flutter Web admin app
# Installs Flutter SDK and dependencies

set -e

echo "=== Vercel Install: Admin Web ==="

# Install Flutter
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

echo "=== Install Complete ==="
