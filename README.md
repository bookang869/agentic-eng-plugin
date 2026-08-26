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

Each command runs the bundled skill of the same name. Invoke it explicitly with the slash command, or let it auto-trigger on the keywords above.

## Installation (team members)

```
/plugin marketplace add bookang869/agentic-eng-plugin
/plugin install agentic-eng-toolkit@agentic-eng
```

After installing, the 4 commands above will show up in `/help` or the `/` menu.

## Prerequisites

- **wiki-* commands**: must be run **inside a second-brain vault** that has `WIKI_SCHEMA.md` and a `wiki/` directory at the repo root. Schema, folder structure, and citation rules are all read from there.
- **ai-readiness-cartography**: works on any repo. Requires `python3` (3.10+, stdlib only). The scoring script is `${CLAUDE_PLUGIN_ROOT}/skills/ai-readiness-cartography/scripts/score.py`.

## Structure

```
agentic-eng-plugin/
├── .claude-plugin/marketplace.json     # marketplace manifest
└── agentic-eng-toolkit/                # the plugin
    ├── .claude-plugin/plugin.json
    ├── commands/                       # 4 slash commands
    └── skills/                         # 4 skills (auto-trigger + called by commands)
        ├── ai-readiness-cartography/   # SKILL.md + scripts/ + assets/ + references/
        ├── wiki-ingest/
        ├── wiki-lint/
        └── wiki-query/
```

## Updating

After editing a skill/command and pushing, team members get the latest with `/plugin marketplace update agentic-eng`.
