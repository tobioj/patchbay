# Security policy

Patchbay gives AI models access to people's files and terminals, so security reports are taken seriously and are very welcome.

## Reporting a vulnerability

**Please don't open a public issue for security problems.**

Report privately through GitHub: go to the repository's **Security** tab and click **Report a vulnerability**
([direct link](https://github.com/tobioj/patchbay/security/advisories/new)).

Please include:

- what the problem is and what an attacker could do with it;
- steps to reproduce, or a proof of concept;
- the Patchbay version or commit (`git rev-parse --short HEAD`), your operating system, and the provider and model if relevant;
- what the attacker needs: a web page you visit, content the AI reads (a file, web page or GitHub issue), a program running on your computer, or access to your account.

## What to expect

- An acknowledgement within a few days.
- An assessment and, if confirmed, a plan for a fix. Patchbay is a small project, so please allow reasonable time.
- Credit in the release notes when the fix ships, if you'd like it.

Please give us a chance to release a fix before disclosing the issue publicly.

## Scope

In scope, for example:

- A web page driving Patchbay's local API, or reading data through it
- Getting an API key sent to the browser, to a terminal command, or to a host other than its provider
- Reading or writing files outside the folders linked to a chat
- Reading secret files through the folder, Docs or skills tools
- Running a command the rules say is blocked, or skipping an approval the rules say is required
- Escaping the macOS command sandbox
- Getting around the per-provider permission switches, the project settings, or the GitHub repo allowlist
- Making Patchbay write to GitHub
- Path traversal through uploads, skill imports or the Docs folder

Out of scope: the limitations already listed under [What Patchbay doesn't protect](security-model.md#what-patchbay-doesnt-protect) and [Limits of the terminal rules](security-model.md#limits-of-the-terminal-rules) (for example, the missing Windows sandbox, or other programs running as you calling the local API), a model doing what you approved, and attacks that need malware already running as your user.

## Supported versions

Patchbay is installed from source. Security fixes go into `main`; please update with `git pull` (see [Install → Updating](install.md#updating)).
