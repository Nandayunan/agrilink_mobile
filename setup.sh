#!/bin/bash
# Setup script untuk Agri-Link

echo "========================================="
echo "  AGRI-LINK - Setup Script"
echo "========================================="
echo ""

# Backend Setup
echo "1. Setting up Backend..."
cd agri_link_backend

if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "✓ .env file created"
    echo "⚠️  Please update .env with your database credentials"
fi

if [ ! -d node_modules ]; then
    echo "Installing npm packages..."
    npm install
    echo "✓ npm packages installed"
else
    echo "✓ npm packages already installed"
fi

echo ""
echo "2. Database Setup"
echo "⚠️  Please:"
echo "   1. Start MySQL in XAMPP"
echo "   2. Open http://localhost/phpmyadmin"
echo "   3. Import database.sql from agri_link_backend folder"
echo "   4. Verify connection in .env file"
echo ""

cd ..

# Flutter Setup
echo "3. Setting up Flutter App..."
cd agri_link_app

if [ ! -d pubspec.lock ]; then
    echo "Getting Flutter dependencies..."
    flutter pub get
    echo "✓ Flutter dependencies installed"
else
    echo "✓ Flutter dependencies already installed"
fi

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Backend: cd agri_link_backend && npm run dev"
echo "2. Frontend: cd agri_link_app && flutter run"
echo ""
