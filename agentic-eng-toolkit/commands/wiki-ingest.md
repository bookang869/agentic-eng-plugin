---
description: Reads a raw source and integrates it into the second-brain wiki (entity extraction · merge · cross-linking · index/log updates)
---

Run the **wiki-ingest** skill bundled with this plugin via the Skill tool.
Always read `WIKI_SCHEMA.md` and `wiki/index.md` at the repo root first to understand the current state, then follow the skill's procedure (entity extraction → merge-first writing → link/contradiction marking → index/log updates).

Source to ingest (e.g. ep02, or a raw file path): $ARGUMENTS

If no arguments are given, ask the user which raw sources haven't been ingested yet before proceeding.
