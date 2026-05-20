# Altrady MCP Skills Repo — Design

**Date:** 2026-05-20
**Status:** Approved (design phase)

## Purpose

A public git repo that lets a trader install the Altrady MCP server plus a curated set of workflow skills with a single prompt fed to an AI tool (Claude Code, etc.).

## Components

### 1. One-liner install prompt

The user's entry point. Designed to be pasted into Claude Code:

```
Set up Altrady for me: read https://raw.githubusercontent.com/altrady/altrady-mcp/main/INSTALL.md and follow it exactly.
```

The AI follows `INSTALL.md`, which is the real recipe.

### 2. `INSTALL.md`

Step-by-step the AI executes:

1. Add the Altrady MCP server (`claude mcp add altrady <URL>` — URL is a `<TODO>` placeholder pending the real endpoint).
2. `git clone https://github.com/altrady/altrady-mcp` into `~/.altrady-mcp`.
3. For each `skills/altrady-*` directory, symlink it into `~/.claude/skills/`.
4. Verify by calling `mcp__altrady__get_session_context` and reporting the active exchange.

### 3. Skills (11)

Each is a single `SKILL.md` file with YAML frontmatter (`name`, `description`) and a focused workflow. No subdirectories of reference files unless a skill genuinely needs them.

| Skill | Workflow summary |
|---|---|
| `altrady-morning-check` | Open positions → triggered alerts → bot stats → watchlist movers — surface what needs attention |
| `altrady-smart-entry` | Take an idea (symbol + bias) → derive size from risk % → place SL at structure → stagger TPs → open via `open_smart_position` |
| `altrady-position-manager` | Walk open positions → suggest BE moves, trails, partial closes → apply via `edit_smart_position` |
| `altrady-technical-analysis` | Multi-timeframe scan → apply indicator template → draw S/R, trend lines, ranges |
| `altrady-grid-bot-builder` | Range from recent high/low or ATR → grid density from volatility → create + start |
| `altrady-signal-bot-builder` | DCA strategy: base order, safety orders, TP grid → create + start |
| `altrady-alert-manager` | Pick alert levels from chart structure → create with sensible messages → audit/prune old alerts |
| `altrady-watchlist-curator` | Build themed lists, prune stagnant tickers, surface today's movers per list |
| `altrady-market-scanner` | Scan markets by criteria (volume spike, volatility, trend) → return ranked candidates |
| `altrady-risk-sizer` | Inputs: account, risk %, entry, SL → outputs: position size, $ risk, leverage |
| `altrady-trade-review` | Pull a closed position → reconstruct entry context → prompt for lessons → save journal entry |

### 4. Repo structure

```
altrady-mcp/
├── README.md           # Tagline, one-liner, manual install, skill catalog
├── INSTALL.md          # AI-executable install recipe
├── install.sh          # Pure-shell fallback (no AI needed)
├── docs/
│   └── superpowers/specs/   # This file lives here
└── skills/
    ├── altrady-morning-check/SKILL.md
    ├── altrady-smart-entry/SKILL.md
    └── ... (11 total)
```

## Skill authoring conventions

- Frontmatter `name` matches the directory name (kebab-case, `altrady-*` prefix).
- `description` follows the superpowers pattern: starts with "Use when..." and names the trigger phrases a trader would say.
- Each skill names the MCP tools it calls explicitly (so the AI doesn't go fishing).
- Decision points use `AskUserQuestion` rather than assumptions for anything money-affecting (size, SL distance, leverage).
- Skills do not execute irreversible actions (open position, start bot, delete alert) without explicit user confirmation.

## Out of scope

- Hosting/distributing the MCP server itself — assumed to exist already.
- Backtesting, P&L analytics dashboards — Altrady already has UI for these.
- Multi-user / team features — single trader, local install.

## Open items

- Real `claude mcp add altrady <URL>` line — placeholder in `INSTALL.md`.
- Whether install.sh should also handle MCP registration or only the skills/clone steps.

## Self-review notes

- No TBDs in scope; the MCP URL placeholder is called out explicitly.
- Skill count (11) is the agreed scope; deferred extras (scalping/swing splits, portfolio analytics) are listed as out-of-scope.
- Each skill maps to a distinct workflow with no overlap between them — `smart-entry` opens, `position-manager` adjusts, `trade-review` reflects. Grid vs signal bots are separate skills because the UX is genuinely different.
- "Money-affecting actions require confirmation" is the load-bearing safety invariant; named once here and repeated in each relevant skill.
