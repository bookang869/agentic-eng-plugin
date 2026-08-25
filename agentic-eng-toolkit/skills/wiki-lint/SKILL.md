---
name: wiki-lint
description: Checks the health of the agentic engineering second-brain wiki. Finds contradictions, stale claims, orphan pages, missing cross-links, index gaps, and abandoned stubs, reports them, and fixes them on approval. Triggers on requests like "check the wiki", "wiki lint", "health check", "check for contradictions", "orphan pages", "clean up the wiki", "wiki lint". Use for periodic maintenance — idempotent.
---

# wiki-lint — Wiki health check

## 0. Do this first
- Read `WIKI_SCHEMA.md` to confirm the rules. All check criteria come from the schema.

## 1. Collect
- Read all of `wiki/` (index, log, concepts/people/tools) and the list of raw files.

## 2. Check items
1. **Contradictions** — pages that assert conflicting claims about the same topic. (Especially framework differences between sources buried without a `## Contradictions / Caveats` note.)
2. **Stale claims** — statements that conflict with raw or are no longer valid.
3. **Orphan pages** — pages never referenced by `[[ ]]` anywhere and not in the index.
4. **Missing cross-links** — body text mentions another entity but has no link.
5. **Broken links** — `[[ ]]` whose target file doesn't exist.
6. **Index sync** — mismatches between actual files and the index listing, missing `sources`/`updated` frontmatter.
7. **Abandoned stubs** — pages that have sat with status=stub for a long time.

## 3. Report & fix
- **Report findings first**, as a per-item list (how many, which files).
- Fix once the user approves. For contradictions, don't arbitrarily delete one side — surface it via `## Contradictions / Caveats` instead.
- Log the result as a single `[LINT]` line in `wiki/log.md`.

## Principles
- Idempotent: if everything is clean, finish with "no issues found." Never touch raw/. Confirm with the user before any large structural change.
