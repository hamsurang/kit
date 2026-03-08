# Output Template

Use this template to assemble the final analysis report.
Replace placeholders with agent results.

---

```markdown
---
library: {library_name}
repo: {owner/repo}
analyzed: {YYYY-MM-DD}
source: {url | local}
sections_completed: {N}/3
---

# {Library Name} Contribution Analysis

> Analyzed on {YYYY-MM-DD} via {source} mode.

{codebase-agent output: sections 1, 2, 3}

{lifecycle-agent output: sections 4, 5}

{contribution-agent output: sections 6, 7, 8}
```

---

## Section Failure Placeholder

If an agent failed, insert this in place of its sections:

```markdown
> ⚠️ This section could not be analyzed. Re-run the analysis or inspect manually.
```
