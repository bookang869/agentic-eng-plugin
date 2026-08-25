---
name: ai-readiness-cartography
description: Audits any repository against the v2 AI-Ready rubric (100 pts · 7 categories — Navigation, Context Quality, Tribal Knowledge, Dependency Mapping, Verification Gates, Freshness, Agent Outcomes) and produces a professional single-file HTML dashboard plus an ROI-ranked action list. The skill bundles a Python scorer (`scripts/score.py`) that auto-detects coverage, hallucinated paths, drift, and god files. Trigger whenever the user asks for an "AI-readiness map", "AI-ready visualization", "repo cartography", "codebase audit visualization", "ai-readiness-cartography", or anything that sounds like "score how agent-friendly this codebase is and visualize it", "check how AI-ready our repo is", "map the repo against the rubric", or "audit our codebase for agent readiness". Also trigger when the user points at a repo and asks whether it is ready for coding agents / LLM workflows — even without the exact keyword. The output is always a clean technical-dashboard HTML (Inter + JetBrains Mono, light surface, blue/green/amber/red accents), never a fantasy map.
---

# AI-Readiness Cartography

This skill audits an arbitrary repository against the **AI-Ready Codebase v2 rubric** (100 points · 7 categories A-G). The output is a single professional technical-dashboard HTML + auto-scored JSON + an ROI-ranked actionable action list. The name is "cartography" but the tone is a decision-making instrument panel — no fantasy parchment / compass-rose decoration, ever.

## When to use

- "Give me an AI-readiness map / visualization / score"
- "Show me how agent-friendly this repo is"
- "codebase audit", "repo cartography"
- Indirect phrasing like "can Claude Code handle this repo well"
- Trigger even without the exact keyword if the user wants an LLM-workflow fitness assessment

## What to produce

**Produce all 3 deliverables in one pass.**

1. **JSON scorecard** (raw data, consumable by other tools)
2. **Single HTML dashboard** (for humans to read and decide)
3. **ROI-ranked action list** (prioritized next steps)

Default save-location priority:
- If the repo has `docs/` → `docs/ai-readiness-map.html`, `docs/ai-readiness-score.json`
- If it has `.claude/` → `.claude/ai-readiness-{map.html,score.json}`
- Otherwise the repo root
- If the user gives an explicit path, that takes priority

## Workflow

### 1. Auto-score with the Python script

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/ai-readiness-cartography/scripts/score.py" <repo-path> \
  --json <output-path>/ai-readiness-score.json
```

> When installed as a plugin, the `${CLAUDE_PLUGIN_ROOT}` env var points at the plugin root. If it's unset, run `scripts/score.py` directly from the same folder as this SKILL.md.

The script is stdlib only (no deps, Python 3.10+). Output:
- A structured scorecard (categories A-G, evidence, sub_scores, findings, ROI actions, large files) at the path given by `--json`
- A human-readable markdown summary on stdout

What auto-scoring catches:
- **A** core module navigation coverage (fraction with CLAUDE.md / AGENTS.md)
- **B1, B5** conciseness · cross-references
- **C Q1-Q4** Five-Question framework heuristic + Q5 MEMORY/ADR presence
- **D** ARCHITECTURE.md / mermaid / workspace file detection
- **E1** **hallucinated path verification** (verifies existence of every path candidate in context) — the single most important item
- **E3** build/test infra presence
- **F** context drift (mtime comparison) + CI / hook validation
- **G** evals/ benchmarks/ directory + telemetry hints

What auto-scoring cannot catch (Manual):
- Depth of B2-B4 quick commands / key files / non-obvious
- Depth of C's tribal knowledge
- Quality of E2 critic review
- Quality of E4 prompt tests

The LLM should take the JSON and either supplement the manual items or reflect them as-is into the chart.

### 2. Fill the HTML dashboard from the JSON

Copy `assets/template.html`, then plug in the JSON values. **Never write it from scratch** — the design would drift every time.

Blocks to change:

**(a) Header**
- `<title>` · the h1's `{{REPO_NAME}}`
- `header-meta`'s date (today) · git branch · `meta.modules_total` · `meta.context_files_total`

**(b) Score hero**
- `score-hero .num` ← `total`
- `grade-badge` text ← grade (`AI-Native` / `AI-Ready` / `AI-Assisted` / `AI-Fragile` / `AI-Hostile`)
- `grade-badge` background/color ← `grade_color` (green / amber / red)
- Grade thresholds:
  - 90-100 AI-Native (green)
  - 75-89  AI-Ready (green)
  - 60-74  AI-Assisted (amber)
  - 40-59  AI-Fragile (amber)
  - < 40   AI-Hostile (red)
- `.desc` — one line naming the 2 weakest categories
- 3 mini stats: modules · context_files · large_files_300plus (or highlight ref_broken)

**(c) 7-category bar chart**
Replace the 10-rule chart with 7 categories. For each row:
- A 15 / B 20 / C 20 / D 15 / E 15 / F 10 / G 5
- bar width = `score / max * 100%`
- color: score/max ≥ 0.75 → bar-good (green) · 0.5-0.74 → bar-warn (amber) · < 0.5 → bar-bad (red)
- `.sub` — 1-2 pieces of evidence, briefly (e.g. "coverage 75% · 1 module missing")
- B and E have sub_scores, so expand them small under the row to also show scores for the 5/4 sub-items

**(d) Structural Map (SVG)**
Reconfigure columns to match the target repo's structure. Show top entries from `large_files` inside cards as hot/warm bars. Modules with CLAUDE.md / AGENTS.md get an accent border + a lit indicator. Modules with `ref_broken` get a red dot.

**(e) Wins / Top ROI Actions panel**
- Left "Wins": pull mostly from high-scoring categories in evidence, list 5 key strengths
- Right "Top ROI Actions": top 5-7 of the JSON's `actions`. Each row shows:
  - Category tag (A-G)
  - Effort (S / M / L · time)
  - Impact (1 line)
  - Priority score (optional)

**(f) Footer**
`{{REPO_NAME}} · AI-Readiness v2 · scored {{YYYY-MM-DD}}`

### 3. Open in browser

```bash
open <output-path>/ai-readiness-map.html   # macOS
xdg-open <path>                            # Linux
```

If the user says "don't open it," just report the path.

### 4. Summary report

Finish with one paragraph covering these 4 things:
1. **Total score / grade** (`32/100 · AI-Hostile`)
2. **1-2 weakest categories** + a one-line diagnosis
3. **Top 3 ROI actions** (Effort + Impact, briefly)
4. **File paths** generated

## Style rules (non-negotiable)

This skill's identity. Deviate and it isn't this skill anymore.

- **Fonts**: Inter (body), JetBrains Mono (numbers/code). No other fonts.
- **Colors**: fixed to the template's CSS-variable palette.
- **Background**: `#fafafa` light. No dark mode.
- **No decoration**: compass rose, parchment, cursive script, emoji, stamps — none of it, ever.
- **No chart libraries**: every visualization is inline SVG + CSS.

## Common pitfalls

- **Forgetting the rubric is v2 and scoring with the old 10-rule system** — a leftover from the previous version. It's now **A-G, 7 categories / 100 points**.
- **Ignoring the script's output and scoring by hand** — auto-detected items are more accurate when left to the script. Run the script first, then supplement on top.
- **Treating E1 hallucinated paths casually** — the Meta standard is "0 hallucinated paths." Even one is an immediate fix action.
- **Ignoring the template and writing from scratch** — the design drifts every time. Copy → edit.
- **Regressing into fantasy** — don't lean into the map metaphor just because the name is "cartography."
- **ROI with only qualitative adjectives** — no vague impact like "efficiency ↑". Use concrete units like "~3 min/task × ~5/day."

## ROI framing

Convention for expressing each action's effort/impact:

- **Effort**: S (<1h) / M (1-4h) / L (4h+)
- **Impact**: prefer quantitative units — "N min/task × M tasks/week", "X% token reduction", "catches Y regressions"
- **Priority**: auto-sorted by `impact_score / effort_hours`

See the end of `references/scoring-rubric.md` for a sample action ROI table.

## Files

- `assets/template.html` — the source dashboard to copy and fill in
- `references/scoring-rubric.md` — the v2 7-category scoring criteria
- `scripts/score.py` — auto-scoring + ROI action generation (Python 3.10+, stdlib only)
