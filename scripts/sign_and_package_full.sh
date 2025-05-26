#!/bin/zsh

echo "🚀 macOS Installer Signing + Notarization Script (Full: .pkg + .dmg)"
echo ""

# Prompt for certificate names
read "?📦 Enter Developer ID Installer certificate (for signing the .pkg): " INSTALLER_CERT
read "?💾 Enter Developer ID Application certificate (for signing the .dmg): " APP_CERT

# Extract team ID from the installer certificate
TEAM_ID=$(echo "$INSTALLER_CERT" | grep -Eo '\(([A-Z0-9]{10})\)' | tr -d '()')
if [[ -z "$TEAM_ID" ]]; then
  echo "❌ Could not extract Team ID from Installer certificate."
  exit 1
fi
echo "✅ Using Team ID: $TEAM_ID"

# Apple account credentials
read "?📧 Enter your Apple Developer Apple ID: " APPLE_ID
read "?🔑 Enter your app-specific password (https://appleid.apple.com): " APP_SPECIFIC_PASSWORD
read "?💼 Enter a name for your notarytool profile (e.g. notary-profile): " PROFILE_NAME

echo "🔐 Storing credentials..."
xcrun notarytool store-credentials --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_SPECIFIC_PASSWORD" \
  --keychain-profile "$PROFILE_NAME"

# Package setup
read "?📁 What is the folder containing your unsigned .pkg (e.g. dmg_staging)? " STAGING_DIR
read "?📦 What is the name of your .pkg file (e.g. bootstrap-mac.pkg)? " PKG_NAME
read "?💾 What volume name should the DMG have (e.g. Bootstrap Installer)? " DMG_LABEL

SIGNED_PKG="signed-$PKG_NAME"
RW_DMG="rw.dmg"
FINAL_DMG="Bootstrap-final.dmg"

# Clean up old files
echo "🧼 Cleaning up..."
rm -f "$STAGING_DIR/$SIGNED_PKG" "$RW_DMG" "$FINAL_DMG"

# Sign and notarize .pkg
echo "🔏 Signing the .pkg..."
productsign --sign "$INSTALLER_CERT" "$STAGING_DIR/$PKG_NAME" "$STAGING_DIR/$SIGNED_PKG"

echo "📤 Notarizing the .pkg..."
xcrun notarytool submit "$STAGING_DIR/$SIGNED_PKG" --keychain-profile "$PROFILE_NAME" --wait

echo "📎 Stapling notarization ticket to .pkg..."
xcrun stapler staple "$STAGING_DIR/$SIGNED_PKG"

# Replace unsigned pkg with signed version
mv "$STAGING_DIR/$SIGNED_PKG" "$STAGING_DIR/$PKG_NAME"

# Build DMG
echo "📦 Creating writable DMG..."
hdiutil create -volname "$DMG_LABEL" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -format UDRW \
  -ov "$RW_DMG"

echo "📂 Mounting DMG — set background and icon layout manually now."
hdiutil attach "$RW_DMG"
read "?🖼️ Once you’ve set layout and ejected the volume, press Enter to continue..."

# Convert to read-only final DMG
echo "🔄 Converting to compressed final DMG..."
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG"

# Sign and notarize DMG
echo "🔏 Signing the final DMG..."
codesign --sign "$APP_CERT" --timestamp --options runtime "$FINAL_DMG"

echo "📤 Notarizing the DMG..."
xcrun notarytool submit "$FINAL_DMG" --keychain-profile "$PROFILE_NAME" --wait

echo "📎 Stapling notarization ticket to DMG..."
xcrun stapler staple "$FINAL_DMG"

echo ""
echo "✅ Done! Final notarized DMG: $FINAL_DMG"
echo "👉 It includes a notarized .pkg and is itself signed and notarized for Gatekeeper trust."
