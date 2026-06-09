# Altrady Report Kit — runtime procedure

This is the shared procedure the **read-only reporter skills** follow to turn their output into a
branded HTML page, open it, and append it to the trader's local report archive. Reporter skills
reference this file instead of repeating the steps.

## Where things live

**Kit (read-only inputs)** — ship with this plugin/repo, next to `skills/`:
- `report-kit/report-template.html` — branded page shell with `{{SLOTS}}`.
- `report-kit/index-template.html` — branded archive shell with a `{{HISTORY_JSON}}` slot.
- `report-kit/altrady-logo.svg` / `report-kit/brand.md` — canonical logo + design tokens.

Locate the kit at runtime, using the first path that exists:
1. `$CLAUDE_PLUGIN_ROOT/report-kit/` — when installed as a Claude Code plugin.
2. `report-kit/` as a sibling of the running skill's **real** directory, i.e. resolve the skill's
   SKILL.md symlink to its canonical path and look at `../../report-kit/`.
3. `$ALTRADY_HOME/report-kit/`, falling back to `~/.altrady-mcp/report-kit/` — the default clone
   path used by `install.sh`.

(2 and 3 cover the symlink-install fallback; the report kit is always a sibling of `skills/` in the
repo clone.)

**Archive (user data)** — always under `~/altrady-reports/` (NEVER inside the repo/plugin, so it
survives plugin updates and is never committed):
```
~/altrady-reports/
├── index.html            # regenerated every run
├── reports/<id>.html     # one self-contained page per run
└── data/history.jsonl    # append-only log; source of truth for index.html
```

## Procedure (run after you've computed the report content)

### 1. Ensure the archive dirs exist
```bash
mkdir -p ~/altrady-reports/reports ~/altrady-reports/data
```

### 2. Build the report id and paths
- `id = <skill-short>[-<market-slug>]-<YYYYMMDD-HHMM>` (local time), e.g.
  `morning-check-20260609-0830`, `backtest-eth-usdt-20260609-1012`.
- `<skill-short>`: morning-check, market-scan, backtest, risk-size, ta, trade-review, watchlist-scan.
- `<market-slug>`: lowercase market for single-market reports; omit for account-wide ones.
- File: `~/altrady-reports/reports/<id>.html`.

### 3. Render the report page
Read `report-template.html` and replace every slot:
- `{{TITLE}}` — short report name (e.g. "Morning Check", "Backtest — ETH-USDT").
- `{{SUBTITLE}}` — account/exchange, or market + timeframe.
- `{{TIMESTAMP}}` — human time, e.g. `2026-06-09 08:30`.
- `{{HEADLINE}}` — the one-line summary (same text you put in `headline` below).
- `{{BODY}}` — your report content, built from the component snippets documented in the
  template's `<style>`/BODY comments (stat tiles, cards, tables, badges). Use the color classes
  (`pos`/`neg`/`warn`) to make gains/losses/risk read at a glance.

Keep the page **self-contained**: do not add external CSS/JS/CDN/image links, and keep the inline
logo. Delete the leading HTML build comment. Write the result to the file from step 2.

### 4. Append one archive record
Append exactly one line of compact JSON to `~/altrady-reports/data/history.jsonl`:
```json
{"id":"morning-check-20260609-0830","skill":"altrady-morning-check","title":"Morning Check","timestamp":"2026-06-09T08:30:00+02:00","market":null,"headline":"3 positions · +2.1% day · 2 alerts fired","metrics":{"openPositions":3,"dayPnlPct":2.1,"alertsFired":2},"file":"reports/morning-check-20260609-0830.html"}
```
- `timestamp` is ISO-8601 with local offset. `market` is `null` for account-wide reports.
- `file` is **relative to `~/altrady-reports/`** (so links work from `index.html`).
- `metrics` is the small skill-specific bag listed in each skill's "Output: branded report" block.
- Append only — never rewrite existing lines.

### 5. Regenerate the archive index
- Read all lines of `history.jsonl`; skip any line that fails to parse (don't abort).
- Sort by `timestamp` descending (newest first).
- Build a JS array literal of the records and substitute it for `{{HISTORY_JSON}}` in
  `index-template.html`. Delete the leading build comment.
- Write the result to `~/altrady-reports/index.html`.

### 6. Open the report
Open the new page in the browser, trying in order:
```bash
open <file> 2>/dev/null || xdg-open <file> 2>/dev/null || start "" <file>
```
(`open` = macOS, `xdg-open` = Linux, `start` = Windows.)

### 7. Terminal recap (keep it short)
Print 2–3 lines max — the headline + the file path. Do **not** dump the full report to the
terminal; the page is the deliverable.
```
Morning check ready — 3 positions · +2.1% day · 2 alerts fired.
Opened: ~/altrady-reports/reports/morning-check-20260609-0830.html
All reports: ~/altrady-reports/index.html
```

## Notes
- First run creates everything; later runs just append + regenerate.
- Reports may contain balances/positions — they live only under `~/altrady-reports/`, which is
  outside any repo and must never be committed.
- If you can't open a browser (headless), skip step 6 and just report the file path.
- The archive index filters client-side (search + skill) over the inlined data — no server needed.
