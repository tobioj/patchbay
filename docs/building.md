# Building from source

Everything you need to work on Patchbay's code. For a tour of how it fits together, read [Architecture](architecture.md) first.

**Contents:** [Toolchain](#toolchain) · [Get the code](#get-the-code) · [Development server](#development-server) · [A separate data folder](#a-separate-data-folder) · [Checks](#checks) · [Production build](#production-build) · [Project conventions](#project-conventions) · [Working on the launchers](#working-on-the-launchers) · [Updating model prices and lists](#updating-model-prices-and-lists) · [Icons and branding](#icons-and-branding) · [Releasing](#releasing)

## Toolchain

| Tool | Version | Notes |
|---|---|---|
| Node.js | 20.9 or newer | The LTS from [nodejs.org](https://nodejs.org) |
| npm | Comes with Node | The repo uses `package-lock.json`; use `npm ci` |
| Git | Any recent | |
| macOS or Windows | | Native dialogs, key storage and the terminal sandbox are platform-specific. On Linux the app runs, but without native dialogs, keychain or sandbox. |
| Chrome or Edge | Optional | For the `--app` window |

The stack is **Next.js 16** (App Router), **React 19**, **TypeScript 5** and **Tailwind CSS 4**.

> **Next.js 16 is newer than most guides.** Some APIs and conventions changed (for example `proxy.ts` replaces `middleware.ts`, and route handlers use the global `RouteContext` type). The Next docs for the exact installed version are in `node_modules/next/dist/docs/`; check them before writing framework code. `AGENTS.md` says the same for AI coding tools.

## Get the code

```bash
git clone https://github.com/tobioj/patchbay.git
cd patchbay
npm ci
```

## Development server

```bash
npm run dev
```

Opens **http://127.0.0.1:3455** with hot reload. The everyday app (via `patchbay`) runs on **3456**, so both can run at the same time.

## A separate data folder

By default **the dev server and the everyday app share the same `data/` folder**, so your real chats, projects and settings are visible (and editable) from the dev server. To work against a scratch copy, point `DATA_DIR` somewhere else:

```bash
DATA_DIR=/tmp/patchbay-dev npm run dev
```

On Windows PowerShell: `$env:DATA_DIR="$env:TEMP\patchbay-dev"; npm run dev`.

The folder is created as needed. API keys still come from the Keychain / DPAPI (or environment variables), not from the data folder, so the scratch copy can use your keys. Leave **Settings → AI providers** alone there if you don't want to change them.

## Checks

There's no automated test suite yet. Before opening a pull request, run:

```bash
npm run typecheck   # tsc --noEmit
npm run lint        # eslint
npm run build       # a production build must succeed
```

Then test the change in the real app: `patchbay restart` rebuilds the everyday app from your working copy. If you touched folders, edits, approvals, the terminal, helpers or a provider, run the relevant sections of the [testing checklist](testing.md). Adding automated tests is very welcome; see the [roadmap](roadmap.md).

## Production build

```bash
npm run build
npm start          # http://127.0.0.1:3456
```

`patchbay` does this for you, and rebuilds automatically whenever a file in `app/`, `components/`, `lib/` or the config files is newer than the last build (`.next/BUILD_ID`). Build output goes to `data/build.log` when the launcher builds.

`next.config.ts` keeps `unpdf` and `mammoth` as server-external packages, and raises `proxyClientMaxBodySize` to 200 MB, because `proxy.ts` buffers request bodies and attachments can be large.

## Project conventions

- **Server vs browser.** Anything that touches keys, files, commands or the network lives in `lib/` and starts with `import "server-only"`, so it can never end up in the browser bundle. `lib/types.ts`, `lib/models.ts`, `lib/tokens.ts` and `lib/client.ts` are shared.
- **State shared between routes goes on `globalThis`.** Next bundles each API route separately in one process; see [Architecture → Storage](architecture.md#storage).
- **JSON writes are atomic** (temp file + rename), and chat updates go through `updateChat()` so concurrent writers can't clobber each other.
- **Every tool is described once** (its OpenAI-style definition in the tool's `lib/` file); `ClaudeSession` converts them for Claude.
- **Permissions only narrow.** New capabilities need a per-provider switch (`ProviderLimits`), must be greyed out in the UI when off, and default to **off** for providers other than DeepSeek.
- **User-facing text is plain and friendly:** say what happened and what to do next. Error messages per provider live in `lib/deepseek.ts`, `lib/glm.ts` and `lib/claude.ts`.
- **Comments explain why.** File headers say what the file is for; keep them current.
- **Style:** the ESLint config (`eslint.config.mjs`, `eslint-config-next`) and the existing code. Tailwind classes use the colour tokens from `app/globals.css` (`bg-app`, `text-muted`, `accent`…), never raw colours, so light and dark mode both work.

## Working on the launchers

| File | What it is |
|---|---|
| `scripts/mac/patchbay` | The macOS launcher (zsh). Linked to `~/.local/bin/patchbay` by `install.sh`. Must keep LF line endings (`.gitattributes`). |
| `scripts/mac/install.sh` | Adds the command and builds `~/Applications/Patchbay.app` with `osacompile`, and sets its icon and bundle id |
| `scripts/windows/patchbay.ps1` | The Windows launcher (PowerShell). Must keep CRLF line endings. |
| `scripts/windows/patchbay.cmd` | Runs `patchbay.ps1` with `-ExecutionPolicy Bypass`, so it works without changing PowerShell settings |
| `scripts/windows/install.ps1` | Adds the user `PATH` entry and the Desktop / Start menu shortcuts |

The launchers find the server by port (`3456`), not by process name, because the Next server renames its process. `stop` first asks the app to stop running commands (`POST /api/processes {"action":"stop_all"}`) so it can confirm they're gone, then stops the server. Test launcher changes on both systems if you can; say in the PR if you couldn't.

## Updating model prices and lists

| What | Where |
|---|---|
| Claude prices | `CLAUDE_PRICES` in `lib/models.ts` (matched by the longest id prefix) |
| DeepSeek and GLM prices, DeepSeek peak hours | `lib/tokens.ts` |
| DeepSeek and GLM models (ids, labels, context, efforts, vision) | `DEEPSEEK_MODELS`, `GLM_MODELS` in `lib/models.ts` |
| Claude models | Nothing to do: the list comes from the Models API for each user's key |
| Web search prices | `WEB_SEARCH_PRICE` (Claude) in `lib/models.ts`; DeepSeek search in `lib/websearch.ts` |

Note the source and month in the comment above each table, as the existing ones do.

## Icons and branding

The logo master is `docs/assets/patchbay-logo.png`. Derived files:

| File | Used for |
|---|---|
| `app/icon.png` (512×512) | Browser icon and web manifest |
| `public/logo.png` (256×256) | The sidebar, the welcome screen, the README |
| `scripts/mac/patchbay.icns` | The Mac app |
| `scripts/windows/patchbay.ico` (16–256 px) | The Windows shortcuts |

The accent colour (`--accent` in `app/globals.css`, `#6c4ee6` light / `#8d72ff` dark) comes from the logo's violet.

## Releasing

A release is a tagged commit plus downloadable apps for macOS and Windows.

1. Update `version` in `package.json` and `package-lock.json`.
2. Run the [checks](#checks) and the [testing checklist](testing.md) on a Mac and a Windows PC.
3. Build the downloads on a Mac:
   ```bash
   zsh scripts/release/build.sh
   ```
   It writes `Patchbay-macos-arm64.zip`, `Patchbay-macos-x64.zip`, `Patchbay-windows-x64.zip`, `Patchbay-windows-arm64.zip` and `SHA256SUMS.txt` to `dist/` (ignored by Git).
4. Test at least the download for your own machine: unzip it, open it, send a message, run a command in a project.
5. Commit, tag `vX.Y.Z`, push the tag, and publish a GitHub release with the five files attached and notes: what's new, anything users must do when updating, and known issues.

### How the downloads are built

`scripts/release/build.sh`:

1. **Copies the source** (tracked and new files only, so never `data/`, `.env` or builds) into a fresh temp folder. Next.js records the build path in its output, so building there keeps your own paths out of the release.
2. **Installs and builds** with `PATCHBAY_RELEASE=1`, which makes `next.config.ts` produce a **standalone** server (`.next-release/standalone/server.js` with only the `node_modules` it needs) and turns off image optimization.
3. **Assembles the payload:** the standalone server, its static files and `public/`, minus sources and docs. Next's native image library (`sharp`) is removed, and the script stops if any other native module (`*.node`) is left, because the same payload is used for every platform.
4. **Adds Node.js** for each platform: the official archive from nodejs.org (version `NODE_VERSION`, an LTS), checked against nodejs.org's `SHASUMS256.txt`, cached in `dist/cache`.
5. **Packages:**
   - **macOS:** `Patchbay.app` with `Contents/Resources/{node, app/, patchbay, Patchbay.icns}`, a small `Contents/MacOS/Patchbay` that runs the launcher (and shows errors in a dialog), an `Info.plist` (`io.github.tobioj.patchbay`), and an ad-hoc signature. Zipped with `ditto`.
   - **Windows:** a `Patchbay` folder with `node.exe`, `app\`, `patchbay.ps1` / `patchbay.cmd` (CRLF), `install.ps1`, `patchbay.ico` and a double-clickable `Install Patchbay.cmd`.

The launchers have a **packaged mode**: when `app/server.js` sits next to them, they run it with the bundled Node (`HOSTNAME=127.0.0.1 PORT=3456`) instead of `npm start`, skip installing and building, and keep data in `~/Library/Application Support/Patchbay` (macOS) or `%LOCALAPPDATA%\Patchbay` (Windows) through `DATA_DIR`.

**Not done yet:** Apple notarization and Windows code signing (users see a first-open warning, as described in [Install](install.md#download-the-app)), and a single-file Windows `.exe`.
