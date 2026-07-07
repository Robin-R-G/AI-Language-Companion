#!/bin/bash
# Vercel build script for Flutter Web admin app
# Builds the web release

set -e

echo "=== Vercel Build: Admin Web ==="

# Ensure Flutter is in PATH
export PATH="/tmp/flutter/bin:$PATH"

# Build web release
flutter build web --release --no-tree-shake-icons

echo "=== Build Complete ==="
echo "Output: build/web/"
