---
name: harness
description: Spec-driven, phased development workflow for a target project — plan work as PRD/ARCHITECTURE/ADR-grounded steps, generate phases/step files, then drive a self-correcting sequential Claude execution loop via a bundled Python script. Also provides an architecture/tech-stack/CRITICAL-rules compliance review checklist. Trigger on "use the harness framework", "harness workflow", "set up the harness", "run harness execute", "/harness", "/harness-review", or when the user wants to break a feature into self-contained, independently-executable implementation steps with automatic retries and git commits per step.
---

# Harness

A workflow for planning a feature as a sequence of small, self-contained implementation steps grounded in a project's own docs (PRD/ARCHITECTURE/ADR/CLAUDE.md), then executing those steps with a self-correcting agent loop that retries on failure, commits per step, and tracks status in JSON.

This skill operates on **the current project** (the repo the user is working in), not on this plugin's own repo. It has two modes: **author** (plan + write step files) and **review** (compliance checklist against the project's own rules).

## Prerequisites

The target project must have these files at its root — this skill scaffolds them from `assets/templates/` on first use if missing, but the user should fill in the placeholders (project name, tech stack, rules) before step files are generated:

- `CLAUDE.md` — tech stack, CRITICAL architecture rules, dev process, commands
- `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/ADR.md` — product/architecture/decision intent
- `docs/UI_GUIDE.md` — optional, only relevant for UI-heavy projects
- `phases/` directory — created automatically when the first phase is authored

If any of these are missing, copy the matching template from `${CLAUDE_PLUGIN_ROOT}/skills/harness/assets/templates/` into the project and tell the user which placeholders need filling in before continuing — do not invent project-specific content on their behalf.

## Mode: author (default)

### A. Explore
Read `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/ADR.md`, `CLAUDE.md` to understand the project's planning, architecture, and design intent. Use the Explore agent in parallel if the project is large.

### B. Discuss
Surface anything that needs clarification or a technical decision before implementation. Present it to the user and discuss — don't silently pick an interpretation.

### C. Step design
When the user asks for an implementation plan, draft it broken into steps and ask for feedback before writing files.

Design principles:
1. **Minimize scope** — each step covers one layer/module. Split steps that touch multiple modules at once.
2. **Self-containment** — each step file runs in an independent Claude session. No "as discussed earlier" references; put everything needed in the file.
3. **Enforce prep** — list paths to relevant docs and to files created/modified in prior steps.
4. **Signature-level instructions** — give function/class interfaces, leave implementation to the agent. Always spell out core rules that must not be violated (idempotency, security, data integrity).
5. **AC as executable commands** — e.g. `npm run build && npm test`, not "should work."
6. **Specific cautions** — "Don't do X. Reason: Y", not "be careful."
7. **Naming** — kebab-case slugs, one or two words (e.g. `project-setup`, `api-layer`).

### D. File creation
Once the user approves the step breakdown, generate:

**`phases/index.json`** (create if missing, else append an entry to `phases`):
```json
{ "phases": [ { "dir": "0-mvp", "status": "pending" } ] }
```
`dir` = task directory name. `status` is one of `pending|completed|error|blocked`, updated automatically by `execute.py`. Do not set timestamps at creation time — the script records them.

**`phases/{task-name}/index.json`**:
```json
{
  "project": "<project name>",
  "phase": "<task-name>",
  "steps": [
    { "step": 0, "name": "project-setup", "status": "pending" },
    { "step": 1, "name": "core-types", "status": "pending" }
  ]
}
```
`project` from CLAUDE.md. `phase` must match the directory name. `steps[].name` kebab-case. All steps start `"pending"`.

**`phases/{task-name}/step{N}.md`** — one per step:
```markdown
# Step {N}: {name}

## Files to read
- `/docs/ARCHITECTURE.md`
- `/docs/ADR.md`
- {paths of files created/modified in previous steps}

## Task
{Concrete instructions: file paths, class/function signatures, logic. Interface-level code only — leave implementation to the agent. Spell out non-negotiable rules.}

## Acceptance Criteria
​```bash
npm run build   # no compile errors
npm test        # tests pass
​```

## Verification Procedure
1. Run the AC commands above.
2. Check: directory structure matches ARCHITECTURE.md, tech stack matches the ADR, no CRITICAL rule in CLAUDE.md is violated.
3. Update `phases/{task-name}/index.json`:
   - Success → `"status": "completed"`, `"summary": "<one-line output summary>"`
   - Still failing after 3 fix attempts → `"status": "error"`, `"error_message": "<details>"`
   - Needs user intervention (API keys, external auth, manual setup) → `"status": "blocked"`, `"blocked_reason": "<reason>"`, then stop immediately

## Prohibited
- {What must not be done in this step. Format: "Don't do X. Reason: Y"}
- Do not break existing tests
```

### E. Execute
Run from the project root (not the plugin directory):
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/harness/scripts/execute.py" {task-name}        # sequential execution
python3 "${CLAUDE_PLUGIN_ROOT}/skills/harness/scripts/execute.py" {task-name} --push  # execute then push
```

What it handles automatically:
- Creates/checks out the `feat-{task-name}` branch
- Guardrail injection — includes `CLAUDE.md` + `docs/*.md` in every step's prompt
- Context accumulation — passes completed steps' summaries into the next step's prompt
- Self-correction — retries up to 3 times on failure, feeding back the previous error
- Two-stage commits — separate `feat` (code) and `chore` (metadata) commits per step
- Timestamps — `started_at`/`completed_at`/`failed_at`/`blocked_at` recorded automatically

Error recovery:
- **On error**: in `phases/{task-name}/index.json`, set the step's `status` back to `"pending"`, delete `error_message`, re-run.
- **On blocked**: resolve `blocked_reason`, set `status` to `"pending"`, delete `blocked_reason`, re-run.

Suggest the user add this to the target project's `.gitignore`:
```
phases/**/phase*-output.json
phases/**/step*-output.json
```

## Mode: review
Triggered by `/harness-review` or "review this against the harness rules."

Read `CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/ADR.md`, then check the project's changed files against:

| Item | Check |
|------|------|
| Architecture compliance | Follows the directory structure in ARCHITECTURE.md? |
| Tech stack compliance | Stays within the ADR's technology choices? |
| Test coverage | Tests written for new features? |
| CRITICAL rules | No CRITICAL rule in CLAUDE.md violated? |
| Buildable | Build command passes without errors? |

Report as a table (✅/❌ + notes per row). If there are violations, propose specific fixes.

## Optional: guardrail hooks
`assets/templates/settings.json.example` is a starting point for a `.claude/settings.json` in the *target* project (not this plugin) — a `Stop` hook running lint/build/test, and a `PreToolUse` hook blocking obviously destructive Bash commands. It assumes an npm toolchain; adapt the commands to the project's actual scripts before adopting it. This is optional and separate from the harness step-execution flow.
