# Providers

Patchbay doesn't sell or proxy access to any model. You bring your own API key for each provider you want, the app talks to that provider directly from your computer, and you pay the provider for what you use. This page covers each supported provider: where to get a key, the models, what they cost, and what's special about them.

**Contents:** [At a glance](#at-a-glance) · [DeepSeek](#deepseek) · [Claude (Anthropic)](#claude-anthropic) · [GLM (Z.ai)](#glm-zai) · [What each AI may do](#what-each-ai-may-do) · [Web search](#web-search) · [Thinking and effort](#thinking-and-effort) · [Costs](#costs) · [Adding another provider](#adding-another-provider)

## At a glance

| | DeepSeek | Claude | GLM |
|---|---|---|---|
| **Get a key** | platform.deepseek.com → API keys | console.anthropic.com → API keys | z.ai → API Keys |
| **Billing** | Prepaid balance | Per use (separate from a Claude.ai plan) | Prepaid balance (pay as you go) |
| **Models** | V4.1 Flash (1017), V4 Pro | Every model your key can use (Haiku to Fable) | GLM-5.3, GLM-5.3 Flash |
| **Sees images** | Flash only | Yes | Flash only |
| **Reads PDFs itself** | No (gets their text) | Yes (layout, tables, scans) | No (gets their text) |
| **Context window** | 1M tokens | Up to 1M, depending on the model | 1M tokens |
| **Web search** | Tavily or DeepSeek's search | Claude's own search | Tavily or DeepSeek's search |
| **Runs code in a cloud sandbox** | No | Yes (**Code** button) | No |
| **Permissions to start with** | All on (except code) | All off | All off |
| **Long-chat summaries written by** | Patchbay (with V4.1 Flash) | Claude itself on newer models, otherwise Patchbay | Patchbay (with GLM-5.3 Flash) |

Every feature in the [user guide](user-guide.md) (folders, Ask / Plan / Edit / Auto, the terminal, GitHub, the Docs folder, skills, helpers, long chats) works with **every** provider, under the same rules and approvals. A chat can switch provider at any time from the model menu.

## DeepSeek

**Key:** create one at **platform.deepseek.com → API keys**, then paste it in **Settings → AI providers → DeepSeek**.

| Model | Model id | Good for | Notes |
|---|---|---|---|
| **V4.1 Flash (1017)** | `deepseek-flash` | Everyday use | Fast, cheapest, sees images. DeepSeek updates it in place; 1017 is the October 17, 2026 version. |
| **V4 Pro** | `deepseek-v4-pro` | Hard problems | Smartest DeepSeek model (version 0813). Text only. |

- **Thinking** can be switched on or off per chat (**Think**), with effort **High** or **Max**.
- **Prices** (USD per million tokens, off-peak): Flash $0.15 input / $0.60 output ($0.003 for cached input); Pro $0.66 / $1.98 ($0.022 cached). **DeepSeek charges double at peak times** (01:00–04:00 and 06:00–10:00 UTC, Monday to Friday), and Patchbay's cost figures include that.
- **Titles and summaries** for DeepSeek chats are written by V4.1 Flash, with thinking off to keep them cheap.
- **Search with DeepSeek:** your DeepSeek key can also power web search for DeepSeek and GLM chats. See [Web search](#web-search).

## Claude (Anthropic)

**Key:** create one at **console.anthropic.com → API keys**, then paste it in **Settings → AI providers → Claude**. Claude API usage is billed per use, separately from any Claude.ai subscription.

**Models:** the model menu lists every Claude model your key can use, fetched from Anthropic's Models API, grouped by family (Fable, Opus, Sonnet, Haiku), newest first. Testing the key in Settings refreshes the list. Rough guide:

| Family | Good for | Cost |
|---|---|---|
| **Haiku** | Quick, simple jobs | Cheapest Claude |
| **Sonnet** | Everyday work and coding | Middle |
| **Opus** | Hard problems, long tasks | Higher |
| **Fable** | The hardest problems | Highest |

Exact per-model prices are in `lib/models.ts` (for example Sonnet 5.5 is $2 input / $10 output per million tokens, Opus 5.5 $4 / $20). A model the app has no price for still works; its cost shows as unknown.

Claude-only features:

| | |
|---|---|
| **Web search** | Claude's own search and page reading (no Tavily key needed), with the **Search** button. $10 per 1,000 searches plus the pages it reads. **Settings → AI providers → Web search and safety options** caps the searches per reply (5 by default) and lists sites it must never use. |
| **Code execution** | The **Code** button. Claude runs Python in **Anthropic's** sandbox, not on your computer: calculations, charts, data files you attach (CSV, Excel). Files it makes appear under the reply to download. The sandbox is kept for the chat between replies. |
| **PDFs and images** | Claude reads PDFs as they are (layout, tables, scanned pages) and sees images. |
| **Declines** | If Claude's safety checks flag a harmless request, another Claude model can answer instead (on by default, in **Web search and safety options**); the reply says so. |
| **Long chats** | Newer models summarize the conversation themselves (Anthropic's compaction); older ones are summarized by Patchbay. |

**Your Claude key only ever goes to Anthropic.** Patchbay deliberately ignores `ANTHROPIC_BASE_URL` and similar settings that tools like Claude Code set for themselves, so a variable meant for another tool can't send your key elsewhere. See [Security model](security-model.md#api-keys).

## GLM (Z.ai)

**Key:** create one at **z.ai → API Keys**, then paste it in **Settings → AI providers → GLM**. Usage is billed per token from the credit you top up at z.ai.

| Model | Model id | Good for | Price (USD per million tokens) |
|---|---|---|---|
| **GLM-5.3** | `glm-5.3` | Hard problems, coding, long tasks. Text only. | $1.40 input / $4.40 output ($0.26 cached) |
| **GLM-5.3 Flash** | `glm-5.3-flash` | Everyday use. Fast, sees images. | $0.15 / $0.50 ($0.03 cached) |

- **Both always think.** Thinking can't be switched off; the effort (**Low**, **High** or **Max**) sets how much. **Settings → Defaults for new chats → GLM: effort** sets the default (High).
- **Titles and summaries** are written by GLM-5.3 Flash.
- **GLM Coding Plan can't be used.** Z.ai only allows Coding Plan subscriptions in its supported tools (Claude Code, Cline, Cursor…) and can restrict or ban accounts that use them elsewhere, so Patchbay always uses the pay-as-you-go endpoint.
- **Your GLM key only ever goes to Z.ai** (`api.z.ai`). Patchbay ignores other tools' `ZAI_*` and `ANTHROPIC_BASE_URL` settings.

## What each AI may do

**Settings → AI providers → What … may do** has a set of switches for each provider:

| Switch | What it allows |
|---|---|
| **Read folders** | Explore and read the folders linked to a chat or project |
| **Change files** | Edit mode: create, change and delete files, with your approval |
| **Auto mode** | Change files without asking (and, on the Mac, run ordinary commands without asking) |
| **Run commands** | The terminal, in projects where it's switched on |
| **Read GitHub** | Read-only GitHub access to repos you've allowed |
| **Save to Docs** | Create and update documents in the Docs folder |
| **Web search** | Search the web and read pages |
| **Code execution** | Claude only: run code in Anthropic's sandbox |

**Claude and GLM start with every switch off**; switch on what you want. DeepSeek starts with them on (it had these abilities before the switches existed). These switches sit **above** each project's and chat's own settings: off means off everywhere, and the matching buttons in chats are greyed out. Clicking a greyed-out button takes you to the switch. How the layers combine: [Architecture → Permissions](architecture.md#permissions).

## Web search

| Chat's AI | How it searches | What you need |
|---|---|---|
| **Claude** | Claude's own search tool, run by Anthropic | Nothing extra; allow **Web search** for Claude |
| **DeepSeek** and **GLM** | Through the service picked in **Settings → Web search** | That setting turned on, plus the matching key |

For DeepSeek and GLM, **Settings → Web search** offers two services:

- **Tavily:** a free key from [app.tavily.com](https://app.tavily.com) gives 1,000 searches a month, no card needed.
- **DeepSeek's search:** uses your DeepSeek key and balance; $0.75 per 1,000 searches and per 1,000 pages read, included in each reply's cost.

Once it's on, a **Search** button appears next to **Think**. It's off by default in each chat; when it's on, the AI can search, read pages and cite its sources.

## Thinking and effort

| | Thinking | Effort levels |
|---|---|---|
| DeepSeek | On / off per chat | High, Max |
| Claude | On / off on most models; the newest Opus and Fable always think | Low to Max, depending on the model |
| GLM | Always on | Low, High, Max |

The **Think** button switches thinking; the effort is in the model menu. **Settings → Defaults for new chats** sets the defaults per provider. When you switch a chat to another model, the effort moves to the nearest level that model accepts (never higher).

## Costs

- Each reply shows what it cost, from the token counts the provider reports and the prices in `lib/models.ts` and `lib/tokens.ts`.
- The **token ring** next to the model picker shows how full the conversation is, the chat's total cost so far, and an estimate for the next message.
- Helpers, summaries and per-use tools (searches) are included in the chat's total.
- Prices change. If a provider updates its prices, edit `lib/models.ts` (Claude) or `lib/tokens.ts` (DeepSeek, GLM). A pull request is welcome.

## Adding another provider

Patchbay is built to grow beyond these three. Providers with an OpenAI-compatible chat API (like DeepSeek and GLM) share most of their code; Claude has its own session because Anthropic's API is different. The files to touch are listed in [Architecture → Adding a provider](architecture.md#adding-a-provider). Please [open an issue](https://github.com/tobioj/patchbay/issues/new/choose) first to discuss it.
