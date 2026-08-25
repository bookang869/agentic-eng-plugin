---
description: Checks the health of the second-brain wiki (contradictions · stale claims · orphan pages · broken links · index sync · abandoned stubs)
---

Run the **wiki-lint** skill bundled with this plugin via the Skill tool.
First check the rules in `WIKI_SCHEMA.md`, then collect all of `wiki/`, and inspect the 7 check items. **Report findings first**, as a per-item list, and only make fixes after user approval. Record the results as a single `[LINT]` line in `wiki/log.md`.

Additional instructions (e.g. check only a specific folder): $ARGUMENTS

If everything is clean, finish with "no issues found" (idempotent). Do not touch raw/.
