#!/usr/bin/env bash
# Allay installer. The 3 plugins are a coordinated bundle — they install
# together or not at all (see .claude-plugin/plugin.json → dependencies).
set -euo pipefail

REPO="https://github.com/enchanted-plugins/allay"
ALLAY_DIR="${HOME}/.claude/plugins/allay"

step() { printf "\n\033[1;36m▸ %s\033[0m\n" "$*"; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$*"; }

step "Allay installer"

# 1. Clone (or update) the monorepo so shared/*.sh is available locally.
#    Plugins themselves are served via the marketplace command below —
#    the clone is just for supporting scripts.
if [[ -d "$ALLAY_DIR/.git" ]]; then
  git -C "$ALLAY_DIR" pull --ff-only --quiet
  ok "Updated existing clone at $ALLAY_DIR"
else
  git clone --depth 1 --quiet "$REPO" "$ALLAY_DIR"
  ok "Cloned to $ALLAY_DIR"
fi

# 2. Ensure hook scripts are executable (fresh clones on some filesystems lose +x).
chmod +x "$ALLAY_DIR"/plugins/*/hooks/*/*.sh 2>/dev/null || true
chmod +x "$ALLAY_DIR"/shared/*.sh 2>/dev/null || true
ok "Hook scripts marked executable"

cat <<'EOF'

─────────────────────────────────────────────────────────────────────────
  Allay is a bundle. The 3 plugins cooperate at runtime —
  context-guard monitors drift and token usage, state-keeper preserves
  context across compactions, and token-saver cuts the tokens you
  spend to get there. Installing only one leaves the others with no
  signal or no savings, so every plugin.json lists the other two as
  dependencies and Claude Code pulls them in together.
─────────────────────────────────────────────────────────────────────────

  Finish in Claude Code with TWO commands:

    /plugin marketplace add enchanted-plugins/allay
    /plugin install allay-context-guard@allay

  The second command installs all 3 plugins via dependency resolution.
  (Any of the 3 names works — they're peers. context-guard is just the
  natural entry point since it's the one you'll feel first.)

  Verify with:   /plugin list
  Expected:      3 plugins installed under the allay marketplace.

EOF
