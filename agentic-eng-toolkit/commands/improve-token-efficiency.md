---
description: Parses Claude Code session JSONL logs into a token/cost efficiency HTML dashboard with savings recommendations
---

Run the **improve-token-efficiency** skill bundled with this plugin via the Skill tool.
Follow the skill's workflow exactly: `scripts/analyze_sessions.py` to parse and score sessions → `scripts/build_dashboard.py` to render the HTML dashboard → open it → report a summary of total cost/tokens/cache hit ratio/grade and the top improvements.

Options such as target repo path / output path: $ARGUMENTS

If no arguments are given, analyze the current working directory's sessions.
