---
name: altrady-trade-review
description: Use when the user wants to review or journal a trade — "review my last trade", "journal this close", "what did I learn from X", "post-mortem on Y trade". Pulls a closed position, reconstructs the chart context, prompts the trader for lessons, and saves a journal entry.
---

# Altrady — Trade Review

Make post-trade reflection cheap so the trader does it. The skill reconstructs what happened and asks one good question; the trader answers in 30 seconds.

## Workflow

1. **Pick the trade.** Ask which one if not obvious:
   - "Most recent close" — call `mcp__altrady__list_positions` (status: closed if the API supports filtering; otherwise filter client-side).
   - "Specific market" — list closed positions on that market.
   - "Specific position id" — direct lookup.

2. **Get the trade details:** `mcp__altrady__get_position` with the chosen id.

3. **Reconstruct context (parallel):**
   - `mcp__altrady__get_ohlc` over the position's lifespan (entry candle to exit candle, plus ~10 candles before and after for context). Use the trader's working timeframe.
   - `mcp__altrady__list_chart_drawings` on that market — drawings present at the time may still be there.

4. **Build the recap:**

   ```
   ETH-USDT LONG  (closed 2026-05-19)
     Held:       18h
     Entry:      3,420 @ 2026-05-18 22:14
     Exit:       3,612 @ 2026-05-19 16:30  (TP2 hit)
     R-multiple: +1.85R
     Max favorable: +2.1R (briefly touched TP3 level)
     Max adverse:   -0.3R (held below entry first 4h)
   ```

5. **Ask one targeted question** based on the outcome:

   | Outcome | Question |
   |---|---|
   | Stopped out at full loss | "Was the SL invalidated by structure, or did price wick and recover? Anything to learn about SL placement?" |
   | Took partial profit but rest stopped at BE | "BE move was correct — would you have left the runner without it?" |
   | Hit all TPs | "Anything from this setup that you'd repeat? Any signal that the runner was coming?" |
   | Closed early manually | "What changed in your read between entry and exit?" |
   | Stagnant close (small P&L) | "Was the thesis invalidated, or did you exit early on noise?" |

6. **Save the journal entry.** Append to a local file the user controls — default `~/altrady-journal/<YYYY>-<MM>-<DD>-<market>.md`:

   ```markdown
   # ETH-USDT LONG — 2026-05-19

   **R-multiple:** +1.85R
   **Held:** 18h
   **Setup:** [user's words]
   **What worked / what didn't:** [user's words]
   **Lesson:** [user's one line]
   ```

   Ask the user to confirm the path before writing. They can override.

7. **Optional roll-up.** If the user asks "review this week", repeat the above for each closed trade in the window and produce a one-pager: count, win rate, average R, and the recurring lessons across entries.

## Do not

- Do not reopen the chart or modify drawings — this is reflection, not action.
- Do not invent a lesson the trader didn't articulate. Their words, not yours.
- Do not store the journal entry anywhere besides what the user approved.
- Do not include account balances or PII in the journal unless the user asks.
