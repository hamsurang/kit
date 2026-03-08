---
title: "refactor: Skill Quality Improvements P1-P8"
type: refactor
status: completed
date: 2026-03-08
deepened: 2026-03-08
---

# Skill Quality Improvements P1-P8

## Overview

skill-creator eval 기반 전체 스킬 리뷰 결과, 7개 플러그인에서 총 5개 errors와 35개 warnings를 발견했다. 2개 플러그인(obsidian, deepwiki-cli)이 FAIL 판정을 받아 publish가 차단된 상태이며, 나머지 5개는 NEEDS WORK 상태다.

| 플러그인 | 판정 | Errors | Warnings | 목표 잔여 Warnings |
|---------|------|--------|----------|-------------------|
| obsidian | FAIL | 4 | 7 | ≤2 |
| deepwiki-cli | FAIL | 1 | 4 | ≤1 |
| gh-cli | NEEDS WORK | 0 | 9 | ≤2 |
| personal-tutor | NEEDS WORK | 0 | 5 | ≤2 |
| library-analyzer | NEEDS WORK | 0 | 4 | ≤1 |
| skill-review | NEEDS WORK | 0 | 3 | ≤1 |
| vitest | NEEDS WORK | 0 | 3 | 3 (변경 없음) |
| **합계** | | **5** | **35** | **≤12** |

---

## Execution Strategy

skill-review checklist 수정 → 7개 플러그인 CP0 pre-flight → 나머지 5개 플러그인 병렬 수정 → 최종 re-review.

1. **skill-review** checklist 먼저 수정 (새 체크 항목이 re-review 기준이 됨)
2. **CP0**: 새 체크 항목(YAML 유효성, 깨진 참조)으로 7개 전부 pre-flight 검증 — 예상치 못한 새 ERROR 조기 발견
3. deepwiki-cli, obsidian, personal-tutor, library-analyzer, gh-cli **병렬** 수정
4. 최종 re-review로 전체 검증

**브랜칭**: 플러그인별 1커밋, 단일 PR. gh-cli 재구성이 문제되면 해당 커밋만 선택적 revert 가능.

**Re-fix 루프**: re-review 실패 시 최대 2회 재수정. 2회 후에도 실패하면 해당 플러그인만 분리하여 별도 PR로 처리. 통과한 플러그인은 먼저 머지 가능.

---

## Fix Instructions

### 0. skill-review (선행 — 반드시 먼저)

**파일:** `plugins/skill-review/skills/skill-review/references/checklist.md`

체크리스트에 누락 항목 추가:
- 섹션 1 (Frontmatter) 첫 항목: `YAML frontmatter is valid YAML syntax (parses without error, no duplicate keys, correct indentation)` (❌ Error)
- 섹션 5 (Progressive Disclosure): `All files linked from SKILL.md via markdown links or explicit Read instructions exist at the referenced path` (❌ Error)
- 섹션 3 (Naming) 헤더 아래에 blockquote 주석 추가:
  ```markdown
  > **Exception:** Tool-wrapper skills (e.g., vitest, gh-cli) may use the tool name directly. This is an accepted convention and not counted as a warning.
  ```

Scoring guide는 **변경하지 않는다** (0 errors + 0 warnings = PASS, 1+ warnings = NEEDS WORK 유지). 대신 tool-wrapper naming 예외를 체크리스트에 명시하여, vitest/gh-cli의 naming warning이 리뷰 시 skip 가능하도록 한다.

### 1. deepwiki-cli (FAIL 해제)

**파일:** `plugins/deepwiki-cli/skills/deepwiki-cli/SKILL.md`, `plugins/deepwiki-cli/.claude-plugin/plugin.json`

**(a) P1: description "Use when..." 형식으로 변경** (ERROR 해결)
```yaml
description: >
  Use when the user asks questions about a GitHub repository's architecture,
  API, or internals, or mentions deepwiki-cli or DeepWiki. Activates when
  the user needs to understand a codebase they haven't cloned locally, or
  asks how a library or framework works. Do NOT activate for local codebases
  already accessible on disk or private repositories.
```
검증: ~370자 (≤500 PASS). "deepwiki-cli" 도구명을 트리거 키워드로 유지. "in owner/repo format"은 본문으로 이동 (description은 트리거 조건만).

**(b) P5: "When NOT to Use" + Error Handling 섹션 추가**
- When NOT to Use: 이미 clone된 로컬 repo, private repo, 자신의 코드
- Error Handling: repo 존재 확인 → `structure` 먼저 시도 → fallback to web search

**(c) plugin.json author 오타 수정**
- `"github": "minsoo.web"` → `"github": "minsoo-web"`
- `"name": "minsoo.web"` — 표시 이름으로 의도된 것인지 확인 후 결정. GitHub username에 dot은 유효하지만, 다른 모든 플러그인의 author.name이 "minsoo.web"이고 github만 "minsoo-web"인 점을 고려하면 name은 유지, github만 수정이 적절.

### 2. obsidian (FAIL 해제)

**파일:** `plugins/obsidian/skills/obsidian/SKILL.md`, `plugins/obsidian/skills/obsidian/references/commands.md`

**(a) P2: frontmatter 정리** (ERROR 해결)
- `metadata.openclaw` 블록 전체 삭제 → `name`과 `description`만 남김
- 설치 정보는 본문 Prerequisites 섹션에 1-2줄로 이동

**(b) P1 + P3: description 재작성** (ERROR 해결)
- 현재 873자(실측) → 500자 이하. "Use when..." 형식으로 변경
```yaml
description: >
  Use when the user mentions Obsidian, vault, daily notes, wikilinks,
  frontmatter, backlinks, graph view, PKM, Zettelkasten, or obsidian-cli.
  Activates for searching, creating, editing, moving notes in an Obsidian
  vault, managing YAML frontmatter, or syncing vaults via Obsidian Headless
  (ob CLI). Also trigger on Korean phrases like "내 노트에서 찾아줘" or
  "vault 동기화". Do NOT trigger for generic Markdown editing (README, docs)
  or other note apps (Notion, Bear).
```
검증: ~474자 (≤500 PASS). 기존 대비 변경: "graph view" 복원 (Obsidian 고유 용어), "ob CLI" → "Obsidian Headless (ob CLI)" 명확화, "Trigger for" → "Activates for" (3인칭 일관성).

**(c) P5: 에러 핸들링 추가**
- `obsidian-cli` 미설치 시 fallback (Glob/Read/Write로 직접 파일 조작)
- OS별 Obsidian config 경로 (macOS / Linux / Windows)
- "When NOT to Use" 섹션 추가 (deepwiki-cli, library-analyzer와 일관성): generic Markdown editing, non-Obsidian note apps

**(d) P6: 시간 민감 정보 제거**
- `references/commands.md`에서 "Version: 0.2.3", "Version: 0.0.6 (open beta)" 제거

**(e) P7: `## Contents` ToC 추가** (최종 SKILL.md가 100줄 초과 시에만)

**(f) Headless 섹션 정리**
- `references/commands.md`에 이미 headless 커맨드 레퍼런스 존재 (lines 168-268)
- SKILL.md의 inline headless 섹션(~55줄) 삭제, `references/commands.md`의 기존 섹션으로 참조 통합
- 별도 `references/headless.md` 생성 불필요 (중복 방지)
- SKILL.md에 한 줄 참조: "For headless sync (CI/servers), see the Headless section in `references/commands.md`."

**(g) lazy loading 테이블 추가**
```markdown
| Situation | Load |
|-----------|------|
| CLI 명령어 상세 옵션, headless 사용법 | `references/commands.md` |
```
참고: `references/workflows.md`는 존재하지 않으므로 테이블에서 제외. 현재 obsidian references는 `commands.md` 1개뿐.

### 3. gh-cli (구조 재편 — 가장 복잡)

**파일:** `plugins/gh-cli/skills/gh-cli/SKILL.md`

**(a) P3: description 500자 이하로 축소**
- 현재 583자(실측) → 500자 이하. 중복 문장 제거 + "Do NOT" 부정 경계 추가.
```yaml
description: >
  Use when working with GitHub from the command line using the gh CLI tool.
  Trigger on "create PR", "open pull request", "list issues", "check CI",
  "merge PR", "review PR", "create issue", "release", "gh auth", "clone repo",
  "fork repo", "close issue", "view workflow run", or any GitHub operation
  from the terminal. Do NOT trigger for GitHub web UI actions or direct REST
  API calls without gh.
```
검증: ~487자 (≤500 PASS). 기존 대비 변경: 중복 3번째 문장 삭제 ("Always use this skill..."), "Do NOT" 부정 경계 추가, "fork repo"/"close issue"/"view workflow run" 트리거 복원.

**(b) P4: cheat sheet → 행동 가이드 전환**
- 현재 299줄 → 목표 80-150줄
- 구조: `## Contents` → `## Behavior Guidelines` (3-5개) → `## Core Workflows` (PR/CI/Issue, 각 10-15줄) → `## JSON Scripting Patterns` (2-3개) → `## Reference Loading Guide` (vitest 스타일 테이블)
- inline 명령어 카탈로그(~200줄)를 기존 3개 reference 파일에 도메인별 분배 (새 `commands.md` 생성 대신 기존 `prs-issues.md`, `repos-actions.md`, `auth-search-api.md` 활용)
- Quick Start 설치/인증 명령은 `references/auth-search-api.md`에 보존. Quick Aliases 섹션은 완전 제거.
- Common Troubleshooting 테이블(8줄)은 본문에 유지 (에러 대응에 유용, 컴팩트)
- **재구성 시 low-freedom 유지**: gh-cli는 정확한 명령어 템플릿이 필요한 도메인. 행동 가이드 전환 후에도 Core Workflows 내에 구체적 명령어 예시를 반드시 포함.

**(c) P6: 버전 번호 제거** — "2.85.0+" 삭제

**(d) P7: `## Contents` ToC 추가**

**(e) P8: vitest 스타일 lazy loading 테이블**
```markdown
| Situation | Load |
|-----------|------|
| PR 생성/리뷰/머지 상세 옵션 | `references/prs-issues.md` |
| Repo/Actions/Workflow 관리 | `references/repos-actions.md` |
| 인증/검색/API 호출 | `references/auth-search-api.md` |
```

**(f) 재구성 검증**: 수정 전/후 skill-review re-review로 warning 수 비교. re-review에서 기존보다 나빠지면 해당 커밋 revert.

### 4. personal-tutor

**파일:** `plugins/personal-tutor/skills/personal-tutor/SKILL.md`

**(신규) description 개선** — 현재 141자로 지나치게 모호. 도메인 경계와 부정 트리거 추가:
```yaml
description: >
  Use when the user wants to learn a technical topic through structured,
  multi-session tutoring with prerequisite tracking and knowledge graphs.
  Activates on "I want to learn X", "teach me X", "let's study X", or
  resuming a previous learning session. Do NOT activate for quick reference
  lookups or one-off coding questions — only for sustained learning goals.
```
검증: ~340자 (≤500 PASS). "structured, multi-session tutoring"으로 quick lookup과 구분. "Do NOT" 부정 경계 추가.

- **P8**: Phase 1에 lazy loading 지시 추가 — `Read knowledge-graph-template.md only when creating a new knowledge graph (first session for a topic).`
- topic 이름 정규화 규칙 추가 (Session Start에 배치)
- knowledge graph 노드 상한 10-15개 (Phase 1에 배치)
- quiz 실패 시 상태 전이 명시 (Phase 5 Upgrade rules, "## Phase 5: Archive" line 72 이후에 배치)
- Early Session Exit 섹션 추가 (Iron Rules 앞에 배치)

> 참고: `knowledge-graph-template.md`가 `references/` 밖(SKILL.md 형제 위치)에 있음. 관례상 `references/`에 넣는 것이 좋으나, 이번 수정 범위에서는 이동하지 않음 (별도 이슈로 분리).

### 5. library-analyzer

**파일:** `plugins/library-analyzer/skills/library-analyzer/SKILL.md`

- **P5**: Step 2 (line 70)에 context 크기 제한 명시 (readme 500줄, file_tree 300항목, wiki_content 800줄, 총 15,000자)
- **P8**: Step 4 (line 189)에 `Read references/output-template.md at this point for the report template.` 추가
- URL mode context bundle 매핑 규칙 추가 (deepwiki-cli output → context bundle 필드 매핑)

### 6. vitest (변경 없음)

변경하지 않는다. 3개 warning은 모두 naming convention 관련:
- 체크리스트 §3.1: skill name이 gerund 형식이 아님 ("vitest" vs "testing-with-vitest")
- 체크리스트 §3.2: 이름이 tool명 그대로
- 체크리스트 §3.3: action이 아닌 domain 반영

이는 tool-wrapper 스킬의 관례적 예외이며, skill-review checklist §3에 예외 주석을 추가하여 문서화한다.

### 7. plugin-spec.md 동기화 (추가 작업)

**파일:** `docs/contributors/plugin-spec.md`

`"This skill should be used when..."` → `"Use when..."` 으로 변경. **2곳** 존재:
- line 118 (description 필드 설명 예시)
- line 132 (code-explainer 예시)

둘 다 수정하여 실제 관행과 일치시킨다. 이를 하지 않으면 새 기여자가 spec을 따라 잘못된 형식을 사용하게 된다.

---

## Done When

### FAIL 해제 (필수)
- [ ] obsidian: frontmatter에 `name`과 `description`만 존재, 총 길이 ≤ 1024자
- [ ] obsidian: description "Use when..."으로 시작, ≤ 500자 (`wc -c` 검증)
- [ ] obsidian: SKILL.md 본문 ≤ 230줄 (headless ~55줄 분리 + 에러핸들링 추가 감안)
- [ ] obsidian: 에러 핸들링/fallback 섹션 + "When NOT to Use" 섹션 존재, OS별 경로 포함
- [ ] obsidian: `references/commands.md`에서 버전 번호 제거됨
- [ ] obsidian: lazy loading 테이블 존재
- [ ] deepwiki-cli: description "Use when..."으로 시작, "deepwiki-cli" 트리거 키워드 포함
- [ ] deepwiki-cli: plugin.json `author.github` = "minsoo-web"
- [ ] deepwiki-cli: "When NOT to Use" + Error Handling 섹션 존재

### 품질 향상
- [ ] gh-cli: description ≤ 500자, "Do NOT" 부정 경계 포함
- [ ] gh-cli: 행동 가이드 형식으로 재구성, SKILL.md 80-150줄, low-freedom 명령어 예시 유지
- [ ] gh-cli: "2.85.0+" 제거, ToC 존재, lazy loading 테이블 존재 (3개 기존 reference 파일 매핑)
- [ ] personal-tutor: description ≥ 300자로 확장, "Do NOT" 부정 경계 포함
- [ ] personal-tutor: topic 정규화, 노드 상한, quiz 실패 전이, lazy loading 지시, Early Session Exit 존재
- [ ] library-analyzer: URL mode 매핑 규칙, output-template lazy loading, context 크기 제한 존재
- [ ] skill-review: YAML 유효성 + 깨진 참조 체크 항목 존재, tool-wrapper 예외 blockquote로 문서화
- [ ] plugin-spec.md: 2곳 모두 "Use when..." 형식으로 업데이트됨

### Success Metrics
- FAIL 플러그인: 2 → 0
- 전체 Error: 5 → 0
- 전체 Warning: 35 → ≤12 (66% 감소)

### 검증 흐름
1. **CP0** (skill-review 수정 직후): 새 체크 항목으로 7개 전부 pre-flight → 예상치 못한 새 ERROR 없음 확인
2. **CP1** (각 플러그인 수정 직후): description 길이(`wc -c`), frontmatter 유효성, 참조 파일 존재 개별 확인
3. **CP2** (전체 완료 후): 업데이트된 checklist로 7개 전부 re-review 실행, success metrics 확인

---

## Risks

- **gh-cli 재구성**: 가장 높은 리스크. 수정 전/후 skill-review로 warning 수 비교, 악화 시 revert. 별도 A/B eval 인프라는 불필요.
- **obsidian 한국어 트리거 감소**: 핵심 2~3개만 선별 유지. "graph view" 등 Obsidian 고유 용어는 복원하여 활성화 정확도 유지.
- **새 체크리스트 항목의 부작용**: CP0 pre-flight로 조기 발견. vitest YAML은 유효하고 references 4개 파일 모두 존재 확인됨.
- **deepwiki-cli author.name**: `"minsoo.web"`은 표시 이름으로 유효할 수 있음 — `author.github`만 확실히 수정, `author.name`은 구현 시 확인 후 결정.

## Sources

- 리뷰 체크리스트: `plugins/skill-review/skills/skill-review/references/checklist.md`
- 플러그인 스펙: `docs/contributors/plugin-spec.md`
- skill 작성 가이드: `compound-engineering:create-agent-skills` skill
- 기술 리뷰: architecture-strategist, code-simplicity-reviewer, critic, specflow-analyzer
- deepen 리서치: create-agent-skills 검증, 파일 상태 검증, description 최적화 분석
