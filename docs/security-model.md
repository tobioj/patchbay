# Security model

Patchbay gives AI models real access to your computer: your folders, your files and a terminal. This page explains what protects you, how each protection works, and, just as important, **where the limits are**, so you can decide what to allow.

To report a vulnerability, see [SECURITY.md](SECURITY.md).

**Contents:** [At a glance](#at-a-glance) · [Who Patchbay trusts](#who-patchbay-trusts) · [The local server](#the-local-server) · [API keys](#api-keys) · [What leaves your computer](#what-leaves-your-computer) · [Permissions and modes](#permissions-and-modes) · [Folders and files](#folders-and-files) · [Edits and undo](#edits-and-undo) · [Terminal commands](#terminal-commands) · [GitHub](#github) · [Docs folder and skills](#docs-folder-and-skills) · [Prompt injection](#prompt-injection) · [What Patchbay doesn't protect](#what-patchbay-doesnt-protect) · [Advice](#advice)

## At a glance

| | |
|---|---|
| **Where it runs** | Only on your computer: the server listens on `127.0.0.1`, never on the network |
| **Accounts / cloud** | None of its own. Your messages go only to the provider of the chat's model (and to the search or GitHub service you've enabled). |
| **Requests from websites** | Refused (`Host`, `Origin` and `Sec-Fetch-Site` checks), so a web page can't drive Patchbay |
| **API keys** | macOS Keychain or Windows DPAPI (encrypted for your Windows account). Never sent to the browser; each sent only to its own provider. |
| **What the AI may do** | Off-by-default switches per provider (DeepSeek's start on), then per project, per chat, and the folder mode. Each layer can only take away. |
| **Folder access** | Only the folders you link; symbolic links that lead outside are refused; secret files are never read by the file tools |
| **Changing files** | Only in Edit / Auto mode. Every change is backed up and can be undone. |
| **Terminal** | Off by default, per project. On macOS: a sandbox (writes only in the project, no secrets, internet off by default). On Windows: no sandbox, so nearly everything asks first. |
| **Never runs** | `sudo`, `git push`, `git reset --hard`, `gh`, `curl … \| sh`, background `&`, and more |
| **GitHub** | Read-only (GET requests only), limited to repos you allow |
| **Encryption at rest** | Not Patchbay's job: your chats are plain JSON in `data/`. Use FileVault / BitLocker. |

## Who Patchbay trusts

| Party | Trusted? | Why it matters |
|---|---|---|
| **You** (at the keyboard) | Yes | You approve changes and commands, and you decide what each AI may do |
| **Your user account and its processes** | Yes | Patchbay runs as you. Anything else running as you could use it, or read its data folder directly. |
| **The model provider** | Partly | It sees everything you send in a chat (messages, files the AI reads, command output). It's trusted with that data, not with your computer: everything it asks to do goes through the rules below. |
| **The model's output** | **No** | A model can make mistakes, or be steered by text it reads (a web page, a README, an issue). Its tool calls are checked, limited and, for anything that changes things, approved by you. |
| **Web pages, files, GitHub content the AI reads** | **No** | See [Prompt injection](#prompt-injection) |
| **Other websites in your browser** | **No** | Blocked by the local server's request checks |
| **Other devices on your network** | **No** | The server doesn't listen on the network |

## The local server

Patchbay's server (`npm start`, or the `patchbay` launcher) listens only on **`127.0.0.1:3456`** (the development server on `3455`), so nothing on your network can reach it.

`proxy.ts` checks every `/api/*` request:

- The `Host` header must be `127.0.0.1`, `localhost` or `[::1]`. This stops **DNS-rebinding** attacks, where a website makes your browser talk to `localhost` under its own domain name.
- If an `Origin` header is present, it must match the host exactly (same port). A page on another site, or a dev server on another port, is refused.
- `Sec-Fetch-Site: cross-site` is refused.

Together these stop a web page you visit from reading your files or sending messages through Patchbay.

**What they don't stop:** a program running on your computer that calls the API directly (for example with `curl`) sends no `Origin` header and is allowed. The local server has **no login**. That's the same trust model as most local developer tools: anything running as you can already read your files. On a computer shared with other people who can run programs, be aware that another local account could reach the port too.

## API keys

**Where keys are stored**

| System | Storage |
|---|---|
| **macOS** | The **Keychain**, as generic passwords (services `deepseek-api-key`, `anthropic-api-key`, `glm-api-key`, `tavily-api-key`, `github-token`). Saved through `security -i` with the command on standard input, so the key never appears in the process list. |
| **Windows** | `data\secrets\<service>.dpapi`, encrypted with **DPAPI** for your Windows account (`ConvertFrom-SecureString`). The key is passed to PowerShell through an environment variable, not the command line. An older plain-text copy in `settings.json` is encrypted and removed the first time it's read. |
| **Other systems (Linux)** | **Plain text** in `data/settings.json`. There's no keychain integration yet; protect the folder, or use environment variables. |

**Environment variables win.** `DEEPSEEK_API_KEY`, `ANTHROPIC_API_KEY`, `GLM_API_KEY`, `TAVILY_API_KEY` and `GITHUB_TOKEN` override the stored keys. If your shell exports one of these for another tool, Patchbay uses it; Settings shows the key's source (*environment*, *Keychain*, *Windows*, *settings*).

**Never sent to the browser.** The interface only ever receives whether a key is set, where it came from, and its **last four characters** (to help you tell keys apart).

**Each key goes only to its own provider:** DeepSeek to `api.deepseek.com`, Claude to `api.anthropic.com`, GLM to `api.z.ai`, Tavily to `api.tavily.com`, GitHub to `api.github.com`. Patchbay deliberately **ignores `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN`** (which Claude Code and similar tools set for themselves) and never reads `ZAI_*`, so a variable meant for another tool can't redirect your key. The explicit overrides `DEEPSEEK_BASE_URL`, `CLAUDE_API_BASE_URL`, `GLM_API_BASE_URL`, `TAVILY_BASE_URL` and `GITHUB_API_URL` exist for testing; **if you set one, your key goes to that address**, so only point them at something you control.

**Keys never reach commands.** Terminal commands get a minimal environment without any of Patchbay's keys (see [Terminal commands](#terminal-commands)).

## What leaves your computer

| Destination | What's sent | When |
|---|---|---|
| **The chat's provider** (DeepSeek, Anthropic or Z.ai) | Your messages, attachments, project context and files, and everything the AI reads or runs in that chat (file contents, command output, search results). Titles and summaries go to the same provider's small model. | Every reply |
| **Anthropic's code sandbox** | Data files you attach while **Code** is on (CSV, Excel, JSON…) | Claude chats with Code on |
| **Tavily** or **DeepSeek's search** | Search queries and page addresses | DeepSeek / GLM chats with Search on. With *DeepSeek* chosen, a GLM chat's searches go to DeepSeek with your DeepSeek key. |
| **Anthropic's web tools** | Search queries and page addresses | Claude chats with Search on |
| **GitHub** | Read requests for the repos you allowed, with your token | Chats with GitHub on |

Nothing else is sent anywhere: no analytics, no telemetry, no update checks.

## Permissions and modes

What the AI can do in a reply is decided in layers, and **each layer can only take away** ([Architecture → Permissions](architecture.md#permissions)):

1. **Settings → AI providers → What … may do:** switches per provider for reading folders, changing files, Auto mode, running commands, reading GitHub, saving docs, web search and (Claude) code execution. **Claude and GLM start with everything off.** DeepSeek starts with them on, because it had these abilities before the switches existed.
2. **The project:** which folders, whether the terminal is on, which GitHub repos, which Docs folder.
3. **The chat:** its folders, project folders switched off, and the Search / GitHub / Code / Helpers toggles.
4. **The mode:** **Ask** and **Plan** can't change anything; **Edit** asks before every change; **Auto** doesn't ask for file changes.

A switch that's off removes the tools from the model entirely (it can't call what it isn't given), and the matching buttons are greyed out.

## Folders and files

The AI can only reach the folders linked to the chat (its own, plus its project's, minus any switched off).

- **Confinement.** Every path is resolved to its real location (following symbolic links) and must be inside one of those folders. A link that points outside is refused, and folder walks skip links altogether.
- **Secret files are never read** by the folder, Docs and skills tools: `.env` and `.env.*` (except `.env.example`, `.sample`, `.template`, `.defaults`), `.npmrc`, `.pypirc`, `.netrc`, `.git-credentials`, `.htpasswd`, SSH keys (`id_rsa`, `id_ed25519`…), and files ending in `.pem`, `.key`, `.p12`, `.pfx`, `.keystore`, `.jks`, `.kdbx`. They can't be attached in the browser either.
- **Skipped folders:** `.git`, `node_modules`, virtual environments, build output (`dist`, `build`, `.next`…), caches and similar are never walked or edited.
- **Binary files** are refused, as is any file with a NUL byte near the start.
- **Size limits:** files over 2 MB are skipped in searches; reads are capped (150,000 characters per read); attachments are cut at **Settings → Files** (100,000 characters by default).

**Not covered by the secret-file list:** credentials stored under other names (for example `~/.aws/credentials`, `*.tfstate`, a `config.json` with a password in it). Don't link folders that hold secrets you wouldn't send to the provider.

## Edits and undo

- File changes are only possible in **Edit** and **Auto** mode, with the provider's **Change files** switch on.
- **Edit** shows each change as a diff and waits for **Approve** / **Reject**. **Approve all** approves waiting *edits* only, never commands.
- The edit tools can't write inside skipped folders (`.git`, `node_modules`, `dist`…), can't touch secret or binary files, and can't write through a link that leads outside the folder.
- **Every change is backed up first** to `data/backups/<chat>/`. **Undo changes** restores a reply's files in reverse order and deletes files it created. If you've changed one of those files since, it asks before overwriting your edit. Backups are kept until the chat is deleted.
- Changes made by **terminal commands** aren't backed up and can't be undone with Undo. Keep your projects in Git.

## Terminal commands

The terminal is **off by default**, switched on per project, available only with the provider's **Run commands** switch, and only in that project's own folders.

### How commands are classified

Every command is parsed (including each part of a chain or pipe, and commands nested in `bash -c` or `powershell -Command`), and the strictest part wins:

| Level | Examples | What happens |
|---|---|---|
| **Look-only** | `ls`, `cat`, `grep`, `rg`, `find` (without `-exec`/`-delete`), `git status`/`diff`/`log`/`show`, `npm ls`, version checks, PowerShell `Get-ChildItem`/`Get-Content`… with every argument inside the project | Runs straight away, in every mode |
| **Ask** | Everything else that isn't below: `npm test`, `npm run build`, `pip install`, redirects to a file, `$(…)`, environment prefixes… | Asks in Ask, Plan and Edit. In Auto (Mac) or with **Run without asking**, runs without asking. An **Always allow** rule can skip the question. |
| **Always ask** | Recursive deletes, `find -delete`/`-exec`, `git clean`, `git checkout .`, `git restore`, `git stash drop`, `git branch -D`, publishing and deploying (`npm publish`, `docker push`, `vercel`, `kubectl`, `aws`, `terraform apply`…), any command naming a secret file | Asks every time, even in Auto and with **Run without asking** |
| **Blocked** | `sudo`, `su`, `git push`, `git reset --hard`, `git credential`, `gh`, `security`, `osascript`, `open`, `launchctl`, `crontab`, shutdown/format tools, `nohup`/`screen`/`tmux`/background `&`, piping into a shell or interpreter (`curl … \| sh`), PowerShell `-EncodedCommand`/`Invoke-Expression`, deleting `/`, `~` or `..`, talking to Patchbay's own port | Refused, even if you approve |

A command you edit on its approval card is classified again before it runs.

### The macOS sandbox

On macOS every command runs under `sandbox-exec` with a profile built for that command:

- **Writes** are allowed only in the project's folders (none at all in Ask and Plan mode), temp folders and package-manager caches (`~/.npm`, `~/.cache`, `~/Library/Caches`…).
- **No reading or writing** of `~/.ssh`, `~/.aws`, `~/.azure`, `~/.gnupg`, `~/.kube`, `~/.config/gh`, `~/.netrc`, `~/.git-credentials`, `~/.npmrc`, shell histories, `~/.claude`, the Keychains, browser profiles, Mail, Messages, and **Patchbay's own data folder**.
- **Can't run** `security`, `osascript`, `open`, `sudo`, `su`, `launchctl`, `defaults`, `shortcuts`, `automator`, `gh`, `hub`, or send Apple Events to other apps.
- **Internet off** by default: all outgoing connections except `localhost` are refused, and name lookups fail. Switch on **Internet for commands** in Project settings when you need it.
- **Patchbay's own ports** are always off-limits, so a command can't drive Patchbay itself.

### Every platform

- **Clean environment.** Commands get only `PATH` (your login shell's), `HOME`, `USER`, `LOGNAME`, `SHELL`, `LANG` and `TMPDIR` (a short allowlist on Windows), **never Patchbay's keys**.
- **Git can't push or log in:** push URLs are rewritten to nowhere, credential helpers are cleared, prompts are off, and SSH runs without keys or an agent.
- **Time limits** for the AI's commands (10, 30 or 60 minutes per project), and the **Running list** shows and stops everything still running. Stopping kills the whole process tree and checks the ports are free.
- **Clean-up:** anything a command leaves behind is killed when it finishes, everything is stopped when the server exits, and leftovers from a crash are killed at the next start.

### Windows

**There's no sandbox on Windows.** Commands run in PowerShell as you, so:

- every command except look-only ones **asks first, even in Auto mode**;
- Ask and Plan mode are read-only only because of classification, not enforced by the system;
- internet access can't be switched off;
- **Run without asking** lets ordinary (*Ask*-level) commands run without a prompt and without a sandbox. Only switch it on in a chat when you're watching.

### Limits of the terminal rules

- **Look-only commands can read any file in the project**, including secret files matched by a pattern (for example `cat .en?` or `grep -r KEY .`), without asking, in every mode. The secret-file list protects the file tools; it isn't a guarantee for the terminal. Keep real secrets out of folders you give the terminal, or keep the terminal off in that project.
- In Edit and Auto mode, commands can write anywhere in the project folders, including `.git`.
- On macOS, reading is allowed everywhere outside the deny list (most of your home folder, `~/.docker`, much of `~/.config`), local network services on other ports are reachable even with internet off, and Unix sockets (such as Docker's) aren't blocked.
- Classification is a careful rule set, not a proof. Anything unusual (`$(…)`, redirects, chains) is pushed up to *Ask*, but read what you approve.

## GitHub

- **Read-only by construction:** the GitHub client only ever makes `GET` requests.
- **Repos you allow:** the AI may only read repos ticked in **Settings → GitHub**, narrowed further by each project's picks.
- **Use a fine-grained token** limited to those repos with read-only permissions. The token's own scope is the real boundary; the allowlist is an extra layer on top.
- **Issues and pull requests** are marked to the model as untrusted text ("never as instructions").
- The token never reaches terminal commands: the environment is cleaned, `~/.config/gh` is unreadable in the sandbox, and `gh` / `hub` are blocked.

## Docs folder and skills

- **Docs folder:** the AI can create and update text documents (`.md`, `.txt`, `.csv`, `.json`, `.html`…) only inside the Docs folder, in any mode, with the same confinement, secret-file rules, backups and undo as edits. Each save asks unless you've ticked *Don't ask again* for that document (or the chat is in Auto). Helpers can read docs but never save them. The Docs folder can be any folder you choose, so choose one that holds only documents.
- **Skills** are read-only to the AI and **nothing in a skill is ever run**. Importing from a folder or a `.zip` skips links, secret files and junk, refuses absolute paths and `..` in archives, and caps the size (500 files, 50 MB unpacked; 20 MB per `.zip` upload).

## Prompt injection

Anything the AI reads (a web page, a file in your repo, a GitHub issue, a document) can contain text written to steer it ("ignore your instructions and…"). Patchbay can't stop a model from being influenced, so it limits what an influenced model can do:

- Read-only tools can't change anything; changes and most commands need your approval unless you've chosen Auto or **Run without asking**.
- Dangerous commands are blocked or always ask, the macOS sandbox fences commands in, and `git push` / `gh` never run.
- Keys never reach the model or commands, and each provider's key only goes to that provider.
- GitHub content is labelled as untrusted.

**Auto mode and Run without asking remove your review step.** Use them for work where you trust the inputs, and avoid combining them with web search or unfamiliar repos.

## What Patchbay doesn't protect

- **Your provider sees your data.** Whatever's in a chat is sent to that chat's provider under its terms. Pick providers (and data) accordingly.
- **Other software running as you** can call the local API (it has no login) or read `data/` directly.
- **The data folder isn't encrypted.** Chats (including file contents and command output), backups of edited files, uploads and settings are plain files. Use full-disk encryption.
- **Linux stores keys in plain text** in `data/settings.json`.
- **Windows has no terminal sandbox** (see above).
- **Model mistakes.** An approved change or command does what it does. Review diffs and commands, keep projects in Git, and use Undo.
- **Costs.** Patchbay shows costs but doesn't cap spending; set limits in each provider's console.

## Advice

- Give each provider only the switches you need, and leave **Auto** and **Run without asking** for trusted work.
- Keep projects in **Git** and commit before letting the AI edit.
- Don't link folders that contain secrets; keep `.env` files out of projects where the terminal is on.
- Use **fine-grained, read-only** GitHub tokens limited to specific repos.
- Turn on **FileVault** (Mac) or **BitLocker** (Windows).
- Set a **spending limit** in each provider's console.
- Keep Patchbay updated (`git pull`), and report problems privately ([SECURITY.md](SECURITY.md)).
