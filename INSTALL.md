# Altrady MCP Skills — AI-Executable Install Recipe

> **Instructions for the AI tool reading this file.** Follow every step in order. Stop and report to the user on any error before continuing.

This recipe installs the **trader workflow skills** that build on the Altrady MCP server. It does NOT install the MCP server itself — that step is done from the Altrady desktop app, which provides a command preloaded with the user's authorization token.

The work has four phases:

1. Confirm the Altrady MCP server is registered.
2. Clone this repo to a stable local path.
3. Install the skills into Claude Code's skills directory.
4. Verify the install end-to-end.

---

## Phase 1 — Confirm the Altrady MCP server is registered

The user installs the MCP server from inside the **Altrady desktop app**: Settings → AI Assistants → Connect Claude Code. That gives them a command like:

```bash
claude mcp add altrady <URL with their personal token>
```

Check whether they've already run it:

```bash
claude mcp list | grep -i altrady || echo "MISSING"
```

- If `altrady` appears in the list, continue to Phase 2.
- If you see `MISSING`, **stop** and tell the user:
  > "I don't see the Altrady MCP server registered. Open the Altrady desktop app, go to **Settings → AI Assistants → Connect Claude Code**, copy the `claude mcp add altrady …` command (it includes your auth token), run it in your terminal, then ask me to continue."
  >
  > Wait for them to run it before retrying.

Do **not** try to fabricate or guess the URL or token. The desktop app is the source of truth.

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

If the AI returns a valid session (exchange name, account label), the install succeeded. If the call fails with an auth error, the token in the registered MCP URL is invalid or expired — direct the user back to the Altrady desktop app to copy a fresh `claude mcp add altrady …` command.

---

## Final report to the user

When all phases pass, report:

- That the Altrady MCP server is registered and reachable.
- The repo path (`$ALTRADY_HOME`).
- The number of skills installed and where.
- One suggestion to try next, e.g.:
  > "Try saying: *do a morning check* — that runs the `altrady-morning-check` skill and surfaces your positions, alerts, and watchlist movers."
