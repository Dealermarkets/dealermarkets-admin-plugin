# DealerMarkets Admin plugin

For DealerMarkets App Admins only, not for dealers. It isn't listed in Claude's or ChatGPT's plugin directory. The dealer plugin is a separate plugin.

- **Connector:** the DealerMarkets admin connector (`/admin/mcp`), App Admin sign-in only.
- **Skill:** `extract-product-facts` reads a product's stored documents (`catalog_get_documents` with `text: true`), writes the product's search facts and saves them (`catalog_facts_upload_link` with curl, or `catalog_set_product_facts`). The server files each fact as public or dealer-only by its document's visibility and refuses the save if any fact fails a check.
- Status: proof of concept. The skill needs connector tools that aren't released yet.

## Install

- **Claude:** add this repo as a plugin (Customize › Plugins). The extraction needs code execution for the upload link; without it the skill sends the facts in the tool call.
- **Claude Code:** `claude plugin install .` (or `claude --plugin-dir .`) from this folder.
- **ChatGPT:** `scripts/package-chatgpt.sh`, then upload `dist/dealermarkets-admin-<version>.zip` privately in OpenAI's Plugins dashboard. After installing, turn the plugin's MCP server on and sign in.

To test against a local Worker or tunnel, change the URL in `.mcp.json` and `chatgpt/mcp.json` on a branch, never on `main`.

## Layout

| Path | What |
| --- | --- |
| `.claude-plugin/plugin.json`, `.mcp.json` | Claude manifest and connector |
| `chatgpt/plugin.json`, `chatgpt/mcp.json` | ChatGPT (Agent Plugins) manifest and connector |
| `skills/extract-product-facts/` | The fact extraction skill, shared by Claude and ChatGPT |
| `scripts/package-chatgpt.sh` | Builds the ChatGPT upload ZIP into `dist/` |
