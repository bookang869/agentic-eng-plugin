---
name: wiki-query
description: Answers a question from the agentic engineering second-brain wiki. Searches the index and related pages, synthesizes a cited answer, and suggests feeding valuable answers back into the wiki. Triggers on requests like "find it in the wiki", "ask the wiki", "summarize what we know about...", "wiki query", "from the second brain...", "what was..." — any question against accumulated knowledge.
---

# wiki-query — Ask the wiki a question

## 0. Do this first
1. Read `WIKI_SCHEMA.md` to confirm the rules (especially citations · language=English).
2. Read `wiki/index.md` to see what pages exist.

## 1. Search
- Pick pages relevant to the question from the index, and read those files.
- Follow aliases · related links to expand into adjacent pages as needed.
- If the wiki lacks sufficient grounding, drop down to the original `raw/` source to check.

## 2. Synthesize the answer
- Answer in English, **with citations**. Cite wiki pages as `[[page-name]]`, and original sources as `[[ep0X-...]]`.
- If sources disagree, surface the difference (this domain has framework differences by source).
- If the wiki has no answer, clearly say "not yet in the wiki" and suggest an ingest.

## 3. Feed back (optional)
- If the answer is worth keeping in the wiki (new synthesis · new connection), suggest what to add to which page, and apply it on approval.
- Log any feedback applied, or any notably meaningful query, as a `[QUERY]` line in `wiki/log.md`.

## Principles
- Never invent what isn't in the wiki. No unsourced assertions.
