#!/usr/bin/env bash
# Altrady MCP — skills installer.
# Symlinks every skill under ./skills into the user's Claude Code skills dir.
# Run from a clone of this repo, or with ALTRADY_HOME pointing at the clone.

set -euo pipefail

ALTRADY_HOME="${ALTRADY_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
CLAUDE_SKILLS="${CLAUDE_SKILLS:-$HOME/.claude/skills}"

if [ ! -d "$ALTRADY_HOME/skills" ]; then
  echo "error: $ALTRADY_HOME/skills not found. Set ALTRADY_HOME to your clone." >&2
  exit 1
fi

mkdir -p "$CLAUDE_SKILLS"

installed=0
for skill_dir in "$ALTRADY_HOME"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  target="$CLAUDE_SKILLS/$name"
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$skill_dir" "$target"
  echo "installed: $name -> $target"
  installed=$((installed + 1))
done

echo
echo "Done. $installed skill(s) linked into $CLAUDE_SKILLS"
echo "Restart Claude Code to pick them up."
echo
echo "If you have not yet registered the Altrady MCP server with Claude Code:"
echo "  Open the Altrady desktop app -> Settings -> MCP server"
echo "  Click 'Copy install prompt' and paste it into Claude Code — it embeds the URL + token"
echo "  and tells Claude Code to register the server and (re)install the skills."
