---
name: altrady-technical-analysis
description: Use when the user asks for technical analysis — "analyze X", "do TA on", "what's the chart say", "is X bullish", "draw S/R on Y", "mark the trend". Performs multi-timeframe analysis, applies an indicator template, and draws structure (support/resistance, trendlines, ranges) directly on the active chart.
---

# Altrady — Technical Analysis

Bring a chart from blank to fully marked-up. Your output is a written read of the chart plus drawings + indicators applied via the MCP.

## Workflow

1. **Resolve the chart context:**
   - `mcp__altrady__resolve_active_chart` — what chart is the user looking at? If none, ask which market via `AskUserQuestion` and `mcp__altrady__open_market`.
   - `mcp__altrady__list_open_charts` if more than one is open and the user didn't specify.

2. **Multi-timeframe data fetch (parallel):**
   - `mcp__altrady__get_ohlc` on the higher timeframe (default 1D) — last 100 candles for trend context.
   - `mcp__altrady__get_ohlc` on the working timeframe (default 4h or 1h) — last 100 candles for setups.
   - `mcp__altrady__get_ohlc` on the lower timeframe (default 15m) — last 50 candles for entry timing.

3. **Identify structure** from the OHLC data:
   - **Trend** (HTF): consecutive higher highs/lower lows? Sideways range?
   - **Support / resistance**: at least 2 touches; rank by recency and reaction strength.
   - **Range** if HTF is sideways: top and bottom band.
   - **Liquidity sweeps / wicks**: long wicks beyond prior swings.

4. **Apply indicator template** via `mcp__altrady__toggle_chart_indicator`. Default set (toggle only what isn't already on — first call `mcp__altrady__list_chart_indicators`):
   - EMA(50), EMA(200) on the working timeframe.
   - RSI(14).
   - Volume.

   If the user has a preferred template, ask once and remember it for the session (note in memory if reused).

5. **Set timeframe** with `mcp__altrady__set_chart_timeframe` to the working timeframe so subsequent drawings land on the right chart context.

6. **Draw the structure** in one batched call `mcp__altrady__add_chart_drawings`:
   - Horizontal lines at each S/R.
   - A trendline (or two) along the dominant trend.
   - A rectangle if a range was identified.
   - Optional: vertical line on a noted liquidity sweep candle.

   Use distinct colors per layer (green = support, red = resistance, neutral = trend) so the chart reads cleanly.

7. **Write the read.** Three short paragraphs:
   - HTF trend + context.
   - Working timeframe setup (what's happening near current price).
   - LTF tactical note (entry trigger, invalidation).

   End with a one-line bias: bullish / bearish / no-trade and why.

## Decision points to ask the user

- Working timeframe (if not obvious from the active chart).
- Whether to clear existing drawings first (`mcp__altrady__clear_chart_drawings`) or layer on top.
- Whether to apply indicators (some traders prefer naked charts).

## Do not

- Do not draw arbitrary Fibs, harmonic patterns, Gann fans, or other low-evidence overlays unless explicitly asked.
- Do not make price predictions ("X will go to Y by Friday"). Describe what the chart shows; the trader decides.
- Do not modify positions, alerts, or bots from this skill — that's other skills' job.
- Do not draw more than ~6 lines/shapes. A messy chart is worse than no chart.
