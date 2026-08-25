---
description: Audits a repo against the AI-Ready v2 rubric (100 pts · 7 categories) and produces an HTML dashboard plus an ROI action list
---

Run the **ai-readiness-cartography** skill bundled with this plugin via the Skill tool.
Follow the skill's workflow exactly: `scripts/score.py` auto-scoring → copy `assets/template.html` and fill it in → open in browser → report a summary of total score/grade/Top ROI.

Options such as target repo path / output path: $ARGUMENTS

If no arguments are given, audit the current working directory.
