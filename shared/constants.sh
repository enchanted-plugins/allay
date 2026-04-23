#!/usr/bin/env bash
# Emu shared constants — sourced by all hooks and utilities

EMU_VERSION="2.0.0"

# State file names
EMU_MEMORY_FILE="state/memory.jsonl"
EMU_METRICS_FILE="state/metrics.jsonl"
EMU_CHECKPOINT_FILE="state/checkpoint.md"
EMU_REMEMBER_FILE="state/remember.md"

# Size limits
EMU_MAX_CHECKPOINT_BYTES=51200       # 50KB
EMU_MAX_MEMORY_BYTES=10485760        # 10MB
EMU_MAX_METRICS_BYTES=10485760       # 10MB (rotate at 10MB, not 1MB)

# Duplicate read TTL
EMU_DUPLICATE_TTL_SECONDS=600        # 10 minutes

# Lock config
EMU_LOCK_SUFFIX=".lock"

# Runway / drift
EMU_RUNWAY_WINDOW=5
EMU_DRIFT_COOLDOWN_TURNS=5
EMU_DRIFT_READ_THRESHOLD=3
EMU_DRIFT_FAIL_THRESHOLD=3

# A8 — Skill-Scoped Attribution
# TTL after which an un-unregistered skill scope is considered stale and evicted.
# Default: 1h. Override via EMU_SKILL_TTL env var.
EMU_SKILL_TTL="${EMU_SKILL_TTL:-3600}"
EMU_ACTIVE_SKILLS_FILE="state/active-skills.json"
EMU_SKILL_METRICS_FILE="state/skill-metrics.jsonl"
EMU_SESSION_MARKER_FILE="state/.session"

# A9 — Worktree Session Graph
# XDG-compliant global state layout. Metrics → STATE, learnings → DATA.
# Spec: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
EMU_XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
EMU_XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
EMU_GLOBAL_STATE_SUBDIR="emu"
EMU_GLOBAL_DATA_SUBDIR="emu"
