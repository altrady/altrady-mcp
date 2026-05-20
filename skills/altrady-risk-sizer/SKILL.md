---
name: altrady-risk-sizer
description: Use when the user needs to size a position — "size this trade", "how much can I buy", "risk calc", "position sizing for X", "what size at Y% risk". Calculates position size from account equity, risk %, entry, SL distance, and leverage. Pure read-only calculation — does not open positions.
---

# Altrady — Risk Sizer

A quick calculator. The trader gives you the inputs; you return the size and the math, and (if asked) hand off to `altrady-smart-entry` to actually place the order.

## Required inputs

Use `AskUserQuestion` for anything missing:

1. **Market** — needed to fetch price if entry not given, and to know the quote currency.
2. **Side** — long or short (affects SL placement validation only).
3. **Entry price** — explicit, or "market" (fetch current price).
4. **Stop loss price** — explicit price.
5. **Risk % of account** — default 1%. Hard-cap warning at > 5%.
6. **Leverage** — if it's a derivatives market. Default 1× (spot).

## Context fetch (parallel)

- `mcp__altrady__get_session_context` — active account equity (in quote currency).
- `mcp__altrady__list_exchange_accounts` if the user wants to size against a non-active account.
- `mcp__altrady__get_market_ticker` — if entry is "market", use this price.

## Math

```
risk_amount      = equity * (risk_pct / 100)
sl_distance_pct  = |entry - sl| / entry
notional_size    = risk_amount / sl_distance_pct
units            = notional_size / entry
margin_required  = notional_size / leverage
```

Sanity checks:

- `margin_required` must be < free margin. If not, show the size that fits AND the size that risks the desired %, and let the user pick.
- If `sl_distance_pct` < 0.1%, warn — the SL is inside likely spread/slippage.
- If `sl_distance_pct` > 25%, warn — this is more a long-term position than a trade; risk % might apply differently.

## Output format

```
ETH-USDT LONG
  Equity:            10,000 USDT
  Risk:              1.0% = 100 USDT
  Entry:             3,420
  SL:                3,250  (-4.97%)
  Notional:          2,012 USDT
  Units:             0.5883 ETH
  Leverage:          3×
  Margin required:   671 USDT  (free: 8,400 — OK)
```

End with: "Want me to open this via `altrady-smart-entry`?" — hand off rather than executing.

## Do not

- Do not open the position from this skill.
- Do not silently pick a different risk % from what the user gave.
- Do not assume leverage 10× because "that's normal." Default 1× for spot, ask if unclear.
- Do not round size up to a "nicer" number. Round to the exchange's minimum step toward smaller (so risk is at most the stated %).
