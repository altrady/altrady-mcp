---
name: altrady-signal-bot-builder
description: Use when the user wants to build a signal/DCA bot — "create a signal bot", "set up DCA on X", "build a DCA strategy", "average down on Y". Designs a DCA strategy with base order, safety orders, and TP grid, then creates + starts the bot. Confirms before launching.
---

# Altrady — Signal Bot Builder

Signal (DCA) bots are accumulation strategies: place a base order, layer safety orders below if price drops, take profit at a configured percentage. Your job is to size the layers sensibly given the user's risk appetite.

## Workflow

1. **Confirm the market and side.** Most DCA bots are long-only spot-style accumulation. If the user asks for short DCA, confirm they understand the asymmetric risk (downside is bounded, upside is not).

2. **Get context (parallel):**
   - `mcp__altrady__get_market_ticker` — current price.
   - `mcp__altrady__get_ohlc` — last 100 candles on working TF for volatility.

3. **Gather strategy inputs** via `AskUserQuestion`:
   - **Total capital** allocated to this bot.
   - **Number of safety orders** (default 5).
   - **Price deviation to first safety order** (% below entry; default 1.5 × ATR%).
   - **Safety order step scale** (each next SO at X% more deviation; default 1.0 = uniform, 1.5 = widening).
   - **Safety order size scale** (martingale-style — each next SO is X × previous; default 1.5).
   - **Take profit %** off average entry (default 1%).

4. **Compute the ladder.** Build a table:

   | # | Price | Deviation | Size (quote) | Cumulative | Avg entry |
   |---|---|---|---|---|---|
   | Base | 3420 | 0% | 100 | 100 | 3420 |
   | SO1 | 3369 | -1.5% | 150 | 250 | 3389 |
   | SO2 | 3287 | -3.9% | 225 | 475 | 3340 |
   | ... | ... | ... | ... | ... | ... |

   Show the worst-case max drawdown price (last SO filled) and the average entry at that point. Compute the TP price off the final average entry.

5. **Sanity checks:**
   - Total capital used == user's allocation (within rounding).
   - Max drawdown isn't through a structural support (warn if it would close below a 200-day low or similar).
   - TP % isn't tighter than 0.5% over fees (the bot would lose to costs).

6. **Show the plan and confirm.**

   ```
   Signal bot: ETH-USDT (long DCA)
     Capital:        2,000 USDT, 6 layers (1 base + 5 SO)
     Base @ 3420    | TP +1.0% = 3454
     Max DD @ 2980  | new avg = 3122, TP = 3153
   Create and start? (yes / adjust / cancel)
   ```

7. **On confirmation:** `mcp__altrady__create_signal_bot`, then `mcp__altrady__start_signal_bot`. Surface the bot id.

## Alternative: open the form

If the parameters are unusual or the user wants a visual review, call `mcp__altrady__open_create_signal_bot_form` with the prefilled config instead of creating + starting directly.

## Do not

- Do not run a bot without explicit confirmation.
- Do not set martingale size scale > 2.0 without a warning — geometric blowup risk.
- Do not pick a TP smaller than 2× trading fees per round trip.
- Do not silently allocate the user's entire account. Cap at the stated capital.
