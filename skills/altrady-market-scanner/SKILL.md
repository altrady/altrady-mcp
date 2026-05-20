---
name: altrady-market-scanner
description: Use when the user wants to scan markets for opportunities — "scan for breakouts", "find volatile coins", "what's pumping", "find dips", "any setups today". Ranks markets by user-chosen criteria (volume, volatility, trend) and returns a shortlist.
---

# Altrady — Market Scanner

Find candidates worth analyzing. This skill produces a ranked shortlist — it does not open trades or do detailed TA (hand off to `altrady-technical-analysis` or `altrady-smart-entry`).

## Workflow

1. **Define the universe.** Ask the user:
   - All markets on the active exchange?
   - One or more watchlists?
   - A specific quote currency (e.g., USDT pairs only)?

   Fetch the universe via `mcp__altrady__list_markets` (with quote filter) or `mcp__altrady__get_watchlist`.

2. **Pick the scan criterion** (single-select via `AskUserQuestion`):

   | Criterion | What it ranks by | OHLC needed |
   |---|---|---|
   | Breakout setup | Price within 1% of N-day high, with rising volume | 100 1d candles |
   | Breakdown setup | Price within 1% of N-day low | 100 1d candles |
   | Volatility expansion | Today's range / 14d ATR | 30 candles |
   | Volume spike | 24h vol / 7d avg vol | from ticker if available, else daily candles |
   | Trend strength | (close - close 50d ago) / ATR | 100 1d candles |
   | Mean reversion | Z-score of distance from 50d SMA | 100 1d candles |

3. **Fetch data in parallel.** For each market in the universe, call `mcp__altrady__get_market_ticker` (always) and `mcp__altrady__get_ohlc` (if needed for the criterion). Cap parallelism reasonably (Altrady rate limits — if you hit them, sequentialize in batches of 10).

4. **Compute the score** for each market. Sort descending.

5. **Return the top 10.** For each, include:
   - Pair.
   - Score / metric value.
   - Current price + 24h %.
   - One-line context (e.g., "BTC-USDT: at 99% of 60d high, volume +2.3× 7d avg").

6. **Offer follow-ups:**
   - "Run TA on any of these?" → `altrady-technical-analysis`.
   - "Add some to a watchlist?" → `altrady-watchlist-curator`.
   - "Set an alert on the breakout level?" → `altrady-alert-manager`.

## Performance notes

- A full exchange scan can be hundreds of markets. Warn the user before scanning > 200 markets and offer to narrow.
- Prefer ticker-only criteria (volume spike, 24h %) when possible — they're cheap. OHLC scans are expensive.

## Do not

- Do not open positions or alerts from this skill. It's discovery.
- Do not promise that a "breakout setup" will break out. Describe what the data shows.
- Do not silently exclude markets due to errors. If `get_market_ticker` fails for some, note them at the end.
