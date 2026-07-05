#!/usr/bin/env bash
# Builds, installs and launches the native iOS app (RIM KMP) on an iOS simulator.
# The native iOS app links the logic-only `RimLogic` framework and renders a
# SwiftUI/TCA UI (the `tokmp1` sharing pattern).
#
# Usage: ./rim_ios/run.sh [simulator-name]
set -euo pipefail

SIMULATOR_NAME="${1:-iPhone 17}"
BUNDLE_ID="com.rim.ios"
SCHEME="App"
# Keep xcodebuild's DerivedData out of Tuist's own "Derived/" folder to avoid clashes.
DERIVED_DATA="./.xcode-derived"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Generating Xcode project (tuist)"
tuist generate --no-open

echo "==> Booting simulator: $SIMULATOR_NAME"
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
open -a Simulator || true

echo "==> Building $SCHEME"
xcodebuild \
    -workspace rim_ios.xcworkspace \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
    -derivedDataPath "$DERIVED_DATA" \
    -skipMacroValidation \
    build

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/${SCHEME}.app"

echo "==> Installing and launching $BUNDLE_ID"
xcrun simctl install "$SIMULATOR_NAME" "$APP_PATH"
xcrun simctl launch "$SIMULATOR_NAME" "$BUNDLE_ID"
