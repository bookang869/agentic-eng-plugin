# AI-Ready Codebase Rubric · v2 (100 pt · 7 categories)

This document is the single source of truth used for both automatic and manual scoring. Items `scripts/score.py` cannot catch automatically are supplemented by a human — the **Auto / Heuristic / Manual** tag at the end of each item indicates confidence.

| Cat | Name | Points |
|-----|------|--------|
| A | AI Navigation & Coverage | 15 |
| B | Context Document Quality | 20 |
| C | Tribal Knowledge Externalization | 20 |
| D | Cross-Module Dependency & Data Flow Mapping | 15 |
| E | Verification & Quality Gates | 15 |
| F | Freshness & Self-Maintenance | 10 |
| G | Agent Performance Outcomes | 5 |

**Total = 100**

---

## A. AI Navigation & Coverage · /15

> Can an AI quickly find its way around the full codebase / modules / workflows?

| Score | Criteria |
|-------|----------|
| 0     | Has to guess at the repo via grep / search |
| 5     | Some modules have a README / context |
| 10    | Most core modules document role · entry point · related files |
| 15    | Every core module / workflow has a navigation guide. "Where should I look" is reachable within 1-2 hops |

**Measurement** *(Auto)*

```
Navigation Coverage = (# of core modules an AI can be guided to via context) / (total # of core modules)
```

- "Core module" = code directories at the repo root + each child of `apps/*` / `packages/*` / `services/*`
- Score = `round(coverage × 15)`, then cap
- Evaluated by module / workflow coverage, not file count

---

## B. Context Document Quality · /20

> Do context files follow the "compass, not encyclopedia" principle?

| Sub | Item | Points | Full-Score Criteria |
|-----|------|--------|---------------------|
| B1 | Conciseness *(Auto)*       | 4 | Every CLAUDE.md is 25-35 lines or ~1,000 tokens or less |
| B2 | Quick Commands *(Heuristic)* | 4 | Copy-pasteable commands + when to use them stated (`~~~bash` block + surrounding explanation) |
| B3 | Key Files *(Heuristic)*    | 4 | Lists the 3-5 core file paths actually needed for edits |
| B4 | Non-Obvious Patterns *(Heuristic)* | 4 | Hidden rules that cause failures + exceptions are stated (`Why:`, `Note:`, `Gotcha`, `Warning`) |
| B5 | See Also / Cross References *(Auto)* | 4 | Links to related modules / context files / dependency maps (relative links) |

Each sub-item is converted to a 4-point score based on the module average or maximum. **The point isn't having lots of docs — it's containing only task-relevant context.**

---

## C. Tribal Knowledge Externalization · /20

> Are hidden rules, failure patterns, and human-only knowledge structured?

### Five-Question Framework *(Heuristic + Manual)*

For each core module, 4 points per question answerable, 20 points total:

1. **What does this module configure / own?** — `## Purpose`, "configures", "owns" phrasing
2. **What are common modification patterns?** — `## Patterns`, "common changes", "## How to"
3. **What non-obvious patterns cause failures?** — `Why:`, `Note:`, `Gotcha`, `Don't`
4. **What are the cross-module dependencies?** — "depends on", "imports", `## Cross-module`
5. **What tribal knowledge is hidden in comments / history / human memory?** — presence of `MEMORY.md` / `ADR` / `docs/decisions`

### Score band

| Score | Criteria |
|-------|----------|
| 0     | Knowledge exists only with the senior engineer / in Slack / in old PRs |
| 5     | Some gotchas scattered across README / comments |
| 10    | Some tacit knowledge of repeated tasks documented |
| 15    | Compatibility rules / naming / generated-code rules / deprecated-but-required rules organized |
| 20    | Most identified tribal knowledge is reflected in context files / checklists / playbooks + retrievable by AI query |

Auto score = (average pass rate across 5 questions × 20). Actual depth verified by a human.

---

## D. Cross-Module Dependency & Data Flow Mapping · /15

> Can an AI trace the blast radius of a change?

| Score | Criteria |
|-------|----------|
| 0     | Change impact tracked manually by a human |
| 5     | Some architecture diagram or dependency note |
| 10    | Dependencies / ownership between major modules documented |
| 15    | "What depends on X?" answerable via a graph / index / map. Can trace repo / service / test / data-flow ripple |

**Auto checks:**
- Presence of `docs/architecture.md`, `ARCHITECTURE.md`, `docs/dependency-graph*`
- Presence of `mermaid` / `graphviz` diagram fences
- `## Dependencies` / `Cross-module` sections inside CLAUDE.md
- Whether a graph is derivable from a monorepo's `pnpm-workspace.yaml` / `turbo.json` / `nx.json`

**Why important.** Decisive in large codebases where a single field change ripples across 6 subsystems. If this is weak, it's correct to dock D.

---

## E. Verification & Quality Gates · /15

> Is there a system to verify AI-generated context and code changes?

| Sub | Item | Points | Full-Score Criteria |
|-----|------|--------|---------------------|
| E1 | Reference Accuracy *(Auto)*        | 5 | Zero hallucinations among file paths · APIs · commands referenced in CLAUDE.md / context files |
| E2 | Independent Critic Review *(Manual)* | 4 | At least 2-3 rounds of independent review or a checklist (CODEOWNERS / review template / agent critic) |
| E3 | Task Validation *(Auto)*           | 4 | Build / test / lint / typecheck / e2e verification commands provided per change type + actually runnable |
| E4 | Prompt / Workflow Tests *(Heuristic)* | 2 | Representative AI task queries actually tested (`evals/`, agent tests) |

**E1 auto-scoring algorithm:**
1. Extract `[A-Za-z0-9_./-]+\.(py|ts|tsx|js|md|sql|json|yaml|yml|toml)` candidates from every context file
2. Verify each candidate's existence relative to the repo root
3. `valid / total` ratio → `round(ratio × 5)`

> "Zero hallucinated paths" is Meta's stated condition for full marks here. This is the core of AI-readiness — unverified context is **more dangerous** than none at all.

---

## F. Freshness & Self-Maintenance · /10

> Is context automatically kept from going stale?

| Score | Criteria |
|-------|----------|
| 0     | Manually maintained + staleness unknown |
| 3     | Has an owner + updated occasionally |
| 6     | CI / script catches some broken paths / references |
| 10    | Periodic file-path validation, coverage-gap detection, critic review, and stale-reference repair run automatically |

**Auto checks:**
- Compare each CLAUDE.md's mtime against the latest mtime of code files in the same module — drift ratio
- Presence of a context / docs validation step in `.github/workflows/*`
- Presence of a path-validation hook in pre-commit / husky
- Date of the most recent entry in `MEMORY.md` Session Notes

**Why it matters.** Stale context justifies hallucination via augmented retrieval. **Worse** than having none.

---

## G. Agent Performance Outcomes · /5

> Is actual AI task success rate / efficiency improvement measured?

| Score | Criteria |
|-------|----------|
| 0     | No AI performance measurement |
| 2     | Qualitative "it helps" level only |
| 3     | Representative task success rate or human intervention rate measured |
| 5     | Tool calls, token usage, task completion time, correctness, prompt pass rate measured before / after |

**Tracked metrics (examples):**
- AI task pass rate
- Average tool calls per task
- Average tokens per task
- Human clarification count
- Failed PR / rework rate
- Hallucinated file path count
- Time-to-first-correct-change

**Auto checks:**
- Presence of `evals/`, `benchmarks/`, `agent-metrics/` directories
- Result files like `.skill-eval.json`, `agent-results.json`
- AI usage telemetry configured (Claude Code session log, OpenTelemetry)

---

## Final Grade

| Score | Level | Meaning | Badge color |
|-------|-------|---------|-------------|
| 90-100 | **AI-Native / Agentic-Ready** | Agent autonomously handles most repetitive tasks + context layer is self-maintaining | green |
| 75-89  | **AI-Ready** | AI reliably navigates, edits, and verifies for most tasks | green |
| 60-74  | **AI-Assisted** | AI is useful, but complex / domain tasks need human context | amber |
| 40-59  | **AI-Fragile** | Simple tasks are fine, high error risk from hidden rules / dependencies | amber |
| < 40   | **AI-Hostile** | Heavy reliance on tribal knowledge + AI is mostly guessing | red |

---

## ROI Heuristics for Recommendations

Present actions for each gap in this format:

```
Effort: S (<1h) / M (1-4h) / L (4h+)
Impact: time saved per AI task × estimated tasks/period
Priority = Impact / Effort
```

Sample action ROI table:

| Action | Effort | Impact (typical) |
|--------|--------|------------------|
| Add CLAUDE.md to a core module | S (30-60 min) | 2-5 min/task × N tasks/week |
| Split a god file (>500 lines) | M (1-3 hr/file) | 30-50% token reduction + accuracy ↑ |
| Add a `## Cross-module deps` section | S (30 min) | Prevents cascade bugs |
| Introduce MEMORY.md / ADR | M (2-4 hr initial) | Preserves tribal knowledge (externalized) |
| Add path-validation CI | S (1 hr) | Auto-blocks stale references |
| Add agent eval tests | L (4-8 hr) | Catches AI regressions |
| Naming refactor | M-L | Improves consistency (low priority) |

Present the top 5, sorted by Priority descending.
