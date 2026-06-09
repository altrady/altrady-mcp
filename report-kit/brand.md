# Altrady report branding

Design tokens and assets for the report kit. Both templates already embed these — this file
is the canonical reference if you ever need to rebuild or extend them.

## Theme
Dark. Self-contained pages only (inline CSS + inline SVG logo, no CDN/JS/web fonts).

## Color tokens
| Token | Hex | Use |
|---|---|---|
| `--bg` | `#0b0e14` | page background (with a soft blue radial glow top-right) |
| `--surface` | `#121826` | cards, tiles, rows |
| `--line` | `rgba(255,255,255,.08)` | hairline borders / dividers |
| `--text` | `#e6edf3` | primary text |
| `--muted` | `#8b97a8` | secondary text, labels |
| `--faint` | `#5b6677` | tertiary / footnotes |
| `--primary` | `#017aff` | Altrady blue — accents, links, brand |
| `--primary-deep` | `#0068d9` | gradient partner |
| `--ink` | `#01438d` | deep brand blue |
| `--pos` | `#16c784` | gains / winners |
| `--neg` | `#ea3943` | losses / risk |
| `--warn` | `#f0a020` | caution |
| `--neutral` | `#8b97a8` | neutral state |

Headline banner and brand glow use `linear-gradient(135deg, #0068d9, #017aff)`.

## Typography
System stack: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif`.
Tabular numerals for numeric table columns and timestamps.

## Logo
The official Altrady logo (`https://cdn.altrady.com/static/altrady-logo-300x300.png`). The canonical
copy lives in **`report-kit/altrady-logo.png`** (downscaled to 72×72 for size). Both templates embed
it inline as a **base64 `data:` URI** so pages stay fully self-contained — no external requests.

Render at 34×34 in headers with a 7px corner radius. To refresh it, re-download the PNG, downscale
(`sips -Z 72`), base64-encode, and replace the `src="data:image/png;base64,…"` in both templates.
