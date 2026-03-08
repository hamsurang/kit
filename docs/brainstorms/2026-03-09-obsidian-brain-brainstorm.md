---
date: 2026-03-09
topic: obsidian-brain
status: brainstorm
---

# Obsidian Brain - 학습 아카이빙 자동화 스킬

## What We're Building

Claude Code 대화에서 배운 것을 Obsidian vault에 Zettelkasten 방식으로 자동 아카이빙하는 플러그인.

두 가지 핵심 기능:
1. **`/obsidian-archive` command** - 현재 세션에서 학습한 내용을 추출 → 기존 vault 노트와 관계 판단 → 드래프트 제시 → 수정 반영 → Zettelkasten 노트로 저장
2. **`obsidian-brain` auto-invoked skill** - vault에 축적된 지식을 Claude 컨텍스트에 자동 반영하여 더 맥락있는 답변 제공

### 사용 흐름

**아카이빙 흐름 (`/obsidian-archive`)**:
1. 사용자가 작업 중 또는 학습 후 `/obsidian-archive` 호출
2. Claude가 현재 대화를 분석하여 핵심 학습 포인트 추출
3. vault의 기존 노트를 스캔하여 관련 노트 탐색
4. 새 노트 드래프트 제시: 제목, 내용, `[[wikilink]]` 연결, 태그
5. 사용자가 수정 제안 가능 (내용 수정, 연결 추가/제거, 태그 변경)
6. 승인 후 vault에 저장

**컨텍스트 활용 흐름 (auto-invoked skill)**:
- Claude가 대화 주제와 관련된 vault 노트를 자동으로 참조
- 사용자의 기존 지식 수준과 용어 사용 패턴을 반영한 답변

### 사용 시나리오

**시나리오 A: 작업 중 부산물 캡처**
> React 프로젝트 작업 중 useTransition에 대해 새로 배움
> → `/obsidian-archive`
> → "useTransition은 concurrent rendering에서 낮은 우선순위 업데이트를 위한 hook"
> → 기존 "React Hooks" 노트, "Concurrent Mode" 노트와 자동 연결
> → 수정 없이 승인 → 저장

**시나리오 B: 의도적 학습 세션**
> "Rust의 lifetime에 대해 알려줘" → 학습 대화 진행
> → `/obsidian-archive`
> → 여러 개의 원자적 노트 생성 제안 (lifetime 기본, borrow checker, 'static lifetime 등)
> → 각 노트 간 연결 + 기존 "Ownership" 노트와 연결
> → 일부 내용 수정 후 승인 → 저장

## Why This Approach

### 별도 플러그인 (`obsidian-brain`)으로 분리하는 이유

- **관심사 분리**: 아카이빙(command)과 컨텍스트 활용(skill)은 다른 트리거와 동작 패턴
- **기존 `obsidian` 플러그인과의 역할 구분**: obsidian 플러그인은 범용 vault 관리, obsidian-brain은 지식 관리에 특화
- **확장성**: 나중에 학습 통계, 복습 리마인더 등 추가 가능
- **브랜치 이름(`obsidian-brain`)과 일치**

### Zettelkasten 방식을 채택하는 이유

- 원자적 노트 = Claude가 특정 개념을 정확히 참조하기 좋음
- `[[wikilink]]` 연결 = 지식 그래프 형성 → "관련 지식" 탐색 가능
- 태그 + 링크 이중 분류 = 다양한 경로로 접근 가능

### Claude 판단 기반 연결의 이유

- 단순 키워드 매칭보다 의미적 관계 파악이 정확
- "확장", "반대 의견", "사례", "전제 조건" 등 관계 유형 판단 가능
- vault 규모가 커져도 관련성 높은 연결만 제안 가능

## Key Decisions

1. **플러그인 구조**: `plugins/obsidian-brain/` 독립 플러그인으로 생성
2. **트리거 방식**: `/obsidian-archive` command (명시적 호출)
3. **노트 형태**: Zettelkasten — 하나의 개념 = 하나의 노트, wikilink 연결
4. **연결 방식**: Claude가 기존 노트를 읽고 의미적 관계를 판단하여 연결
5. **사용자 개입**: 드래프트 제시 → 수정 제안 가능 → 승인 후 저장
6. **vault 구조**: 새로 시작 — 스킬과 함께 설계
7. **활용 목적**: 개인 레퍼런스 + Claude 컨텍스트 (양방향 지식 순환)
8. **기존 obsidian 플러그인 의존**: vault 탐색, 파일 생성 등 기본 동작은 기존 스킬 활용
9. **vault 경로**: 첫 실행 시 사용자에게 질문하여 저장
10. **파일명**: 타임스탬프 기반 (`YYYYMMDDHHmmss-title.md`)
11. **노트 스캔**: MOC 기반 탐색 (MOC → 관련 노트 순으로 탐색)
12. **컨텍스트 활용**: 사용자 명시적 요청 시만 vault 참조
13. **언어**: 제목/태그는 영어, 내용은 한국어

## Vault Structure (초안)

```
vault/
├── 0-inbox/          # 새 노트가 처음 생기는 곳
├── 1-zettelkasten/   # 정리된 원자적 노트
├── 2-maps/           # MOC (Map of Contents) — 주제별 인덱스 노트
├── templates/        # 노트 템플릿
│   ├── zettel.md
│   └── moc.md
└── .obsidian/        # Obsidian 설정
```

## Note Template (초안)

```markdown
---
id: {{YYYYMMDD}}{{HHmmss}}
title: {{title}}
tags: [{{tags}}]
created: {{date}}
source: claude-session
related: []
---

# {{title}}

{{content}}

## Links
- {{wikilinks with relationship type}}

## Source
- Claude Code 세션 ({{date}})
```

## Resolved Questions

1. **vault 경로 설정** → command 첫 실행 시 사용자에게 물어보고 저장
2. **노트 ID 체계** → 타임스탬프 기반 (`202603091430-react-use-transition.md`)
3. **기존 노트 스캔 범위** → MOC 기반 탐색 (MOC를 먼저 읽고, 관련 MOC에 연결된 노트만 깊이 탐색)
4. **auto-invoked skill 트리거** → 사용자 명시적 요청 시만 ("내 노트에서 찾아봐", "이전에 정리한 거 있어?" 등)
5. **다국어 처리** → 혼용 (제목/태그는 영어, 내용은 한국어)
