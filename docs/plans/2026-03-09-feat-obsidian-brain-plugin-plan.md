---
title: "feat: Add obsidian-brain plugin for learning archival automation"
type: feat
status: active
date: 2026-03-09
origin: docs/brainstorms/2026-03-09-obsidian-brain-brainstorm.md
---

# feat: Add obsidian-brain plugin for learning archival automation

## Enhancement Summary

**Deepened on:** 2026-03-09
**Research agents used:** Zettelkasten best practices, Claude Code skill patterns, Knowledge extraction patterns, Architecture review, Quality compliance review

### Key Improvements
1. **트리거 충돌 해소**: 기존 obsidian 스킬과의 상호 배제 경계를 명확히 정의, 양쪽 스킬 모두 수정
2. **MOC 스캔 알고리즘 교정**: 예산 불일치 수정 (char 기반), Grep 기반 확장성 확보
3. **vault 경로 전략 변경**: 별도 config 대신 obsidian-cli 해석 재사용, config는 override만
4. **SKILL.md 콘텐츠 예산 수립**: ~93줄 타겟, references 3개 파일로 분리
5. **Cold start 개선**: 첫 MOC 자동 생성 (제안 → 승인)
6. **노트 품질 기준 추가**: Zettelkasten 원자성 테스트, 선언형 제목 패턴

### New Considerations Discovered
- 기존 obsidian 스킬의 "Zettelkasten", "PKM" 트리거를 범위 조정해야 함
- Progressive Summarization 패턴을 학습 추출에 적용 가능
- Orphan note 감지를 `/brain` command에 추가 가능 (향후)

---

## Overview

Claude Code 대화에서 배운 것을 Obsidian vault에 Zettelkasten 방식으로 자동 아카이빙하는 `obsidian-brain` 플러그인. 두 가지 핵심 기능: (1) `/obsidian-archive` command로 세션 학습 내용 추출 및 저장, (2) `obsidian-brain` auto-invoked skill로 vault 지식을 Claude 컨텍스트에 반영.

## Problem Statement / Motivation

- Claude Code로 작업하며 배우는 것들이 대화가 끝나면 사라짐
- 수동으로 노트를 정리하는 건 번거롭고 일관성 없음
- 축적된 지식을 다시 Claude에게 참조시키면 더 맥락 있는 답변을 받을 수 있음
- **양방향 지식 순환**: 학습 → 저장 → 참조 → 더 나은 학습

## Proposed Solution

### Plugin Structure

```
plugins/obsidian-brain/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── obsidian-archive.md      # 학습 아카이빙 command
│   └── brain.md                 # vault 컨텍스트 명시적 로딩 command
├── skills/
│   └── obsidian-brain/
│       ├── SKILL.md             # auto-invoked skill (컨텍스트 활용)
│       └── references/
│           ├── vault-setup.md   # vault 구조, 경로 해석, 초기화 가이드
│           ├── templates.md     # 노트/MOC 템플릿 정의
│           └── archive-workflow.md  # 학습 추출, 드래프트 형식, 중복 검사 로직
├── README.md
└── README.ko.md
```

### Research Insights: Plugin Architecture

**References 3-파일 분리 근거** (from skill quality review):
- `vault-setup.md`: 첫 실행 시에만 로딩 — vault 경로 해석, 디렉토리 부트스트랩
- `templates.md`: 노트 생성 시에만 로딩 — zettel/MOC 템플릿, 파일명 규칙
- `archive-workflow.md`: `/obsidian-archive` 실행 시에만 로딩 — 추출 기준, 드래프트 형식, 중복 검사

이 분리로 SKILL.md body를 ~93줄로 유지 가능 (150줄 한도 내).

---

### Component 1: `/obsidian-archive` Command

**흐름:**

```
/obsidian-archive
     │
     ▼
[vault 경로 확인] ──없음──▶ [사용자에게 질문 → config에 저장]
     │                              │
     ▼                              ▼
[vault 구조 확인] ──없음──▶ [디렉토리 생성 + 첫 MOC 자동 생성 제안]
     │
     ▼
[현재 세션 분석 → 학습 포인트 추출]
     │
     ▼
[추출 결과 없음?] ──예──▶ ["이 세션에서 아카이빙할 내용을 찾지 못했습니다"]
     │ 아니오
     ▼
[Grep으로 2-maps/ 내 주제 키워드 검색 → 관련 MOC 식별]
     │
     ▼
[상위 3 MOC Read → wikilink 추출 → 관련 노트 최대 5개 Read]
     │
     ▼
[Grep으로 중복 체크 (제목 + 핵심 문구)]
     │
     ▼
[드래프트 생성: 선언형 제목, 내용, wikilink + 관계유형, 태그]
     │
     ▼
[사용자에게 제시 → 수정/승인/거절]
     │
     ├─승인──▶ [0-inbox/에 저장 → 관련 MOC 업데이트 → 완료]
     ├─수정──▶ [수정 반영 → 다시 제시]
     └─거절──▶ [저장 없이 종료]
```

**command 파일 (`commands/obsidian-archive.md`) 설계:**

```yaml
---
description: Archive learnings from current session to Obsidian vault as Zettelkasten notes
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---
```

command body는 thin wrapper — "Follow the **obsidian-brain** skill's archive workflow. Read `references/archive-workflow.md` for extraction criteria and draft format." 패턴 사용 (see `library-analyzer/commands/analyze.md`).

### Research Insights: Command Design

- **`allowed-tools` 명시** (from quality review): 필요한 도구를 선언하여 의도하지 않은 도구 접근 방지
- **Thin wrapper 패턴** (from skill patterns research): command는 6줄 이내의 진입점, 실제 로직은 skill + references에 위임
- **`!`command`` 구문 활용 가능**: vault 경로를 동적으로 주입할 수 있으나, config 읽기는 런타임에서 처리

---

### Component 2: `/brain` Command (명시적 컨텍스트 로딩)

```yaml
---
description: Load relevant knowledge from Obsidian vault into current conversation context
argument-hint: [topic]
allowed-tools: [Read, Glob, Grep]
---
```

사용자가 명시적으로 vault 지식을 불러오고 싶을 때 사용. `$ARGUMENTS`로 topic을 받아 MOC 기반 탐색 실행.

---

### Component 3: `obsidian-brain` Auto-Invoked Skill

**SKILL.md description 설계 — 기존 obsidian 스킬과의 경계:**

```yaml
---
name: obsidian-brain
description: >
  Use when the user explicitly requests their personal vault notes as
  conversational context. Activates on "이전에 정리한 거 있어?",
  "내 노트 참고해서 답해줘", "check my notes about", "I wrote something
  about this before", "what do my notes say about". Do NOT trigger for
  vault management (creating, moving, editing, searching notes) — those
  belong to the obsidian skill. Do NOT trigger for generic Obsidian or
  Zettelkasten questions.
---
```

### Research Insights: Trigger Delineation (CRITICAL)

**문제**: 기존 `obsidian` 스킬이 "Zettelkasten", "PKM", "내 노트에서 찾아줘"를 트리거로 사용 중 — `obsidian-brain`과 충돌.

**해결 — 양쪽 스킬 모두 수정 필요:**

| 조치 | 대상 |
|------|------|
| "search my vault for context" 제거 (검색 동작과 혼동) | `obsidian-brain` description |
| "내 노트에서 찾아줘" → obsidian 스킬에서 유지, brain에서는 다른 문구 사용 | 양쪽 |
| obsidian 스킬에 "Do NOT activate when user wants vault notes as conversational context" 추가 | `obsidian` SKILL.md |
| "Zettelkasten" 트리거를 obsidian에서 "Zettelkasten vault setup/structure"로 스코프 축소 | `obsidian` SKILL.md |

**핵심 구분**: **obsidian = vault 관리 (CRUD)**, **obsidian-brain = 지식 활용 (read for context)**

| 요청 | 담당 스킬 |
|------|-----------|
| "노트 만들어줘", "frontmatter 수정해줘" | `obsidian` |
| "vault에서 X 검색해줘" | `obsidian` |
| "내가 이전에 정리한 거 있어?" | `obsidian-brain` |
| "이 주제에 대해 내 노트 참고해서 답해줘" | `obsidian-brain` |
| `/obsidian-archive` | `obsidian-brain` (command) |

---

## Technical Considerations

### Vault 경로 해석 (수정됨)

**전략 변경** (from architecture review): 별도 config 대신 기존 obsidian 스킬의 해석 메커니즘을 **재사용**하고, config는 override로만 사용.

**해석 우선순위:**
1. `~/.claude/obsidian-brain/config.json`의 `vaultPath` (사용자 override, 있으면 최우선)
2. `obsidian-cli print-default --path-only` (obsidian-cli 설치 시)
3. Obsidian 앱 config에서 default vault 읽기:
   - macOS: `~/Library/Application Support/obsidian/obsidian.json`
   - Linux: `~/.config/obsidian/obsidian.json`
4. 모두 실패 시: 사용자에게 경로 질문 → config.json에 저장

```json
{
  "vaultPath": "/Users/username/obsidian-vault",
  "language": "ko"
}
```

### Research Insights: Config Storage
- 기존 obsidian 스킬과 **동일한 vault**를 가리키므로 해석 메커니즘 통일이 중요
- config.json은 override + 추가 설정(언어 등)만 저장
- 에러 핸들링 추가: config 디렉토리 쓰기 불가 시 인메모리 fallback

---

### Vault 구조 부트스트랩

첫 실행 시 vault 경로에 필요한 디렉토리가 없으면 생성을 제안:

```
다음 디렉토리를 생성하겠습니다:
- 0-inbox/
- 1-zettelkasten/
- 2-maps/
- templates/

진행할까요?
```

**Cold Start 개선** (from architecture review): 첫 번째 노트 저장 시 관련 MOC가 없으면, **자동으로 첫 MOC 생성을 제안하고 승인 시 생성**. 단순 제안에 그치지 않고, 첫 노트가 즉시 MOC에 연결되어 시스템의 가치를 첫 사용에서 보여줌.

---

### MOC 스캔 알고리즘 (수정됨)

**예산 기반 설계** (from architecture review — 기존 10노트×200줄 ≠ 15K chars 불일치 수정):

```
총 컨텍스트 예산: 15,000자 (hard limit)

1. Grep으로 2-maps/*.md 내에서 주제 키워드 검색 → 관련 MOC 파일 식별
   (파일명 매칭이 아닌 내용 기반 — 확장성 확보)
2. 상위 3개 MOC의 전체 내용 Read (~1,000자 × 3 = ~3,000자)
3. MOC에서 [[wikilink]] 추출
4. 관련 노트 최대 5개 Read (노트당 최대 2,000자 — ~10,000자)
5. 잔여 예산 ~2,000자: 관계 판단용 여유 공간
```

**확장성** (from architecture review):
- MOC 매칭: Grep 기반이므로 수천 개 MOC에서도 동작
- 중복 검사: Grep으로 `0-inbox/` + `1-zettelkasten/` 내 제목 + 핵심 문구 검색 (전체 노트 Read 대신)
- MOC 25개 항목 초과 시 자동으로 sub-MOC 분리 제안

---

### 노트 포맷

**파일명**: `YYYYMMDDHHmmss-kebab-title.md`
- 배치 저장 시 타임스탬프 충돌 방지: sequential suffix 추가 (`-01`, `-02`, zero-padded 2자리)
- 특수문자(`/`, `\`, `:`, `?`, `*`) 제거, 공백은 하이픈으로, 최대 60자

### Research Insights: Zettelkasten Note Quality

**원자성 테스트** (from Zettelkasten research):
- "하나의 선언형 제목으로 표현할 수 있는가?" → 가능하면 원자적
- 제목은 **완전한 문장/구** 형태 (e.g., "useTransition defers low-priority state updates" not "useTransition")
- 노트가 하나의 개념/인수/모델/관찰만 포함해야 함

**관계 유형 taxonomy** (from Zettelkasten research — 검증 및 보강):

| 관계 | 의미 | 예시 |
|------|------|------|
| `extends` | 이 개념을 확장/심화 | "Lifetime elision" extends "Rust lifetimes" |
| `prerequisite` | 이 개념을 이해하려면 필요 | "Ownership" is prerequisite for "Borrowing" |
| `example` | 구체적 사례 | "React useMemo" exemplifies "Memoization" |
| `contrast` | 대조되는 개념 | "Composition" contrasts with "Inheritance" |
| `related` | 일반적 관련 | "TS generics" related to "Rust generics" |

향후 확장 고려: `source`, `supersedes`, `refines`, `contradicts`

**모든 wikilink에 관계 유형 주석 필수** — 나중에 다시 읽을 때 *왜* 연결했는지 알 수 있어야 함:
```markdown
## Related
- [[rust-ownership]] — prerequisite (ownership 없이 lifetime 이해 불가)
- [[cpp-raii-pattern]] — contrast (C++의 같은 문제 접근법)
```

**노트/MOC 템플릿**: `references/templates.md`에 정의 (SKILL.md body에서 분리).

---

### 학습 추출 기준

### Research Insights: Knowledge Extraction

**Progressive Summarization 적용** (from knowledge extraction research):
Claude가 세션을 분석할 때 계층적 추출 적용:
1. **1차**: 세션 전체에서 학습 관련 대화 구간 식별
2. **2차**: 각 구간에서 핵심 개념/인사이트 추출
3. **3차**: 각 인사이트를 원자적 노트로 변환 가능한지 판단

**추출 대상** (Zettelkasten knowledge atoms 기반):
- **개념 정의** — 새로운 용어나 개념의 경계를 정한 것
- **패턴 발견** — 디버깅 과정에서 찾은 원인-해결 패턴
- **모델/관계** — 엔티티 간 관계에 대한 이해 ("A는 B의 특수한 경우")
- **실증적 관찰** — 라이브러리/프레임워크의 실제 동작 확인

**제외**: 단순 파일 조작, 설정 변경, 반복 작업, 이미 잘 알고 있는 내용

**중복 검사** (from knowledge extraction research):
- Claude의 판단 기반 semantic comparison (embeddings 불필요)
- Grep으로 기존 노트에서 제목 + 핵심 용어 검색 → 유사 노트 발견 시 사용자에게 "병합/별도 생성/건너뛰기" 선택 제시

---

### MOC 자동 업데이트

노트 저장 시 관련 MOC에 wikilink를 자동 추가.
- 매칭되는 MOC가 없으면 새 MOC 생성을 제안 (승인 후 생성)
- MOC 내 항목이 25개 초과 시 sub-MOC 분리 제안 (from Zettelkasten research)
- MOC format: navigation 역할만 — 간단한 wikilink + 한 줄 설명

---

### 의존성 전략

Claude Code 플러그인은 의존성 선언이 불가하므로, `obsidian-brain`은 **자체적으로 vault 조작이 가능**하도록 설계:
- vault 경로 탐색: 다단계 fallback (obsidian-cli → 앱 config → 사용자 질문)
- 파일 생성/수정: Claude의 Read/Write/Edit 도구 직접 사용
- 검색: Glob/Grep 직접 사용

obsidian-cli는 optional enhancement (설치되어 있으면 wikilink-aware move 등에 활용).

---

### 에러 핸들링

| 상황 | 대응 |
|------|------|
| vault 경로 무효 | "vault 경로가 변경된 것 같습니다. 새 경로를 알려주세요" |
| config 디렉토리 쓰기 불가 | 인메모리 fallback, 세션 내에서만 유지 |
| obsidian-cli 미설치 | Read/Write/Glob으로 fallback (wikilink-aware move 불가 안내) |
| 세션에 학습 내용 없음 | "이 세션에서 아카이빙할 학습 내용을 찾지 못했습니다" |
| 중복 노트 감지 | "유사한 노트가 이미 있습니다: [[기존노트]]. 병합/별도 생성/건너뛰기?" |
| 파일 쓰기 실패 | 에러 메시지 표시, 드래프트 내용을 텍스트로 제시하여 수동 저장 가능 |
| MOC 25개 항목 초과 | sub-MOC 분리 제안 |

---

## SKILL.md Content Budget

**~93줄 타겟** (from quality review — 150줄 한도 내 comfortable headroom):

| 섹션 | 예상 줄수 |
|------|-----------|
| Frontmatter (name + description) | 8 |
| When This Skill Activates | 12 |
| Skill Boundary (obsidian vs obsidian-brain) | 10 |
| Vault Path Resolution (요약) | 8 |
| Context Loading Workflow (요약, 5단계) | 15 |
| Archive Workflow (요약, "Read references/archive-workflow.md") | 10 |
| Iron Rules | 12 |
| References Loading Guide | 10 |
| 여유 | 8 |
| **합계** | **~93** |

**References Loading Guide 테이블:**

| Situation | Load |
|-----------|------|
| Setting up vault for the first time | `references/vault-setup.md` |
| Creating new zettel notes or MOC entries | `references/templates.md` |
| Running /obsidian-archive (extraction, draft, dedup) | `references/archive-workflow.md` |

---

## Acceptance Criteria

### Functional Requirements

- [ ] `plugins/obsidian-brain/` 디렉토리가 plugin-spec.md 규격을 준수
- [ ] `/obsidian-archive` command가 현재 세션에서 학습 내용을 추출
- [ ] 추출된 내용을 Zettelkasten 노트 드래프트로 변환하여 사용자에게 제시
- [ ] 노트 제목은 선언형 구(declarative phrase) 형태
- [ ] 사용자가 드래프트를 수정, 승인, 거절할 수 있음
- [ ] 승인된 노트가 `0-inbox/`에 타임스탬프 기반 파일명으로 저장
- [ ] MOC 기반으로 기존 노트를 스캔하여 `[[wikilink]]` + 관계유형 연결을 제안
- [ ] 관련 MOC에 새 노트 링크가 자동 추가됨
- [ ] Cold start 시 첫 MOC 자동 생성 제안
- [ ] `/brain [topic]` command가 vault에서 관련 노트를 로딩하여 컨텍스트로 활용
- [ ] `obsidian-brain` skill이 명시적 요청 시에만 활성화됨
- [ ] **기존 `obsidian` skill description에 상호 배제 "Do NOT" 절 추가**
- [ ] vault 경로 해석: obsidian-cli → 앱 config → 사용자 질문 순서
- [ ] vault 구조 없으면 생성 제안
- [ ] 노트 제목/태그는 영어, 내용은 한국어로 작성
- [ ] marketplace.json에 플러그인 등록 (keywords ≤ 5개)
- [ ] `1-zettelkasten/` 승격은 v1 범위 밖 — 수동 Obsidian 작업으로 처리

### Quality Gates

- [ ] SKILL.md body ≤ 150 lines (~93줄 타겟, references 3개로 분리)
- [ ] SKILL.md frontmatter은 `name` + `description`만
- [ ] Description은 "Use when..." 형식 + "Do NOT..." 경계 조건 (≤ 500자)
- [ ] Command frontmatter에 `allowed-tools` 명시
- [ ] skill-review 통과 (zero errors)
- [ ] README.md에 설치 방법, 사용 예시, vault 구조 설명 포함

---

## Implementation Phases

### Phase 0: 기존 obsidian 스킬 수정 (선행 조건)

**목표**: 트리거 충돌 방지를 위한 기존 스킬 업데이트

**파일 수정:**
- `plugins/obsidian/skills/obsidian/SKILL.md` — description에 "Do NOT activate when the user wants to use vault notes as conversational context (e.g., '내 노트 참고해서 답해줘', 'check my notes about X') — that belongs to obsidian-brain" 추가. "Zettelkasten" 트리거를 "Zettelkasten vault setup" 등으로 스코프 축소.

**Success**: obsidian 스킬이 컨텍스트 활용 요청에 활성화되지 않음

### Phase 1: Plugin Skeleton + Vault Setup

**목표**: 플러그인 구조 생성 및 vault 초기화 로직

**파일 생성:**
- `plugins/obsidian-brain/.claude-plugin/plugin.json`
- `plugins/obsidian-brain/skills/obsidian-brain/SKILL.md` (~93줄)
- `plugins/obsidian-brain/skills/obsidian-brain/references/vault-setup.md`
- `plugins/obsidian-brain/skills/obsidian-brain/references/templates.md`
- `plugins/obsidian-brain/skills/obsidian-brain/references/archive-workflow.md`
- `plugins/obsidian-brain/README.md`

**SKILL.md 콘텐츠 (요약):**
- 트리거 조건 (한국어 + 영어) — 기존 obsidian과 상호 배제
- vault 경로 해석 (4단계 fallback, 요약)
- 컨텍스트 로딩 워크플로우 (5단계 요약)
- 아카이빙 워크플로우 (references 위임)
- Iron Rules
- References Loading Guide 테이블

**Success**: plugin.json이 validate-plugin CI를 통과, SKILL.md ≤ 150줄

### Phase 2: `/obsidian-archive` Command

**목표**: 아카이빙 command 구현

**파일 생성:**
- `plugins/obsidian-brain/commands/obsidian-archive.md`

**command 내용 (thin wrapper):**
1. "Follow the obsidian-brain skill's archive workflow"
2. vault 경로 확인 → `references/vault-setup.md` 참조
3. 세션 분석 + 추출 → `references/archive-workflow.md` 참조
4. 노트 생성 → `references/templates.md` 참조
5. 수정/승인/거절 흐름
6. 저장 + MOC 업데이트

**Success**: `/obsidian-archive` 실행 시 드래프트가 제시되고, 승인 후 vault에 저장됨

### Phase 3: `/brain` Command + Context Loading

**목표**: 명시적 vault 컨텍스트 로딩

**파일 생성:**
- `plugins/obsidian-brain/commands/brain.md`

**Success**: `/brain React hooks` 실행 시 관련 노트가 로딩되어 답변에 반영됨

### Phase 4: Marketplace 등록 + README

**목표**: 배포 준비

**파일 수정:**
- `.claude-plugin/marketplace.json`에 obsidian-brain 추가

**파일 생성/수정:**
- `plugins/obsidian-brain/README.md` (한국어 버전 포함)

**Success**: marketplace 등록 완료, skill-review zero errors

---

## Dependencies & Risks

| 리스크 | 영향 | 완화 |
|--------|------|------|
| 기존 obsidian 스킬과 트리거 충돌 | 잘못된 스킬 활성화 | **Phase 0에서 양쪽 description 수정** + 상호 "Do NOT" 절 |
| MOC 스캔 시 컨텍스트 초과 | 느린 응답, 토큰 낭비 | char 기반 예산 (15K), Grep 기반 매칭 |
| 빈 vault에서 사용성 저하 | 첫 경험이 빈약 | 첫 MOC 자동 생성 제안, 즉시 연결 |
| Claude의 학습 추출 품질 불안정 | 저품질/무관한 노트 생성 | Progressive Summarization 계층 추출 + 원자성 테스트 + 사용자 리뷰 |
| vault 경로 divergence | obsidian과 다른 vault 참조 | obsidian-cli 해석 재사용, config는 override만 |
| SKILL.md 150줄 초과 | 스킬 품질 기준 위반 | 콘텐츠 예산 수립 (~93줄), references 3개 분리 |
| "Hoarder" 안티패턴 | vault에 저품질 노트 축적 | 원자성 테스트 (선언형 제목 가능?), 사용자 승인 필수 |

---

## Sources & References

### Origin

- **Brainstorm document:** [docs/brainstorms/2026-03-09-obsidian-brain-brainstorm.md](docs/brainstorms/2026-03-09-obsidian-brain-brainstorm.md) — Key decisions: 별도 플러그인 분리, Zettelkasten 방식, MOC 기반 탐색, 명시적 트리거, 혼용 언어 정책

### Internal References

- Plugin spec: `docs/contributors/plugin-spec.md`
- Skill quality standards: `docs/solutions/quality-maintenance/skill-plugin-quality-review-fixes.md`
- Existing obsidian plugin: `plugins/obsidian/skills/obsidian/SKILL.md`
- Command+skill pattern: `plugins/library-analyzer/commands/analyze.md`
- Persistent state pattern: `plugins/personal-tutor/skills/personal-tutor/SKILL.md`
- Skill review checklist: `plugins/skill-review/skills/skill-review/references/checklist.md`
- Marketplace: `.claude-plugin/marketplace.json`

### External References (from research)

- [zettelkasten.de Atomicity Guide](https://zettelkasten.de/atomicity/guide/) — 원자적 노트 구조
- [Andy Matuschak's Taxonomy of Note Types](https://notes.andymatuschak.org/Taxonomy_of_note_types) — 선언형 제목
- [Obsidian Rocks MOC Guide](https://obsidian.rocks/maps-of-content-effortless-organization-for-notes/) — MOC 패턴
- [Progressive Summarization - Forte Labs](https://fortelabs.com/blog/progressive-summarization-a-practical-technique-for-designing-discoverable-notes/) — 계층적 추출
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) — 스킬 설계
- [12 Common PKM Mistakes](https://www.dsebastien.net/12-common-personal-knowledge-management-mistakes-and-how-to-avoid-them/) — 안티패턴
