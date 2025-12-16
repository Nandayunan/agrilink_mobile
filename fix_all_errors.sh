#!/bin/bash

# ============================================
# AGRI-LINK AUTOMATED FIX SCRIPT (macOS/Linux)
# This script fixes all import and dependency errors
# ============================================

echo ""
echo "========================================"
echo "  AGRI-LINK ERROR FIX SCRIPT"
echo "========================================"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: $SCRIPT_DIR"

# Check if we're in the right directory
if [ ! -d "$SCRIPT_DIR/agri_link_app" ]; then
    echo "ERROR: agri_link_app folder not found!"
    echo "Expected location: $SCRIPT_DIR/agri_link_app"
    exit 1
fi

echo ""
echo "========================================"
echo "  STEP 1: CLEAN FLUTTER CACHE"
echo "========================================"
echo ""
cd "$SCRIPT_DIR/agri_link_app" || exit 1
echo "Current directory: $(pwd)"
echo ""
echo "Running: flutter clean"
flutter clean
if [ $? -ne 0 ]; then
    echo "ERROR: flutter clean failed!"
    exit 1
fi
echo "Clean completed successfully!"

echo ""
echo "========================================"
echo "  STEP 2: GET DEPENDENCIES"
echo "========================================"
echo ""
echo "Running: flutter pub get"
echo "This may take 2-5 minutes on first run..."
echo ""
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: flutter pub get failed!"
    exit 1
fi
echo "Dependencies installed successfully!"

echo ""
echo "========================================"
echo "  STEP 3: VERIFY INSTALLATION"
echo "========================================"
echo ""
echo "Running: flutter pub list"
echo ""
flutter pub list
echo ""

echo ""
echo "========================================"
echo "  STEP 4: ANALYZE CODE"
echo "========================================"
echo ""
echo "Running: flutter analyze"
echo "This checks for remaining errors..."
echo ""
flutter analyze

echo ""
echo "========================================"
echo "  STEP 5: CHECK FLUTTER HEALTH"
echo "========================================"
echo ""
flutter doctor -v

echo ""
echo "========================================"
echo "  SETUP COMPLETE!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Open emulator or connect device"
echo "2. Run: flutter run"
echo "3. App should open without errors!"
echo ""
echo "If you still see errors:"
echo "- Make sure Flutter SDK is up to date: flutter upgrade"
echo "- Check QUICK_FIX_GUIDE.md for troubleshooting"
echo ""
