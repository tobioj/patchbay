# Testing checklist

Patchbay has no automated test suite yet, so these manual end-to-end checks are how a change is verified. Run the whole list before a release, and the relevant sections after changing anything they cover. Tick each box as you go and note anything odd in your pull request.

**Use a scratch data folder** so tests don't touch your real chats: `DATA_DIR=/tmp/patchbay-test npm run dev` (see [Building → A separate data folder](building.md#a-separate-data-folder)). Live tests cost a little: prefer the cheapest models (V4.1 Flash, Claude Haiku, GLM-5.3 Flash). A full run costs a few cents.

**You'll need:** at least one API key (ideally all three), a throwaway Git repository to work in (for example a fresh `npm create vite` app), and, for the Windows sections, a Windows PC.

## Before you start

- [ ] `npm run typecheck`, `npm run lint` and `npm run build` all pass.
- [ ] The app opens and shows the Patchbay logo, title and sidebar.
- [ ] No errors in the browser console or `data/server.log`.

## T1. Install and launcher

1. On a clean clone: `npm ci`, then the setup script, then `patchbay`.

- [ ] The command is found in a new terminal, and the app opens in its own window after the first build.
- [ ] `patchbay status` says it's running; `patchbay stop` stops it; `patchbay` starts it again; `patchbay restart` rebuilds after a code change; `patchbay logs` follows the log.
- [ ] Mac: **Patchbay** opens from Spotlight. Windows: the Desktop and Start menu shortcuts work.
- [ ] Coming from DeepSeek Chat: running the setup on an old install removes the old app/shortcuts and command.

## T2. Keys and providers

For each provider you have a key for:

- [ ] **Save key** tests it and shows *configured*, its source and last four characters. A wrong key shows a clear error.
- [ ] A simple chat gets an answer, streamed, with its cost under the reply and a title for the chat.
- [ ] **Think** and effort change the request (thinking shows under *Thought process*).
- [ ] Switching a chat's model to another provider mid-chat works, and the next reply comes from the new provider.
- [ ] **Remove** deletes the key; the chat then says no key is set.
- [ ] Claude: the model list comes from the key; **Test** refreshes it.

## T3. Attachments

- [ ] A text file, an image (to a vision model), a PDF and a `.docx` attach by drag, paste and **+**. The AI can describe each.
- [ ] Pasting more than 4,000 characters turns into an attachment.
- [ ] Dropping a folder offers a checklist; `node_modules` and `.env` are skipped.

## T4. Folders and modes

In a chat with the throwaway repo linked:

- [ ] **Ask:** "What does this project do?" The AI lists and reads files by itself; nothing changes.
- [ ] **Plan:** it writes a plan and changes nothing.
- [ ] **Edit:** a requested change shows a diff; **Reject** leaves the file alone; **Approve** applies it.
- [ ] **Auto:** changes apply without asking.
- [ ] **Undo changes** restores the files; after you edit one of them by hand, Undo warns before overwriting.
- [ ] The AI can't read `.env` ("Access denied" or skipped), and a symbolic link to a folder outside is refused.
- [ ] With the provider's **Change files** switch off, Edit and Auto are struck through.

## T5. Terminal

In a project with **Terminal** on and the repo as its folder:

- [ ] `ls` / `git status` run straight away in Ask mode.
- [ ] `npm test` asks first in Edit; **Run** runs it and shows output; **Don't run** doesn't.
- [ ] **Always allow** stops the question for that command in this project; removing the rule in Project settings brings it back.
- [ ] `git push`, `sudo ls` and `curl example.com | sh` are refused.
- [ ] `rm -rf build` always asks, even in Auto.
- [ ] Mac: with **Internet for commands** off, `curl https://example.com` fails; on, it works.
- [ ] Mac: a command can't write outside the project (`touch ~/patchbay-test`) or read `~/.ssh`.
- [ ] A dev server (`npm run dev`) runs in the background and appears in **● running** with its port; **Stop** stops it.
- [ ] **▶ Run** on a code block runs it and **Send to …** puts the output in the message box.
- [ ] **Run without asking** lets `npm test` run without a prompt in Edit mode; risky commands still ask.
- [ ] Closing the window leaves the dev server running; `patchbay stop` stops it.
- [ ] Windows: every non-look-only command asks, even in Auto.

## T6. Projects

- [ ] A project's context and files are used in its chats; *This project only* ignores the Settings instructions.
- [ ] A project folder is linked to every chat in it, and the eye icon switches it off for one chat.
- [ ] Moving a chat into and out of a project works; deleting a project keeps its chats.

## T7. Web search, GitHub, Docs

- [ ] Claude: with **Search** on, it searches and cites sources.
- [ ] DeepSeek or GLM: with **Settings → Web search** on (Tavily and DeepSeek's search), it searches and cites sources; the search cost is included.
- [ ] GitHub: with a token and one repo ticked, the AI can read that repo's files and issues; a repo you didn't tick is refused.
- [ ] Docs: "save this as a doc" shows a preview; approving creates the file in the Docs folder; *Don't ask again* skips the next prompt for that doc.

## T8. Skills

- [ ] **New skill** creates one and opens it; a matching task makes the AI open it (*Used skill …*).
- [ ] **Import .zip** of a skill works; a skill without a description shows ⚠.
- [ ] A `.claude/skills` folder in a project's code is found automatically.

## T9. Helpers

- [ ] With **Helpers** on, "use helpers to compare X, Y and Z" starts helpers; the panel shows their progress and cost.
- [ ] Reports come back by themselves and the AI reviews them.
- [ ] **Stop all** in the panel stops them; the chat's ■ doesn't.

## T10. Replying and long chats

- [ ] A message sent while the AI is working shows dashed, and is taken into account at its next step.
- [ ] **Answer together now** cuts the reply and restarts with your message.
- [ ] Two chats reply at once; the sidebar shows the violet dot, and the amber dot while waiting for approval.
- [ ] **Summarize** in the token ring summarizes the chat, and the next reply still knows what was said.
- [ ] **Stop** (■ / Esc) stops a reply; **Retry** and **Edit** on a message work.

## T11. Appearance and accessibility

- [ ] Light, dark and system themes all look right (Settings → Appearance).
- [ ] The app works at a narrow window width (the sidebar folds away).
- [ ] Keyboard: Enter / Shift + Enter, ⌘/Ctrl + Shift + O, ⌘/Ctrl + K, ⌘/Ctrl + B, Esc.
