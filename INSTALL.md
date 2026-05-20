# Altrady MCP — AI-Executable Install Recipe

> **Instructions for the AI tool reading this file.** Follow every step in order. Stop and report to the user on any error before continuing.

You are setting up the Altrady MCP server plus the trader workflow skills for the user. The work has four phases:

1. Add the Altrady MCP server.
2. Clone this repo to a stable local path.
3. Install the skills into Claude Code's skills directory.
4. Verify the install.

---

## Phase 1 — Add the Altrady MCP server

Run:

```bash
claude mcp add altrady <TODO: ALTRADY_MCP_URL>
```

> **TODO for repo maintainers:** replace `<TODO: ALTRADY_MCP_URL>` with the current Altrady MCP endpoint (e.g. `https://mcp.altrady.com/v1/sse`) before publishing. If you are an AI running this file and the placeholder is still here, **stop** and tell the user the MCP URL is not set — link them to https://altrady.com/mcp for the current value.

If the MCP requires an API key, prompt the user for it and pass it via `--env ALTRADY_API_KEY=<value>` or follow the auth flow Altrady documents.

After the command completes, confirm it appears in:

```bash
claude mcp list
```

---

## Phase 2 — Clone this repo

Pick the install path:

```bash
ALTRADY_HOME="${ALTRADY_HOME:-$HOME/.altrady-mcp}"
```

Clone (or pull if already present):

```bash
if [ -d "$ALTRADY_HOME/.git" ]; then
  git -C "$ALTRADY_HOME" pull --ff-only
else
  git clone https://github.com/altrady/altrady-mcp "$ALTRADY_HOME"
fi
```

---

## Phase 3 — Install the skills

The repo ships skills under `skills/`. Symlink each into the user's Claude Code skills directory so updates via `git pull` propagate automatically.

```bash
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"
mkdir -p "$CLAUDE_SKILLS"

for skill_dir in "$ALTRADY_HOME"/skills/*/; do
  name="$(basename "$skill_dir")"
  target="$CLAUDE_SKILLS/$name"
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$skill_dir" "$target"
  echo "Installed skill: $name"
done
```

Equivalent: just run `bash "$ALTRADY_HOME/install.sh"`.

---

## Phase 4 — Verify

Ask the user to **restart Claude Code** (skills are loaded at startup), then run one MCP call:

```
Use the Altrady MCP to call get_session_context and tell me which exchange account is active.
```

If the AI returns a valid session (exchange name, account label), the install succeeded. If the call fails with an auth error, walk the user through the Altrady auth flow.

---

## Final report to the user

When all phases pass, report:

- The MCP server name (`altrady`) and where it's registered.
- The repo path (`$ALTRADY_HOME`).
- The number of skills installed and where.
- One suggestion to try next, e.g.:
  > "Try saying: *do a morning check* — that runs the `altrady-morning-check` skill and surfaces your positions, alerts, and watchlist movers."
