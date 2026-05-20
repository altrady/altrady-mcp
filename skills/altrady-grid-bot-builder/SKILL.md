---
name: altrady-grid-bot-builder
description: Use when the user wants to set up a grid bot — "create a grid bot", "build a grid on X", "set up grid trading", "grid bot on Y range". Derives a sensible range from recent price action, sets grid density from volatility, and creates + starts the bot. Confirms before launching.
---

# Altrady — Grid Bot Builder

Take a market and turn it into a grid bot configured for the current regime. Grids work in ranges, not trends — your first job is to check that.

## Workflow

1. **Confirm the market.** `mcp__altrady__list_markets` if ambiguous. The bot runs on one pair.

2. **Regime check.** Fetch `mcp__altrady__get_ohlc` last 100 candles on the user's working timeframe (default 4h).
   - Compute ATR or stdev of returns.
   - Check trend: is the 50-period close drifting > 5% from the 100-period close? If so, **warn the user** — grids in trends bleed.
   - If user wants to proceed despite a trend warning, note it and move on. Do not refuse.

3. **Derive range.** Use one of:
   - **Recent high/low** (default): high and low of last N candles (default 100 on the working TF).
   - **ATR bands**: current price ± k × ATR (ask k, default 2).
   - **User-supplied**: explicit upper/lower prices.

   Always show the chosen bounds and the rationale.

4. **Derive grid density:**
   - Default grid count: `ceil(range_width_pct / step_pct)` where step_pct ≈ `0.5 × ATR_pct` so each step roughly captures one candle's noise.
   - Cap at 50 levels for clarity; expose the trade-off (more grids = smaller profit per fill, more orders).

5. **Sizing.** Ask: total capital to allocate. Show capital-per-grid and worst-case allocation at the bottom of the range (long bias) or top (short bias).

6. **Show the plan and confirm.**

   ```
   Grid bot: BTC-USDT
     Range:     58,000 – 72,000  (4h high/low of last 100 candles)
     Levels:    32 (~430 USD step)
     Capital:   10,000 USDT  (~313 / grid)
     Mode:      Long (price below mid)
     Trend warning: HTF is up — grid may underperform vs. holding spot.
   Create and start? (yes / adjust / cancel)
   ```

7. **On confirmation:** `mcp__altrady__create_grid_bot`, then `mcp__altrady__start_grid_bot`. Confirm the bot id and show grid levels via `mcp__altrady__get_grid_bot_levels` for visual sanity check.

## Alternative: hand off to the UI

If the trader prefers to fine-tune, call `mcp__altrady__open_create_grid_bot_form` with the prefilled parameters instead of creating directly. Use this when:

- More than one regime warning fired.
- The user has explicitly said "let me adjust in the UI."

## Do not

- Do not start a bot without explicit confirmation.
- Do not pick a grid range that's tighter than 2 × ATR — almost certain to be breached.
- Do not auto-allocate the user's entire account balance. Cap at what they specified.
- Do not silently skip the trend warning. If you see one, surface it.
