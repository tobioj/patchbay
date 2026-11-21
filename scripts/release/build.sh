#!/bin/zsh
# Builds Patchbay's downloadable apps into dist/ (run on a Mac, from the app folder):
#   zsh scripts/release/build.sh
#
#   dist/Patchbay-macos-arm64.zip    Patchbay.app for Apple silicon Macs
#   dist/Patchbay-macos-x64.zip      Patchbay.app for Intel Macs
#   dist/Patchbay-windows-x64.zip    Patchbay folder for Windows (x64)
#   dist/Patchbay-windows-arm64.zip  Patchbay folder for Windows on Arm
#   dist/SHA256SUMS.txt              checksums for all of the above
#
# Each one carries an official Node.js runtime (downloaded from nodejs.org and checked against its
# SHA-256 sums) and a prebuilt, self-contained server (Next.js "standalone" output), so people
# don't need Node, Git or a build step. The server is built once from a clean copy of the tracked
# files (never your data/ folder), and contains no native modules, so the same build runs everywhere.
set -euo pipefail

NODE_VERSION="${NODE_VERSION:-v26.13.1}" # Node.js LTS bundled with the app
ROOT="${0:A:h:h:h}"
DIST="$ROOT/dist"
# Built in a fresh temp folder: Next records the build path in its output, so it mustn't be yours.
WORK=$(mktemp -d -t patchbay-release)
CACHE="$DIST/cache"
VERSION=$(node -p "require('$ROOT/package.json').version")

echo "Building Patchbay $VERSION with Node $NODE_VERSION"
rm -rf "$DIST/work" "$DIST"/Patchbay-*(N) "$DIST/SHA256SUMS.txt"
mkdir -p "$CACHE"
trap 'rm -rf "$WORK"' EXIT

# 1. A clean copy of the source: tracked and new files only, nothing ignored (no data/, .env, builds).
echo "• Copying the source"
SRC="$WORK/src"
mkdir -p "$SRC"
(cd "$ROOT" && git ls-files -z --cached --others --exclude-standard | while IFS= read -r -d '' f; do
  [[ -e "$f" ]] && rsync -R "$f" "$SRC/"
done)

# 2. Install and build the standalone server.
echo "• Installing packages"
(cd "$SRC" && npm ci --no-audit --no-fund --loglevel=error > "$WORK/install.log" 2>&1) || { cp "$WORK/install.log" "$DIST/install.log"; echo "npm ci failed: $DIST/install.log"; exit 1; }
echo "• Building the server"
(cd "$SRC" && PATCHBAY_RELEASE=1 NEXT_TELEMETRY_DISABLED=1 npx next build > "$WORK/build.log" 2>&1) || { cp "$WORK/build.log" "$DIST/build.log"; echo "Build failed: $DIST/build.log"; exit 1; }

# 3. The app payload: server.js, its node_modules and the compiled app, plus static files.
echo "• Assembling the payload"
PAYLOAD="$WORK/payload"
cp -R "$SRC/.next-release/standalone" "$PAYLOAD"
mkdir -p "$PAYLOAD/.next-release"
cp -R "$SRC/.next-release/static" "$PAYLOAD/.next-release/static"
cp -R "$SRC/public" "$PAYLOAD/public"
# Not needed at run time: sources, docs, scripts, config. (The compiled app is in .next-release.)
for x in app components lib docs scripts data CHEATSHEET.md AGENTS.md CLAUDE.md eslint.config.mjs \
         postcss.config.mjs tsconfig.json tsconfig.tsbuildinfo next-env.d.ts proxy.ts instrumentation.ts \
         next.config.ts package-lock.json .github .gitignore .gitattributes .claude; do
  rm -rf "$PAYLOAD/$x"
done
# Next's image optimizer (sharp) is native and per-platform; Patchbay doesn't use it.
rm -rf "$PAYLOAD/node_modules/sharp" "$PAYLOAD/node_modules/@img"
if [[ -n $(find "$PAYLOAD" -name "*.node" -print -quit) ]]; then
  echo "A native module ended up in the payload; it wouldn't run on other platforms:"; find "$PAYLOAD" -name "*.node"; exit 1
fi
cp "$ROOT/LICENSE" "$ROOT/NOTICE" "$PAYLOAD/"

# Downloads a Node.js archive into the cache and checks it against nodejs.org's SHASUMS256.txt.
fetch_node() {
  local file="$1"
  [[ -f "$CACHE/SHASUMS256-$NODE_VERSION.txt" ]] || curl -fsSL "https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt" -o "$CACHE/SHASUMS256-$NODE_VERSION.txt"
  [[ -f "$CACHE/$file" ]] || { echo "  downloading $file"; curl -fsSL "https://nodejs.org/dist/$NODE_VERSION/$file" -o "$CACHE/$file"; }
  local want=$(grep " $file\$" "$CACHE/SHASUMS256-$NODE_VERSION.txt" | cut -d' ' -f1)
  local got=$(shasum -a 256 "$CACHE/$file" | cut -d' ' -f1)
  [[ -n "$want" && "$want" == "$got" ]] || { echo "Checksum mismatch for $file"; rm -f "$CACHE/$file"; exit 1; }
}

# 4. macOS: Patchbay.app with the launcher, Node and the payload inside.
build_mac() {
  local arch="$1" out="$WORK/mac-$1"
  echo "• macOS $arch"
  local tarball="node-$NODE_VERSION-darwin-$arch.tar.gz"
  fetch_node "$tarball"
  local app="$out/Patchbay.app"
  mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
  tar -xzf "$CACHE/$tarball" -C "$out" "node-$NODE_VERSION-darwin-$arch/bin/node"
  mv "$out/node-$NODE_VERSION-darwin-$arch/bin/node" "$app/Contents/Resources/node"
  rm -rf "$out/node-$NODE_VERSION-darwin-$arch"
  cp -R "$PAYLOAD" "$app/Contents/Resources/app"
  cp "$ROOT/scripts/mac/patchbay" "$app/Contents/Resources/patchbay"
  cp "$ROOT/scripts/mac/patchbay.icns" "$app/Contents/Resources/Patchbay.icns"
  chmod +x "$app/Contents/Resources/patchbay" "$app/Contents/Resources/node"
  cat > "$app/Contents/MacOS/Patchbay" <<'EOF'
#!/bin/zsh
# Opening Patchbay.app: start the server if needed and open the window. Errors show in a dialog.
out=$("${0:A:h:h}/Resources/patchbay" open 2>&1) || osascript -e "display dialog \"Patchbay couldn't start:\n\n${out//\"/\\\"}\" buttons {\"OK\"} default button 1 with icon caution with title \"Patchbay\"" >/dev/null
EOF
  chmod +x "$app/Contents/MacOS/Patchbay"
  cat > "$app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Patchbay</string>
  <key>CFBundleDisplayName</key><string>Patchbay</string>
  <key>CFBundleIdentifier</key><string>io.github.tobioj.patchbay</string>
  <key>CFBundleExecutable</key><string>Patchbay</string>
  <key>CFBundleIconFile</key><string>Patchbay</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>13.5</string>
  <key>NSHumanReadableCopyright</key><string>Copyright © 2026 Oluwatobi Ojulari. Apache License 2.0.</string>
</dict>
</plist>
EOF
  # Ad-hoc signature (not notarized): macOS asks once before the first open.
  codesign --force --deep --sign - "$app" >/dev/null 2>&1 || true
  (cd "$out" && ditto -c -k --keepParent "Patchbay.app" "$DIST/Patchbay-macos-$arch.zip")
}

# 5. Windows: a Patchbay folder with node.exe, the payload, the launcher and the installer.
build_windows() {
  local arch="$1" out="$WORK/win-$1"
  echo "• Windows $arch"
  local zip="node-$NODE_VERSION-win-$arch.zip"
  fetch_node "$zip"
  local dir="$out/Patchbay"
  mkdir -p "$dir"
  unzip -q -j "$CACHE/$zip" "node-$NODE_VERSION-win-$arch/node.exe" -d "$dir"
  cp -R "$PAYLOAD" "$dir/app"
  for f in patchbay.ps1 patchbay.cmd install.ps1 patchbay.ico; do cp "$ROOT/scripts/windows/$f" "$dir/$f"; done
  # Windows line endings for the scripts, whatever the checkout used.
  for f in patchbay.ps1 patchbay.cmd install.ps1; do perl -pi -e 's/\r?\n/\r\n/' "$dir/$f"; done
  printf '@echo off\r\nREM Double-click to set up Patchbay: Desktop and Start menu shortcuts, and the patchbay command.\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%%~dp0install.ps1"\r\nif errorlevel 1 pause & exit /b 1\r\ncall "%%~dp0patchbay.cmd"\r\n' > "$dir/Install Patchbay.cmd"
  (cd "$out" && zip -qr -X "$DIST/Patchbay-windows-$arch.zip" "Patchbay")
}

build_mac arm64
build_mac x64
build_windows x64
build_windows arm64

echo "• Checksums"
(cd "$DIST" && shasum -a 256 Patchbay-*.zip > SHA256SUMS.txt)
echo ""
ls -lh "$DIST"/Patchbay-*.zip "$DIST/SHA256SUMS.txt" | awk '{print $5, $9}'
echo "Done: Patchbay $VERSION"
