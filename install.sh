#!/bin/bash

# Exit on error
set -e

# Download Flutter SDK (stable channel)
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter doctor (optional)
flutter doctor

# Enable web support
flutter config --enable-web
flutter pub get
