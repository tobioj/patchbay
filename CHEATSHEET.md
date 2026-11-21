# Patchbay Cheat Sheet

Everything you need, in one place. Type the commands in **Terminal** (PowerShell on Windows). For the full explanations, see the [documentation](docs/README.md).

---

## 1. Open and close the app

**Downloaded the app?** Open **Patchbay** from Applications / Spotlight (Mac) or the Desktop / Start menu (Windows). The commands below work too: on Windows after **Install Patchbay.cmd**, on a Mac after linking them (`ln -sf "/Applications/Patchbay.app/Contents/Resources/patchbay" ~/.local/bin/patchbay`). Its data lives in `~/Library/Application Support/Patchbay` or `%LOCALAPPDATA%\Patchbay`. Install steps: [docs/install.md](docs/install.md#download-the-app).

| I want to… | Do this |
|---|---|
| Open the app | Spotlight (⌘ Space) → **Patchbay**, or run `patchbay` |
| Close the window | Red button or ⌘ Q. **The server keeps running in the background**, so the app reopens instantly. That's normal and harmless (about 58 MB of memory, no CPU while idle). Commands that are running (like a dev server) keep running too: reopen the app and stop them from the **Running** list. |
| Shut everything down | `patchbay stop` (restarting your Mac also stops it). This also stops every command the app started. |

## 2. Server commands

| Command | What it does |
|---|---|
| `patchbay` | Starts the server if needed, then opens the app window |
| `patchbay start` | Starts the server only, without opening a window |
| `patchbay status` | Shows whether the server is running, and lists any commands still running |
| `patchbay stop` | Stops every running command, then the server |
| `patchbay restart` | Stops, rebuilds if the code changed, and starts again. Use it after code changes or if something acts weird. |
| `patchbay logs` | Shows the server log live (press Ctrl + C to exit) |

**Getting updates**, in the app folder: `patchbay stop`, then `git pull`, then `npm ci`, then `patchbay` (it rebuilds, a few minutes).

The app lives at **http://127.0.0.1:3456** and is only reachable from your Mac.

**Setting it up on another Mac:** in the app folder, run `npm ci`, then `zsh scripts/mac/install.sh`. That adds the `patchbay` command and the **Patchbay** app.

**Coming from DeepSeek Chat** (the app's old name): in the app folder, run `deepseek-chat stop`, `git pull`, `npm ci`, then `zsh scripts/mac/install.sh` (Windows: `install.ps1`, below) and open a new terminal. From then on the command is `patchbay`; your chats, settings and keys are untouched. The setup removes the old **DeepSeek Chat** app and command.

## 2b. On Windows

One-time setup, from the app folder in PowerShell:

```
npm ci
powershell -ExecutionPolicy Bypass -File scripts\windows\install.ps1
```

This adds **Patchbay** to your Desktop and Start menu, and the `patchbay` command to new terminals. After that, the same commands as on the Mac work: `patchbay`, `patchbay start`, `status`, `stop`, `restart`, `logs`. The app opens in its own Chrome or Edge window.

- **The first start builds the app**: a few minutes, showing only "Building the app…". Don't close the window or press Ctrl + C; it opens by itself.
- **If `patchbay` "is not recognized"**: close every terminal window and open a new one, or run `scripts\windows\patchbay.cmd` from the app folder.
- **Getting updates**, in the app folder: `patchbay stop`, then `git pull`, then `npm ci`, then `patchbay` (it rebuilds). Stop it first: Windows locks the files of a running app, so `npm ci` would fail.
- Step-by-step setup, updates and fixes for both systems are in the README under **Install and run**.

- **Keys** are saved encrypted with your Windows login (Windows' equivalent of the Keychain). Paste them in **Settings → AI providers**.
- **Choose folder…** and **Save** use Windows' own dialogs.
- The `security …` Keychain commands in section 3 are Mac-only. On Windows, manage keys in **Settings**.
- **Terminal** works the same, except Windows has no sandbox: look-only commands (`dir`, `git status`…) run straight away, and **every other command asks you first, even in Auto mode**, unless you switch on **Run without asking** in the chat (see Terminal below). The Internet switch is greyed out because it can't be enforced. Commands run in PowerShell.

## 3. API keys

Keys are stored in the **macOS Keychain**, never in a file. The easiest way: in the app, open **Settings → AI providers** (bottom-left), paste the key and click **Save key**. **Remove** deletes it from this computer; your chats are kept.

You need **at least one** of DeepSeek, Claude or GLM. With more than one, **Settings → Defaults for new chats** picks which one new chats use.

**DeepSeek key.** Get one at platform.deepseek.com → API keys.

| I want to… | Command |
|---|---|
| Add or replace the key | `security add-generic-password -U -a "$USER" -s deepseek-api-key -w` (it asks you to paste it) |
| Check a key is saved | `security find-generic-password -s deepseek-api-key` |
| Remove the key | `security delete-generic-password -s deepseek-api-key` |

**Claude key.** Get one at console.anthropic.com → API keys. It's billed per use, separately from a Claude.ai plan.

| I want to… | Command |
|---|---|
| Add or replace the key | `security add-generic-password -U -a "$USER" -s anthropic-api-key -w` |
| Check a key is saved | `security find-generic-password -s anthropic-api-key` |
| Remove the key | `security delete-generic-password -s anthropic-api-key` |

**GLM key.** Get one at z.ai → API Keys. It's billed per use from your Z.ai balance. A GLM Coding Plan doesn't cover this app (Z.ai only allows it in tools like Claude Code).

| I want to… | Command |
|---|---|
| Add or replace the key | `security add-generic-password -U -a "$USER" -s glm-api-key -w` |
| Check a key is saved | `security find-generic-password -s glm-api-key` |
| Remove the key | `security delete-generic-password -s glm-api-key` |

**Tavily key** (only for DeepSeek's and GLM's web search when **Settings → Web search → Search with** is *Tavily*; with *DeepSeek* it uses your DeepSeek key instead, and Claude has its own). Free at app.tavily.com: 1,000 searches a month, no card.

| I want to… | Command |
|---|---|
| Add or replace the key | `security add-generic-password -U -a "$USER" -s tavily-api-key -w` |
| Remove the key | `security delete-generic-password -s tavily-api-key` |

**GitHub token**: paste it in **Settings → GitHub** (the steps are there). Remove it with `security delete-generic-password -s github-token`.

## 4. Using the app

**Models:** pick from the dropdown next to the send button, per chat. New chats start with the one set in **Settings → Defaults for new chats**. The Claude list comes from your key, so every model it can use is there.

| Model | Good for | Cost |
|---|---|---|
| **DeepSeek V4.1 Flash (1017)** | Everyday use. Fast, and can see images. DeepSeek updates it in place: 1017 is the October 17, 2026 version. | Cheapest |
| **DeepSeek V4 Pro** | Hard problems. Text only. | About 4× Flash |
| **Claude Haiku** | Quick, simple jobs | Cheapest Claude |
| **Claude Sonnet** | Everyday work, coding | Middle |
| **Claude Opus** | Hard problems, long tasks | Higher |
| **Claude Fable** | The hardest problems | Highest |
| **GLM-5.3 Flash** | Everyday use. Fast, and can see images. | Cheap ($0.15 / $0.50 per million tokens) |
| **GLM-5.3** | Hard problems, coding, long tasks. Text only. | $1.40 / $4.40 per million tokens |

**Buttons next to the message box**

| Button | What it does |
|---|---|
| **+** | Upload files or images, or **Add a folder…** |
| **Think** | The AI reasons step by step before answering. Better for hard questions, but slower and uses more tokens. Effort is in the model dropdown (DeepSeek: High / Max; Claude: Low to Max; GLM: Low / High / Max). The newest Opus and Fable, and GLM, always think. |
| **Search** | The AI can search the web and cite sources. DeepSeek and GLM: only visible when turned on in **Settings → Web search for DeepSeek and GLM**, through Tavily (free key) or DeepSeek's search ($0.75 per 1,000, your DeepSeek key). Claude: its own search, $10 per 1,000 searches. Off by default in each chat. |
| **Code** (Claude) | Claude runs Python in Anthropic's sandbox (not on your computer) for sums, charts and data files you attach. Charts it makes appear under the reply to download. |
| **Token ring** | Hover it to see how full the chat is and what it has cost. **Summarize** there shortens a long chat now. |
| Greyed-out button | Not allowed for this AI: **Settings → AI providers → What … may do**. Clicking it takes you there. |
| **■** | Stops the reply in this chat (or press Esc). Other chats keep going. |

**Files and folders**
- **Drag** files, images, PDFs, Word docs, or whole folders anywhere onto the window.
- **+ → Add a folder… → Let the AI explore it:** it reads whatever files it needs by itself. **Repeat to link more folders** (e.g. backend and frontend); each shows as a chip, and × removes it.
- **+ → Add a folder… → Attach selected:** pick specific files from a checklist.
- Type **@** to mention a file from the open project folder.
- `.env` files and other secrets are always blocked.

**What each AI may do** (Settings → AI providers): switches for Read folders, Change files, Auto mode, Run commands, Read GitHub, Save to Docs, Web search and (Claude) Code execution. **Claude and GLM start with all of them off**; DeepSeek starts with them on. They apply on top of each project's and chat's own switches: off means off.

**Long chats** (Settings → Long chats): past 200K tokens (sooner for models with a smaller context), the earlier messages are summarized so the chat can keep going, for every provider. A line in the chat shows where. Editing a message from before that line drops the summary.

**Skills** (Settings → Skills, and Project settings → Skills)
- A skill is a folder with a `SKILL.md`: a name, a one-line description of when to use it, then your instructions (how you like it done, a checklist, a template). Same format as Claude Code and Claude.ai.
- The AI (DeepSeek, Claude or GLM) sees only the names and descriptions and opens a skill when a task matches. It can only read skills.
- **Your skills** live in the app's `data/skills` folder, so they move with it. **New skill** makes one and opens it in your text editor; the **pencil** opens it again. **Import folder…** / **Import .zip…** bring skills in. **Open folder** shows them in Finder.
- **Also use a folder on this computer:** e.g. Claude Code's `~/.claude/skills` (one click). Those stay on this computer; the copy button next to one copies it into your skills.
- **Projects** can have their own skills (kept with the project), and automatically use any `.claude/skills` folder inside their folders (those travel with your code). Switch **Also use my skills** or single skills off per project.
- Same name in two places: the project's own wins, then the one in its code, then yours.

**Helpers** (the **Helpers** button by the message box; limits in Settings → Helpers)
- For big tasks that split into parts: the AI sends **helpers** (separate runs of the same model, with an empty context) to research parts at the same time, then judges their reports and acts on them. DeepSeek chats get DeepSeek helpers, Claude chats get Claude helpers, GLM chats get GLM helpers.
- Helpers **only read** (folders, the web if Search is on, GitHub if on, skills, the Docs folder). They never change files or run commands; the AI does that, with your usual approvals.
- **● 2 helpers working** (top right) opens the helpers panel: what each is doing, its time, steps and cost, its task and report, and **Stop** / **Stop all**.
- The chat's **■ / Esc** stops the AI's reply only; helpers keep going until they finish or you stop them in the panel. Quitting the app stops them.
- When a round of helpers finishes, the AI gets their reports by itself (*Helper reports arrived*) and carries on. After 3 automatic replies in a row it waits for you: click **Send to …**.
- Limits: helpers at once (4), steps per helper (30), minutes per helper (15). Each helper costs about as much as a reply.

**Messages:** hover your message → **Edit** to change and resend it. **Retry** under a reply gets a new answer. **Save** under a reply saves it to a file you choose (new file, or add to the end of an existing one).

**Docs folder** (Settings → Docs folder; projects can set their own)
- The AI can **create and update documents** there in **any mode**, even Ask and Plan. Just say "save this as a doc".
- Every save shows a preview with **Approve** / **Reject**. Tick **Don't ask again for this doc** to skip the prompt for that doc; undo that in Settings → Docs folder.
- It can't reach anything else through the Docs folder, and in Plan mode your code stays read-only.

**GitHub (read-only)** (Settings → GitHub)
- Make a **fine-grained token** limited to chosen repos with read-only permissions (the steps are in Settings), then paste it in.
- **Tick** the repos the AI may read. Nothing is allowed until you tick it.
- In each **project's settings**, pick which of those repos its chats may read. None picked = no GitHub in that project.
- Turn the **GitHub** button on in a chat when you want it. It's off by default.
- The AI can read code, issues, PRs, commits and CI, and can't change anything on GitHub.

**Terminal** (Project settings → Terminal; off by default)
- The AI can **run commands** (tests, builds, installs, dev servers) in the **project's folders**. Chats outside a project never get it, and folders a chat adds on its own don't count.
- **Code blocks** in replies get a **▶ Run** button: it runs the command right there and shows the output. It costs nothing (the AI isn't involved). **Send to** (the chat's AI, e.g. *Send to Claude*) puts the output in your message if you want help with it.
- On the Mac, commands run in a **sandbox**: they can only change files in the project folders, can't read your SSH keys, logins, Keychain or this app's data, and can't open or control other apps.
- **Internet for commands** is off by default. Turn it on in Project settings for `npm install`, `pip install`, `git pull`.
- **GitHub stays read-only:** `git push` and the `gh` command never run, and git logins are hidden from commands. Push from your own terminal.

| Kind of command | What happens |
|---|---|
| Look-only (`ls`, `cat`, `grep`, `git status/diff/log`…) | Runs straight away, in every mode |
| Most commands (`npm test`, `npm run build`…) | **Asks first** in Ask, Plan and Edit. Runs without asking in **Auto** (Mac), or in Edit and Auto when the chat's **Run without asking** switch is on. Click **Always allow** on the card to stop asking for that command in this project; remove it in Project settings. |
| Risky (deleting folders, `git clean`, publishing, anything touching `.env`) | Always asks, even in Auto or with **Run without asking** on |
| Never (`sudo`, `git push`, `git reset --hard`, `gh`, `curl … \| sh`, running things in the background with `&`) | Refused, even if you approve |

- **Run without asking** (the switch at the right of the folder row, above the message box, in Edit and Auto mode): for a stretch of work where you don't want to click Run on every command, like implementing a plan and testing it. When it's on (amber), ordinary commands run straight away in that chat and their cards say *ran without asking*; risky ones still ask and blocked ones never run. It's off in every new chat and stays on in that chat until you switch it off. It needs **Auto mode** allowed for that AI in Settings. On the Mac, Auto mode already runs commands without asking, so the switch shows in Edit mode only.
- On the approval card: **Run**, **Don't run**, **Edit** (change the command first) or **Always allow**. What a command changes can't be undone with **Undo**, so keep your project in Git.
- In **Ask** and **Plan** mode, commands can only look: on the Mac even the project folder is read-only to them.
- **Time limit:** 10 minutes per command the AI runs, by default (30 or 60 in Project settings). Background commands and ▶ Run have no limit. If a command is stopped, the AI still gets the output so far.
- **Running list:** the **● running** button at the top right shows every command still running, from any chat, with its log, its port (e.g. localhost:3000) and a **Stop** button. Stop ends the command and everything it started, and only says *Stopped* once the system confirms they're gone. Dev servers the AI starts run in the background and show up here.

**Folder modes** (appear next to the model picker once a folder is open)

| Mode | What the AI can do |
|---|---|
| **Ask** (default) | Read and search your project, and answer questions. Changes nothing. |
| **Plan** | Read your project, then write a step-by-step plan. Changes nothing. When you're happy with the plan, switch to **Edit** or **Auto** and say "go ahead". |
| **Edit** | Create, change and delete files. Every change shows a red/green before-and-after preview with **Approve** / **Reject**. The input box turns amber so you know editing is on. |
| **Auto** | Like Edit, but the AI makes **all** the changes without asking. Use it when the plan is settled and you want the whole thing implemented. Every reply can still be undone. |

**"I've mapped out the whole change, just do it":** plan it in **Plan**, then switch to **Auto** and say "go ahead".

In Edit mode:
- **Approve all** approves everything currently waiting. **Switch to Auto** approves them and stops asking in this chat. Click **Edit** to go back to approving each change.
- **Undo changes** under a reply puts every file it touched back the way it was. If you edited one of those files afterwards, it asks before overwriting your edit.
- It never touches `.env`/secret files, `.git`, `node_modules`, or anything outside the folder. Running commands is separate: see **Terminal** above.
- If the folder has uncommitted Git changes, you'll see a warning. Committing first makes the AI's edits easy to review.

**Projects** (the **Projects** section of the sidebar)

| I want to… | Do this |
|---|---|
| Create a project | Sidebar → **Projects** → **+** |
| Start a chat in a project | Hover the project → ✎ icon, or open it and click **+ New chat** |
| Edit context, files, folder, memory | Hover the project → sliders icon, or click the project name at the top of a chat |
| Move a chat into / out of a project | Hover the chat → **⋯** → **Move to project** / **Remove from project** |
| Delete a project | Project settings → **Delete project** (its chats are kept) |

- **Project context:** instructions and background every chat in the project sees.
- **Folders:** your codebase. Linked to **every** chat in the project (old and new). The AI explores them on demand and only reads what it needs, so size doesn't matter. Add several if your project has several repos.
- **Project files:** small documents (specs, notes, a style guide). Their full text goes with every message.
- In a chat, a project folder shows with a stack icon. Click its **eye** icon to switch it off for just that chat, and again to switch it back on. Folders you add in the chat itself are for that chat only.
- **Memory:** *Project + global* also applies your Settings instructions. *This project only* ignores them.

**What the AI sees in each message:** your Settings instructions (unless the project is set to *This project only*), the project's context and files (if the chat is in a project), and **this chat only**. It never sees your other chats.

**Chats:** saved automatically. Hover a chat in the sidebar → **⋯** to rename, export to Markdown, or delete.

**Sending while it's replying:** you don't have to wait. Type and press Enter while the AI is still working; your message shows with a dashed outline.
- The AI reads it at its **next step** (for example after it reads a file or runs a command) and carries on with it in mind. If it's writing a plain answer, it finishes that answer and then continues with your message. Several messages sent meanwhile go in together. It costs nothing extra.
- **Answer together now** cuts off what it's writing and starts again with your message, for one joint answer. The cut-off part is still billed. If the AI is waiting for your approval or running a command, your message goes in right after that.
- **Cancel** takes the message back into the message box. If you press **Stop**, any waiting message goes back into the box too, so nothing is sent without you.

**Several chats at once:** while one chat is replying, switch to another and keep going. Up to **4 chats** can reply at the same time.
- In the sidebar, a **pulsing violet dot** means a chat is replying and an **amber dot + "waiting"** means it's waiting for you to approve a change or command. A folded project shows the dot too.
- If two chats in Edit or Auto mode are changing the same folder, the message box warns you, because edits made at the same time can clash.
- Closing or reloading the window stops replies still being written. Commands in the Running list keep going.

**Keyboard shortcuts**

| Action | Keys |
|---|---|
| Send | Enter |
| New line | Shift + Enter |
| New chat | ⌘ ⇧ O |
| Search chats | ⌘ K |
| Show / hide sidebar | ⌘ B |
| Stop reply | Esc |

## 5. Optional: the `deepseek` Terminal command (not part of Patchbay)

Only if you've set this up yourself; Patchbay doesn't install it. It's Claude Code (a text-only coding assistant that runs in Terminal) with DeepSeek plugged in. It can edit files and run commands in any folder you start it in, without the app's sandbox. It uses no Claude models and Anthropic bills nothing.

| I want to… | Do this |
|---|---|
| Start it in a project | `cd ~/Documents/Coding/my-project`, then `deepseek` |
| Switch to V4 Pro inside it | Type `/model opus` (in this tool, "opus" means DeepSeek V4 Pro) |
| Switch back to V4.1 Flash | Type `/model sonnet` |
| Start directly on V4 Pro | `deepseek --model opus` |
| Leave it | Type `/exit` or press Ctrl + C twice |

## 6. If something goes wrong

| Problem | Fix |
|---|---|
| App window is blank or says it can't reach the server | `patchbay restart` |
| "DeepSeek rejected your API key" | Settings → paste the key again → it's tested automatically |
| "Your DeepSeek balance has run out" | Top up at platform.deepseek.com |
| "Can't reach DeepSeek" | Check your internet connection, then press **Retry** |
| "Claude rejected your API key" | Settings → AI providers → paste the Claude key again |
| "Your Claude credit balance is too low" | Add credit at console.anthropic.com → Billing |
| "GLM rejected your API key" | Settings → AI providers → paste the GLM key again (create one at z.ai → API Keys) |
| "Your Z.ai balance has run out" | Top up at z.ai. A Coding Plan subscription doesn't count here: the app uses your pay-as-you-go balance |
| A button is greyed out (Search, Code, GitHub, a mode) | **Settings → AI providers → What … may do** → switch it on → Save |
| A skill isn't used | Check its switch in Settings → Skills (or Project settings), and that its description says when to use it. A ⚠ marks skills to fix. |
| The AI doesn't send helpers | Turn on **Helpers** by the message box. It only uses them for tasks that split into parts; you can also ask it to ("use helpers to…"). |
| "Waiting for you" note about helper reports | The AI already replied to helpers 3 times in a row. Click **Send to …** to let it review the new reports. |
| Search button missing | Settings → Web search → turn it on → Save |
| Search button does nothing | Settings → Web search: with *Tavily*, add your Tavily key; with *DeepSeek*, add your DeepSeek key in AI providers |
| The AI made a change you don't want | Click **Undo changes** under that reply |
| Ask / Plan / Edit / Auto buttons missing | They only show when a folder is open: **+ → Add a folder…** |
| The AI says it can't edit files | Switch the chat to **Edit** or **Auto**. It's told about the switch in your next message. |
| No ▶ Run buttons, or the AI can't run commands | The chat must be in a project with **Project settings → Terminal** on, and a project folder switched on in the chat |
| `npm install` / `git pull` fails in a command | **Project settings → Terminal → Internet for commands** (Mac) |
| A command says "not permitted" | The sandbox stopped it from going outside the project folders. That's intended. |
| "4 chats are already replying" | Wait for one to finish, or open one and press ■ / Esc to stop it |
| Something keeps running after I closed the window | Reopen the app → **● running** (top right) → **Stop**, or `patchbay stop` |
| App doesn't show in Spotlight | `mdimport ~/Applications/Patchbay.app` |
| Want to see what went wrong | `patchbay logs` |

## 7. Where things live

| What | Where |
|---|---|
| The app's code | The app folder: where you cloned it (e.g. `~/patchbay`) |
| Your saved chats | `…/data/chats/` in the app folder (one file per chat) |
| Projects | `…/data/projects/` (one file per project) |
| Uploaded images | `…/data/uploads/` |
| Docs the AI saves | `~/Documents/Patchbay Docs` by default for new installs (an existing setting is kept) (change in Settings or per project) |
| Backups for Undo | `…/data/backups/` |
| Settings | `…/data/settings.json` |
| Your skills | `…/data/skills/` (a project's own: `…/data/project-skills/`) |
| Server logs | `…/data/server.log` |
| App launcher | `~/Applications/Patchbay.app` |
| Commands | `~/.local/bin/patchbay` (set up by `scripts/mac/install.sh`, linked to `scripts/mac/patchbay`). The optional `deepseek` tool, if you have it: `~/.local/bin/deepseek` |

**Back up your chats** (and projects, skills and settings) by copying the `data/` folder. Copying it to another computer brings everything along except the keys: paste those again in Settings there.

## 8. For editing the code

| Command (run inside the app folder) | What it does |
|---|---|
| `npm run dev` | Development version with live reload at http://127.0.0.1:3455 |
| `npm run typecheck` | Checks the code for type errors |
| `npm run lint` | Checks code style |
| `patchbay restart` | Puts your changes into the everyday app |

## 9. Removing everything

```
patchbay stop
rm -rf ~/Applications/Patchbay.app ~/.local/bin/patchbay
security delete-generic-password -s deepseek-api-key
security delete-generic-password -s tavily-api-key
security delete-generic-password -s anthropic-api-key
security delete-generic-password -s glm-api-key
security delete-generic-password -s github-token
```
Then delete the app folder (back up `data/` first if you want your chats). If you also set up the optional `deepseek` tool, remove it with `rm ~/.local/bin/deepseek`.
