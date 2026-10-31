#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache"
version="0.1.0"
options=(--disable-sandbox --cache-path .build/cache --scratch-path .build -c release --product Nudi)
label="$(uname -m)"
if [[ "${1:-}" == "--universal" ]]; then
  options+=(--arch arm64 --arch x86_64)
  label="universal"
elif [[ $# -gt 0 ]]; then
  printf 'Usage: %s [--universal]\n' "$0" >&2
  exit 1
fi
swift build "${options[@]}"
binary_dir="$(swift build "${options[@]}" --show-bin-path)"
app="$PWD/dist/Nudi.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$binary_dir/Nudi" "$app/Contents/MacOS/Nudi"
cat > "$app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>Nudi</string>
  <key>CFBundleIdentifier</key><string>io.github.j611062000.nudi</string>
  <key>CFBundleName</key><string>Nudi</string>
  <key>CFBundleDisplayName</key><string>Nudi</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$version</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleLocalizations</key><array><string>en</string><string>zh-Hant</string></array>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSSupportsAutomaticGraphicsSwitching</key><true/>
</dict></plist>
EOF
iconset="$PWD/.build/AppIcon.iconset"
mkdir -p "$iconset"
"$app/Contents/MacOS/Nudi" --render-icon "$iconset/icon_512x512@2x.png"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$iconset/icon_512x512@2x.png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
  if [[ "$size" -lt 512 ]]; then
    doubled=$((size * 2))
    sips -z "$doubled" "$doubled" "$iconset/icon_512x512@2x.png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
  fi
done
iconutil -c icns "$iconset" -o "$app/Contents/Resources/AppIcon.icns"
plutil -lint "$app/Contents/Info.plist"
# Finder/iCloud can add bundle metadata that codesign rejects. Remove only
# these packaging attributes on our generated app; never strip quarantine.
xattr -dr com.apple.FinderInfo "$app" 2>/dev/null || true
xattr -dr com.apple.ResourceFork "$app" 2>/dev/null || true
codesign --force --sign - --timestamp=none "$app"
codesign --verify --deep --strict "$app"
archive="$PWD/dist/Nudi-$version-macOS-$label.zip"
ditto -c -k --keepParent "$app" "$archive"
shasum -a 256 "$archive" | sed "s|$PWD/dist/||" > "$archive.sha256"
printf '\nApp: %s\nArchive: %s\n' "$app" "$archive"
