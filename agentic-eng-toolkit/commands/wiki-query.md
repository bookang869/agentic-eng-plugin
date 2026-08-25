---
description: Answers a question from the second-brain wiki with cited, synthesized answers (suggests feeding back into the wiki if valuable)
---

Run the **wiki-query** skill bundled with this plugin via the Skill tool.
Read `WIKI_SCHEMA.md` and `wiki/index.md` to search for relevant pages, and answer with citations (`[[page-name]]` · `[[ep0X-...]]`). Surface differences in stance between sources, and if the answer isn't in the wiki, say "not yet in the wiki" and suggest an ingest.

Query: $ARGUMENTS

If the query is empty, first ask the user what they're looking for.
