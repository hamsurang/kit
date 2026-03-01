# Repo Structure & Documentation Renewal — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure docs into users/contributors split, redesign README as a landing page, and fix all information inconsistencies.

**Architecture:** Move existing 3 docs files into `docs/contributors/`, create 2 new files (`docs/users/getting-started.md`, `docs/index.md`), rewrite README.md as a minimal landing page, sync README.ko.md, and update all cross-links.

**Tech Stack:** Markdown only. No build tools. Verification = checking links manually and with grep.

---

## Affected Files Overview

| Action | File |
|--------|------|
| MOVE + update links | `docs/CONTRIBUTING.md` → `docs/contributors/contributing.md` |
| MOVE + update links | `docs/PLUGIN_SPEC.md` → `docs/contributors/plugin-spec.md` |
| MOVE + update links | `docs/CATEGORIES.md` → `docs/contributors/categories.md` |
| CREATE | `docs/users/getting-started.md` |
| CREATE | `docs/index.md` |
| REWRITE | `README.md` |
| SYNC | `README.ko.md` |
| FIX link | `.github/ISSUE_TEMPLATE/plugin-submission.md` |
| FIX text | `scripts/scaffold-plugin.sh` |

---

### Task 1: Create directory structure

**Files:**
- Create: `docs/contributors/` (directory)
- Create: `docs/users/` (directory)

**Step 1: Create both directories**

```bash
mkdir -p docs/contributors docs/users
```

**Step 2: Verify**

```bash
ls docs/
```
Expected output includes: `contributors/  plans/  users/`

**Step 3: Commit**

```bash
git add docs/contributors/.gitkeep docs/users/.gitkeep 2>/dev/null || true
git add docs/
git commit -m "chore: create docs/contributors and docs/users directories"
```

---

### Task 2: Move CATEGORIES.md → docs/contributors/categories.md

**Files:**
- Delete: `docs/CATEGORIES.md`
- Create: `docs/contributors/categories.md`

Content is **identical** to current `docs/CATEGORIES.md` — only path changes.

**Step 1: Move the file**

```bash
mv docs/CATEGORIES.md docs/contributors/categories.md
```

**Step 2: Verify file exists**

```bash
ls docs/contributors/
```
Expected: `categories.md`

**Step 3: Commit**

```bash
git add docs/CATEGORIES.md docs/contributors/categories.md
git commit -m "docs: move CATEGORIES.md to docs/contributors/categories.md"
```

---

### Task 3: Move PLUGIN_SPEC.md → docs/contributors/plugin-spec.md and fix its internal link

**Files:**
- Delete: `docs/PLUGIN_SPEC.md`
- Create: `docs/contributors/plugin-spec.md`

**Step 1: Move the file**

```bash
mv docs/PLUGIN_SPEC.md docs/contributors/plugin-spec.md
```

**Step 2: Fix the internal link inside plugin-spec.md**

Find line 37 in `docs/contributors/plugin-spec.md`:
```
See [CATEGORIES.md](./CATEGORIES.md)
```
Change to:
```
See [CATEGORIES.md](./categories.md)
```

**Step 3: Verify the link**

```bash
grep "CATEGORIES" docs/contributors/plugin-spec.md
```
Expected: `See [CATEGORIES.md](./categories.md)`

**Step 4: Commit**

```bash
git add docs/PLUGIN_SPEC.md docs/contributors/plugin-spec.md
git commit -m "docs: move PLUGIN_SPEC.md to docs/contributors/plugin-spec.md, fix internal link"
```

---

### Task 4: Move CONTRIBUTING.md → docs/contributors/contributing.md and fix its internal links

**Files:**
- Delete: `docs/CONTRIBUTING.md`
- Create: `docs/contributors/contributing.md`

**Step 1: Move the file**

```bash
mv docs/CONTRIBUTING.md docs/contributors/contributing.md
```

**Step 2: Fix internal link inside contributing.md**

Find line 34 in `docs/contributors/contributing.md`:
```
Refer to [PLUGIN_SPEC.md](./PLUGIN_SPEC.md) for format details.
```
Change to:
```
Refer to [PLUGIN_SPEC.md](./plugin-spec.md) for format details.
```

Also find line 43:
```
- [ ] The plugin follows [PLUGIN_SPEC.md](../../docs/PLUGIN_SPEC.md)
```
Wait — this is actually in `.github/ISSUE_TEMPLATE/plugin-submission.md`, not here.
In `contributing.md` check if there are any other self-referencing links to old paths:

```bash
grep -n "PLUGIN_SPEC\|CATEGORIES\|CONTRIBUTING" docs/contributors/contributing.md
```
Fix any remaining references to old filenames.

**Step 3: Verify no broken old-path references**

```bash
grep "\.\/PLUGIN_SPEC\|\.\/CATEGORIES\|\.\/CONTRIBUTING" docs/contributors/contributing.md
```
Expected: no output (all fixed)

**Step 4: Commit**

```bash
git add docs/CONTRIBUTING.md docs/contributors/contributing.md
git commit -m "docs: move CONTRIBUTING.md to docs/contributors/contributing.md, fix internal links"
```

---

### Task 5: Create docs/users/getting-started.md

**Files:**
- Create: `docs/users/getting-started.md`

**Step 1: Create the file with this exact content**

```markdown
# Getting Started with hamkit

hamkit is a community plugin & skills marketplace for [Claude Code](https://claude.ai/code).

## Installing a Plugin

```bash
claude plugin install <plugin-name>@hamsurang/hamkit
```

Example:

```bash
claude plugin install vitest@hamsurang/hamkit
```

## Installing Skills Only (via npx)

```bash
# Install all hamkit skills
npx skills add hamsurang/hamkit

# Install a specific skill
npx skills add hamsurang/hamkit --skill vitest

# Preview available skills without installing
npx skills add hamsurang/hamkit --list
```

## Available Plugins

See the [plugin directory](../../README.md#plugin--skills-directory) in README for the full list.

## Getting Help

- Browse [GitHub Issues](https://github.com/hamsurang/hamkit/issues)
- Open a new issue if you encounter a bug or need help
```

**Step 2: Verify file exists**

```bash
ls docs/users/
```
Expected: `getting-started.md`

**Step 3: Commit**

```bash
git add docs/users/getting-started.md
git commit -m "docs: add docs/users/getting-started.md"
```

---

### Task 6: Create docs/index.md

**Files:**
- Create: `docs/index.md`

**Step 1: Create the file with this exact content**

```markdown
# hamkit Docs

## For Plugin Users

- [Getting Started](./users/getting-started.md) — How to install and use plugins

## For Plugin Contributors

- [Contributing Guide](./contributors/contributing.md) — How to submit a plugin
- [Plugin Spec](./contributors/plugin-spec.md) — Plugin format reference
- [Categories](./contributors/categories.md) — Category taxonomy
```

**Step 2: Verify**

```bash
cat docs/index.md
```

**Step 3: Commit**

```bash
git add docs/index.md
git commit -m "docs: add docs/index.md as entry point"
```

---

### Task 7: Rewrite README.md

**Files:**
- Modify: `README.md`

**Step 1: Replace the entire file with**

```markdown
# hamkit

> A community-driven plugin & skills marketplace for [Claude Code](https://claude.ai/code)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](docs/contributors/contributing.md)

[한국어](./README.ko.md)

---

## Using Plugins

Install a plugin from the marketplace:

```bash
claude plugin install <plugin-name>@hamsurang/hamkit
```

Or install individual skills:

```bash
npx skills add hamsurang/hamkit
```

→ [Full installation guide](docs/users/getting-started.md)

---

## Building Plugins

Scaffold a new plugin interactively:

```bash
git clone https://github.com/hamsurang/hamkit
cd hamkit
bash scripts/scaffold-plugin.sh
```

→ [Contributing guide](docs/contributors/contributing.md) · [Plugin spec](docs/contributors/plugin-spec.md)

---

## Plugin & Skills Directory

| Plugin | Category | Description | Author |
|--------|----------|-------------|--------|
| [vitest](./plugins/vitest) | code-quality | Auto-invoked skill for writing, debugging, and configuring Vitest tests | [hamsurang](https://github.com/hamsurang) |

*Have a plugin to share? See [Contributing](docs/contributors/contributing.md).*

---

## Security Notice

hamkit does not audit or sandbox plugins. Review any plugin — especially `.mcp.json` and shell commands — before installing. Only install from authors you trust.

## License

MIT — see [LICENSE](./LICENSE)
```

**Step 2: Verify ham-starter is gone**

```bash
grep "ham-starter" README.md
```
Expected: no output

**Step 3: Verify key links are present**

```bash
grep "docs/contributors/contributing" README.md
grep "docs/users/getting-started" README.md
```
Expected: both return a match

**Step 4: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README as landing page, remove ham-starter, update doc links"
```

---

### Task 8: Sync README.ko.md

**Files:**
- Modify: `README.ko.md`

**Step 1: Replace the entire file with the Korean equivalent**

Mirror the README.md structure exactly, translated to Korean. Key changes:
- Remove `ham-starter` row from plugin table (replace with `vitest` row)
- Update badge link: `docs/CONTRIBUTING.md` → `docs/contributors/contributing.md`
- Update Categories link: `docs/CATEGORIES.md` → `docs/contributors/categories.md`
- Update CONTRIBUTING link: `docs/CONTRIBUTING.md` → `docs/contributors/contributing.md`
- Match the same two-path (users / contributors) structure as README.md

```markdown
# hamkit

> [Claude Code](https://claude.ai/code)를 위한 커뮤니티 플러그인 & 스킬 마켓플레이스

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](docs/contributors/contributing.md)

[English](./README.md)

---

## 플러그인 사용하기

마켓플레이스에서 플러그인 설치:

```bash
claude plugin install <플러그인-이름>@hamsurang/hamkit
```

또는 개별 스킬 설치:

```bash
npx skills add hamsurang/hamkit
```

→ [전체 설치 가이드](docs/users/getting-started.md)

---

## 플러그인 만들기

대화형으로 새 플러그인 스캐폴딩:

```bash
git clone https://github.com/hamsurang/hamkit
cd hamkit
bash scripts/scaffold-plugin.sh
```

→ [기여 가이드](docs/contributors/contributing.md) · [플러그인 스펙](docs/contributors/plugin-spec.md)

---

## 플러그인 & 스킬 목록

| 플러그인 | 카테고리 | 설명 | 작성자 |
|---------|---------|------|--------|
| [vitest](./plugins/vitest) | code-quality | Vitest 테스트 작성·디버깅·설정을 위한 자동 활성화 스킬 | [hamsurang](https://github.com/hamsurang) |

*플러그인을 기여하고 싶으신가요? [기여 방법](docs/contributors/contributing.md)을 확인하세요.*

---

## 보안 안내

hamkit은 플러그인을 별도로 감사하거나 샌드박스 처리하지 않습니다. 특히 `.mcp.json`과 셸 커맨드가 포함된 플러그인은 설치 전 반드시 내용을 검토하세요. 신뢰할 수 있는 작성자의 플러그인만 설치하시기 바랍니다.

## 라이선스

MIT — [LICENSE](./LICENSE) 참고
```

**Step 2: Verify ham-starter is gone**

```bash
grep "ham-starter" README.ko.md
```
Expected: no output

**Step 3: Commit**

```bash
git add README.ko.md
git commit -m "docs: sync README.ko.md — remove ham-starter, update structure and links"
```

---

### Task 9: Fix .github/ISSUE_TEMPLATE/plugin-submission.md

**Files:**
- Modify: `.github/ISSUE_TEMPLATE/plugin-submission.md`

**Step 1: Find and fix the broken link**

Line 42 currently reads:
```
- [ ] The plugin follows [PLUGIN_SPEC.md](../../docs/PLUGIN_SPEC.md)
```

Change to:
```
- [ ] The plugin follows [PLUGIN_SPEC.md](../../docs/contributors/plugin-spec.md)
```

**Step 2: Verify**

```bash
grep "PLUGIN_SPEC\|plugin-spec" .github/ISSUE_TEMPLATE/plugin-submission.md
```
Expected: `../../docs/contributors/plugin-spec.md`

**Step 3: Commit**

```bash
git add .github/ISSUE_TEMPLATE/plugin-submission.md
git commit -m "fix: update plugin-submission template link to new plugin-spec path"
```

---

### Task 10: Fix scripts/scaffold-plugin.sh output text

**Files:**
- Modify: `scripts/scaffold-plugin.sh`

**Step 1: Find the lines to change**

```bash
grep -n "CONTRIBUTING\|PLUGIN_SPEC" scripts/scaffold-plugin.sh
```
Expected: lines near the bottom with info output text.

**Step 2: Update the two info lines**

Find:
```bash
info "  Contribution guide: docs/CONTRIBUTING.md"
info "  Plugin spec:        docs/PLUGIN_SPEC.md"
```

Change to:
```bash
info "  Contribution guide: docs/contributors/contributing.md"
info "  Plugin spec:        docs/contributors/plugin-spec.md"
```

**Step 3: Verify**

```bash
grep "CONTRIBUTING\|PLUGIN_SPEC" scripts/scaffold-plugin.sh
```
Expected: no output (old paths gone)

```bash
grep "contributing\|plugin-spec" scripts/scaffold-plugin.sh
```
Expected: shows the new paths

**Step 4: Commit**

```bash
git add scripts/scaffold-plugin.sh
git commit -m "fix: update scaffold-plugin.sh output text to new doc paths"
```

---

### Task 11: Final verification — no broken old paths remain

**Step 1: Check no file references old doc paths**

```bash
grep -r "docs/CONTRIBUTING\|docs/PLUGIN_SPEC\|docs/CATEGORIES" --include="*.md" --include="*.sh" --include="*.js" --include="*.json" --include="*.yml" .
```
Expected: **no output** (all old paths replaced)

**Step 2: Check no ham-starter references remain**

```bash
grep -r "ham-starter" --include="*.md" .
```
Expected: **no output**

**Step 3: Check all new paths exist**

```bash
ls docs/contributors/
ls docs/users/
ls docs/index.md
```
Expected:
- `contributors/`: `categories.md  contributing.md  plugin-spec.md`
- `users/`: `getting-started.md`
- `docs/index.md` exists

**Step 4: Final commit if any cleanup needed, otherwise done**

```bash
git log --oneline -12
```
Review all commits in this task. If everything looks clean, you're done.
