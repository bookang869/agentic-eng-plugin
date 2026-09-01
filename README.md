# agentic-eng-plugin

Claude Code plugin marketplace for agentic engineering teams.
Ships a single plugin: **`agentic-eng-toolkit`**.

## Commands provided

| Slash command | What it does | Auto trigger |
|---|---|---|
| `/ai-readiness-cartography` | Audits a repo against the AI-Ready v2 rubric (100 pts · 7 categories) → HTML dashboard + ROI action list | "AI-readiness map", "visualize repo audit", etc. |
| `/wiki-ingest` | Integrates raw sources into the second-brain wiki (entity extraction · merge · cross-linking · index/log updates) | "organize this into the wiki", "ingest ep0X", etc. |
| `/wiki-lint` | Wiki health check (contradictions · orphan pages · broken links · index sync · abandoned stubs) | "check the wiki", "wiki lint", etc. |
| `/wiki-query` | Ask the wiki a question → cited synthesized answer, suggests feeding back if valuable | "find it in the wiki", "what was...", etc. |
| `/revise-claude-md` | Reviews the current session and proposes CLAUDE.md additions to capture learnings | run manually at end of session |
| *(no command — skill only)* `claude-md-improver` | Audits all CLAUDE.md files in a repo against a quality rubric, reports scores, and applies approved fixes | "audit my CLAUDE.md files", "check if my CLAUDE.md is up to date", etc. |

Most commands run a bundled skill of the same name — invoke it explicitly with the slash command, or let it auto-trigger on the keywords above. `claude-md-improver` is skill-only (no matching slash command); `/revise-claude-md` is command-only (no matching auto-triggering skill).

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
    │   └── revise-claude-md.md
    └── skills/                         # skills (auto-trigger + called by commands)
        ├── ai-readiness-cartography/   # SKILL.md + scripts/ + assets/ + references/
        ├── wiki-ingest/
        ├── wiki-lint/
        ├── wiki-query/
        └── claude-md-improver/         # SKILL.md + references/ + LICENSE (Apache-2.0, adapted from anthropics/claude-plugins-official)
```

## Third-party content

`claude-md-improver` (skill) and `/revise-claude-md` (command) are adapted
unmodified from Anthropic's official
[`claude-md-management`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management)
plugin, licensed Apache-2.0. See `THIRD_PARTY_NOTICES.md`.

## Updating

After editing a skill/command and pushing, team members get the latest with `/plugin marketplace update agentic-eng`.
