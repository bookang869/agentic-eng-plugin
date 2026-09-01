---
description: Spec-driven, phased implementation workflow — explore project docs, discuss open questions, design self-contained steps, generate phases/step files, then execute via a self-correcting agent loop
---

Run the **harness** skill (author mode) bundled with this plugin via the Skill tool.
Read `CLAUDE.md`, `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/ADR.md` at the project root first (scaffold from the skill's templates if any are missing, and tell the user which placeholders to fill in). Then follow the skill's Explore → Discuss → Step design → File creation → Execute workflow.

Task or phase name (e.g. `0-mvp`, or a feature description to plan): $ARGUMENTS

If no arguments are given, ask the user what feature or phase they want to plan before proceeding.
