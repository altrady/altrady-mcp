# Altrady MCP

Drive [Altrady](https://altrady.com) from any AI assistant that speaks MCP — open positions, run bots, set alerts, draw charts, and review trades through natural conversation.

This repo ships a curated set of **trader workflow skills** that build on top of the Altrady MCP server. The skills turn high-level requests ("size up a long on ETH with 1% risk", "scan my watchlist for breakouts", "review yesterday's closed trades") into the right sequence of MCP calls.

---

## Install

The install is two steps. The Altrady desktop app gives you the first; this repo gives you the second.

### Step 1 — Connect the MCP server (from the Altrady desktop app)

1. Open the **Altrady desktop app**.
2. Go to **Settings → AI Assistants → Connect Claude Code** (or the equivalent for your AI tool).
3. Copy the install command shown there. It includes your personal authorization token and looks roughly like:
   ```
   claude mcp add altrady <URL with your token>
   ```
4. Paste and run it in your terminal.

> The token is account-scoped — don't share it or commit it. The desktop app can rotate it if needed.

### Step 2 — Install the workflow skills

Paste this into Claude Code (or any AI tool that can read URLs and run shell):

```
Set up the Altrady workflow skills: read https://raw.githubusercontent.com/altrady/altrady-mcp/main/INSTALL.md and follow it exactly.
```

The AI will clone this repo, install the skills into your Claude Code config, and verify the connection by calling the MCP.

Prefer to do it by hand? See **Manual install** below.

> **Heads up:** money-affecting actions (opening positions, starting bots, deleting alerts) always require explicit confirmation. The skills are designed so the AI suggests and you approve.

---

## Manual install

If you'd rather run the steps yourself:

```bash
# 1. Run the MCP install command from the Altrady desktop app
#    (Settings → AI Assistants → Connect Claude Code)
#    It looks like: claude mcp add altrady https://mcp.altrady.com/...?token=...

# 2. Clone this repo
git clone https://github.com/altrady/altrady-mcp ~/.altrady-mcp

# 3. Install the skills
bash ~/.altrady-mcp/install.sh

# 4. Restart Claude Code and verify
#    Ask: "Use the altrady MCP to show my session context"
```

---

## Skill catalog

| Skill | Trigger phrases | What it does |
|---|---|---|
| `altrady-morning-check` | "morning check", "what's happening today", "review my account" | Surfaces open positions, triggered alerts, bot performance, and watchlist movers in one sweep. |
| `altrady-smart-entry` | "open a long/short", "I want to buy X", "enter a position" | Sizes a position from your risk %, places SL at structure, staggers TPs, opens via `open_smart_position`. |
| `altrady-position-manager` | "manage my positions", "move SL to BE", "trail this trade" | Walks open positions and applies BE moves, trails, partial closes. |
| `altrady-technical-analysis` | "analyze X", "do TA on", "what's the chart saying" | Multi-timeframe scan with indicator templates + structure drawings. |
| `altrady-grid-bot-builder` | "set up a grid bot", "build a grid on X" | Derives range from recent price action, sets density from volatility, creates + starts a grid bot. |
| `altrady-signal-bot-builder` | "create a signal bot", "set up DCA on X" | Designs DCA with base, safety orders, and TP grid; creates + starts a signal bot. |
| `altrady-alert-manager` | "set alerts on X", "audit my alerts", "clean up alerts" | Creates alerts at meaningful levels; prunes stale alerts. |
| `altrady-watchlist-curator` | "manage watchlist", "what's moving on my list" | Builds themed lists, prunes stagnant tickers, ranks today's movers. |
| `altrady-market-scanner` | "scan for breakouts", "find volatile coins", "what's pumping" | Ranks markets by volume, volatility, or trend criteria. |
| `altrady-risk-sizer` | "size this trade", "how much can I buy", "risk calc" | Calculates position size from account risk %, SL distance, leverage. |
| `altrady-trade-review` | "review my last trade", "journal this close", "what did I learn" | Pulls a closed position, reconstructs context, captures lessons. |

---

## What this repo is not

- Not the MCP server itself. The server is installed via the command provided in the Altrady desktop app.
- Not a trading bot. The skills suggest actions; you confirm before anything executes.
- Not financial advice. The skills automate workflows you'd already do by hand.

---

## License

MIT.
