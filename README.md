# DealerMarkets Admin plugin

For DealerMarkets App Admins only, not for dealers. It isn't listed in Claude's or ChatGPT's plugin directory. The dealer plugin is a separate plugin.

- **Connector:** the DealerMarkets admin connector (`/admin/mcp`), App Admin sign-in only. It creates and updates products and their pages.
- **Skills:** none yet. Skills ship here as new plugin versions.

## Install

- **ChatGPT (desktop app):** Plugins › Add › Add a marketplace, enter `https://github.com/Dealermarkets/dealermarkets-marketplace` (leave Git ref and Sparse paths empty), then install DealerMarkets Admin and sign in with your App Admin login. To get a new version, quit ChatGPT and open it again.
- **Claude:** add this repo as a plugin (Customize › Plugins).
- **Claude Code:** `claude plugin install .` (or `claude --plugin-dir .`) from this folder.
- **ChatGPT archive upload (fallback):** `scripts/package-chatgpt.sh`, then upload `dist/dealermarkets-admin-<version>.zip` with Plugins › Add › Upload plugin archive.

## Releasing a version

Bump `version` in both `plugin.json` and `.claude-plugin/plugin.json` and push to `main`. ChatGPT picks it up when the app restarts. To test against another Worker, change the URL in `.mcp.json` and `mcp.json` on a branch, never on `main`.

## Layout

| Path | What |
| --- | --- |
| `.claude-plugin/plugin.json`, `.mcp.json` | Claude manifest and connector |
| `plugin.json`, `mcp.json` | ChatGPT (Agent Plugins) manifest and connector, at the repo root where ChatGPT reads them |
| `skills/` | Skills, shared by Claude and ChatGPT (none yet) |
| `scripts/package-chatgpt.sh` | Builds the ChatGPT upload ZIP into `dist/` |
