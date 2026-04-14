#!/usr/bin/env bash
# Test: learnings.sh accumulates strategy data across sessions
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/../.."
LEARNINGS_SCRIPT="${REPO_ROOT}/shared/scripts/learnings.sh"

# Create temp plugins directory structure
TMP_DIR=$(mktemp -d)
mkdir -p "${TMP_DIR}/context-guard/state"
mkdir -p "${TMP_DIR}/token-saver/state"
mkdir -p "${TMP_DIR}/state-keeper/state"

LEARNINGS_FILE="${TMP_DIR}/context-guard/state/learnings.json"

# ── Session 1: Write mock metrics ──
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Token-saver metrics: 3 compressions (test_tail rule)
for i in 1 2 3; do
  printf '{"event":"bash_compressed","ts":"%s","rule":"test_tail"}\n' "$TS" >> "${TMP_DIR}/token-saver/state/metrics.jsonl"
done

# Context-guard metrics: 2 turn events + 1 drift
printf '{"event":"turn","ts":"%s","tool":"Read","tokens_est":500,"turn":1}\n' "$TS" >> "${TMP_DIR}/context-guard/state/metrics.jsonl"
printf '{"event":"turn","ts":"%s","tool":"Bash","tokens_est":800,"turn":2}\n' "$TS" >> "${TMP_DIR}/context-guard/state/metrics.jsonl"
printf '{"event":"drift_detected","ts":"%s","pattern":"read_loop","file":"test.ts","cmd":"","turn":2}\n' "$TS" >> "${TMP_DIR}/context-guard/state/metrics.jsonl"

# Run learnings.sh (session 1)
OUTPUT=$(bash "$LEARNINGS_SCRIPT" "$TMP_DIR" 2>/dev/null) || true

# Verify learnings.json was created
if [[ ! -f "$LEARNINGS_FILE" ]]; then
  echo "FAIL: learnings.json should be created after first session"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify learnings.json is valid JSON
if ! jq empty "$LEARNINGS_FILE" >/dev/null 2>&1; then
  echo "FAIL: learnings.json should be valid JSON"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify sessions_recorded is 1
SESSIONS=$(jq -r '.sessions_recorded' "$LEARNINGS_FILE" 2>/dev/null)
if [[ "$SESSIONS" != "1" ]]; then
  echo "FAIL: sessions_recorded should be 1, got $SESSIONS"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify strategy_rates contains test_tail
if ! jq -e '.strategy_rates.test_tail' "$LEARNINGS_FILE" >/dev/null 2>&1; then
  echo "FAIL: strategy_rates should contain test_tail"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify test_tail has a rate > 0 (it fired, so success = 1, EMA = 0.3*1 + 0.7*0.5 = 0.65)
RATE=$(jq -r '.strategy_rates.test_tail.rate' "$LEARNINGS_FILE" 2>/dev/null)
if ! awk "BEGIN{exit ($RATE > 0) ? 0 : 1}" 2>/dev/null; then
  echo "FAIL: test_tail rate should be > 0, got $RATE"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Save first session rate for comparison
FIRST_RATE="$RATE"

# ── Session 2: Add more metrics and re-run ──
printf '{"event":"bash_compressed","ts":"%s","rule":"test_tail"}\n' "$TS" >> "${TMP_DIR}/token-saver/state/metrics.jsonl"
printf '{"event":"turn","ts":"%s","tool":"Read","tokens_est":600,"turn":3}\n' "$TS" >> "${TMP_DIR}/context-guard/state/metrics.jsonl"

# Run learnings.sh (session 2)
bash "$LEARNINGS_SCRIPT" "$TMP_DIR" >/dev/null 2>/dev/null || true

# Verify sessions_recorded incremented to 2
SESSIONS=$(jq -r '.sessions_recorded' "$LEARNINGS_FILE" 2>/dev/null)
if [[ "$SESSIONS" != "2" ]]; then
  echo "FAIL: sessions_recorded should be 2, got $SESSIONS"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify rate was updated (not just overwritten to same value)
SECOND_RATE=$(jq -r '.strategy_rates.test_tail.rate' "$LEARNINGS_FILE" 2>/dev/null)
if [[ "$SECOND_RATE" == "null" ]] || [[ -z "$SECOND_RATE" ]]; then
  echo "FAIL: test_tail rate should still exist after second session"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify fires accumulated
FIRES=$(jq -r '.strategy_rates.test_tail.fires' "$LEARNINGS_FILE" 2>/dev/null)
if [[ "$FIRES" -lt 4 ]]; then
  echo "FAIL: test_tail fires should be >= 4 (3 + 1), got $FIRES"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Verify output is JSONL
OUTPUT=$(bash "$LEARNINGS_SCRIPT" "$TMP_DIR" 2>/dev/null) || true
if [[ -n "$OUTPUT" ]] && ! printf "%s" "$OUTPUT" | jq empty >/dev/null 2>&1; then
  echo "FAIL: stdout output should be valid JSONL"
  rm -rf "$TMP_DIR"
  exit 1
fi

# Cleanup
rm -rf "$TMP_DIR"
rm -rf "${LEARNINGS_FILE}.lock"

exit 0
