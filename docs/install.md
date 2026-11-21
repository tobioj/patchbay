# Install

There are two ways to install Patchbay:

- **Download the app** (recommended): a ready-to-run app for macOS or Windows from the [latest release](https://github.com/tobioj/patchbay/releases/latest). Nothing else to install: Node.js comes inside it.
- **Run from source:** clone the repository, and a small launcher builds it and keeps it running. Best if you want to change the code or follow `main`.

Both work the same once they're running. This page covers both, plus adding your API keys, updating, moving and uninstalling.

**Contents:** [Download the app](#download-the-app) · [From source: requirements](#requirements) · [Mac](#mac) · [Windows](#windows) · [Add an API key](#add-an-api-key) · [What the launcher does](#what-the-launcher-does) · [Updating](#updating) · [Moving to a new folder or computer](#moving-to-a-new-folder-or-computer) · [Running without the launcher](#running-without-the-launcher) · [Uninstalling](#uninstalling)

## Download the app

| Download | For |
|---|---|
| **`Patchbay-macos-arm64.zip`** | Macs with Apple silicon (M1 and later) |
| **`Patchbay-macos-x64.zip`** | Intel Macs |
| **`Patchbay-windows-x64.zip`** | Most Windows PCs |
| **`Patchbay-windows-arm64.zip`** | Windows on Arm |
| `SHA256SUMS.txt` | Checksums, to verify a download |

Get them from the **[latest release](https://github.com/tobioj/patchbay/releases/latest)**. Each one includes its own copy of Node.js and a prebuilt Patchbay, about 40–55 MB.

### Mac app

1. Unzip the download and move **Patchbay.app** to your **Applications** folder.
2. Open it. Patchbay isn't notarized by Apple, so the first time macOS says it can't verify the app: open **System Settings → Privacy & Security**, scroll down and click **Open Anyway** (on older macOS, right-click the app → **Open**). You only do this once.
3. Patchbay opens in its own window (Google Chrome's app mode if Chrome is installed, otherwise your default browser). Add a key in **Settings → AI providers**; see [Add an API key](#add-an-api-key).

Your chats, projects and settings are kept in `~/Library/Application Support/Patchbay`, and keys in the Keychain. Closing the window leaves Patchbay running in the background so it reopens instantly; to stop it, run this in Terminal:

```bash
"/Applications/Patchbay.app/Contents/Resources/patchbay" stop
```

Want the short `patchbay` command (`patchbay stop`, `status`, `logs`…)? Link it once:

```bash
mkdir -p ~/.local/bin && ln -sf "/Applications/Patchbay.app/Contents/Resources/patchbay" ~/.local/bin/patchbay
```

(`~/.local/bin` must be on your `PATH`; open a new Terminal window afterwards.)

### Windows app

1. **Before unzipping**, right-click the zip → **Properties** → tick **Unblock** → **OK**. This stops Windows warning about every script inside a downloaded file.
2. Unzip it somewhere permanent, for example `%LOCALAPPDATA%\Programs\Patchbay` (not Downloads).
3. Double-click **Install Patchbay.cmd** in the folder. It adds **Patchbay** to your Desktop and Start menu and the `patchbay` command to new terminals, then opens Patchbay. If SmartScreen warns you, choose **More info → Run anyway**.
4. Add a key in **Settings → AI providers**; see [Add an API key](#add-an-api-key).

From then on, open **Patchbay** from the Desktop or Start menu. Your chats, projects, settings and (encrypted) keys are kept in `%LOCALAPPDATA%\Patchbay`. `patchbay stop` in a new terminal stops it. Terminal commands run without a sandbox on Windows, so nearly every command asks first; see [Security model → Terminal](security-model.md#terminal-commands).

### Updating the app

Stop Patchbay (`patchbay stop`), download the new release, and replace the app (Mac: replace **Patchbay.app** in Applications; Windows: replace the folder's contents). Your data stays where it is, outside the app.

### Already using Patchbay from source?

The downloaded app keeps its data in its own place (above), not in a clone's `data` folder. To bring your chats across, stop both, then copy the **contents** of the clone's `data` folder into `~/Library/Application Support/Patchbay` (Mac) or `%LOCALAPPDATA%\Patchbay` (Windows). Keys carry over on their own on a Mac (same Keychain); on Windows, paste them again. Both versions use port 3456, so run one at a time.

## From source

### Requirements

| | |
|---|---|
| **Operating system** | macOS (Apple silicon or Intel) or Windows 10/11 |
| **Node.js** | 20.9 or newer. The LTS version from [nodejs.org](https://nodejs.org) is the easiest choice. |
| **Git** | To clone the code and get updates ([git-scm.com](https://git-scm.com)). On a Mac, `git` offers to install itself the first time you run it. |
| **A browser** | Google Chrome (Mac) or Chrome / Edge (Windows) opens Patchbay as its own window, without tabs or an address bar. Without one, it opens in your default browser. |
| **An API key** | At least one of DeepSeek, Claude (Anthropic) or GLM (Z.ai). See [Providers](providers.md). |
| **Disk space** | About 1.5 GB for the code, its packages and the build. Your chats live in the `data` folder and grow with use. |

Put the app somewhere **permanent** (not Downloads). The `patchbay` command, the app shortcut and your saved chats (in the app's `data` folder) all live in that folder. A new terminal window starts in your user folder, which is a good place.

### Mac

In **Terminal**:

1. **Get the code.** This makes a `patchbay` folder:
   ```bash
   git clone https://github.com/tobioj/patchbay.git
   cd patchbay
   ```
2. **Install the app's packages** (a few minutes):
   ```bash
   npm ci
   ```
3. **Add the `patchbay` command and the Patchbay app** (Spotlight, Launchpad, Dock):
   ```bash
   zsh scripts/mac/install.sh
   ```
   This links `~/.local/bin/patchbay` to the launcher in this folder (so `git pull` keeps it current), adds `~/.local/bin` to your `PATH` in `~/.zshrc` if it isn't there yet, and builds `~/Applications/Patchbay.app`. Nothing else on your Mac is changed, and it's safe to run again.
4. **Open a new Terminal window**, then start the app:
   ```bash
   patchbay
   ```
   The first start builds the app. It takes a minute or two and only shows *Building the app…*. **Don't close the window or press Ctrl + C**; the app opens by itself when it's ready.

From then on, open **Patchbay** from Spotlight (⌘ Space) or run `patchbay`.

### Windows

In **PowerShell** or **Command Prompt**:

1. **Get the code.** This makes a `patchbay` folder:
   ```powershell
   git clone https://github.com/tobioj/patchbay.git
   cd patchbay
   ```
2. **Install the app's packages.** It takes a few minutes; the `npm warn` lines are normal:
   ```powershell
   npm ci
   ```
3. **Add the `patchbay` command and a Patchbay shortcut** on your Desktop and Start menu:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\windows\install.ps1
   ```
   This adds `scripts\windows` to *your* `PATH` (not the system-wide one) and creates the two shortcuts. Nothing else is changed, and it's safe to run again. `-ExecutionPolicy Bypass` applies to this one script only; your PowerShell settings stay as they are.
4. **Close the terminal and open a new one** (the old one doesn't see the new `PATH`), then start the app:
   ```powershell
   patchbay
   ```
   The first start builds the app, showing only *Building the app…*. Don't close the window or press Ctrl + C.

From then on, open **Patchbay** from the Desktop or Start menu, or run `patchbay`.

> **Windows differences.** Keys are encrypted with your Windows login instead of the macOS Keychain, the Save and folder dialogs are Windows' own, and terminal commands run in PowerShell **without a sandbox**, so every command except look-only ones asks you first. See [Security model → Terminal](security-model.md#terminal-commands).

## Add an API key

1. In the app, click **Settings** (bottom left) → **AI providers**.
2. Paste a key for **DeepSeek**, **Claude** or **GLM** (or several) and click **Save key**. Each key is tested right away.
3. Pick a model in the model menu next to the message box, and start chatting.

Where to get each key, what it costs and what each provider can do: [Providers](providers.md). How keys are stored: [Configuration → API keys](configuration.md#api-keys).

## What the launcher does

`patchbay` (the script in `scripts/mac/patchbay` or `scripts/windows/patchbay.ps1`) manages a background server on **http://127.0.0.1:3456**:

| Command | What it does |
|---|---|
| `patchbay` | Starts the server if it isn't running, then opens the app window |
| `patchbay start` | Starts the server only, without opening a window |
| `patchbay status` | Says whether the server is running, and lists any commands it started that are still running |
| `patchbay stop` | Stops every running command, then the server |
| `patchbay restart` | Stops, rebuilds if the code changed, and starts again |
| `patchbay logs` | Follows the server log (Ctrl + C to leave) |

When it starts the server, it:

1. installs the packages if `node_modules` is missing (log: `data/install.log`);
2. rebuilds if there's no build yet, or if any file in `app/`, `components/`, `lib/` or the config files is newer than the last build (log: `data/build.log`);
3. runs `npm start` in the background (log: `data/server.log`) and waits until `/api/health` answers.

Closing the app window **doesn't** stop the server or the commands it started, so the app reopens instantly. `patchbay stop` (or restarting the computer) stops everything.

## Updating

In a terminal, go to the app folder (`cd patchbay` from your user folder), then:

```bash
patchbay stop
git pull
npm ci
patchbay
```

1. `patchbay stop` stops the app. On Windows it **must** be stopped first, or `npm ci` fails because the app's files are in use.
2. `git pull` downloads the latest code.
3. `npm ci` makes the packages match the new `package-lock.json`. It's safe to run every time.
4. `patchbay` rebuilds with the new code (a minute or two) and opens the app.

Your chats, projects, skills, settings and keys are untouched by updates.

## Moving to a new folder or computer

A ZIP download can't get updates with `git pull`, so clone the app as above instead. To keep your chats, projects, skills and settings, copy the `data` folder across:

1. Stop the old copy: in the old folder, run `patchbay stop` (or `scripts\windows\patchbay.cmd stop` on Windows if the command isn't set up).
2. Copy the old folder's `data` folder into the new `patchbay` folder.
3. Run the [first-time steps](#mac) in the new folder. The setup points the command and the shortcut at the new folder.

The same works for another computer. **Keys don't travel:** on a Mac they're in the Keychain, and on Windows they're encrypted for your Windows account on that PC, so paste them again in **Settings** there.

## Running without the launcher

```bash
npm ci
npm run build
npm start
```

Then open http://127.0.0.1:3456. It runs only while that terminal stays open (Ctrl + C stops it, along with any commands it started), and you need `npm run build` again after every update. For development with live reload, see [Building from source](building.md).

## Uninstalling

**Downloaded app, Mac:** stop it (`"/Applications/Patchbay.app/Contents/Resources/patchbay" stop`), delete **Patchbay.app**, and delete `~/Library/Application Support/Patchbay` if you don't want your chats. Remove the keys with the `security` lines below.

**Downloaded app, Windows:** run `patchbay stop`, delete the **Patchbay** shortcuts, remove the Patchbay folder from your user `PATH` (see the Windows steps below), delete the folder, and delete `%LOCALAPPDATA%\Patchbay` if you don't want your chats and keys.

**From source, Mac:**

```bash
patchbay stop
rm -rf ~/Applications/Patchbay.app ~/.local/bin/patchbay
security delete-generic-password -s deepseek-api-key
security delete-generic-password -s anthropic-api-key
security delete-generic-password -s glm-api-key
security delete-generic-password -s tavily-api-key
security delete-generic-password -s github-token
```

Then delete the app folder (back up `data/` first if you want your chats). A `security` line that says the item couldn't be found just means that key was never saved.

**From source, Windows:** run `patchbay stop`, delete the **Patchbay** shortcuts from the Desktop and Start menu, remove the app's `scripts\windows` folder from your user `PATH` (Settings → System → About → Advanced system settings → Environment Variables), then delete the app folder. Keys are stored inside it (`data\secrets`), so they go with it.
