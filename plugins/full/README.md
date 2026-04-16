# full

**Meta-plugin. Installs every Allay plugin at once.**

This plugin has no hooks, skills, or agents of its own. It exists so you can install the whole 3-plugin platform with one command:

```
/plugin marketplace add enchanted-plugins/allay
/plugin install full@allay
```

Claude Code resolves the three dependencies and installs:

- `allay-context-guard` — drift alerts, runway forecast, per-tool analytics
- `allay-state-keeper` — checkpoint before compaction, auto-restore after
- `allay-token-saver` — compression, dedup, delta mode, output efficiency

If you want to cherry-pick a single plugin (e.g. just `allay-token-saver`), you can — but the three lifecycle phases (PreToolUse / PostToolUse / PreCompact) are designed to cooperate, so you'll typically want them all.
