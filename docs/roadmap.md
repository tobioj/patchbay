# Roadmap

Patchbay grows in steps, and each step is usable on its own. This page lists what's built, what's being considered next, and what's deliberately out of scope. Ideas and votes are welcome in [issues](https://github.com/tobioj/patchbay/issues/new/choose).

## ✅ Built

**The harness**

- [x] A desktop-style chat app that runs only on your computer (`127.0.0.1`), opened as its own window
- [x] Saved chats with search, rename, export to Markdown
- [x] Attachments: text, code, images, PDFs, Word documents, whole folders
- [x] Folders the AI explores by itself, read-only, with secret files always blocked
- [x] Several folders per chat and per project
- [x] Ask / Plan / Edit / Auto modes, with diff previews, approvals, backups and undo
- [x] Projects: shared context, files, folders, memory setting
- [x] A terminal per project, with command rules, a macOS sandbox, a Running list and ▶ Run on code blocks
- [x] **Run without asking** per chat
- [x] A Docs folder the AI can write to in any mode
- [x] Read-only GitHub with a repo allowlist
- [x] Web search (Tavily or DeepSeek's search; Claude's own)
- [x] Skills in the Claude Code format, from your library, a folder, a project, or the project's code
- [x] Helpers: read-only researchers in parallel, with a live panel
- [x] Long-chat summaries for every provider
- [x] Sending while it's replying, and up to 4 chats replying at once
- [x] Costs per reply and per chat, and a token meter

**Providers**

- [x] DeepSeek (V4.1 Flash, V4 Pro)
- [x] Claude (every model your key can use), with web search, code execution and model fallback
- [x] GLM (GLM-5.3, GLM-5.3 Flash)
- [x] Per-provider permission switches, off by default for new providers

**Platforms**

- [x] macOS (Keychain, native dialogs, sandbox, `.app` launcher)
- [x] Windows (DPAPI, native dialogs, PowerShell, shortcuts)
- [x] Downloadable apps for macOS (Apple silicon, Intel) and Windows (x64, Arm), with Node.js included
- [x] Open source under Apache 2.0

## 🧭 Being considered

Not promises, and not in order. Each would be discussed in an issue first.

- [ ] **Automated tests** for the command rules, path confinement, permissions and the chat loop
- [ ] **More providers**, starting with other OpenAI-compatible APIs (see [Adding a provider](architecture.md#adding-a-provider))
- [ ] **A local access token** for the API, so other programs on the computer can't call it
- [ ] **Keychain support on Linux** (Secret Service), instead of plain-text keys
- [ ] **A sandbox for Windows commands**
- [ ] **Spending limits** per chat or per day
- [ ] **Configurable ports**
- [ ] **Signed releases:** Apple notarization and Windows code signing, so there's no first-open warning
- [ ] **A single-file Windows app** (`Patchbay.exe`) and a **Quit** item, for people who never use a terminal
- [ ] **Updates from inside the app**

## 🚫 Out of scope

- **A hosted or multi-user version.** Patchbay is a personal app for your own computer. Running it on a server or exposing it to a network is unsupported and unsafe.
- **Reselling or proxying model access.** You always bring your own keys and pay providers directly.
- **Write access to GitHub** (pushing, opening PRs, commenting). Push from your own terminal.
- **Using subscriptions in place of API keys** where the provider doesn't allow it (for example a GLM Coding Plan).
