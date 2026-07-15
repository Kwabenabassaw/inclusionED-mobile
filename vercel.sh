#!/bin/bash
# Script to build Flutter web app on Vercel

echo "Checking for Flutter..."
if cd flutter; then
  echo "Flutter already installed, updating..."
  git pull
  cd ..
else
  echo "Cloning Flutter repository..."
  git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to the PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Build the web application
echo "Building Flutter web..."
flutter build web --release
