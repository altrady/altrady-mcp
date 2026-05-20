---
name: altrady-position-manager
description: Use when the user wants to manage open positions — phrases like "manage my positions", "move SL to BE", "trail this", "partial close", "scale out", "tighten stops", "review open trades". Walks each open position and suggests adjustments (BE moves, trails, partial closes). Always confirms before editing.
---

# Altrady — Position Manager

Help the trader keep their open positions healthy. You suggest, they confirm, then you edit via the MCP.

## Workflow

1. **List positions:** `mcp__altrady__list_positions`. If empty, tell the user and stop.

2. **For each position, fetch details in parallel:**
   - `mcp__altrady__get_position` — entry, SL, TPs, current PnL.
   - `mcp__altrady__get_market_ticker` — live price.

3. **For each position, analyze and tag with one or more of:**

   | Tag | Condition | Suggested action |
   |---|---|---|
   | `BREAKEVEN_CANDIDATE` | Price is > 1R favorable from entry, SL is still at initial level | Move SL to entry (BE) |
   | `TRAIL_CANDIDATE` | Price is > 2R favorable, no trailing SL set | Set a trailing SL at last swing low/high |
   | `PARTIAL_CANDIDATE` | TP1 not yet hit but price is within 0.25R of it | Pre-position partial close at TP1 |
   | `STAGNANT` | Position has been open > N hours (ask user threshold; default 48h) with PnL within ±0.25R | Suggest closing or re-evaluating thesis |
   | `STOPPED_OUT_RISK` | Price within 0.25R of SL | Notify, do NOT auto-tighten — that destroys the trade plan |
   | `NO_SL` | No SL set | URGENT — recommend setting one immediately |

4. **Present a table** of positions with tags and one suggested action per position. Skip positions with no tag.

5. **Ask the user which adjustments to apply.** Multi-select OK.

6. **Apply each approved adjustment** via `mcp__altrady__edit_smart_position`. If the user picks a full close, use `mcp__altrady__close_smart_position`.

7. **Report final state:** what changed, what didn't.

## Tagging rules

- `BREAKEVEN_CANDIDATE` and `TRAIL_CANDIDATE` are mutually exclusive — once trailing, the position is past the BE phase.
- `NO_SL` is always urgent and listed first.
- Trailing distance default: the height of the last 3 candles on the position's working timeframe (estimate from `get_ohlc` if needed). Always show the trader the absolute price you'd set.

## Do not

- Do not tighten SLs beyond their original level toward entry except via the BE move (which is by definition entry). Tightening into a moving market destroys plans.
- Do not edit positions without explicit per-position confirmation. Approving "BE move on ETH" is not approval for "trail on BTC."
- Do not close a position unless the user explicitly says close. Suggesting is fine; executing is not.
- Do not invent SL/TP prices. Every suggestion is anchored to a candle, an R-multiple, or the trader's original plan.
