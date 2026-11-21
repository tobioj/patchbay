## What does this change?

<!-- A short description, and the issue it closes if there is one (Closes #…). -->

## How was it tested?

- [ ] `npm run typecheck`, `npm run lint` and `npm run build` pass
- [ ] Tried in the real app (which OS, which provider and model):
- [ ] [Testing checklist](https://github.com/tobioj/patchbay/blob/main/docs/testing.md) sections run, if this touches folders, edits, approvals, the terminal, permissions, keys or a provider:

## Checklist

- [ ] Docs updated if behaviour changed (`README.md`, `docs/`, `CHEATSHEET.md`)
- [ ] Works on macOS and Windows, or the PR says which one wasn't tested
- [ ] No new network calls, telemetry or dependencies without a reason given above
- [ ] Keys never reach the browser, commands or another provider
- [ ] New capabilities have a per-provider switch and start off for providers other than DeepSeek
