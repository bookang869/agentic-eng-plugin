---
name: wiki-ingest
description: Reads a raw source and integrates it into the agentic engineering second-brain wiki. Extracts entities, merge-updating existing pages or creating new ones, and handles cross-linking, contradiction marking, and index/log updates in one pass. Triggers on requests like "ingest", "put this in the wiki", "organize this into the wiki", "add a new source", "integrate raw", "update the second brain", "ingest ep0X". Use when accumulating knowledge into the wiki.
---

# wiki-ingest — Integrate a source into the wiki

## 0. Do this first
1. **Always read `WIKI_SCHEMA.md` at the repo root first.** All rules (folder structure · frontmatter · naming · citations · language=English) come from there.
2. Read `wiki/index.md` and any relevant existing pages to **understand the current state of the wiki**. This is the key step to avoid creating duplicates.

## 1. Determine the target
- If the user specifies a source (e.g. "ep02"), use only that. If unspecified, ask which raw sources haven't been ingested yet, or proceed with all of them.
- Read the target raw file carefully.

## 2. Extract entities
- Identify concepts/people/tools from the source. Reference the seed map in `WIKI_SCHEMA.md` §10, but also add anything not listed there.
- Check the index for whether each entity **already exists as a page**.

## 3. Write pages (merge-first)
- **If it exists:** **merge** consistently with existing content. Don't overwrite — add the new source's perspective under `## Perspective by Source`, add the ep number to the `sources` frontmatter, update `updated`, and bump `status` appropriately (stub→draft→solid).
- **If it doesn't exist:** create it fresh in the type-specific folder (`concepts/`·`people/`·`tools/`) using the `WIKI_SCHEMA.md` §4 template.
- Don't paste the transcript verbatim — **condense to the essentials** (in English).

## 4. Links and contradictions
- Link other entities mentioned in the body with `[[ ]]`. If a page doesn't exist yet, create a stub or leave just the link.
- Attach a `[[ep0X-...]]` source citation to every claim wherever possible.
- If sources conflict (e.g. the "5 pillars" differ in origin/composition between ep01 John Kim vs ep02 Karpathy), don't delete either — note it explicitly in that page's `## Contradictions / Caveats`.

## 5. Wrap-up (mandatory)
- Add new pages to `wiki/index.md` under the right category with a one-line summary, and update `updated`.
- Log a single `[INGEST]` line at the top of `wiki/log.md`: source, number of new/updated pages, contradictions flagged.
- Report a summary to the user: what was created/updated, and what contradictions were found.

## Principles
- Simplicity first. Mark speculation as "(inferred)". Never modify raw/.
