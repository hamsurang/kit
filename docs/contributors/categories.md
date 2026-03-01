# Plugin Categories

hamkit organizes plugins into 10 categories. Choose the category that best describes your plugin's primary purpose.

## Category Reference

### `productivity`
**Workflow automation, time-saving commands**

Tools that help developers work faster by automating repetitive tasks, organizing workflows, or providing shortcuts.

*Examples:* task runners, clipboard managers, snippet inserters, project scaffolders

---

### `git`
**Version control, commit, PR, and branch management**

Plugins focused on Git workflows — from commit message generation to PR review automation.

*Examples:* conventional commit helpers, PR description generators, branch cleanup tools, git log analyzers

---

### `code-quality`
**Linting, review, refactoring, testing aids**

Tools that help maintain high code quality through automated review, refactoring suggestions, and testing support.

*Examples:* code reviewers, complexity analyzers, refactoring assistants, test generators

---

### `documentation`
**Docs generation, README helpers, comment writers**

Plugins that assist with creating and maintaining documentation, README files, inline comments, and API docs.

*Examples:* JSDoc generators, README templates, changelog writers, API documentation tools

---

### `ai-agents`
**Multi-agent orchestration and agent definitions**

Plugins providing specialized AI agent definitions, orchestration patterns, or multi-agent workflows for Claude Code.

*Examples:* custom agent definitions, orchestration frameworks, specialized reasoning agents

---

### `integrations`
**Third-party service and API connectors (via MCP)**

Plugins that connect Claude Code to external services and APIs via the Model Context Protocol (MCP).

*Examples:* GitHub connector, Jira integration, Slack messenger, database query tools

---

### `learning`
**Tutorials, onboarding, knowledge transfer**

Plugins designed to teach, onboard, or help users understand codebases, technologies, or workflows.

*Examples:* codebase explainers, language tutors, onboarding guides, documentation walkthroughs

---

### `security`
**Security review, secrets scanning, audit tools**

Tools focused on identifying security vulnerabilities, scanning for exposed secrets, and auditing code safety.

*Examples:* OWASP scanners, secrets detectors, dependency auditors, permission analyzers

---

### `devops`
**CI/CD, deployment, infrastructure tooling**

Plugins that assist with continuous integration, deployment pipelines, and infrastructure management.

*Examples:* deployment assistants, CI config generators, Dockerfile writers, Kubernetes helpers

---

### `data`
**Data analysis, transformation, visualization**

Tools for working with data — querying, transforming, analyzing, and visualizing datasets.

*Examples:* SQL query builders, CSV analyzers, data pipeline helpers, chart generators

---

## Choosing a Category

- Pick the **single best category** — plugins should have one primary category
- If your plugin fits multiple categories, pick the most prominent one
- Use `keywords` in `plugin.json` for secondary topics (see [plugin-spec.md](./plugin-spec.md))
- When in doubt, use `productivity`
