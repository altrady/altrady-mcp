---
name: altrady-morning-check
description: Use when the user says "morning check", "what's happening today", "review my account", "daily check", or asks for an overview of their trading account. Surfaces open positions, recently triggered alerts, bot performance, and watchlist movers in one sweep so the trader knows what needs attention.
---

# Altrady — Morning Check

A one-shot daily routine. Your job is to brief the trader in 60 seconds: what's open, what fired overnight, how the bots did, what's moving on their watchlists.

## Workflow

Run these MCP calls in parallel (no dependencies between them):

1. `mcp__altrady__get_session_context` — confirm which exchange account is active. If multiple accounts exist (`mcp__altrady__list_exchange_accounts`), note that and ask if they want all of them or just the active one.
2. `mcp__altrady__list_positions` — every open position.
3. `mcp__altrady__list_alerts` — all alerts; you'll filter for recently triggered ones.
4. `mcp__altrady__get_bots_stats` — aggregate bot P&L and counts.
5. `mcp__altrady__list_grid_bots` and `mcp__altrady__list_signal_bots` — current bot state.
6. `mcp__altrady__list_watchlists` — get watchlist names + ids.

Then, for each watchlist, call `mcp__altrady__get_watchlist` (parallel) to pull the markets in it. For up to the top 3 watchlists by user preference, fetch `mcp__altrady__get_market_ticker` for each market and rank by 24h % change.

## Report format

Brief the user in this order. Skip sections that are empty.

### 1. Open positions
For each: pair, side, entry, current PnL %, distance to SL/TP. Flag any position where:
- PnL is < -1R (stopped out territory)
- Price has crossed the entry by > 1R but SL is still at original (candidate for BE move)
- No SL is set (urgent)

### 2. Triggered alerts (last 24h)
Group by market. For each: which alert fired, current price vs alert price.

### 3. Bots
One line per bot type: count running, total realized P&L (24h if available), any bot that errored or stopped unexpectedly.

### 4. Watchlist movers
Top 3 gainers and top 3 losers across the user's watchlists by 24h %. Note any market in a watchlist where price is near a recent high/low (could be a breakout setup — suggest the `altrady-technical-analysis` skill for follow-up).

### 5. Suggested actions
End with at most 3 concrete suggestions, each one mapped to a follow-up skill:

- "Move SL to BE on ETH-USDT long" → `altrady-position-manager`
- "BTC alert at 65k fired — do you want a TA pass?" → `altrady-technical-analysis`
- "Two watchlist coins look like breakout setups (SOL, AVAX)" → `altrady-market-scanner`

## Do not

- Do not open positions, edit positions, start/stop bots, or delete alerts from this skill. It's read-only by design.
- Do not dump raw JSON. Summarize.
- Do not invent metrics the API doesn't return (e.g., "Sharpe ratio") — stick to what `get_position` and `get_bots_stats` actually expose.
