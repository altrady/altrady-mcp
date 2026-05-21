---
name: altrady-alert-manager
description: Use when the user wants to manage alerts — "set an alert on X", "alert me when X hits Y", "audit my alerts", "clean up alerts", "list alerts". Creates alerts anchored to chart structure (S/R, MA, swing levels) and prunes stale alerts.
---

# Altrady — Alert Manager

Two modes: **create** (anchor alerts to meaningful levels) and **audit** (review what's set, prune what's dead).

## Mode: Create

1. **Identify the market.** Ask if unclear.

2. **If the user gave an explicit price**, go straight to step 5.

3. **If the user asked for alerts "at structure"** or similar:
   - `mcp__altrady__get_ohlc` last 100 candles on working TF.
   - Identify the 2-3 most recent S/R levels.
   - Identify any psychological level (round number) the price is near.
   - Present the candidate levels and let the user pick which to alert on.

4. **For bar-close / candle-evaluated alerts** (e.g., "alert me when the 1h candle closes above 65k"):
   - Confirm the price level and the candle timeframe.
   - Use `alertType: "price"` with `data: {triggerType: "ONCE_ON_BAR_CLOSE", triggerResolution: "60"}` (resolution in minutes — "60" = 1h, "240" = 4h, "1D" = daily). The backend's `alertType` enum is `price | trend_line | time` — there's no separate `indicator` type.
   - Pure indicator alerts ("alert when RSI < 30") aren't directly supported by `create_alert`; tell the user to set those up via the UI's Alert Form (chart → Alert tab) and offer to open the right chart with `mcp__altrady__open_market`.

5. **Create the alert(s)** via `mcp__altrady__create_alert`. Use a descriptive message:
   - `"BTC-USDT reclaims 65,000 (4h resistance)"`
   - `"ETH-USDT loses 3200 (swing low from 2026-05-18)"`

   Confirm with the user before creating multiple alerts at once.

6. **Report** the alert id(s) and current distance from price.

## Mode: Audit

1. **Two parallel calls** to `mcp__altrady__list_alerts`:
   - `status: "pending"` — alerts still armed.
   - `status: "delivered"` — alerts that have already fired (these are your `FIRED` set without inference).

2. **For each alert, fetch current price** via `mcp__altrady__get_market_ticker` (parallel by market).

3. **Tag each alert:**
   - `FIRED` — came back in the `delivered` page above.
   - `STALE` — alert price is > 20% away from current AND alert is > 30 days old.
   - `DUPLICATE` — multiple alerts within 0.5% of the same price on the same market.
   - `IMMINENT` — alert is within 1% of current price.

4. **Present the table.** Group by tag. Suggest:
   - Delete: `STALE` and `DUPLICATE`.
   - Keep: `IMMINENT` (these are about to fire).
   - Review: `FIRED` (did the user act on them? if not, why is it still there?).

5. **Ask the user which to delete.** Apply via `mcp__altrady__delete_alert`. Edit (rather than delete) if the user wants to keep the level but update the message — use `mcp__altrady__edit_alert`.

## Do not

- Do not bulk-delete alerts without per-alert or per-group confirmation.
- Do not create alerts at arbitrary round percentages (e.g., "alert at +5%"). Anchor to actual chart levels or user-supplied prices.
- Do not create more than ~5 alerts per market in one session — alert spam masks real signals.
