# DealerMarkets Admin plugin (private)

For DealerMarkets App Admins (Jim, Mike), not for dealers. Never submit it to Claude's or ChatGPT's directory: the public `dealermarkets` plugin is the repo root.

- **Connector:** the DealerMarkets admin connector (`/admin/mcp`), App Admin sign-in only.
- **Skill:** `extract-product-facts` reads a product's stored documents (`catalog_get_documents` with `text: true`), writes the product's search facts and saves them (`catalog_facts_upload_link` with curl, or `catalog_set_product_facts`). The server files each fact as public or dealer-only by its document's visibility and refuses the save if any fact fails a check.
- Status: proof of concept (2026-11-18). The tools are on MCP branch `chat-extraction-poc`, against Bubble branch `facts-json-2`. Plan: `docs/plans/chat-fact-extraction-plan.md` in the MCP repo.

## Install

- **Claude:** add this folder as a plugin (Customize › Plugins › add from a folder or the repo's `admin/` path). The extraction needs code execution for the upload link; without it the skill sends the facts in the tool call.
- **Claude Code:** `claude plugin install ./admin` (or `--plugin-dir ./admin`).
- **ChatGPT:** `../scripts/package-chatgpt.sh admin`, then upload `dist/dealermarkets-admin-<version>.zip` privately in OpenAI's Plugins dashboard.

To test against a local Worker or tunnel, change the URL in `.mcp.json` and `chatgpt/mcp.json` on a branch, never on `main`.
