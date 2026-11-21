# Configuration

Where Patchbay keeps things, every setting and its default, and the environment variables it reads. Almost everything here is set from the app itself; this page is the reference behind it.

**Contents:** [The data folder](#the-data-folder) · [API keys](#api-keys) · [Settings](#settings) · [Projects](#projects) · [Chats](#chats) · [Environment variables](#environment-variables) · [Ports](#ports) · [Backing up and resetting](#backing-up-and-resetting)

## The data folder

Where Patchbay saves everything depends on how you installed it:

| Installed as | Data folder |
|---|---|
| **Downloaded app, macOS** | `~/Library/Application Support/Patchbay` |
| **Downloaded app, Windows** | `%LOCALAPPDATA%\Patchbay` |
| **From source** | `data/` inside the app folder (ignored by Git) |

Set the `DATA_DIR` environment variable to use another folder. From source, the `patchbay` launcher still writes its logs to `<app folder>/data`; the downloaded app writes them into its data folder. The rest of this page calls it `data/`.

| Path | What's in it |
|---|---|
| `chats/<id>.json` | One file per chat: messages, tool calls and results, file changes, helper runs, its summary |
| `projects/<id>.json` | One file per project |
| `settings.json` | Your settings (see below) |
| `uploads/` | Images, PDFs and data files you attached, and files Claude's code made. Random file names. |
| `backups/<chat id>/` | Copies of files taken before each edit, for **Undo changes**. Kept until the chat is deleted. |
| `skills/` | Your skills (one folder each, with a `SKILL.md`) |
| `project-skills/<project id>/` | Each project's own skills |
| `secrets/*.dpapi` | Windows only: your keys, encrypted for your Windows account |
| `claude-models.json` | The Claude models your key can use, refreshed every 12 hours |
| `processes.json` | Commands still running, so a crash can be cleaned up |
| `server.log`, `build.log`, `install.log` | The launcher's logs: the server, the last build, the first package install |

All JSON files are written atomically (to a temp file, then renamed), so a crash can't leave half a file.

## API keys

Keys are **not** in the data folder on macOS. Where each one is looked up, in order:

1. **An environment variable**, if set (see [below](#environment-variables)).
2. **Secure storage:** the macOS Keychain, or `data/secrets/` (DPAPI) on Windows.
3. **`data/settings.json`:** used on systems without either (Linux), in plain text.

| Key | Keychain service / Windows file | Environment variable | Used for |
|---|---|---|---|
| DeepSeek | `deepseek-api-key` | `DEEPSEEK_API_KEY` | DeepSeek models, and DeepSeek's web search |
| Claude | `anthropic-api-key` | `ANTHROPIC_API_KEY` | Claude models |
| GLM | `glm-api-key` | `GLM_API_KEY` | GLM models |
| Tavily | `tavily-api-key` | `TAVILY_API_KEY` | Web search for DeepSeek and GLM (Tavily) |
| GitHub | `github-token` | `GITHUB_TOKEN` | Read-only GitHub |

The easy way is **Settings → AI providers** (and **Settings → GitHub**, **Settings → Web search**). On a Mac you can also manage them in Terminal:

```bash
security add-generic-password -U -a "$USER" -s deepseek-api-key -w   # add or replace (asks for the key)
security find-generic-password -s deepseek-api-key                    # check it's saved
security delete-generic-password -s deepseek-api-key                  # remove it
```

Replace `deepseek-api-key` with the service name for other keys. Keys are cached in memory for 30 seconds, and the cache is cleared when you save or remove a key in the app, or when a provider rejects it.

## Settings

Stored in `data/settings.json`, edited in **Settings**. A missing field takes its default. Values outside the allowed range are clamped when saved.

### Models and thinking

| Field | Default | Meaning |
|---|---|---|
| `defaultModel` | `"deepseek-flash"` | Model for new chats |
| `thinking` | `true` | DeepSeek: thinking on in new chats |
| `effort` | `"high"` | DeepSeek effort: `high` or `max` |
| `claudeThinking` | `true` | Claude: thinking on in new chats (for models that can switch it off) |
| `claudeEffort` | `"medium"` | Claude effort: `low`, `medium`, `high`, `xhigh` or `max` |
| `glmEffort` | `"high"` | GLM effort: `low`, `high` or `max` (GLM always thinks) |

### What each AI may do

`limits` holds the switches from **Settings → AI providers → What … may do**, one set per provider (`deepseek`, `claude`, `glm`):

| Switch | Meaning | DeepSeek | Claude | GLM |
|---|---|---|---|---|
| `folders` | Read linked folders | on | off | off |
| `edit` | Change files (Edit mode) | on | off | off |
| `auto` | Auto mode, Run without asking | on | off | off |
| `commands` | Run terminal commands | on | off | off |
| `github` | Read GitHub | on | off | off |
| `docs` | Save to the Docs folder | on | off | off |
| `search` | Web search | on | off | off |
| `code` | Code execution (Claude only) | off (always) | off | off (always) |

### Claude options

| Field | Default | Meaning |
|---|---|---|
| `claudeMaxSearches` | `5` | Most web searches per reply (1–50) |
| `claudeBlockedSites` | `[]` | Domains Claude's search and page reading must never use (up to 100) |
| `claudeFallback` | `true` | If Claude declines a harmless request, let another Claude model answer |

### Web search (DeepSeek and GLM)

| Field | Default | Meaning |
|---|---|---|
| `webSearch` | `false` | Show the **Search** button in DeepSeek and GLM chats |
| `searchProvider` | `"tavily"` | `"tavily"` (Tavily key) or `"deepseek"` (DeepSeek key) |

### Everything else

| Field | Default | Meaning |
|---|---|---|
| `systemPrompt` | A short default | **Instructions for the AI**: text every chat sees (unless its project is *This project only*) |
| `maxFileChars` | `100000` | Most characters kept per attached file (1,000–2,000,000) |
| `summarizeAt` | `200000` | Summarize long chats past this many tokens (50,000–900,000; `0` = never). Always at most 80% of the model's context window. |
| `helpersMax` | `4` | Helpers running at once (1–8) |
| `helperSteps` | `30` | Steps per helper (5–100) |
| `helperMinutes` | `15` | Minutes per helper (1–60) |
| `docsFolder` | `"~/Documents/Patchbay Docs"` | The Docs folder. `""` switches it off. |
| `docsAutoSave` | `[]` | Documents (full paths) the AI may save without asking |
| `githubRepos` | `[]` | Repos (`owner/name`) the AI may read, up to 100 |
| `skillsFolder` | `""` | An extra skills folder on this computer (for example `~/.claude/skills`) |
| `skillsOff` | `[]` | Skills switched off, by name |

The theme (light / dark / system) is stored in the browser (`localStorage`), not in `settings.json`.

## Projects

Stored in `data/projects/<id>.json`, edited in **Project settings**.

| Field | Default | Meaning |
|---|---|---|
| `name` | | The project's name |
| `context` | `""` | Instructions and background every chat in the project sees |
| `files` | `[]` | Project files whose full text goes with every message (up to 50, 500,000 characters each) |
| `folders` | `[]` | Folders linked to every chat in the project |
| `isolated` | `false` | **Memory: This project only**: ignore your Settings instructions (and your skills, by default) |
| `docsFolder` | `null` | This project's Docs folder (`null` = the one in Settings) |
| `githubRepos` | `[]` | Which of your allowed repos this project's chats may read |
| `terminal` | `false` | Let the AI run commands in the project's folders |
| `terminalInternet` | `false` | Internet for commands (enforced on macOS only) |
| `terminalMinutes` | `10` | Time limit per command the AI runs: 10, 30 or 60 |
| `allowedCommands` | `[]` | Commands you clicked **Always allow** for (up to 200) |
| `skillsGlobal` | not set | **Also use my skills** (not set = on unless the project is isolated) |
| `skillsOff` | `[]` | Skills switched off for this project |

## Chats

Stored in `data/chats/<id>.json`. The fields that change behaviour:

| Field | Default | Meaning |
|---|---|---|
| `model`, `thinking`, `effort` | From Settings | The chat's model and reasoning |
| `projectId` | `null` | The project it belongs to |
| `folders` | `[]` | Folders added to this chat only (up to 20) |
| `hiddenProjectFolders` | `[]` | Project folders switched off for this chat |
| `mode` | `"ask"` | `ask`, `plan`, `edit` or `auto` |
| `webSearch`, `github`, `code` | `false` | The Search, GitHub and Code toggles |
| `helpersOn` | `false` | The Helpers toggle |
| `runWithoutAsking` | `false` | **Run without asking** |
| `summary` | | The long-chat summary, once there is one |

## Environment variables

Set these in the environment of the server (or in a `.env.local` file in the app folder, which Next.js loads).

| Variable | Effect |
|---|---|
| `DEEPSEEK_API_KEY`, `ANTHROPIC_API_KEY`, `GLM_API_KEY`, `TAVILY_API_KEY`, `GITHUB_TOKEN` | Use this key instead of the stored one |
| `DATA_DIR` | Keep the data folder somewhere else (the launcher's logs still go to `<app folder>/data`) |
| `DEEPSEEK_BASE_URL`, `CLAUDE_API_BASE_URL`, `GLM_API_BASE_URL`, `TAVILY_BASE_URL`, `GITHUB_API_URL` | Send that service's requests elsewhere. **For testing only:** your key goes to whatever address you set. |

**Ignored on purpose:** `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` and `ZAI_*`. Other tools (Claude Code and its relatives) set these for themselves, and Patchbay won't let them redirect your keys.

The ports are fixed (there's no `PORT` variable); see below.

## Ports

| Port | What |
|---|---|
| `3456` | The everyday app (`npm start`, the `patchbay` launcher) |
| `3455` | The development server (`npm run dev`) |

Both listen on `127.0.0.1` only. To change a port, edit the `dev` / `start` scripts in `package.json` and `PORT` at the top of both launchers (`scripts/mac/patchbay`, `scripts/windows/patchbay.ps1`). Terminal commands are always blocked from reaching 3455, 3456 and the port the app is serving on.

## Backing up and resetting

- **Back up:** stop the app (`patchbay stop`) and copy the `data` folder. That's every chat, project, skill and setting. Keys aren't included (Keychain / DPAPI); paste them again after restoring on another computer.
- **Start fresh, keeping your keys:** stop the app and move `data` somewhere else. A new empty one is created on the next start.
- **Reset settings only:** stop the app and delete `data/settings.json`.
- **Free space:** delete old chats in the app; that also deletes their backups.
