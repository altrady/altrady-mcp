---
name: altrady-backtest-analyzer
description: Use when the user wants to analyze a replay backtest — "analyze my backtest", "review backtest X", "how did the backtest do", "what worked in this backtest", "show me backtest stats". Pulls a replay-backtest with positions and trades, computes the win/loss / drawdown / hold-time picture, and asks targeted questions about what to keep or change.
---

# Altrady — Backtest Analyzer

Turn a replay-backtest into a one-page picture of what worked, what didn't, and what's worth carrying into live trading. Read-only by design.

## Workflow

1. **Pick the backtest.** In order of preference:
   - User said "the one I have open" or "current" → `mcp__altrady__get_backtest` with `id: "current"`.
   - User named a specific backtest → `mcp__altrady__list_backtests` with `query`, then `get_backtest` with the matching id.
   - User said "my last one" / "most recent finished" → `list_backtests` with `status: "finished"`, sort by `updatedAt` desc, pick first.
   - Ambiguous → `list_backtests` (no filters), show 5–10 most relevant, ask which one.

2. **Fetch full payload.** `mcp__altrady__get_backtest` returns positions, orders, trades, stats, config, and balances. Everything you need is in this one call — do not make extra round-trips for per-position detail.

3. **Surface a 3-line "is this the right backtest?" recap.** Market, timeframe, window, position count, net PnL. Confirm with the user implicitly by moving on; if it's obviously the wrong one, they'll redirect.

4. **Ask the trader to state their rules.** The analysis is only worth as much as the benchmark — without their rules you're guessing. Ask in **one short batch**, four bullets, with examples so it's a 30-second answer, not an essay:

   ```
   Before I dig in, in one or two lines each:

   - Strategy:   What's the system? (e.g. "1D trend-follow on majors", "4h breakout from range",
                  "mean-revert on oversold RSI"). Side rule — long-only, short-only, both?
   - Sizing:     What's the risk rule? (e.g. "1% of equity per trade", "fixed 5k notional",
                  "Kelly fraction", "vibes"). Risk on starting balance or running balance?
   - Entry:      What triggers an entry? (e.g. "20-EMA reclaim + bullish engulfing",
                  "break of prior swing high with volume", "RSI < 30 + S/R bounce").
   - Exit:       SL and TP rules? (e.g. "SL at last swing low, TP at next resistance",
                  "fixed 3R TP, hard SL", "trail behind 4h SuperTrend").

   If you don't have a written rule for one of these, just say "discretionary" — that's a real answer
   and tells me to evaluate looser.
   ```

   Edge cases:
   - User wants to skip ("just analyze it") → proceed with assumptions explicitly labeled. State each assumption inline in the report (e.g. "assuming 1% risk on starting equity") so they can correct it after.
   - User answers only some bullets → use stated rules for those dimensions, assumption-tagged defaults for the rest.
   - User has already stated their rules earlier in this conversation → don't re-ask. Reference what they said.

5. **Compute analytics — both aggregate and per-rule deviations.** Backend `stats` may include aggregates already (`totalProfitQuote`, `totalProfitPct`, etc.) — use those when present, compute the rest.

   **Aggregate metrics:**
   - **Counts:** total positions, open, closed, canceled. Skip canceled for win-rate math.
   - **Win rate:** closed positions with `netProfit > 0` ÷ closed positions.
   - **PnL distribution:** total, mean, median, best, worst (in quote currency and %).
   - **Hold time:** mean / median of `closeTime - openTime` for closed positions.
   - **Long vs short split:** if mixed, break PnL and win rate down by side.
   - **Streaks:** longest winning and losing streak by close time order.
   - **Approx drawdown:** walk closed positions in `closeTime` order, accumulate PnL, track max-to-trough drop.
   - **Fee drag:** sum of fees (from `trades[]` or aggregate stats) as % of gross PnL.
   - **Trade frequency:** trades per day over `replayStartAt` → `lastCandleSeenAt || replayEndAt`.

   **Per-rule deviation checks** — for each rule the user stated, compare actuals trade-by-trade:

   - **Sizing rule** (highest leverage check). For each position pull `openPrice` and `smartSettings.stopLoss.stopPrice`. Compute `SL_distance = (openPrice - stopPrice) / openPrice` (sign-flipped for shorts). Then `actual_$_risk = openCost × SL_distance`. As % of equity at that point, that's the *real* risk taken. Compare to the stated rule:
     - Fixed-% risk (e.g. "1% per trade"): `target_cost = (target_risk_$ / SL_distance)`. Flag any trade where actual cost is >25% above or below target. Compute counterfactual PnL: `norm_PnL = actual_PnL × target_cost / actual_cost`. Sum normalized PnL and compare to actual — that's the dollar value of sizing inconsistency. **This is usually the biggest single finding.**
     - Fixed notional (e.g. "always 5k"): flag deviations from the fixed amount.
     - "Discretionary": skip the deviation check, just report the *range* (min, median, max $ risk) so they can see the actual variance.
   - **Entry rule deviation:** harder to verify from data alone, but check for *clustered re-entries* — same level tested within a few candles of a stop-out. Surface them as "did you take this re-entry on purpose or was it a discretion miss?"
   - **Exit rule deviation:** check `closeTime - openTime` outliers (e.g. one trade held 3× median). Check whether winners closed at the stated TP level (`smartSettings.exitOrders[].price`) or short of it. Check whether losers closed at the stated SL price exactly (`smartSettings.stopLoss.stopPrice`) or above/below (manual exits).
   - **Side rule:** if user said "long only", flag any short positions. If "both", report the split.

6. **Reconstruct chart context (optional, only if needed for a question).** The payload includes `coinraySymbol`, `resolution`, and the replay window. If the user wants to see *where* a specific trade happened, fetch `mcp__altrady__get_ohlc` over that window — don't do it upfront.

7. **Present the summary in three blocks: numbers, vs-your-rules, lessons.** Skip sections that don't apply.

   ```
   Backtest: ETH-USDT 1h  —  "Range strategy v2"
   Window:   2026-03-01 → 2026-04-30  (60 days, finished)
   Capital:  10,000 USDT start  →  11,420 USDT end  (+14.2%)

   Positions: 47 closed  (32 win / 15 loss, win rate 68%)
   Avg PnL:   +30 USDT  (median +18, best +280, worst -190)
   Hold:      median 6h, mean 11h
   Drawdown:  -8.4% peak-to-trough (after position #23 → #29 losing streak)
   Fees:      214 USDT  (15% of gross profit)
   Bias:      Longs 30/40 winners (75%) vs shorts 2/7 (29%) — short side underperformed.

   Vs your stated rules:
   ✓ Strategy:  1h breakout from range — you stuck with it (no off-system trades detected).
   ✗ Sizing:    Rule was 1% risk per trade. Actual $ risk per trade ranged 0.6% to 2.3%,
                median 1.4%. Three winners were undersized by 30%+, costing ~$340 normalized.
                Inconsistent sizing alone cost ~$420 of net PnL.
   ✓ Entry:     No re-entry-after-stop clusters detected.
   △ Exit:      8 of 32 winners closed manually before TP1 (median: -$45 vs stated TP1).
                Either the rule needs to allow earlier exits, or the discretion cost ~$360.
   ```

   Where the user said "discretionary" for a dimension, skip the ✓/✗ verdict and just report the *range* you saw — they can decide if that variance was intentional.

8. **Ask one targeted question** based on what stands out. Pick at most one — the trader writes the lesson, not you. Prefer questions tied to the largest rule deviation surfaced above:

   | What stands out | Question |
   |---|---|
   | High win rate, low avg PnL | "Are TPs hitting too early? What would the curve look like if you'd held one more leg?" |
   | Low win rate, high avg PnL | "Losers small, winners large is fine — but the win rate suggests entries need work. Where did losing trades go wrong?" |
   | One side dominated negatively | "Your shorts lost money in this backtest. Was the regime wrong for shorts, or is the setup itself worse short-side?" |
   | Big drawdown despite end-positive | "You ended green but drew down -8% mid-run. Would you have stuck with the system through that streak in real money?" |
   | Fees > 10% of gross | "Fees ate 15% of your gross. Lower trade frequency or larger size per trade would change this. Which lever?" |
   | Most PnL from 1–2 trades | "One trade did most of the work. Would the system still be worth running without it?" |
   | Hold time skewed long | "Mean hold is 4× median — a few trades sat for days. Were those intentional, or stop-outs you forgot about?" |

9. **Suggest one follow-up** at most, mapped to another skill or MCP tool:
   - "Open this backtest in the widget to scroll the chart" → `mcp__altrady__open_backtest`.
   - "Run TA on the same pair to see if the regime still holds" → `altrady-technical-analysis`.
   - "Size a live entry off this thesis" → `altrady-smart-entry`.

## Notes on the data

- `backtestPositions[]` items have `status` ∈ `open` / `closed` / `canceled`. Filter canceled out of stats; show them separately if non-trivial count.
- Each position has `openTime`/`closeTime` as epoch seconds (or ISO — check), `openPrice`/`closePrice`, `openCost`, `netProfit`, `netProfitPercentage`, `side`, `numTrades`.
- Each position has `smartSettings.stopLoss.stopPrice` (the configured SL) and `smartSettings.exitOrders[].price` (the configured TP levels). These are the *intended* rules; `closePrice` is what actually happened. Comparing the two surfaces rule deviations.
- `trades[]` items have `externalOrderId` linking back to orders. For per-position trade detail, filter `trades` by the position's exit-order ids — the payload has both.
- The aggregate `stats` block may include `totalProfitQuote`, `totalProfitPct`, `totalFeesQuote`, `numBuyFills`, `numSellFills`, etc. Use them when present rather than recomputing.

## Do not

- Do not open new positions, modify alerts, or touch live trading from this skill. It's analysis only.
- Do not skip the rules-question step "to be helpful." Without their rules you're benchmarking against your own assumptions — that's worse than asking. The one exception is if they've already stated their rules in this conversation; reference what they said.
- Do not invent metrics the data doesn't support (Sharpe, Sortino, Calmar) — compute them only if you have what you need *and* the user asked.
- Do not call `open_backtest` automatically. Suggest it as a follow-up; the user opens it when they want.
- Do not dump raw position arrays. Summarize.
- Do not present more than one targeted question per session — picking the right one is the value.
