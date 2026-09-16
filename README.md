# agentic-eng-plugin

Claude Code plugin marketplace for agentic engineering teams.
Ships a single plugin: **`agentic-eng-toolkit`**.

The toolkit has three kinds of building blocks:
- **Commands** (`/foo`) — explicit slash commands, listed below.
- **Skills** — the logic each command runs; most also auto-trigger on natural-language phrasing without typing the slash command.
- **Hooks** — background logic wired into the Claude Code tool lifecycle (e.g. `PreToolUse`) with no command or skill of its own. This plugin ships one: the **TDD guard** (see [below](#tdd-guard-hook-no-commandskill)).

## Commands provided

| Slash command | What it does | Auto trigger |
|---|---|---|
| `/ai-readiness-cartography` | Audits a repo against the AI-Ready v2 rubric (100 pts · 7 categories) → HTML dashboard + ROI action list | "AI-readiness map", "visualize repo audit", etc. |
| `/wiki-ingest` | Integrates raw sources into the second-brain wiki (entity extraction · merge · cross-linking · index/log updates) | "organize this into the wiki", "ingest ep0X", etc. |
| `/wiki-lint` | Wiki health check (contradictions · orphan pages · broken links · index sync · abandoned stubs) | "check the wiki", "wiki lint", etc. |
| `/wiki-query` | Ask the wiki a question → cited synthesized answer, suggests feeding back if valuable | "find it in the wiki", "what was...", etc. |
| `/revise-claude-md` | Reviews the current session and proposes CLAUDE.md additions to capture learnings | run manually at end of session |
| `/harness` | Plans a feature as PRD/ARCHITECTURE/ADR-grounded steps, writes phases/step files, then drives a self-correcting sequential execution loop (retries, per-step commits) | "use the harness framework", "harness workflow", etc. |
| `/harness-review` | Reviews the project's changes against its own CLAUDE.md CRITICAL rules, ARCHITECTURE.md, and ADR.md | "review this against the harness rules", etc. |
| `/improve-token-efficiency` | Parses local Claude Code session JSONL logs into a token/cost efficiency HTML dashboard with savings recommendations | "analyze token efficiency", "how much did I spend on Claude", "session cost report", etc. |
| *(no command — skill only)* `claude-md-improver` | Audits all CLAUDE.md files in a repo against a quality rubric, reports scores, and applies approved fixes | "audit my CLAUDE.md files", "check if my CLAUDE.md is up to date", etc. |

Most commands run a bundled skill of the same name — invoke it explicitly with the slash command, or let it auto-trigger on the keywords above. `claude-md-improver` is skill-only (no matching slash command); `/revise-claude-md` is command-only (no matching auto-triggering skill).

## TDD guard hook (no command/skill)

`agentic-eng-toolkit/scripts/tdd-guard.sh` is wired up as a **`PreToolUse` hook** in `hooks/hooks.json`, matched against the `Edit` and `Write` tools. It runs on every attempted file write, unconditionally — there's no slash command or skill to invoke, and no auto-trigger phrase; installing the plugin is what turns it on.

**What it does:** enforces test-first development. Before letting Claude write or edit an implementation file, it checks whether a corresponding test file already exists. If not, it returns a `deny` decision with a message telling Claude to write the test first — Claude sees this as a blocked tool call and must react.

**Exemption logic** (files that never require a test), checked before the test-existence check:
- The file being written *is itself* a test file — matched by basename convention (`test_*.py`, `*_test.py`, `*.test.*`, `*.spec.*`, `conftest.py`, `tests.py`) or by living inside an exact `tests/`, `test/`, `spec/`, `specs/`, `__tests__/` path segment.
- Config/style/lockfiles by extension (`.json`, `.css`, `.md`, `.yml`, `.toml`, `.lock`, etc.) and named config files by exact basename (`tailwind.config.*`, `next.config.*`, `tsconfig.json`, `.env`, etc.).
- Type declarations (`*.d.ts`, root `types.ts`, anything under a `types/` directory).
- Next.js framework files (`layout.tsx`, `page.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `globals.css`).
- Python packaging/framework boilerplate (`__init__.py`, `setup.py`, `manage.py`, `wsgi.py`, `asgi.py`) and migration files (`migrations/*.py`, `alembic/versions/*.py`).

**Test discovery** for everything else:
- **JS/TS** (`.ts`/`.tsx`/`.js`/`.jsx`): looks for a colocated `*.test.*`/`*.spec.*`, a `__tests__/` sibling or parent folder, or a repo-root `src/__tests__/` mirror.
- **Python** (`.py`): tries, in order, same-folder `test_<module>.py`/`<module>_test.py` → colocated/parent `tests/`|`test/` → repo-root `tests/` (flat or path-mirrored) → a feature-area convention where `tests/test_<parent-dir-name>.py` is treated as covering every module in that directory (e.g. `tests/test_providers.py` covers all of `providers/*.py`) → as a last resort, greps test directories for an actual `import <module>` / `from <module> import` statement.

All classification is done on the file's **basename or an exact path segment** — never a bare substring match on the full path and never a glob that requires a leading `/` to match nested files. That distinction matters: e.g. `latest.py` or `contest_handler.py` contain the substring `"test"` but are real implementation files, and a root-level `manage.py` (no parent directory) still needs to match the same exemption as a nested one.

If none of the above finds a test, the hook denies the write with a reason string naming the missing test file it expects.

## Installation (team members)

```
/plugin marketplace add bookang869/agentic-eng-plugin
/plugin install agentic-eng-toolkit@agentic-eng
```

After installing, the commands above will show up in `/help` or the `/` menu.

## Prerequisites

- **wiki-* commands**: must be run **inside a second-brain vault** — a separate repo you set up, not this plugin repo. None of the wiki skills create this structure for you; it must already exist at the target repo's root before `wiki-ingest`/`wiki-lint`/`wiki-query` will work correctly:
  - `WIKI_SCHEMA.md` — defines folder layout, frontmatter fields, page template, naming, and citation rules. Every wiki skill reads this file first; **you have to author it yourself**, no starter template ships with this plugin.
  - `wiki/index.md` — master listing of pages by category (kept in sync by `wiki-ingest`/`wiki-lint`).
  - `wiki/log.md` — append-only log of ingest/lint/query actions.
  - `wiki/concepts/`, `wiki/people/`, `wiki/tools/` (or whatever categories your schema defines) — the actual pages.
  - `raw/` — the untouched source material (e.g. transcripts) that `wiki-ingest` reads from and never modifies.
- **ai-readiness-cartography**: works on any repo. Requires `python3` (3.10+, stdlib only). The scoring script is `${CLAUDE_PLUGIN_ROOT}/skills/ai-readiness-cartography/scripts/score.py`.
- **harness**: run inside the target project you want to plan/execute work in (not this plugin repo). It scaffolds `CLAUDE.md` / `docs/PRD.md` / `docs/ARCHITECTURE.md` / `docs/ADR.md` from `${CLAUDE_PLUGIN_ROOT}/skills/harness/assets/templates/` on first use if missing — fill in the placeholders before generating step files. Execution runs `python3 "${CLAUDE_PLUGIN_ROOT}/skills/harness/scripts/execute.py" <phase-dir>` from the project root and shells out to `claude -p`, so it requires `python3`, `git`, and the `claude` CLI on `PATH`.
- **improve-token-efficiency**: requires `python3`. Reads local session logs from `~/.claude/projects/<encoded-repo-path>/*.jsonl` for the target repo — nothing to set up beyond having used Claude Code in that repo before.
- **TDD guard hook**: requires `bash` and `jq` on `PATH` (both used to parse the tool-call JSON piped into `scripts/tdd-guard.sh`). No configuration — it's active for every `Edit`/`Write` call as soon as the plugin is installed.

## Structure

```
agentic-eng-plugin/
├── .claude-plugin/marketplace.json     # marketplace manifest
├── THIRD_PARTY_NOTICES.md              # attribution for imported (Apache-2.0) content
└── agentic-eng-toolkit/                # the plugin
    ├── .claude-plugin/plugin.json
    ├── commands/                       # slash commands
    │   ├── ai-readiness-cartography.md
    │   ├── wiki-ingest.md
    │   ├── wiki-lint.md
    │   ├── wiki-query.md
    │   ├── revise-claude-md.md
    │   ├── harness.md
    │   ├── harness-review.md
    │   └── improve-token-efficiency.md
    ├── skills/                         # skills (auto-trigger + called by commands)
    │   ├── ai-readiness-cartography/   # SKILL.md + scripts/ + assets/ + references/
    │   ├── wiki-ingest/
    │   ├── wiki-lint/
    │   ├── wiki-query/
    │   ├── claude-md-improver/         # SKILL.md + references/ + LICENSE (Apache-2.0, adapted from anthropics/claude-plugins-official)
    │   ├── harness/                    # SKILL.md + scripts/execute.py (+ tests) + assets/templates/
    │   └── improve-token-efficiency/   # SKILL.md + scripts/analyze_sessions.py + scripts/build_dashboard.py
    ├── hooks/
    │   └── hooks.json                  # wires PreToolUse[Edit|Write] to scripts/tdd-guard.sh
    └── scripts/
        └── tdd-guard.sh                # TDD guard hook — no command/skill, see "TDD guard hook" above
```

## Third-party content

`claude-md-improver` (skill) and `/revise-claude-md` (command) are adapted
unmodified from Anthropic's official
[`claude-md-management`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management)
plugin, licensed Apache-2.0. See `THIRD_PARTY_NOTICES.md`.

## Updating

After editing a skill/command and pushing, team members get the latest with `/plugin marketplace update agentic-eng`.
