# Contributing to Patchbay

Thanks for your interest in Patchbay! Bug reports, ideas, documentation fixes and code are all welcome.

By taking part you agree to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Ways to help

- **Report a bug:** [open an issue](https://github.com/tobioj/patchbay/issues/new/choose) using the bug template. Include your OS, Node version, the provider and model, what you expected and what happened. The relevant part of `data/server.log` helps, but look it over first: it can contain file paths and command output from your projects.
- **Suggest a feature:** open an issue with the feature template. Check the [roadmap](roadmap.md) first; it may already be under consideration.
- **Test on your setup:** run the [testing checklist](testing.md) and share the results, especially on Windows, or with a provider or model that's rarely tested.
- **Improve the docs:** typos, unclear steps, missing troubleshooting tips. Small PRs are great.
- **Update prices or models** when a provider changes them (see [Building → Updating model prices](building.md#updating-model-prices-and-lists)).
- **Write code:** see below.

**Security issues:** please don't open a public issue. Follow [SECURITY.md](SECURITY.md).

## Development setup

See [Building from source](building.md). In short:

```bash
git clone https://github.com/tobioj/patchbay.git
cd patchbay
npm ci
DATA_DIR=/tmp/patchbay-dev npm run dev    # http://127.0.0.1:3455, with a scratch data folder
```

Read [Architecture](architecture.md) for a map of the code. This project uses **Next.js 16**; check `node_modules/next/dist/docs/` before writing framework code, as some APIs differ from older guides.

## Pull requests

1. **Open an issue first** for anything bigger than a small fix, so we can agree on the approach before you spend time on it.
2. Fork the repository and create a branch from `main`.
3. Keep each PR focused on one change. Update the docs (`README.md`, `docs/`, `CHEATSHEET.md`) if behaviour changes.
4. Before pushing:
   ```bash
   npm run typecheck
   npm run lint
   npm run build
   ```
5. Test it in the real app, and describe what you changed and how you tested it. If you touched folders, edits, approvals, the terminal, permissions, keys or a provider, say which [testing checklist](testing.md) sections you ran, on which OS.

## Guidelines

- **Safety first.** Patchbay gives models access to people's computers. Changes to `lib/commands.ts`, `lib/sandbox.ts`, `lib/files.ts`, `lib/roots.ts`, `lib/edits.ts`, `lib/access.ts`, `lib/secrets.ts`, `lib/github.ts` or `proxy.ts` get extra review. Explain why the change keeps the [security model](security-model.md) intact, and update that page if it changes.
- **Permissions only narrow.** A new capability needs a per-provider switch, must be greyed out when it's off, and starts **off** for providers other than DeepSeek.
- **Keys stay on the server.** Never send a key (or anything derived from it beyond the last four characters) to the browser, to commands, or to a provider other than its own.
- **Provider-neutral by default.** Features should work for every provider. Provider-specific behaviour belongs in that provider's session or client.
- **Few dependencies.** New packages need a good reason. Server-only code imports `server-only`.
- **Cross-platform.** Patchbay runs on macOS and Windows. Think about Windows paths, PowerShell, CRLF line endings for `.ps1`/`.cmd` files, and the missing sandbox on Windows. Say in your PR if you couldn't test one of them.
- **Privacy.** No analytics, telemetry or network calls beyond the services a user has configured.
- **Style.** Follow ESLint and the existing code. Use the colour tokens from `app/globals.css`, not raw colours. Comments explain *why*.
- **User-facing text** is plain and friendly: say what happened and what to do next.

## Commit messages

A short summary line in the imperative ("Add Mistral as a provider", "Fix undo after a rename"), then a blank line and any detail.

## License

Patchbay is licensed under the [Apache License 2.0](../LICENSE). By submitting a contribution you agree that it's provided under the same license (see section 5 of the license).
