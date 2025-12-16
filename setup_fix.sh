#!/bin/bash

# AGRI-LINK SETUP SCRIPT - PERBAIKAN DEPENDENCIES

echo "================================"
echo "AGRI-LINK - SETUP LENGKAP"
echo "================================"

# 1. Setup Backend
echo ""
echo "📦 Setting up BACKEND..."
cd agri_link_backend
npm install
echo "✅ Backend dependencies installed"

# 2. Setup Frontend
echo ""
echo "📱 Setting up FRONTEND..."
cd ../agri_link_app
flutter clean
echo "✅ Cleaned Flutter cache"

flutter pub get
echo "✅ Flutter dependencies installed"

# 3. Verify setup
echo ""
echo "🔍 Verifying setup..."
echo ""
echo "Backend packages:"
cd ../agri_link_backend
npm list --depth=0

echo ""
echo "Flutter packages:"
cd ../agri_link_app
flutter pub list

echo ""
echo "================================"
echo "✅ SETUP SELESAI!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Backend: cd agri_link_backend && npm run dev"
echo "2. Frontend: cd agri_link_app && flutter run"
echo ""
