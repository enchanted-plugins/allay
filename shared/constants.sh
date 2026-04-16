#!/usr/bin/env bash
# Allay shared constants — sourced by all hooks and utilities

ALLAY_VERSION="2.0.0"

# State file names
ALLAY_MEMORY_FILE="state/memory.jsonl"
ALLAY_METRICS_FILE="state/metrics.jsonl"
ALLAY_CHECKPOINT_FILE="state/checkpoint.md"
ALLAY_REMEMBER_FILE="state/remember.md"

# Size limits
ALLAY_MAX_CHECKPOINT_BYTES=51200       # 50KB
ALLAY_MAX_MEMORY_BYTES=10485760        # 10MB
ALLAY_MAX_METRICS_BYTES=10485760       # 10MB (rotate at 10MB, not 1MB)

# Duplicate read TTL
ALLAY_DUPLICATE_TTL_SECONDS=600        # 10 minutes

# Lock config
ALLAY_LOCK_SUFFIX=".lock"

# Runway / drift
ALLAY_RUNWAY_WINDOW=5
ALLAY_DRIFT_COOLDOWN_TURNS=5
ALLAY_DRIFT_READ_THRESHOLD=3
ALLAY_DRIFT_FAIL_THRESHOLD=3

# A8 — Skill-Scoped Attribution
# TTL after which an un-unregistered skill scope is considered stale and evicted.
# Default: 1h. Override via ALLAY_SKILL_TTL env var.
ALLAY_SKILL_TTL="${ALLAY_SKILL_TTL:-3600}"
ALLAY_ACTIVE_SKILLS_FILE="state/active-skills.json"
ALLAY_SKILL_METRICS_FILE="state/skill-metrics.jsonl"
ALLAY_SESSION_MARKER_FILE="state/.session"

# A9 — Worktree Session Graph
# XDG-compliant global state layout. Metrics → STATE, learnings → DATA.
# Spec: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
ALLAY_XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
ALLAY_XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
ALLAY_GLOBAL_STATE_SUBDIR="allay"
ALLAY_GLOBAL_DATA_SUBDIR="allay"
