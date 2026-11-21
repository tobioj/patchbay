# Troubleshooting

Find your problem below. If it isn't here, check the logs ([Seeing more detail](#seeing-more-detail)) and [open an issue](https://github.com/tobioj/patchbay/issues/new/choose).

**Contents:** [Installing and starting](#installing-and-starting) · [Keys and providers](#keys-and-providers) · [Buttons missing or greyed out](#buttons-missing-or-greyed-out) · [Folders and edits](#folders-and-edits) · [The terminal](#the-terminal) · [Web search and GitHub](#web-search-and-github) · [Skills and helpers](#skills-and-helpers) · [Several chats, long chats](#several-chats-long-chats) · [Seeing more detail](#seeing-more-detail) · [Starting over](#starting-over)

## Installing and starting

| Problem | Fix |
|---|---|
| `command not found: patchbay` (Mac) | Run `zsh scripts/mac/install.sh` in the app folder, then open a **new** Terminal window. |
| `'patchbay' is not recognized` (Windows) | Run the setup (`powershell -ExecutionPolicy Bypass -File scripts\windows\install.ps1`), then close **every** terminal window (Windows Terminal completely; new tabs keep the old settings) and open a new one. Or run `scripts\windows\patchbay.cmd` from the app folder. |
| "Node.js isn't installed (npm wasn't found)" | Install the LTS version from [nodejs.org](https://nodejs.org), open a new terminal, and try again. On a Mac with Node from nvm or similar, the launcher also tries your login shell's `PATH`. |
| You pressed Ctrl + C during *Building the app…* | Run `patchbay` again. It sees the build didn't finish and starts it over. |
| "Build failed — see …/data/build.log" | Open `data/build.log`. After an update, run `npm ci` first (the packages may have changed), then `patchbay`. |
| "Installing packages failed" | Open `data/install.log`. Check your internet connection and Node version (20.9+), then run `npm ci` in the app folder. |
| `npm ci` fails with `EPERM` or `EBUSY` (Windows) | The app is still running and Windows locks its files: `patchbay stop`, then `npm ci` again. |
| `npm start` says "Could not find a production build" | It hasn't been built: use `patchbay`, or run `npm run build` first. |
| "The server didn't start" | Open `data/server.log`. Another program may be using port 3456: on a Mac, `lsof -i :3456`; on Windows, `Get-NetTCPConnection -LocalPort 3456`. |
| The window is blank or says it can't reach the server | `patchbay restart`. |
| It opens in a normal browser tab, not its own window | Patchbay uses Google Chrome's (or on Windows, Edge's) app mode. Install Chrome, or use the tab; everything works the same. |
| The app doesn't show in Spotlight (Mac) | `mdimport ~/Applications/Patchbay.app`, or run `zsh scripts/mac/install.sh` again. |
| macOS says it can't verify the downloaded Patchbay.app | It isn't notarized by Apple. Open **System Settings → Privacy & Security**, scroll down and click **Open Anyway** (once). On older macOS, right-click the app → **Open**. |
| macOS says it can't open Patchbay.app (from source) | Run `zsh scripts/mac/install.sh` again (it rebuilds and re-signs the app locally), or just use `patchbay` in Terminal. |
| Windows warns about the scripts in the downloaded app, or SmartScreen blocks **Install Patchbay.cmd** | Right-click the zip → **Properties** → **Unblock** before unzipping, then unzip again. For SmartScreen, **More info → Run anyway**. |
| "Patchbay didn't start" (downloaded app) | Open the log: `~/Library/Application Support/Patchbay/server.log` (Mac) or `%LOCALAPPDATA%\Patchbay\server.log` (Windows). Another program may be using port 3456, for example a from-source Patchbay: stop it first. |
| I installed the app and also have a from-source copy | Both use port 3456, so whichever starts first answers. Stop one (`patchbay stop`) before opening the other. They keep separate data folders. |

## Keys and providers

| Message or problem | Fix |
|---|---|
| "No … API key is set" | **Settings → AI providers** → paste the key → **Save key**. Or switch the chat to a model you have a key for. |
| "… rejected your API key" | Paste the key again in Settings; it's tested right away. If Settings says the key comes from the *environment*, an environment variable (for example `ANTHROPIC_API_KEY` exported in your shell for another tool) is overriding it; unset it, or update it. |
| "Your DeepSeek balance has run out" | Top up at platform.deepseek.com. |
| "Your Claude credit balance is too low" | Add credit at console.anthropic.com → Billing. A Claude.ai subscription doesn't cover the API. |
| GLM: "rate-limiting you, or your quota is used up" / balance errors | Top up at z.ai. A GLM Coding Plan doesn't count here; the app uses your pay-as-you-go balance. |
| "Z.ai's content filter blocked this request" | Rephrase, or switch the chat to another model. |
| "Can't reach …" | Check your internet connection, then **Retry**. |
| "… is rate-limiting you" / "servers are busy" | Wait a few seconds and **Retry**. |
| "Claude doesn't recognize this model (it may have been retired)" | Pick another model in the model menu. **Settings → AI providers → Claude → Test** refreshes the list. |
| A Claude model you expected is missing | The list comes from your key. Test the key in Settings to refresh it (it's otherwise refreshed every 12 hours). |
| "This message is too large for Claude" | Remove some attachments (Claude's limit is 32 MB per request). |
| "This chat is too long for GLM's context window" | **Summarize** in the token ring, or start a new chat. |
| A reply says another Claude model answered | Claude's safety checks flagged the request and the fallback model answered. Switch it off in **Settings → AI providers → Web search and safety options**. |
| Costs look high | Thinking, Max effort, helpers and long chats all use more tokens. DeepSeek also charges double at peak times (01:00–04:00 and 06:00–10:00 UTC, weekdays). Hover the token ring to see where it went. |

## Buttons missing or greyed out

| Problem | Fix |
|---|---|
| A button is greyed out (Search, Code, GitHub, Helpers, a mode) | That AI isn't allowed to: **Settings → AI providers → What … may do** → switch it on → **Save**. Clicking the greyed-out button takes you there. |
| No **Search** button (DeepSeek or GLM) | **Settings → Web search for DeepSeek and GLM** → turn it on. |
| No **Code** button | Code execution is Claude only. Switch the chat to Claude and allow **Code execution**. |
| No Ask / Plan / Edit / Auto | The modes appear once the chat has a folder: **+ → Add a folder…** |
| Edit / Auto are struck through | That AI may not change files (or use Auto mode). Allow it in Settings. |
| No **Run without asking** switch | It needs a project with the terminal on, Edit or Auto mode, and **Auto mode** allowed for that AI. On the Mac it only shows in Edit mode (Auto already runs commands without asking). |

## Folders and edits

| Problem | Fix |
|---|---|
| "… isn't allowed to read folders (Settings)" | Allow **Read folders** for that AI in Settings. |
| The AI says it can't edit files | Switch the chat to **Edit** or **Auto**. It's told about the switch in your next message. |
| The AI can't see a file | It may be skipped on purpose: secret files (`.env`, keys), binaries, files over 2 MB, or anything in `node_modules`, `.git`, build folders and caches. See [Security model → Folders](security-model.md#folders-and-files). |
| "Access denied: … is outside the project folder" | The path (or a symbolic link it goes through) leads outside the folders linked to the chat. Link the real folder instead. |
| A file is cut off | Attachments are cut at **Settings → Files** (100,000 characters by default). Let the AI explore the folder instead; it reads files in parts. |
| The AI made a change you don't want | **Undo changes** under that reply. Changes made by commands can't be undone this way; use Git. |
| Undo warns about a conflict | You (or something else) changed the file after the AI did. Choose whether to overwrite your edit. |
| "Uncommitted changes" warning | The folder has Git changes. Committing first makes the AI's edits easy to review and revert. |

## The terminal

| Problem | Fix |
|---|---|
| No ▶ Run buttons, or the AI can't run commands | The chat must be in a **project** with **Project settings → Terminal** on, the AI needs **Run commands** allowed in Settings, and a project folder must be switched on in the chat. |
| Every command asks, even in Auto (Windows) | Expected: Windows has no sandbox, so only look-only commands run without asking. Use **Run without asking** in the chat if you're watching. |
| A command was refused | It's on the blocked list (`sudo`, `git push`, `git reset --hard`, `gh`, `curl … \| sh`, background `&`…). Run it yourself in your own terminal if you really mean it. |
| "Not permitted" / "Operation not permitted" (Mac) | The sandbox stopped the command from writing outside the project folders or reading something private. That's intended. |
| `npm install`, `pip install` or `git pull` fails | **Project settings → Terminal → Internet for commands** (Mac). |
| A command in Ask or Plan mode can't write | Expected: those modes are read-only, for commands too. Switch to Edit. |
| `git push` doesn't work | Pushing is never allowed from Patchbay. Push from your own terminal. |
| A command timed out | The AI's commands stop after 10 minutes by default. Raise it to 30 or 60 in Project settings, or ask the AI to run long tasks in the background. |
| "can't run here, so nothing keeps running out of sight" | Commands can't put themselves in the background with `&`, `nohup` or similar. Ask the AI to use background mode; it shows up in the Running list. |
| Something keeps running after I closed the window | Expected: closing the window doesn't stop commands. Reopen the app → **● running** (top right) → **Stop**, or `patchbay stop`. |
| A command says *couldn't stop* | Something it started is still holding a port. `patchbay stop` stops everything; restarting the computer always works. |

## Web search and GitHub

| Problem | Fix |
|---|---|
| Search button does nothing | **Settings → Web search**: with *Tavily*, add your Tavily key; with *DeepSeek*, add your DeepSeek key in AI providers. |
| Claude can't search | Allow **Web search** for Claude in Settings, then turn **Search** on in the chat. |
| The AI can't see a GitHub repo | Tick it in **Settings → GitHub**, pick it in the project's settings (for chats in a project), turn on the **GitHub** button in the chat, and make sure your token can read it. |
| GitHub says the token was rejected | Make a new fine-grained token (the steps are in Settings → GitHub) and paste it again. |

## Skills and helpers

| Problem | Fix |
|---|---|
| A skill isn't used | Check its switch in **Settings → Skills** (or Project settings), and that its description says when to use it. A ⚠ marks skills that need fixing (for example a `SKILL.md` without a `description`, or one that can't be read). |
| An imported skill is missing files | Links, secret files and junk (`.git`, `node_modules`, `__MACOSX`) are skipped on import, and imports are capped at 500 files / 50 MB. |
| The AI doesn't send helpers | Turn on **Helpers** by the message box. It only uses them for tasks that split into parts; you can also ask ("use helpers to…"). |
| "Waiting for you" note about helper reports | The AI already replied to helpers 3 times in a row. Click **Send to …** to let it review the new reports. |
| Helpers keep running after I pressed Stop | Expected: Stop stops the reply, not helpers. Stop them in the helpers panel. |

## Several chats, long chats

| Problem | Fix |
|---|---|
| "4 chats are already replying" | Wait for one to finish, or open one and press ■ / Esc. |
| A reply stopped when I closed or reloaded the window | Expected: replies being written stop with the window. Commands and helpers keep going. |
| "Edits made at the same time can clash" warning | Two chats in Edit or Auto mode are working on the same folder. Let one finish first. |
| The AI forgot something from early in a long chat | The chat was summarized (a line shows where). Repeat the detail, or put lasting information in the project's context. |

## Seeing more detail

| What | Where |
|---|---|
| The server's log | `patchbay logs` (follows it live), or `data/server.log` |
| The last build | `data/build.log` |
| The first package install | `data/install.log` |
| Is it running, and what commands are still running? | `patchbay status` |
| A command's full output | The **● running** list → open the command |
| What the AI did | Open the tool cards in the reply (files read, changes, commands, searches) |

When you report a bug, include the relevant part of the log. Logs can contain file paths and command output from your projects, so look them over first.

## Starting over

- **Restart everything:** `patchbay restart`.
- **Rebuild from scratch:** `patchbay stop`, delete the `.next` folder, then `patchbay`.
- **Reinstall packages:** `patchbay stop`, delete `node_modules`, `npm ci`, then `patchbay`.
- **Fresh data, keeping your keys:** `patchbay stop` and move the `data` folder somewhere safe. See [Configuration → Backing up and resetting](configuration.md#backing-up-and-resetting).
