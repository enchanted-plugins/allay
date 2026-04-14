# Allay

> An @enchanted-plugins product — algorithm-driven, agent-managed, self-learning.

The context health platform that learns what wastes your tokens — and stops it.

**3 plugins. 7 algorithms. 4 agents. Honest numbers.**

> 40 minutes into a session, Allay told me Claude had been editing and reverting
> the same file for 12 minutes. I didn't notice. It did.

---

## How It Works

```
                          Claude Code
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                  ▼
       PreToolUse        PostToolUse         PreCompact
            │                 │                  │
     ┌──────┴──────┐   ┌─────┴──────┐    ┌──────┴──────┐
     │ token-saver │   │context-guard│    │ state-keeper│
     │             │   │             │    │             │
     │ A3 compress │   │ A1 drift    │    │ A4 atomic   │
     │ A5 dedup    │   │ A2 runway   │    │    write    │
     │ A6 delta    │   │    token    │    │ checkpoint  │
     │    aging    │   │    est.     │    │ auto-restore│
     └──────┬──────┘   └─────┬──────┘    └──────┬──────┘
            │                │                   │
            ▼                ▼                   ▼
        exit 0/2       metrics.jsonl        checkpoint.md
        updatedInput   stderr alert         metrics.jsonl
                             │
                     ┌───────┴────────┐
                     │ A7 learnings   │
                     │ (after report) │
                     └────────────────┘
```

Three plugins. Three lifecycle phases. No overlap. No dependencies between plugins.

## What Makes Allay Different

### Drift Alert

Catches Claude spinning in circles — in real time, not after the fact:

```
⚠️ Drift Alert: src/auth.ts read 4× without changes.
Claude may be stuck re-reading without progress.
→ Reframe the problem or /allay:checkpoint before /compact.
```

Three patterns: **read loops**, **edit-revert cycles**, **test fail loops**.
5-turn cooldown between alerts to avoid noise.

### Token Runway

Not "43% context used." Not "$0.12 spent."
Just: **"~8 turns until compaction."**

```
RUNWAY FORECAST (Algorithm A2: Linear Runway Forecasting)

Point estimate:  ~14 turns remaining
95% CI:          [8, 20] turns
Confidence:      MEDIUM (CV=0.31)
Velocity:        4,200 tokens/turn avg (sigma=1,302)
```

### Per-Tool Analytics

See exactly where your tokens go:

```
TOOL ANALYTICS (this session)
  Read:    42 calls, ~18,400 tokens (34%)
  Bash:    28 calls, ~14,200 tokens (26%)
  Write:   15 calls, ~11,800 tokens (22%)
```

### Output Efficiency

Configurable terse mode that cuts output token waste without losing information.
Four levels: off / lite / full / ultra. Code stays verbose — only prose gets lean.

### Delta Mode

Re-reading a changed file? Allay shows only what changed instead of the full file.
Re-reading an unchanged file? Blocked — with a preview and elapsed time.

### Self-Learning

Allay accumulates strategy success rates across sessions. After each report,
it logs which compression rules fired, which drift patterns recurred, and which
interventions worked — then adjusts its internal model via exponential moving average.

### The Receipt

`/allay:report` shows exact savings per feature, drift alerts fired, turns
remaining, and accumulated learnings. Conservative methodology. We don't inflate numbers.

---

## The Science Behind Allay

Seven named algorithms. Each one referenced in code, agents, and reports.

### A1. Markov Drift Detection

Pattern-matching finite automaton over tool call sequences.

States: `PRODUCTIVE`, `READ_LOOP`, `EDIT_REVERT`, `TEST_FAIL_LOOP`.
Transitions on tool name + file hash + exit code.
5-turn cooldown between alerts.

$$P(\text{drift} \mid s_1, \dots, s_n) = \begin{cases} 1 & \text{if } |\{s_i = s_j\}| \geq \theta \\ 0 & \text{otherwise} \end{cases}$$

Where $\theta = 3$ (configurable via `ALLAY_DRIFT_READ_THRESHOLD`).

### A2. Linear Runway Forecasting

Estimates turns until compaction from a sliding window of token velocities.

$$\hat{R} = \frac{C_{max} - \sum_{i=1}^{n} t_i}{\bar{t}_w}, \quad \text{CI}_{95} = \hat{R} \pm 1.96 \cdot \frac{\sigma_t}{\bar{t}_w} \cdot \hat{R}$$

Where $C_{max} = 200{,}000$ tokens and $\bar{t}_w$ is the windowed mean of recent turns.

### A3. Shannon Compression

Reduces output $O$ to $O'$ preserving information density above threshold $\theta$:

$$H(O') \geq \theta \cdot H(O), \quad \theta = \begin{cases} 1.0 & \text{code} \\ 0.7 & \text{tests} \\ 0.3 & \text{logs} \end{cases}$$

15 pattern-matched rules for input compression. Extensions:
- **Shannon Output Compression** — prose terse mode (4 levels)
- **Temporal Decay Compression** — age-based result stubbing

### A4. Atomic State Serialization

Write-validate-rename protocol for checkpoint persistence.

$$\text{write}(tmp) \rightarrow \text{validate}(tmp) \rightarrow \text{rename}(tmp, target)$$

50KB bound. Atomic `mkdir` locking (never `flock`).

### A5. Content-Addressable Dedup

SHA-256 hash + TTL cache for read deduplication.

$$\text{decision}(f) = \begin{cases} \text{BLOCK} & h(f) = h_{cached} \land \Delta t < \text{TTL} \\ \text{ALLOW} & \Delta t \geq \text{TTL} \end{cases}$$

TTL = 600s. Block unchanged, allow after expiry.

### A6. Content-Addressable Delta

Extension of A5. Third decision path for changed files:

$$\text{decision}(f) = \text{DELTA} \quad \text{when } h(f) \neq h_{cached} \land \Delta t < \text{TTL}$$

Returns unified diff with 3 context lines instead of full file content.
Only activates when diff is smaller than half the full file.

### A7. Bayesian Strategy Accumulation

Exponential moving average over compression strategy success rates across sessions.

$$r_{new} = \alpha \cdot s_{current} + (1 - \alpha) \cdot r_{prior}, \quad \alpha = 0.3$$

Detects dormant rules, chronic drift patterns, and velocity drift.
Persisted to `learnings.json` after each report.

---

## Install

```
/plugin marketplace add enchanted-plugins/allay
```

Start with context-guard. It's the one you'll feel:

```
/plugin install context-guard@allay
```

Full suite:

```
/plugin install state-keeper@allay
/plugin install token-saver@allay
/plugin install context-guard@allay
```

Or manually:

```bash
bash <(curl -s https://raw.githubusercontent.com/enchanted-plugins/allay/main/install.sh)
```

## 3 Plugins, 4 Agents, 7 Algorithms

| Plugin | Hook | Command | Algorithms |
|--------|------|---------|------------|
| state-keeper | PreCompact | `/allay:checkpoint` | A4 |
| token-saver | PreToolUse + PostToolUse | — | A3, A5, A6 |
| context-guard | PostToolUse | `/allay:report` | A1, A2 |
| shared | — | — | A7 |

| Agent | Model | Plugin | What |
|-------|-------|--------|------|
| analyst | Haiku | context-guard | Background report generation |
| forecaster | Haiku | context-guard | Runway forecast with confidence interval |
| restorer | Haiku | state-keeper | Autonomous context restoration |
| compressor | Haiku | token-saver | Compression strategy analysis |

## What You Get Per Session

```
state-keeper/state/
├── checkpoint.md        # Pre-compaction snapshot (branch, files, instructions)
├── remember.md          # User-flagged context (/allay:checkpoint items)
└── metrics.jsonl        # checkpoint_saved events

token-saver/state/
└── metrics.jsonl        # bash_compressed, duplicate_blocked, delta_read events

context-guard/state/
├── metrics.jsonl        # turn (token est.), drift_detected events
└── learnings.json       # Accumulated strategy rates across sessions (A7)
```

## Commands

| Command | Plugin | What |
|---------|--------|------|
| `/allay:report` | context-guard | Full session dashboard (Runway > Drift > Savings > Learnings) |
| `/allay:runway` | context-guard | Quick turns-until-compaction check |
| `/allay:analytics` | context-guard | Per-tool token consumption breakdown |
| `/allay:doctor` | context-guard | Diagnostic self-check for all plugins |
| `/allay:checkpoint [text]` | state-keeper | Save context that survives compaction |
| `/allay:checkpoint-show` | state-keeper | Display most recent automatic checkpoint |

## Compression Rules (15)

| Pattern | Action |
|---------|--------|
| npm/yarn/pnpm test, vitest, jest | `tail -n 40` |
| pytest, python -m unittest | filter pass/fail summary |
| go test | filter PASS/FAIL lines |
| mvn/gradle test | filter BUILD + test summary |
| dotnet build/test | filter pass/fail summary |
| npm/yarn/pnpm install | filter errors/warnings |
| cargo build/test | filter errors/warnings |
| make | filter errors or "Build succeeded" |
| docker build | filter layer summaries + image ID |
| terraform plan | filter Plan summary |
| eslint | filter error count + first errors |
| tsc | filter TS errors |
| git log (verbose) | `--oneline -20` |
| find (no head) | `head -n 30` |
| cat (>100 lines) | `head -n 80` + line count |

Bypass: prefix with `FULL:` to skip compression.

## vs Everything Else

| | Allay | Caveman | Cozempic | context-mode | token-optimizer |
|---|---|---|---|---|---|
| Drift detection | real-time, 3 patterns | — | — | — | — |
| Turn forecast | Runway + 95% CI | — | threshold only | — | — |
| Output reduction | 4 modes | 65% prose cut | — | — | — |
| Input compression | 15 rules | — | 18 strategies | — | — |
| Delta mode | diff on re-read | — | — | — | delta mode |
| Per-tool analytics | /allay:analytics | — | — | per-tool stats | waste dashboard |
| Tool result aging | age-based alerts | — | 3-tier stubbing | — | — |
| Savings proof | /allay:report | — | session report | ctx_stats | quality score |
| Compaction survival | checkpoint.md | — | team state | SQLite | checkpoints |
| Self-learning | learnings.json | — | — | — | — |
| Agents | 4 (Haiku) | — | — | — | — |
| Dependencies | bash + jq | — | Python | Node.js + MCP | Node.js |

Combined: 30-45% token reduction. Not 70%. Honest numbers.
Plus the only tool that catches Claude going in circles — and learns from it.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

MIT
