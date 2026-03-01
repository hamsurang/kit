# Repo Structure & Documentation Renewal — Design

**Date:** 2026-03-01
**Status:** Approved
**Approach:** B — Audience-split docs with landing README

---

## Problem Statement

The hamkit repository mixes user-facing content (how to install/use plugins) and contributor-facing content (how to build/submit plugins) in the same files, making the first-time experience unclear for both audiences. Additionally, there are known information inconsistencies (a `ham-starter` plugin referenced in README that does not exist).

---

## Goals

- Serve **both** plugin users and plugin contributors equally well
- Fix all known information inconsistencies
- Improve onboarding so first-time visitors know immediately what to do
- Avoid over-engineering — no new features beyond what's needed now

---

## Directory Structure (After)

```
hamkit/
├── README.md                       # Landing page — two clear paths
├── README.ko.md                    # Korean mirror, same structure
├── docs/
│   ├── index.md                    # NEW: docs entry point / table of contents
│   ├── users/
│   │   └── getting-started.md      # NEW: install & use plugins
│   └── contributors/
│       ├── contributing.md         # MOVED from docs/CONTRIBUTING.md
│       ├── plugin-spec.md          # MOVED from docs/PLUGIN_SPEC.md
│       └── categories.md           # MOVED from docs/CATEGORIES.md
├── plugins/
│   └── vitest/                     # unchanged
└── scripts/
    └── scaffold-plugin.sh          # unchanged
```

---

## README Redesign

README becomes a minimal landing page:

1. **One-line project description**
2. **Two entry points** — "Using Plugins" and "Building Plugins" — immediately visible
3. **Available Plugins table** — only lists plugins that actually exist
4. **Links** — to deep docs, issues, license

No long explanations in README. All detail lives in `docs/`.

---

## New Files

### `docs/users/getting-started.md`
- How to install a plugin via `claude plugin install`
- What plugins are available (link to plugin table)
- How to get help (GitHub Issues link)

### `docs/index.md`
- Docs folder entry point
- Two-section table of contents: For Users / For Contributors

---

## Information Inconsistency Fixes

| Location | Issue | Fix |
|----------|-------|-----|
| `README.md` | References `ham-starter` plugin that doesn't exist | Remove the row |
| `README.ko.md` | Same `ham-starter` reference | Remove the row |
| `.claude-plugin/marketplace.json` | Already accurate (`vitest` only) | No change needed |

---

## Migration Map

| Old Path | New Path | Change |
|----------|----------|--------|
| `docs/CONTRIBUTING.md` | `docs/contributors/contributing.md` | Move only |
| `docs/PLUGIN_SPEC.md` | `docs/contributors/plugin-spec.md` | Move only |
| `docs/CATEGORIES.md` | `docs/contributors/categories.md` | Move only |

All internal cross-links within the moved files must be updated to reflect new paths.

---

## Out of Scope (YAGNI)

- Plugin catalog / search page (add when there are 10+ plugins)
- `marketplace.json` schema expansion (add when commands/agents are submitted)
- Docs site / static site generator
- Changelog or versioned docs

---

## Success Criteria

- [ ] First-time user can find install instructions within 2 clicks from README
- [ ] First-time contributor can find plugin spec within 2 clicks from README
- [ ] No broken links in any `.md` file
- [ ] No references to non-existent plugins
- [ ] README.ko.md in sync with README.md structure
