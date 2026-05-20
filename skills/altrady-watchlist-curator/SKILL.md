---
name: altrady-watchlist-curator
description: Use when the user wants to manage watchlists — "manage my watchlist", "what's moving on my list", "add X to watchlist", "clean up watchlists", "build a watchlist of Y". Creates themed lists, prunes stagnant tickers, and ranks today's movers per list.
---

# Altrady — Watchlist Curator

Three sub-workflows: **build** a new themed list, **mover scan** an existing list, **prune** dead tickers.

## Build a new watchlist

1. Ask for the theme ("layer 1s", "AI coins", "RWA narrative", "high-beta to BTC").

2. If the user supplies markets, skip discovery. Otherwise:
   - `mcp__altrady__list_markets` filtered by the user's exchange.
   - Apply theme filter (you do this from your knowledge; the API doesn't do thematic search).
   - Present 10-15 candidates for the user to pick.

3. `mcp__altrady__create_watchlist` with the chosen name.

4. `mcp__altrady__add_to_watchlist` for each market in one batch (sequential if the API requires it, parallel if it doesn't).

5. Confirm and offer to run a mover scan immediately.

## Mover scan on an existing list

1. `mcp__altrady__list_watchlists` if the user didn't name one.

2. `mcp__altrady__get_watchlist` for the chosen list.

3. **Parallel:** `mcp__altrady__get_market_ticker` for each market in the list.

4. **Rank and report:**
   - Top 5 by absolute 24h % change.
   - Top 3 by volume spike (24h volume / 7d avg, if available).
   - Any market within 2% of a 30-day high or low (potential breakout/breakdown).

5. End with: "Want me to do TA on any of these?" — suggesting the `altrady-technical-analysis` skill.

## Prune

1. `mcp__altrady__get_watchlist` for the target list.

2. For each market, check 7-day % range from `mcp__altrady__get_ohlc` (1d candles).

3. **Tag each ticker:**
   - `STAGNANT` — 7-day range < 3%.
   - `ILLIQUID` — average volume below user threshold (ask; default $1M/day).
   - `RENAMED/DELISTED` — `get_market_ticker` returns error or no data.

4. Show tagged candidates, ask which to remove, apply `mcp__altrady__remove_from_watchlist`.

## Do not

- Do not delete a watchlist via `mcp__altrady__delete_watchlist` without explicit "yes, delete the whole list" confirmation.
- Do not silently drop markets from a list during a mover scan — that's the prune workflow.
- Do not invent thematic categories beyond what the user asked for.
