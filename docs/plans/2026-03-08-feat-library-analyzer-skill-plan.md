---
title: "feat: Add library-analyzer skill for open-source contribution"
type: feat
status: completed
date: 2026-03-08
deepened: 2026-03-08
origin: docs/brainstorms/2026-03-08-library-analyzer-skill-brainstorm.md
---

# feat: Add Library Analyzer Skill

## Enhancement Summary

**Deepened on:** 2026-03-08
**Research agents used:** create-agent-skills, agent-native-architecture, architecture-strategist, pattern-recognition-specialist, code-simplicity-reviewer, best-practices-researcher

### Key Improvements from Deepening

1. **6개 에이전트 → 3개로 단순화** — structure/modules/keywords는 경계가 겹침. codebase-agent, lifecycle-agent, contribution-agent 3개로 통합 (code-simplicity-reviewer)
2. **플러그인 이름 변경** — `analyze-library` → `library-analyzer` (noun-form, 레포 네이밍 컨벤션 일치) (pattern-recognition)
3. **WebSearch 폴백 제거 (v1)** — deepwiki-cli 필수. 없으면 로컬 모드 안내. 품질 보장 (code-simplicity-reviewer)
4. **커스텀 출력 경로 제거** — YAGNI. 고정 경로 사용 (code-simplicity-reviewer)
5. **SKILL.md 500줄 제한 준수** — 에이전트 프롬프트를 `references/agent-prompts.md`로 분리 (create-agent-skills, best-practices-researcher)
6. **Task tool 호출 방식 명확화** — 한 턴에 3개 Task 동시 호출, `run_in_background: false` (agent-native-architecture)
7. **gh issue list를 오케스트레이터에서 수집** — 이슈 데이터를 inline으로 contribution-agent에 전달 (agent-native-architecture)
8. **이슈 분류 단순화** — 3축 분류 제거. 라벨 기반 필터 + 최근 활동 정렬 (code-simplicity-reviewer)
9. **context bundle 스키마 정의** — 데이터 수집 → 에이전트 간 데이터 계약 명확화 (architecture-strategist)
10. **`allowed-tools` frontmatter 추가** — 권한 프롬프트 방지 (create-agent-skills)

### Decisions Changed from Brainstorm

| 브레인스토밍 결정 | 변경 | 근거 |
|----------------|------|------|
| 6개 병렬 에이전트 | → 3개 | 경계 겹침, v1 단순성, fan-out 패턴 검증에 3개면 충분 |
| WebSearch 폴백 | → v1에서 제거 | 두 번째 데이터 파이프라인은 복잡도 2배. 로컬 모드가 대안 |
| 커스텀 출력 경로 | → 제거 | 프롬프트 파싱 복잡도 증가, 사용자가 직접 이동 가능 |
| 3축 이슈 분류 | → 라벨 기반만 | LLM 추론 분류는 신뢰도 낮음. 라벨 필터가 결정적 |

---

## Overview

오픈소스 라이브러리에 기여하고자 하는 사용자를 위한 Claude Code 스킬. `/library-analyzer:analyze` 실행 시 GitHub URL 또는 로컬 경로를 입력받아, **3개 병렬 서브 에이전트**로 라이브러리를 분석하고 구조화된 Markdown 보고서를 생성한다.

이 레포에서 **병렬 서브 에이전트 팬아웃 패턴을 사용하는 최초의 스킬**이다.

## Problem Statement / Motivation

오픈소스에 기여하려면 라이브러리의 구조, 모듈, 라이프사이클, 기여 방법, 이슈 현황, 도메인 키워드를 파악해야 한다. 이를 수동으로 하면 시간이 많이 걸리고, 핵심을 놓치기 쉽다. 자동화된 분석 스킬로 기여 진입 장벽을 낮춘다.

## Proposed Solution

### 입력 전략 (see brainstorm: Key Decisions)

```
사용자 → /library-analyzer:analyze <target>
       │
       ├─ 입력 파싱
       │   ├─ https://github.com/owner/repo → URL 모드
       │   ├─ owner/repo (shorthand) → URL 모드
       │   ├─ /path/to/dir 또는 ./path → 로컬 모드
       │   └─ bare name (react) → 거부 + owner/repo 안내
       │
       ├─ 입력 검증
       │   ├─ URL 모드: deepwiki-cli 없으면 → 설치 안내 또는 로컬 모드 제안
       │   └─ 로컬 모드: 경로 존재 + 디렉토리 확인
       │
       ├─ 데이터 수집 → context bundle 생성
       │   ├─ URL: deepwiki-cli read/structure + gh issue list
       │   └─ 로컬: Glob/Read + gh issue list (GitHub remote 있으면)
       │
       └─ 분석 (3개 병렬 Task) → 결과 조립 → 파일 저장
```

### 실행 전략: 병렬 팬아웃 (see brainstorm: Approach B, simplified)

```
context bundle 준비 완료
       │
       ├─ Task 1: codebase-agent   (구조 + 모듈 + 키워드)
       ├─ Task 2: lifecycle-agent   (라이프사이클 + 확장 포인트)
       └─ Task 3: contribution-agent (기여 방법 + 이슈 분류 + 첫 기여 추천)
       │
       ▼
오케스트레이터: 결과 수집 → 품질 체크 → Markdown 조립 → 파일 저장
```

### 에이전트 통합 근거 (from code-simplicity-reviewer)

| 기존 6개 | → 통합 3개 | 이유 |
|---------|----------|------|
| structure + modules + keywords | **codebase-agent** | 동일한 입력 데이터(파일 트리, README) 분석. 경계 겹침. |
| lifecycle | **lifecycle-agent** | 독립적 관심사 (런타임 흐름 추적) |
| contribution + issues | **contribution-agent** | "어떻게 기여할까?"라는 단일 질문에 답함. 교차 종합 불필요. |

### 출력 (see brainstorm: Key Decisions)

```
docs/library-analysis/<library-name>-<YYYY-MM-DD>.md
```

## Technical Considerations

### 플러그인 디렉토리 구조

기존 플러그인 패턴을 따르되, `references/`로 프롬프트 분리 (see `docs/contributors/plugin-spec.md`):

```
plugins/library-analyzer/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── library-analyzer/
│       ├── SKILL.md                    # 오케스트레이션 흐름 (~300줄, 500줄 제한 준수)
│       └── references/
│           ├── agent-prompts.md        # 3개 에이전트 프롬프트 템플릿
│           └── output-template.md      # 출력 Markdown 템플릿
├── commands/
│   └── analyze.md                      # /library-analyzer:analyze (thin wrapper)
└── README.md
```

### Research Insights

**Progressive disclosure (from create-agent-skills):**
SKILL.md에 모든 에이전트 프롬프트를 인라인하면 500줄을 초과한다. `references/`에 분리하면 SKILL.md는 오케스트레이션 흐름만 담고, 에이전트 프롬프트는 필요 시 로드한다. 이는 `vitest`, `gh-cli`, `skill-review` 플러그인이 사용하는 패턴과 동일하다.

**Naming convention (from pattern-recognition):**
레포의 모든 플러그인이 noun-form 이름을 사용한다 (`personal-tutor`, `skill-review`, `deepwiki-cli`). `analyze-library`(verb-noun)에서 `library-analyzer`(noun-form)로 변경하여 일관성을 유지한다.

### Context Bundle 스키마 (from architecture-strategist)

데이터 수집 완료 후 에이전트에 전달할 정규화된 데이터 구조:

```
context_bundle = {
  metadata: {
    owner_repo: "facebook/react",
    source_mode: "url" | "local",
    library_name: "react"
  },
  readme: "<README.md 내용>",
  contributing: "<CONTRIBUTING.md 내용 또는 null>",
  file_tree: "<상위 3레벨 디렉토리 구조>",
  package_manifest: "<package.json/Cargo.toml/pyproject.toml 등>",
  ci_config: "<GitHub Actions 워크플로우 요약 또는 null>",
  issues: "<gh issue list JSON 결과 또는 null>"
}
```

**대형 레포 대응 (from architecture-strategist):**
- 파일 트리 500개 항목 초과 시 → 상위 2레벨만 포함
- README 2000줄 초과 시 → 첫 500줄만 포함
- 각 에이전트 프롬프트에 context bundle의 관련 부분만 인라인 전달

### 이슈 수집 전략 (see brainstorm: Open Questions, simplified)

오케스트레이터가 데이터 수집 단계에서 `gh` CLI로 이슈를 미리 수집하여 contribution-agent에 inline 전달:

```bash
# 1. Good first issues (최대 20개)
gh issue list --repo owner/repo --label "good first issue" --state open \
  --json number,title,createdAt,updatedAt,comments --limit 20

# 2. Help wanted (최대 15개)
gh issue list --repo owner/repo --label "help wanted" --state open \
  --json number,title,createdAt,updatedAt,comments --limit 15

# 3. 최근 활동 이슈 (최대 30개, 중복 제거용)
gh issue list --repo owner/repo --sort updated --state open \
  --json number,title,labels,updatedAt,comments --limit 30
```

중복 제거 후 최대 50개. contribution-agent는 수집된 데이터를 분류만 한다:
- **추천 첫 기여**: `good first issue` / `help wanted` 라벨 + 최근 90일 내 활동
- **최근 활발한 이슈**: 업데이트 순 정렬, 코멘트 수 표시

### 병렬 Task 호출 패턴 (from agent-native-architecture)

SKILL.md에서 Claude Code에 다음을 지시:

> **한 턴에 3개 Task를 동시에 호출하라. 하나씩 순차 호출하지 마라.**
> 각 Task는 `run_in_background: false`로 호출하여 모든 결과를 한 번에 수집한다.

```
Claude Code 한 턴에 3개 tool call:
  Task(prompt=codebase-agent-prompt + context_bundle 일부)
  Task(prompt=lifecycle-agent-prompt + context_bundle 일부)
  Task(prompt=contribution-agent-prompt + context_bundle 일부)
→ 3개 결과 동시 수신 → 조립
```

**Sub-agent output bound (from agent-native-architecture):**
각 에이전트 프롬프트에 "분석을 500단어 이내로 작성하라" 명시. 3개 결과 합산 시 context overflow 방지.

### 서브 에이전트 실패 처리

3개 에이전트 중 일부가 실패해도 전체 분석이 중단되지 않는다:
- **실패한 섹션**: `> ⚠️ 이 섹션은 분석에 실패했습니다: [에러 메시지]` 로 표시
- **교차 종합 섹션 ("추천 첫 기여")**: contribution-agent 실패 시 섹션 생략, codebase-agent만 성공 시에도 나머지 출력
- **재시도 없음**: 프롬프트 기반 스킬이므로 사용자가 재실행

### deepwiki-cli 의존성 (see brainstorm: Open Questions → v1 결정 변경)

v1에서는 **deepwiki-cli를 URL 모드의 필수 도구로 취급**한다:
- 미설치 시 → `"deepwiki-cli가 필요합니다. cargo install deepwiki-cli 로 설치하거나, 레포를 클론하여 로컬 모드를 사용하세요."` 안내
- WebSearch 폴백은 v2에서 검토 (두 번째 데이터 파이프라인은 v1 복잡도를 2배로 증가시킴)

### 로컬 경로에서 owner/repo 추출

contribution-agent가 이슈 데이터를 받으려면 `owner/repo`가 필요:
1. `git -C <path> remote get-url origin` 실행
2. GitHub URL 패턴 매칭 (`github.com[:/]owner/repo`)
3. GitHub remote가 없으면 → 이슈 데이터 없이 기여 분석만 수행

### 보안 고려사항

- `gh` CLI는 사용자의 기존 인증 정보를 사용 (추가 토큰 불필요)
- 로컬 경로 분석 시 symlink traversal 방지 필요 없음 (Claude Code 샌드박스가 처리)

## Acceptance Criteria

### 플러그인 구조
- [x] `plugins/library-analyzer/.claude-plugin/plugin.json` 매니페스트 생성
- [x] `plugins/library-analyzer/skills/library-analyzer/SKILL.md` — 자동 트리거 스킬 (191줄, 500줄 제한 준수)
- [x] `plugins/library-analyzer/skills/library-analyzer/references/agent-prompts.md` — 3개 에이전트 프롬프트
- [x] `plugins/library-analyzer/skills/library-analyzer/references/output-template.md` — 출력 템플릿
- [x] `plugins/library-analyzer/commands/analyze.md` — `/library-analyzer:analyze` 슬래시 커맨드
- [x] `plugins/library-analyzer/README.md` — 사용자 문서

### 입력 처리
- [x] `https://github.com/owner/repo` 및 `owner/repo` shorthand → URL 모드
- [x] 로컬 경로 → 경로 존재 + 디렉토리 검증
- [x] 로컬 경로 git remote → `owner/repo` 자동 추출 (없으면 이슈 생략)
- [x] bare name → `owner/repo` 형식 안내

### 데이터 수집 및 분석
- [x] URL 모드: deepwiki-cli `read`/`structure` 로 원격 데이터 수집
- [x] URL 모드: deepwiki-cli 미설치 시 설치 안내 또는 로컬 모드 제안
- [x] 로컬 모드: Glob/Read로 정적 분석
- [x] 오케스트레이터에서 `gh issue list` 3회 호출 (good-first-issue, help-wanted, recent)
- [x] context bundle 생성 후 3개 Task를 **한 턴에** 동시 호출
- [x] 개별 에이전트 실패 시 해당 섹션만 경고, 나머지 정상 출력

### 출력
- [x] `docs/library-analysis/<name>-<date>.md` YAML frontmatter 포함 저장
- [x] 동일 날짜 재실행 시 덮어쓰기
- [x] deepwiki-cli 스킬과 트리거 겹침 없음 (기여 vs 이해)

## Implementation Tasks

### Phase 1: 플러그인 스캐폴딩

| 파일 | 설명 |
|------|------|
| `plugins/library-analyzer/.claude-plugin/plugin.json` | 매니페스트 |
| `plugins/library-analyzer/README.md` | 사용자 가이드 |

**plugin.json:**
```json
{
  "name": "library-analyzer",
  "version": "1.0.0",
  "description": "Analyze open-source libraries for contribution readiness with parallel agents",
  "author": { "name": "minsoo.web", "github": "minsoo-web" },
  "license": "MIT",
  "keywords": ["open-source", "contribution", "analysis", "library"],
  "skills": "./skills/"
}
```

### Phase 2: SKILL.md 작성 (핵심)

`plugins/library-analyzer/skills/library-analyzer/SKILL.md`:

**1. Frontmatter**
```yaml
---
name: library-analyzer
description: >
  Use when the user wants to contribute to an open-source library,
  says "analyze this library for contribution", "I want to contribute to X",
  "help me contribute to", "contribution readiness", or "기여하고 싶다".
  Do NOT activate for general "how does X work" questions (use deepwiki-cli instead).
---
```

**2. SKILL.md 본문 구조 (~300줄)**

```markdown
# Library Analyzer

## Contents
- When This Skill Activates
- Input Parsing
- Data Collection
- Parallel Analysis
- Result Assembly
- Iron Rules

## When This Skill Activates
[기여 의도 감지 vs deepwiki-cli 이해 의도 구분]

## Step 1: Input Parsing
[URL/shorthand/local/bare-name 판별 + 검증]

## Step 2: Data Collection
[deepwiki-cli 또는 Glob/Read + gh issue list → context bundle 생성]
[references/agent-prompts.md 로드 지시]

## Step 3: Parallel Analysis
"한 턴에 3개 Task를 동시 호출하라. 각 Task에 context bundle의
관련 부분을 인라인으로 포함한다. run_in_background: false."

## Step 4: Result Assembly
[3개 결과 수집 → 실패 체크 → output-template.md 기반 조립 → 파일 저장]

## Iron Rules
- 데이터 수집이 완료되기 전에 절대 에이전트를 실행하지 마라
- 한 에이전트 실패로 전체 분석을 중단하지 마라
- 파일 저장 후 경로 + 분석 요약을 사용자에게 보고하라
```

**3. references/agent-prompts.md**

각 에이전트에 대해:
- **역할**: 한 문장
- **입력 데이터**: context bundle에서 받을 필드
- **출력 포맷**: 정확한 Markdown 섹션 구조
- **경계**: "분석하지 말 것" 명시
- **제한**: 500단어 이내

| 에이전트 | 역할 | 입력 | 출력 섹션 | 경계 |
|---------|------|------|---------|------|
| codebase-agent | 코드 구조·모듈·키워드 분석 | file_tree, readme, package_manifest | §1 디렉토리 구조, §2 모듈 구성, §3 핵심 키워드 | 런타임 흐름 분석 금지 |
| lifecycle-agent | 런타임 흐름·확장 포인트 분석 | readme, package_manifest, file_tree | §4 라이프사이클, §5 확장 포인트 | 정적 구조 분석 금지 |
| contribution-agent | 기여 방법·이슈 분류·첫 기여 추천 | contributing, ci_config, issues, readme | §6 기여 방법, §7 이슈 현황, §8 추천 첫 기여 | 코드 구조 분석 금지 |

**4. references/output-template.md**

```markdown
---
library: {library_name}
repo: {owner/repo}
analyzed: {YYYY-MM-DD}
source: {url | local}
sections_completed: {N}/3
---

# {Library Name} 기여 분석 보고서

## 1. 디렉토리 구조
## 2. 모듈 구성
## 3. 핵심 키워드
## 4. 라이프사이클
## 5. 확장 포인트
## 6. 기여 방법
## 7. 이슈 현황
## 8. 추천 첫 기여
```

### Phase 3: 슬래시 커맨드

`plugins/library-analyzer/commands/analyze.md` — thin wrapper:

```yaml
---
description: Analyze an open-source library for contribution readiness
argument-hint: <owner/repo or local-path>
---
```

본문은 SKILL.md 워크플로우에 위임하는 2-3줄 프롬프트만 포함.

### Phase 4: 검증

| 테스트 케이스 | 검증 항목 |
|-------------|----------|
| URL + deepwiki-cli 설치 | 3개 에이전트 실행, 8개 섹션 생성, 파일 저장 |
| 로컬 경로 + GitHub remote | 정적 분석 + 이슈 수집 + 파일 저장 |
| 로컬 경로 + GitHub remote 없음 | 이슈 섹션 "데이터 없음" 표시, 나머지 정상 |
| URL + deepwiki-cli 미설치 | 설치 안내 메시지 또는 로컬 모드 제안 |

## Output Template

```markdown
---
library: react
repo: facebook/react
analyzed: 2026-03-08
source: url
sections_completed: 3/3
---

# React 기여 분석 보고서

## 1. 디렉토리 구조
[codebase-agent: 상위 2-3레벨 트리 + 주요 디렉토리 역할]

## 2. 모듈 구성
[codebase-agent: 주요 패키지/모듈 목록 + 각 책임 + 초보자 친화 모듈 표시]

## 3. 핵심 키워드
[codebase-agent: 도메인 용어 테이블 (용어 | 설명 | 사용 위치), 15-20개]

## 4. 라이프사이클
[lifecycle-agent: 진입점 → 초기화 → 실행 → 종료 흐름]

## 5. 확장 포인트
[lifecycle-agent: 기여자가 코드를 추가할 수 있는 지점]

## 6. 기여 방법
[contribution-agent: CONTRIBUTING.md 요약 + 개발 환경 설정 + PR 프로세스]

## 7. 이슈 현황
[contribution-agent: good-first-issue/help-wanted 이슈 테이블 + 최근 활발한 이슈]

## 8. 추천 첫 기여
[contribution-agent: 라벨 + 최근 활동 기반 상위 3-5개 이슈 추천]
```

## Dependencies & Risks

| 의존성 | 필수 여부 | 폴백 |
|--------|----------|------|
| deepwiki-cli | URL 모드 필수 | 설치 안내 + 로컬 모드 제안 |
| gh CLI | 선택 | 이슈 섹션 "데이터 없음" + 안내 |
| 인터넷 연결 | URL 모드 필수 | 로컬 경로 전환 안내 |

**리스크:**

| 리스크 | 영향 | 완화 |
|--------|------|------|
| SKILL.md 프롬프트 품질 → 에이전트 동작 정확도 | 높음 | references/로 분리, 명확한 경계 + 출력 포맷 지정 |
| 대형 monorepo 컨텍스트 초과 | 중간 | file_tree 500개 제한, README 500줄 제한, 에이전트 출력 500단어 제한 |
| 트리거 겹침 (deepwiki-cli) | 낮음 | description에 negative boundary 명시 |
| fan-out 첫 도입 → 예상치 못한 동작 | 중간 | 3개(최소)로 시작, 검증 후 확장 고려 |

## Success Metrics

- `/library-analyzer:analyze facebook/react` 실행 → 완성된 분석 보고서 생성
- 3개 에이전트 모두 의미 있는 출력 생성 (8개 섹션)
- SKILL.md 500줄 이하 유지

## Future Enhancements (v2)

- WebSearch 폴백 (deepwiki-cli 없을 때 URL 모드 지원)
- 커뮤니티 건강 지표 (마지막 커밋 날짜, 기여자 수, 릴리스 빈도)
- CI/CD 파이프라인 분석 (contribution-agent 확장)
- 재분석 시 이전 보고서와 diff 표시
- 에이전트 수 확장 (3 → 4-5, 검증 후)

## Sources & References

### Origin

- **Brainstorm document:** [docs/brainstorms/2026-03-08-library-analyzer-skill-brainstorm.md](docs/brainstorms/2026-03-08-library-analyzer-skill-brainstorm.md)
  - Key decisions carried forward: 병렬 팬아웃 실행, gh cli 이슈 수집, deepwiki-cli 원격 분석
  - Decisions changed: 6→3 에이전트, WebSearch 폴백 제거, 커스텀 경로 제거

### Deepening Research

| 에이전트 | 핵심 기여 |
|---------|---------|
| create-agent-skills | `allowed-tools` frontmatter, 500줄 제한, `references/` 분리, progressive disclosure |
| agent-native-architecture | Task tool 한 턴 호출, inline data 전달, `run_in_background: false`, 출력 bound |
| architecture-strategist | context bundle 스키마, 에이전트 경계 명확화, 점진적 파일 출력, 대형 레포 대응 |
| pattern-recognition | noun-form 이름(`library-analyzer`), TOC 추가, "When This Skill Activates" 섹션 |
| code-simplicity-reviewer | 6→3 에이전트, WebSearch 제거, 커스텀 경로 제거, 이슈 분류 단순화, 테스트 축소 |
| best-practices-researcher | issue 수집 3회 쿼리 전략, Iron Rules 패턴, 출력 품질 가드 |

### Internal References

- Plugin spec: `docs/contributors/plugin-spec.md`
- deepwiki-cli skill: `plugins/deepwiki-cli/skills/deepwiki-cli/SKILL.md`
- personal-tutor skill: `plugins/personal-tutor/skills/personal-tutor/SKILL.md` — multi-phase + Iron Rules 패턴
- skill-review checklist: `plugins/skill-review/skills/skill-review/references/checklist.md`
