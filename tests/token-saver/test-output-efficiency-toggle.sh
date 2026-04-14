#!/usr/bin/env bash
# Test: output-efficiency SKILL.md contains all 4 modes and required frontmatter
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
SKILL_FILE="${REPO_ROOT}/plugins/token-saver/skills/output-efficiency/SKILL.md"

# Verify SKILL.md exists
if [[ ! -f "$SKILL_FILE" ]]; then
  echo "FAIL: output-efficiency SKILL.md not found at $SKILL_FILE"
  exit 1
fi

# Verify allowed-tools frontmatter
if ! grep -q "allowed-tools" "$SKILL_FILE"; then
  echo "FAIL: SKILL.md missing allowed-tools frontmatter"
  exit 1
fi

if ! grep -q "Read" "$SKILL_FILE" || ! grep -q "Bash" "$SKILL_FILE"; then
  echo "FAIL: allowed-tools should include Read and Bash"
  exit 1
fi

# Verify all 4 modes are defined
for mode in "OFF" "LITE" "FULL" "ULTRA"; do
  if ! grep -qi "$mode" "$SKILL_FILE"; then
    echo "FAIL: SKILL.md missing mode: $mode"
    exit 1
  fi
done

# Verify session_injection section exists
if ! grep -q "session_injection" "$SKILL_FILE"; then
  echo "FAIL: SKILL.md missing session_injection section"
  exit 1
fi

# Verify constraints section exists
if ! grep -q "constraints" "$SKILL_FILE"; then
  echo "FAIL: SKILL.md missing constraints section"
  exit 1
fi

exit 0
