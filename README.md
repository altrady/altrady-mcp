# Altrady MCP

Drive [Altrady](https://altrady.com) from any AI assistant that speaks MCP — open positions, run bots, set alerts, draw charts, and review trades through natural conversation.

This repo ships a curated set of **trader workflow skills** that build on top of the Altrady MCP server. The skills turn high-level requests ("size up a long on ETH with 1% risk", "scan my watchlist for breakouts", "review yesterday's closed trades") into the right sequence of MCP calls.

---

## Install

One prompt, one paste. The Altrady desktop app generates a prompt with your MCP URL and auth token already embedded; your AI assistant does the rest. Works with Claude Code, Cursor, Codex CLI, Claude Desktop, and any other MCP-capable tool.

### Step 1 — Copy the install prompt

1. Open the **Altrady desktop app**.
2. Go to **Settings → MCP server**.
3. Enable the MCP server if it isn't already.
4. Click **Copy install prompt**.

The clipboard now holds a prompt that looks like:

```
Install the Altrady MCP server for me.

MCP server URL: http://127.0.0.1:6850/mcp
Auth token:     <your token>

Fetch the install instructions at
https://raw.githubusercontent.com/altrady/altrady-mcp/main/INSTALL.md
and follow them exactly. The instructions cover Claude Code, Cursor, Codex,
Claude Desktop, and other MCP-capable AI tools — pick the one that matches
your runtime. Use the URL and token above when registering the server.
```

> The token is account-scoped — don't share it or commit it. The desktop app can rotate it if needed.

### Step 2 — Paste it into your AI assistant

Open your AI assistant (Claude Code, Cursor, Codex, etc.) and paste. The assistant will:

1. Register the Altrady MCP server using the URL and token from the prompt — the registration mechanism is runtime-specific (CLI command, JSON config file, etc.) and `INSTALL.md` covers each.
2. Clone this repo into `~/.altrady-mcp` (skipped on hosts without terminal access).
3. **Claude Code only:** symlink the workflow skills into your Claude Code skills directory.
4. Verify the connection by calling the MCP.

Restart the host app if it asks you to. Skills load on Claude Code restart; Cursor and Codex pick up MCP servers immediately.

> **Skills are Claude Code only.** The MCP server works with any MCP-capable AI tool — but the curated workflow skills below target Claude Code's `Skill` mechanism. On other tools you'll call the MCP tools directly (still very usable, just no scripted multi-step workflows).

> **Heads up:** money-affecting actions (opening positions, starting bots, deleting alerts) always require explicit confirmation. The skills are designed so the AI suggests and you approve.

---

## Manual install

If you'd rather run the steps yourself, the per-tool registration blocks are in `INSTALL.md`. The shared steps after registration:

```bash
# Clone this repo
git clone https://github.com/altrady/altrady-mcp ~/.altrady-mcp

# Claude Code only: install the workflow skills
bash ~/.altrady-mcp/install.sh

# Verify from your AI assistant
#   Ask: "Use the altrady MCP to show my session context"
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
| `altrady-backtest-analyzer` | "analyze my backtest", "review backtest X", "how did the backtest do" | Pulls a replay backtest with positions and trades; computes win rate, drawdown, hold time, fee drag; asks one targeted question. |

---

## What this repo is not

- Not the MCP server itself. The server runs inside the Altrady desktop app — this repo only ships the workflow skills and the install recipe the AI follows to wire everything together.
- Not a trading bot. The skills suggest actions; you confirm before anything executes.
- Not financial advice. The skills automate workflows you'd already do by hand.

---

## License

MIT.
