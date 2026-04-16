#!/usr/bin/env bash
# Allay installer. The 3 plugins are a coordinated bundle; the `full`
# meta-plugin pulls them all in via one dependency-resolution pass.
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
  Allay ships as 3 plugins cooperating across PreToolUse / PostToolUse /
  PreCompact. The `full` meta-plugin lists all three as dependencies so
  one install pulls in the whole platform.
─────────────────────────────────────────────────────────────────────────

  Finish in Claude Code with TWO commands:

    /plugin marketplace add enchanted-plugins/allay
    /plugin install full@allay

  That installs all 3 plugins via dependency resolution. To cherry-pick
  a single plugin instead, use e.g. `/plugin install allay-context-guard@allay`.

  Verify with:   /plugin list
  Expected:      full + 3 plugins installed under the allay marketplace.

EOF
