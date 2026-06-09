---
name: altrady-report-archive
description: Use when the user wants to open or browse their saved Altrady reports — "open my altrady reports", "show my report history", "report archive", "rebuild my report archive", "where are my reports". Opens the local branded report archive that the read-only reporter skills write into.
---

# Altrady — Report Archive

The read-only reporter skills (morning-check, market-scanner, backtest-analyzer, risk-sizer,
technical-analysis, trade-review, watchlist-curator mover scan) save a branded HTML page per run
and append to a local archive. This skill opens and maintains that archive. Read-only — it never
touches trading. See `report-kit/REPORT-KIT.md` for the full layout and record schema.

Archive location: `~/altrady-reports/` (`index.html`, `reports/`, `data/history.jsonl`).

## Open the archive

1. If `~/altrady-reports/index.html` exists, open it:
   ```bash
   open ~/altrady-reports/index.html 2>/dev/null \
     || xdg-open ~/altrady-reports/index.html 2>/dev/null \
     || start "" ~/altrady-reports/index.html
   ```
2. If `index.html` is missing but `data/history.jsonl` exists, **rebuild** it first (below), then open.
3. If neither exists, tell the user there are no reports yet and name a few skills that create them
   (e.g. "do a morning check", "analyze my backtest"). Don't create empty files.

After opening, print a one-line confirmation with the path and how many reports are in the archive.

## Rebuild the index

Use when the user says "rebuild/refresh my report archive", or when `index.html` is missing/stale
while `history.jsonl` has entries. Follow step 5 of `report-kit/REPORT-KIT.md`:
- Read every line of `~/altrady-reports/data/history.jsonl`; skip any that fail to parse.
- Sort by `timestamp` descending.
- Substitute the records (as a JS array literal) for `{{HISTORY_JSON}}` in the kit's
  `index-template.html`, drop the build comment, and write `~/altrady-reports/index.html`.

## Quick stats (optional)

If the user asks "what's in my archive" without wanting the browser, read `history.jsonl` and
summarize in the terminal: total reports, counts by skill, date range, most-reported market.
Don't open the browser in that case.

## Do not

- Do not open positions, edit anything, or call trading MCP tools — this skill only reads/opens
  local files.
- Do not delete or rewrite report files or `history.jsonl` (append-only is the reporters' job).
- Do not commit or upload the archive — it contains the trader's balances/positions and stays local.
