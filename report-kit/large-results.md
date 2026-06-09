# Handling large Altrady result sets (token discipline)

Several Altrady MCP calls return big payloads that can blow the context window and waste tokens:
- `list_positions` (closed history is large — ~2-3 KB per position),
- `get_backtest` (positions + orders + trades + stats in one blob),
- full ticker/OHLC sweeps in `market-scanner` and `morning-check`,
- `list_alerts` / `get_watchlist` on big accounts.

When a tool result exceeds the limit, the harness **auto-saves it to a file** and returns the path +
schema instead of the content. Treat that as the normal path for these calls, not an error.

## Rules

1. **Query as narrow as the task allows.**
   - Filter by `marketSymbol` / `status` / `exchange` when you only need a slice.
   - Use the smallest `perPage` that covers the need, and only request the pages you'll use.
   - "Last N closed" → one page with `perPage: N`, not the whole history.

2. **Never Read a large saved payload into context.** `Read`'s line offsets won't chunk JSON
   sensibly and you'll burn tokens on fields you don't use. Instead:
   - **Probe** structure first: `jq 'type, (.positions|length), (.positions[0]|keys)' FILE`.
   - **Extract only the fields you need** with `jq -c` (e.g. side, netProfitUsd, openTime,
     closeTime, openPrice, stop price), or
   - **Compute the answer in a script** (jq/python) and print only the small result — aggregates,
     a top-N table, a handful of rows. Bring *that* into context, not the raw array.

3. **For full-payload analysis, use a subagent.** If you genuinely must read everything (not just
   aggregate it), dispatch the Agent tool so the raw content stays out of the main context. Give it
   verbatim: the file path, the JSON schema line the harness printed, what to compute, and the exact
   small result to return.

4. **Money math on mixed currencies:** positions span EUR/USDC/USDT — sum the `*Usd` fields
   (`netProfitUsd`, `openUsdCost`), not the raw quote amounts.

5. **Report rows, not dumps.** The branded report (see `REPORT-KIT.md`) is where detail goes —
   compute the page from the extracted data; don't echo raw positions to the terminal.

## Quick recipe (last-N closed positions)

```bash
# the harness saved list_positions output to $FILE (path is in the tool result)
jq 'type, (.positions|length), (.positions[0]|keys)' "$FILE"          # probe
jq -c '.positions[] | {mkt:.coinraySymbol, side, usd:.netProfitUsd,
        open:.openTime, close:.closeTime, entry:.openPrice,
        sl:(.smartSettings.stopLoss.stopPrice)}' "$FILE" > /tmp/slim.jsonl  # extract
# then compute aggregates from /tmp/slim.jsonl in python and emit only the summary
```
