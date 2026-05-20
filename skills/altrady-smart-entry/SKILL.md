---
name: altrady-smart-entry
description: Use when the user wants to open a position — phrases like "open a long on X", "buy X", "short Y", "enter a trade", "I want to long/short". Sizes the position from account risk %, places SL at structure, staggers take-profits, and opens via Altrady's smart position. Always confirms before executing.
---

# Altrady — Smart Position Entry

Your job: turn a trader's idea ("long ETH, stop below 3200, target 3500") into a properly sized, multi-TP smart position. **Never open the position without explicit confirmation.**

## Required inputs

Use `AskUserQuestion` to gather what's missing:

1. **Market** — pair (e.g. `ETH-USDT`). If ambiguous, call `mcp__altrady__list_markets` and disambiguate.
2. **Side** — long or short.
3. **Entry type** — market, or limit at price X. (If limit, ask for the price.)
4. **Stop loss** — explicit price, or "structure" (you derive from recent swing).
5. **Take profits** — single target, or staggered (e.g. 50% at T1, 50% at T2).
6. **Risk** — % of account to risk on this trade (default 1%).

## Workflow

1. **Get context** in parallel:
   - `mcp__altrady__get_session_context` — active account, equity.
   - `mcp__altrady__get_market_ticker` for the chosen pair — current price.
   - `mcp__altrady__get_ohlc` last ~50 candles on the trader's working timeframe (ask if unclear; default 1h) — for structure-based SL if needed.

2. **Derive SL if "structure":** for a long, place SL just below the most recent swing low; for a short, just above the most recent swing high. Show the user the candle you anchored on and the price.

3. **Calculate size:**
   ```
   risk_$ = account_equity * (risk_pct / 100)
   sl_distance = |entry - sl| / entry
   size = risk_$ / sl_distance
   ```
   For leveraged markets, also show effective leverage.

4. **Plan TPs:** if user picked staggered, default to R-multiples (T1 = 1R, T2 = 2R, T3 = 3R) unless they gave explicit prices. Each TP has a size fraction summing to 100%.

5. **Show the plan and ask for confirmation.** Format:

   ```
   ETH-USDT LONG (limit @ 3420)
     Size:        $X (Y ETH, ~Zx leverage if applicable)
     SL:          3198  (-6.5%, structure low from 1h candle 2026-05-19 14:00)
     TP1 (50%):   3642  (+6.5%, 1R)
     TP2 (50%):   3864  (+13%, 2R)
     Risk:        1.00% of $E equity = $R
   Confirm? (yes / adjust / cancel)
   ```

6. **On confirmation:** call `mcp__altrady__open_smart_position` with the parameters. Report the position ID and the next step (`altrady-position-manager` to track it).

## Do not

- **Never open the position without an explicit "yes"** from the user. "Looks good" is not "yes" — ask once more.
- Do not set a position with no SL. If the user refuses to set one, decline and explain.
- Do not size beyond available margin. If `size` exceeds what the account can fund, cap it and tell the user.
- Do not "improve" the user's SL or TP levels beyond the structure check. They have a thesis; you place orders.
