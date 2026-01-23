#!/bin/bash
set -e

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Install Flutter if not already installed
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
  export PATH="$HOME/flutter/bin:$PATH"
  flutter precache --web
  flutter --version
fi

# Navigate to project directory
cd /opt/build/repo

# Get dependencies and build
flutter pub get
flutter build web --release

echo "Build completed successfully!"

