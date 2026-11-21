#!/bin/zsh
# One-time setup for macOS. Run from the app folder:
#   zsh scripts/mac/install.sh
# It adds the `patchbay` command and a "Patchbay" app (Spotlight, Launchpad, Dock).
# Nothing else on your Mac is changed. Run it again any time; it's safe.
set -e
HERE="${0:A:h}"
BIN="$HOME/.local/bin"
APP="$HOME/Applications/Patchbay.app"

# 1. The `patchbay` command: a link to the script in this folder, so `git pull` keeps it up to date.
mkdir -p "$BIN"
chmod +x "$HERE/patchbay"
if [[ -e "$BIN/patchbay" && ! -L "$BIN/patchbay" ]]; then
  mv "$BIN/patchbay" "$BIN/patchbay.backup"
  echo "Kept your previous patchbay as $BIN/patchbay.backup"
fi
ln -sfn "$HERE/patchbay" "$BIN/patchbay"
echo "Added the command: $BIN/patchbay"

# 2. Make sure new terminals can find it.
if [[ ":$PATH:" != *":$BIN:"* ]] && ! grep -qs '\.local/bin' "$HOME/.zshrc" "$HOME/.zprofile"; then
  printf '\n# patchbay\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.zshrc"
  echo "Added ~/.local/bin to your PATH (in ~/.zshrc). Open a new terminal to use: patchbay"
fi

# 3. The app, so you can open it from Spotlight, Launchpad or the Dock. It just runs patchbay.
mkdir -p "$HOME/Applications"
rm -rf "$APP"
osacompile -o "$APP" 2> >(grep -v "replacing existing signature" >&2) -e '
try
	do shell script "$HOME/.local/bin/patchbay"
on error errMsg
	display dialog "Patchbay couldn’t start:" & return & return & errMsg buttons {"OK"} default button 1 with icon caution
end try'
cp "$HERE/patchbay.icns" "$APP/Contents/Resources/applet.icns"
plutil -replace CFBundleIdentifier -string com.local.patchbay "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true
touch "$APP"
mdimport "$APP" >/dev/null 2>&1 || true
echo "Added the app: $APP"

# 4. Patchbay used to be called DeepSeek Chat: take away the old command and app if they're here.
#    (The separate `deepseek` command, which runs Claude Code on DeepSeek, isn't touched.)
OLD_BIN="$BIN/deepseek-chat"
OLD_APP="$HOME/Applications/DeepSeek Chat.app"
if [[ -L "$OLD_BIN" ]]; then
  rm -f "$OLD_BIN"
  echo "Removed the old command: $OLD_BIN (use patchbay now)"
elif [[ -e "$OLD_BIN" ]]; then
  mv "$OLD_BIN" "$OLD_BIN.backup"
  echo "Kept your old deepseek-chat as $OLD_BIN.backup (use patchbay now)"
fi
if [[ -d "$OLD_APP" ]]; then
  rm -rf "$OLD_APP"
  echo "Removed the old app: $OLD_APP"
fi

echo ""
echo "Done. Open Patchbay from Spotlight (⌘ Space), or run: patchbay"
