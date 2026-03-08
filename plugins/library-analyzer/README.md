# Library Analyzer

Analyze open-source libraries for contribution readiness. Get a structured report covering codebase structure, lifecycle, issues, and recommended first contributions.

## Installation

Install via hamkit:

```bash
hamkit install library-analyzer
```

## Usage

### Slash Command

```bash
/library-analyzer:analyze facebook/react
/library-analyzer:analyze /path/to/local/repo
```

### Auto-Activation

The skill activates automatically when you mention contribution intent:

- "I want to contribute to facebook/react"
- "Analyze this library for contribution"
- "Help me contribute to tokio-rs/tokio"

## How It Works

1. **Input parsing** — accepts GitHub URL, `owner/repo` shorthand, or local path
2. **Data collection** — uses `deepwiki-cli` (URL mode) or static file analysis (local mode)
3. **Issue collection** — fetches open issues via `gh` CLI (good-first-issue, help-wanted, recent)
4. **Parallel analysis** — 3 specialized agents analyze simultaneously:
   - **codebase-agent**: directory structure, modules, domain keywords
   - **lifecycle-agent**: runtime flow, extension points
   - **contribution-agent**: contribution guide, issue landscape, first contribution recommendations
5. **Report generation** — assembles results into `docs/library-analysis/<name>-<date>.md`

## Output

The generated report includes 8 sections:

1. Directory Structure
2. Module Architecture
3. Key Concepts
4. Lifecycle
5. Extension Points
6. How to Contribute
7. Issue Landscape
8. Recommended First Contributions

## Prerequisites

- **deepwiki-cli** (required for URL mode): `cargo install deepwiki-cli`
- **gh CLI** (optional, for issue collection): `brew install gh && gh auth login`

If `deepwiki-cli` is not installed, clone the repo and use local mode instead.

## Examples

```bash
# Analyze a popular library
/library-analyzer:analyze facebook/react

# Analyze a Rust project
/library-analyzer:analyze tokio-rs/tokio

# Analyze a local clone
/library-analyzer:analyze ./my-local-repo
```
