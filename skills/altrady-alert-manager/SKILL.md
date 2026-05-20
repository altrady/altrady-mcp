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

4. **For indicator-based alerts** (e.g., "alert me on RSI < 30", "MA cross"):
   - Confirm the indicator and threshold.
   - Note: indicator alerts are typically evaluated server-side by Altrady; create them via the same `create_alert` call with the indicator parameters.

5. **Create the alert(s)** via `mcp__altrady__create_alert`. Use a descriptive message:
   - `"BTC-USDT reclaims 65,000 (4h resistance)"`
   - `"ETH-USDT loses 3200 (swing low from 2026-05-18)"`

   Confirm with the user before creating multiple alerts at once.

6. **Report** the alert id(s) and current distance from price.

## Mode: Audit

1. `mcp__altrady__list_alerts` — all alerts.

2. **For each alert, fetch current price** via `mcp__altrady__get_market_ticker` (parallel by market).

3. **Tag each alert:**
   - `FIRED` — recently triggered (Altrady should expose this; if not, infer from price having crossed level).
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
