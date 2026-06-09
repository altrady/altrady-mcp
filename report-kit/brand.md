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
The Altrady globe mark, embedded inline as SVG (no image file). The canonical, validated markup
lives in **`report-kit/altrady-logo.svg`** — a four-layer version (brand blues `#017AFF`,
`#01438D`, `#0156B3`, `#0068D9`) that is visually identical to the full mark at small sizes.

Both `report-template.html` and `index-template.html` already embed it in their header at 34×34.
When building a new template, copy the `<svg>…</svg>` from `altrady-logo.svg` verbatim and keep it
inline (so pages stay self-contained). Do not hand-edit the path data.
