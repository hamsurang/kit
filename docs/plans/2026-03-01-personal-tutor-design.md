# Personal Tutor Skill — Design Document

**Date:** 2026-03-01
**Status:** Approved

---

## Overview

A Claude Code skill that acts as a personalized technical tutor. The skill guides Claude through structured learning sessions, builds a persistent knowledge graph per topic, and accumulates a learner profile over time to adapt its teaching style — creating a "private tutor that knows you" experience.

**Target scope:** Technical/programming topics (Rust, TypeScript, algorithms, system design, etc.)

---

## Core Flow

```
호출
 ↓
기존 knowledge-graph 확인
 ├─ 없음 → Phase 1: Socratic Diagnostic
 └─ 있음 → Phase 2: Agenda Planning (프로파일 로드)
 ↓
Phase 2: Agenda Planning
 ↓
Phase 3: Teaching (Socratic + reference 인용)
 ↓
Phase 4: Verification Quiz
 ↓
Phase 5: Archive (관찰 확인 → 저장)
```

---

## Phase Design

### Phase 1: Socratic Diagnostic (첫 세션만)

- 5–7개 open-ended 질문으로 선행 지식 맵핑
- 마지막에 레퍼런스 자료 확인: "참고하고 싶은 책/문서/강의 있어?"
  - 있으면: `knowledge-graph.md` 상단에 저장, 레퍼런스 구조 참조해 커리큘럼 힌트로 활용
  - 없으면: Claude가 직접 커리큘럼 구성
- 결과물: `knowledge-graph.md` 초기 생성 (모든 노드 `gap` 상태)

### Phase 2: Agenda Planning

세션 구성 원칙:
- **새 개념 1–2개**: `gap` 노드 중 prerequisites 충족된 것 우선
- **복습 1개**: `partial` 노드 중 가장 오래된 것
- returning 사용자: 이전 `partial` 노드 복습 퀴즈를 세션 첫머리에 배치

`learner-profile.md`의 패턴 참조해서 teaching 방식 사전 조정.

### Phase 3: Teaching

- Claude 주도 커리큘럼, 레퍼런스는 보조 역할
  - 설명 중 인용: "The Rust Book 4장에서 이 예제 봐봐"
  - 심화 안내: "더 보고 싶으면 해당 챕터 참고"
- 루프: 설명 → 소크라테스 Q&A → 이해 확인
  - 막히면: 비유 / 코드 예시 / 역질문으로 다른 각도 재설명
- `learner-profile`의 "잘 반응하는 방식" 참조해서 접근법 조정

### Phase 4: Verification Quiz

3가지 포맷 중 컨텍스트에 맞게 선택:

| 포맷 | 예시 | 측정하는 것 |
|------|------|------------|
| **Feynman** | "5살한테 설명해봐" | 내재화 수준 |
| **Apply** | "이 코드에서 뭐가 문제야?" | 적용 능력 |
| **Analyze** | "왜 이렇게 설계됐을까?" | 깊이 이해 |

힌트 사용 여부 트래킹 (노드 승급 기준에 사용).

### Phase 5: Archive

세션 종료 시:
1. **노드 상태 업데이트** (승급 규칙 적용)
2. **세션 로그 저장** (`sessions/YYYY-MM-DD-session-N.md`)
3. **관찰 내용 제시 + 확인**: "오늘 이런 패턴 관찰했는데 저장할까?"
   - 확인 후 `learner-profile.md` 업데이트

---

## Knowledge Graph

### 노드 상태 머신

```
gap
 ↓ (이번 세션 퀴즈 통과, 힌트 무관)
partial
 ↓ (다음 세션 복습 퀴즈 힌트 없이 통과)
understood
```

깊이는 **Bloom's Taxonomy** 기반:
`recall` → `apply` → `explain`

### knowledge-graph.md 형식

```markdown
# {Topic} Knowledge Graph

Reference: The Rust Programming Language (https://doc.rust-lang.org/book/)

## Nodes

### Ownership
- Status: partial
- Depth: apply
- Prerequisites: []
- Quiz history:
  - 2026-03-01: passed (hint used) → gap→partial

### Borrowing
- Status: gap
- Depth: -
- Prerequisites: [Ownership]
- Quiz history: []

### Lifetimes
- Status: gap
- Depth: -
- Prerequisites: [Ownership, Borrowing]
- Quiz history: []
```

**엣지 케이스:**
- `understood` 노드 + 마지막 세션 30일+ 경과 → 가벼운 복습 퀴즈 제안
- 퀴즈 완전 실패 → 노드 강등 없음, `learner-profile`에 "재강화 필요" 메모

---

## Learner Profile

### learner-profile.md 형식

```markdown
# Learner Profile

## 학습 패턴
- 잘 반응하는 방식: C++ 비유, 구체적 예시 먼저
- 약한 방식: 추상적 형식 표기, 이론 설명 먼저
- 학습 방향: 구체 → 추상 (bottom-up)

## 관찰된 약점 패턴
- 타입 시스템 계열은 평균 2세션 필요
- 처음엔 "알겠다" 하지만 퀴즈에서 구멍 드러나는 경향

## 토픽별 이력
- Rust: 3세션 (Ownership ✓, Borrowing ⚠, Lifetimes ✗)
```

업데이트 방식: 세션 종료 시 Claude가 관찰 내용 제시 → 사용자 확인 후 저장.

---

## Storage Structure

```
~/.claude/learning/
  learner-profile.md
  topics/
    rust/
      knowledge-graph.md
      sessions/
        2026-03-01-session-1.md
        2026-03-08-session-2.md
    typescript/
      knowledge-graph.md
      sessions/
```

---

## Applied Learning Science

| 원칙 | 적용 지점 |
|------|----------|
| **Bloom's Taxonomy** | 노드 깊이 트래킹 (recall/apply/explain) |
| **Zone of Proximal Development** | prerequisites 충족된 노드만 가르침 |
| **Retrieval Practice** | 퀴즈 없이 세션 종료 불가 |
| **Feynman Technique** | 퀴즈 포맷 중 하나 |
| **Spaced Repetition** | A+B 승급 기준 (이번 세션 + 다음 세션 검증) |
| **Interleaving** | 새 개념 + 기존 partial 복습 혼합 |
| **Cognitive Load Theory** | 세션당 새 개념 최대 1–2개 |

---

## Skill Iron Rules

1. **퀴즈 없이 세션 끝내지 말 것** — Retrieval Practice 필수
2. **prerequisites 미충족 개념 가르치지 말 것** — ZPD 존중
3. **아카이빙 없이 세션 종료하지 말 것** — 학습 이력 보존
4. **learner-profile은 확인 없이 자동 저장하지 말 것** — 사용자 확인 필수

---

## Skill File Structure

```
~/.claude/skills/personal-tutor/
  SKILL.md
  knowledge-graph-template.md
```
