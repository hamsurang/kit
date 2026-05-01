---
title: "feat: Add desirable-difficulty hooks to personal-tutor skill"
type: feat
status: completed
date: 2026-04-25
origin: docs/brainstorms/2026-04-25-personal-tutor-desirable-difficulty-requirements.md
---

# feat: Add desirable-difficulty hooks to personal-tutor skill

## Overview

`plugins/personal-tutor/skills/personal-tutor/SKILL.md`의 학습 protocol을 변경해, Bjork의 *desirable difficulty* 원리를 학습 사이클 세 지점(Generation / Cold quiz / Hint follow-through)에 분포시킨다. 같은 세션 안에서는 노드가 `understood`로 절대 승급하지 못하도록 protocol 차원에서 차단해 fluency illusion을 끊고, 힌트 사용 통과는 다음 세션 cold quiz로 자동 follow-up되도록 한다. 노드 메타데이터를 확장(`knowledge-graph-template.md`)해 cold-quiz pending 잔고와 직전 quiz 형식을 추적한다.

---

## Problem Frame

`personal-tutor`는 Phase 3에서 가르친 직후 같은 세션 Phase 4 quiz로 노드를 승급시킨다. 정답이 학습자의 워킹메모리에 echo된 상태에서 retrieval이 일어나기 때문에, 사용자가 직접 보고한 대로 "세션에 정답지가 있어서 quiz가 너무 쉽다"는 신호가 발생한다. SKILL.md의 명시적 룰(`partial → understood: passed quiz today WITHOUT hints` AND `prior session partial`)은 이미 spacing을 *기록*상으로 요구하지만, Phase 2의 review 슬롯이 oldest partial 노드를 *재교육 후 quiz*하는 구조라 **진짜 cold retrieval이 한 번도 발화되지 않은 채** 노드가 `understood`로 올라가는 경로가 열려 있다. 이 plan은 (1) Phase 3에 generation 단계를 박고, (2) 같은 세션 quiz의 효과를 `partial`까지로 묶고, (3) 다음 세션 시작에 *재교육 없는* cold quiz를 의무 protocol로 만든다.

(see origin: `docs/brainstorms/2026-04-25-personal-tutor-desirable-difficulty-requirements.md`)

---

## Requirements Trace

- R1. Explain 전 학습자 추측·시도 1턴 요청
- R2. 빈 답·"모르겠다"엔 strategic hint 한 줄만, 답을 흘리지 않음
- R3. Explain은 학습자 추측을 명시적으로 인용·비교
- R4. Phase 4 quiz는 "warm quiz", 효과는 `gap → partial`까지
- R5. **Cold-quiz scheduler (sole trigger).** 신개념을 warm quiz로 통과한 모든 노드(힌트 유무 무관)는 `Cold quiz pending: yes` 표식과 함께 다음 세션 cold quiz로 자동 schedule된다. 다음 세션은 시작 시 cold quiz를 먼저 실행한다. warm quiz를 *실패한* 노드는 schedule되지 않으며 기존 agenda re-pick 메커니즘으로 다음 세션에 다시 가르친다.
- R6. cold quiz는 직전 warm quiz와 다른 형식
- R7. `partial → understood`의 유일한 경로 = 힌트 없는 cold quiz 통과
- R8. cold quiz 실패는 quiz history에 `cold: failed` prefix로 기록. cold quiz 실패는 기존 SKILL.md Phase 5의 "2회 연속 실패 시 `partial → gap` 강등" 룰의 카운트에 *포함된다* (R8은 그 강등 룰을 *생성*하지 않고 *scope-extend*함). **3-strike 강등 룰 (신규)**: hint-pass loop 방지를 위해, cold quiz를 *no-hint로 통과하지 못한 채* 3회 연속(failed 또는 hint-passed)으로 시도된 노드는 `partial → gap`으로 강등 후 다음 세션 다른 각도로 재교육. 이는 기존 "2회 연속 실패 강등" 룰을 보완한다 (실패 2회로도, 혼합 3회로도 강등 가능).
- R9. **Hint-pass forcing rule.** 힌트 사용 warm quiz 통과는 R5의 schedule을 명시적으로 *force*한다 — no-hint pass는 R5만으로 schedule되고, hint-pass는 R5 + R9 양쪽으로 schedule된다(결과 동일). R9의 행동 의미는 "힌트 사용은 다음 세션 cold quiz 비용을 자동 발생시킨다"는 명시적 학습자 신호.
- R10. cold-quiz pending 잔고 ≥ 1이면 *신개념 슬롯* cap을 1로 하향 (review 슬롯 1개와 cold quiz 슬롯들은 cap 외 별도 단위). 잔고 0이면 신개념 cap = 1-2 (기존 유지).
- R11. 한 세션 cold quiz 최대 2개
- R12. Iron Rule 신설: 같은 세션에 처음 가르친 노드를 같은 세션에서 `understood`로 승급 금지

**Origin actors:** A1 (학습자/사용자), A2 (Claude 튜터)
**Origin flows:** F1 (신개념 학습 세션, Phase 3-5 변경), F2 (다음 세션 시작 cold quiz)
**Origin acceptance examples:** AE1 (R1, R3), AE2 (R2), AE3 (R5, R6, R7), AE4 (R9), AE5 (R10)

---

## Scope Boundaries

- Closed-book 모드(답 참조 차단) 도입하지 않음 — 학습 지속성 보호
- "다음 세션 첫 5분 기억으로 코드 재작성"은 의무화하지 않음 — 옵션 후크로 보조
- 새 quiz 형식(현재 Feynman/Apply/Analyze 외) 추가는 별개 작업
- 학습자별 desirable-difficulty 임계값 자동 캘리브레이션은 v1 이후
- 30일 stale check를 cold-quiz 결과 기반으로 동적 조정하는 작업은 본 plan 범위 밖
- 본 plan은 `personal-tutor` 스킬 한정 — 동일 원리를 다른 스킬에 이식하지 않음
- Phase 2 review 슬롯(oldest partial 재교육)의 fluency-illusion 위험 자체는 본 plan에서 정면으로 다루지 않음. 단 review slot은 cold-fail 누적 노드의 stranded-partial 방지를 위해 *upgrade-equivalent escape valve* 역할로 일부 변경된다 (Phase 5 Upgrade rules path B 참조). 재교육 후 warm-quiz가 cold retrieval을 *대체*하는 경우는 여전히 차단됨

---

## Context & Research

### Relevant Code and Patterns

- `plugins/personal-tutor/skills/personal-tutor/SKILL.md` — 현재 5단계 protocol 본문. 모든 변경의 1차 대상.
- `plugins/personal-tutor/skills/personal-tutor/knowledge-graph-template.md` — 노드 sub-block 형식. 메타데이터 확장 위치.
- `plugins/personal-tutor/README.md` — 스킬 외부 설명. R12 Iron Rule 신설 등 사용자 가시 변경은 README 동기화 검토.
- `docs/plans/2026-03-01-personal-tutor-plan.md` — 원본 구현 plan. 노드 lifecycle 룰("partial → understood: prior session partial AND no hints")의 *의도*가 본 plan과 정합. 본 plan은 그 의도를 protocol 차원으로 강제하는 단계.

### Institutional Learnings

- `docs/solutions/`에 personal-tutor 또는 학습과학 관련 학습 문서 없음. 본 plan이 향후 reference가 될 가능성.

### External References

- 본 작업의 외부 references는 origin 문서에서 carry — Bjork(desirable difficulty), Roediger & Karpicke(retrieval practice), Slamecka & Graf(generation effect), Anderson(절차기억 3단계), Sweller(인지부하). 추가 외부 research 불필요.

---

## Key Technical Decisions

- **노드 메타데이터는 sub-block에 라인 추가**: 현재 `Status / Depth / Prerequisites / Quiz history` 4-line 구조에 `Cold quiz pending: yes|no` (정확히 이 표기 — hyphen 없음, 첫 단어만 대문자), `Last quiz format: feynman|apply|analyze|none`을 같은 형태로 추가. 별도 컬럼·테이블·외부 파일을 만들지 않는다 — 가독성과 grep 친화성 우선, 템플릿 변경 최소화.
- **세션 cap = 1 (신개념 슬롯 한정) when cold-quiz pending**: cold quiz 잔고 ≥ 1이면 신개념 슬롯 cap을 1로 하향. review 슬롯 1개와 cold quiz 슬롯들은 cap 외 별도 단위. 즉 잔고 2 + 신개념 1 + review 1 = 4단위 세션. 이유: (1) 세션 길이 일관성, (2) Cognitive Load 보호 — cold retrieval은 작업기억 부하가 높으므로 신개념을 줄여 균형, (3) 매 세션 의사결정 부담 안 짊어짐.
- **Quiz history 형식 확장으로 warm/cold 구분**: 기존 자유 형식을 `warm: passed (no hint)` / `cold: passed (no hint)` / `cold: failed` 식 prefix 컨벤션으로 통일. 새 필드를 만들지 않고 기존 array에 의미만 부여.
- **Cold quiz 형식 선택 룰**: 직전 warm/cold quiz *통과* 형식과 다른 형식을 의무 사용(R6). 회전은 Bloom 깊이 진행 방향으로 deterministic — `Feynman → Apply → Analyze → Apply → Analyze → Apply ...`. Analyze 통과 노드는 다음에 Apply 고정 (Bloom 가장 얕은 Feynman으로 가지 않고 retrieval 강도 유지). 이는 단순 "다른 형식 random"보다 학습 깊이 progression과 정합적이며, depth 갱신 룰(Phase 5 기존 "Quiz format이 Apply였고 통과 → depth toward `apply`")과도 일관. Fail 노드는 Finding 6 룰에 따라 escalation 절대 금지(같은 형식 retry 또는 한 단계 down).
- **Cold quiz 위치 = 새 Session Start step**: Phase 2 agenda planning *앞*에 새 step("Phase 2.0: Cold Quiz Sweep")으로 추가. agenda 조정도 cold-quiz 잔고에 의존하므로 cold quiz가 먼저 와야 cap 룰이 잔고를 정확히 알고 결정 가능.
- **첫 세션엔 cold quiz 발생 안 함**: 직전 세션이 없어 자동으로 발생 안 함 — 별도 조건문 불필요, Phase 1 Socratic Diagnostic 흐름 보존.
- **Iron Rule 신설**: rule statement는 정확히 한 문장으로만 — `Never advance a node to \`understood\` within the same session it was first taught.` 룰 본문에 Phase 5 메커니즘 설명을 섞지 않는다(가독성과 drift-방지 동시 충족). Implementation enforcement(Phase 5 Upgrade rules의 cross-session 게이트)는 plan U3 Approach에 별도 implementation note로 분리.

---

## Open Questions

### Resolved During Planning

- **Cold quiz 형식 선택 룰 (deterministic)**: `Feynman → Apply → Analyze → Apply → ...` 회전. Analyze 통과 후 Apply 고정. fail 노드는 `Last quiz format` 갱신 안 하고 same-format retry 또는 한 단계 down (escalation 금지).
- **메타데이터 표현 방식**: sub-block 6-line. canonical 표기 `Cold quiz pending: yes|no` (hyphen 없음, 첫 단어 대문자), `Last quiz format: feynman|apply|analyze|none`.
- **Quiz history warm/cold 구분**: prefix 컨벤션 — `warm: passed (no hint|hint used)`, `warm: failed`, `cold: passed (no hint|hint used)`, `cold: failed`.
- **Cold quiz 발생 위치**: Session Start 분기 — pending ≥ 1이면 Phase 2.0, 잔고 0이면 직접 Phase 2로.
- **Review 슬롯 동작 변경 범위**: 진입·재교육은 기존 동작 유지. 단 *upgrade 효과*가 path B로 확장 (cold-fail 누적 노드의 escape valve). Predict는 review에 적용 *안 함* (R1이 새 개념에 한정).
- **Cold-quiz pending 트리거 (R5/R9 분리)**: R5는 *sole scheduler* — 모든 신개념 warm-pass(힌트 유무 무관) 노드를 schedule. R9는 *forcing rule* — 힌트 사용 통과를 명시적으로 force (결과는 R5와 동일하지만 학습자 신호 명시).
- **`partial → understood` 승급 경로**: path A (cold quiz no-hint pass, 다음 세션) + path B (review-slot warm pass + cold-attempt 이력). Phase 5 self-audit hook이 둘 중 하나의 이력을 강제 검증.
- **3-strike 강등 룰**: cold quiz no-hint pass 없이 3회 연속 mix(failed + hint-passed)면 partial→gap. 기존 "2회 연속 failed" 룰과 함께 작동.
- **Streak counter**: no-hint pass는 prefix 무관 reset. failed와 hint-passed는 카운트 포함.
- **Backward-compat 정책**: read-time default + write-time gradual upgrade (touched 노드만 6-line으로 expand). 일괄 마이그레이션 불필요.
- **Iron Rule #6 enforcement**: Phase 5 archive에 self-audit hook으로 mechanical enforcement.

### Deferred to Implementation

- **README.md 동기화 (의무화됨, U4 Verification에 명시)**: Session Flow + Applied Learning Science + Phase 4 명칭 모두 반드시 동기화.
- **Cold quiz 시 review 슬롯 처리 — short-session 케이스**: 잔고 2 + review 1 + new 1 = 4단위가 학습자 시간 제약을 넘는 경우의 escape valve(예: 학습자가 cold skip 요청 시 1회 한정 허용)는 implementation walkthrough에서 검증 후 결정.
- **`Phase 2.0` 첫 발화의 학습자 안내 톤**: cold quiz 시작 전 "오늘은 검증부터 시작합니다" 같은 1-line preamble을 protocol에 명시할지 (implementation 시점에 walkthrough로 결정).

---

## Implementation Units

- U1. **Knowledge graph schema extension**

**Goal:** 노드 sub-block에 cold-quiz pending 잔고와 직전 quiz 형식을 표현할 수 있는 필드를 추가하고, quiz history의 warm/cold 구분 컨벤션을 문서화한다. 다른 모든 unit이 이 스키마 위에서 동작.

**Requirements:** R8, R9 (메타데이터 read/write 기반)

**Dependencies:** None

**Files:**
- Modify: `plugins/personal-tutor/skills/personal-tutor/knowledge-graph-template.md`

**Approach:**
- 노드 sub-block의 4-line(`Status / Depth / Prerequisites / Quiz history`)에 두 줄 추가:
  - `Cold quiz pending: no` (default)
  - `Last quiz format: none` (default)
- 템플릿 하단 주석에 quiz history prefix 컨벤션 명시 — `warm: passed (no hint)`, `warm: passed (hint used)`, `cold: passed (no hint)`, `cold: failed` 네 가지가 표준.
- 기존 노드 마이그레이션은 *일괄 작업 불필요* — read-time backward-compat (누락 필드는 default로 간주, U2의 한 줄 룰)와 write-time gradual upgrade (touched 노드만 6-line으로 expand) 조합으로 처리. 즉 (a) Phase 5 archive가 update할 때마다 *그 노드만* sub-block을 6-line 형식으로 재작성(default 채움), (b) update되지 않은 노드는 4-line 그대로 유지. 시간이 지나면서 자연스럽게 migrate되며, 한 파일 안에 6-line/4-line 노드가 공존해도 read-time default 룰이 처리.

**Patterns to follow:**
- 현재 4-line sub-block 형식을 그대로 따라 라인 추가. 새 컬럼·테이블·별도 파일 도입 금지.
- 템플릿 하단 `<!-- Depth scale ... -->` 주석 패턴을 mirror해 "Quiz history convention" 주석을 같은 위치에 추가.

**Test scenarios:**
- 스키마 자체는 behavioral 변화 없음 (dormant 필드 추가).
- Test expectation: none — pure scaffold; 동작 검증은 U2-U4의 walkthrough 시나리오에서 수행.

**Verification:**
- 새 토픽 처음 시작 시(첫 세션) 생성되는 `knowledge-graph.md`의 모든 노드 sub-block에 6개 라인이 들어 있고, default 값이 `Cold quiz pending: no` / `Last quiz format: none`으로 출력된다.
- 템플릿 하단 주석에 quiz history prefix 컨벤션 4종이 명시되어 있다.

---

- U2. **Phase 3 — Generation-first turn**

**Goal:** Phase 3 Teaching loop의 첫 단계를 "Predict"로 변경한다. Claude가 새 개념을 Explain하기 전에 학습자에게 추측·시도 1턴을 의무로 요청하고, "모르겠다" 답에는 strategic hint 한 줄만 주며, Explain 본문은 학습자의 추측을 명시적으로 인용·비교한다.

**Requirements:** R1, R2, R3 (covers AE1, AE2)

**Dependencies:** U1 (스키마는 의존하지 않지만, U1과 함께 atomic하게 합쳐 한 PR로 가는 게 자연스러움 — sequencing 우선순위는 U1 → U2)

**Files:**
- Modify: `plugins/personal-tutor/skills/personal-tutor/SKILL.md` (Phase 3 섹션)

**Approach:**
- Phase 3 Teaching loop을 다음 순서로 명시 변경:
  1. **Predict** — "이 개념이 어떻게 동작할 거 같으세요? 한 줄 추측이라도 좋습니다" (의무, 새 개념마다)
  2. 학습자 답 듣기. 빈 답·"모르겠다"인 경우 strategic hint 한 줄만 (전체 답 금지) → 다시 시도
  3. **Explain** — 학습자 추측을 명시적으로 인용·비교 ("추측한 대로 ~지만, 추가로 ~")
  4. **Socratic Q&A** (기존)
  5. 이해 확인 (기존)
- Review 노드(oldest partial 재방문)에는 Predict 단계를 *적용하지 않는다*. R1이 "새 개념"으로 한정함을 따르고, Scope Boundaries의 "review 흐름의 진입·재교육은 기존 동작 유지"와 정합. review 슬롯은 재교육 + warm quiz + (Finding 5의 path B) upgrade-equivalent escape valve로만 작동.
- "Strategic hint"의 정의를 SKILL.md에 한 줄로 박음: "최소 정보(키워드 한 글자, 카테고리 힌트)만. 정답 동사·구조·관계어는 흘리지 않는다."
- backward-compat 한 줄 추가 (U1 마이그레이션 위임처): "노드 sub-block에 `Cold quiz pending` 또는 `Last quiz format` 필드가 누락되었으면 default(`no` / `none`)로 간주하고 진행."

**Patterns to follow:**
- 현재 Phase 3 "Loop for each concept in agenda" 형식 유지, 단계 번호만 갱신.
- 현재 "If stuck or confused: analogy → code example → reverse question" 가이드는 Explain 이후 단계로 보존 — Predict 단계의 strategic hint와 충돌하지 않음.

**Test scenarios:**
- *Walkthrough — Happy path (Covers AE1).* 학습자가 Rust `borrow` 학습 시작 → Claude가 "ref와 borrow가 어떻게 다를 거 같으세요? 한 줄 추측이라도" 질문 → 학습자 "값을 빌려주는데 소유권은 안 넘긴다고 생각합니다" 답 → Claude의 Explain이 "추측한 대로 소유권은 그대로지만, 추가로 lifetime이 추적됩니다" 식으로 *명시적으로* 비교.
- *Walkthrough — Edge case (Covers AE2).* 학습자가 "전혀 모르겠어요"라고 답함 → Claude는 즉시 Explain으로 넘어가지 않고 "한 글자 힌트: 이 키워드는 'borrow'와 짝을 이룹니다. 다시 추측?" 같은 minimal hint만 → 학습자 두 번째 시도 → 그제서야 Explain 진행.
- *Walkthrough — Error path.* 학습자가 strategic hint 받고도 "여전히 모르겠어요" 답함 → Claude는 *세 번째 hint를 주지 않고* Explain으로 진행, 단 Explain 시작 첫 줄이 "추측이 어렵다고 느꼈죠? 그 자체가 신호입니다 — 이 개념은 X와 Y의 교차점이라" 식으로 *generation 시도 자체를 인용*.
- *Walkthrough — Review slot.* Phase 2가 review로 oldest partial 노드 1개 선정 → Phase 3 loop이 그 노드도 Predict 단계로 시작 → 학습자가 (이미 partial이므로) 더 정확한 추측 → Explain은 그 추측을 confirm·정정 형태로.

**Verification:**
- Phase 3 텍스트가 "Explain → Q&A" 순서를 명시적으로 "Predict → Explain → Q&A"로 갱신했다.
- "Strategic hint" 정의 한 줄이 SKILL.md에 명문화되어 있다.
- 메타데이터 누락 노드 backward-compat 룰이 Phase 3 또는 Session Start 섹션에 한 줄로 명시되어 있다.

---

- U3. **Phase 4-5 — warm quiz semantics, hint follow-through, Iron Rule**

**Goal:** Phase 4 quiz를 "warm quiz"로 명명하고 효과를 `gap → partial`까지로 한정한다. Phase 5 archive에서 힌트 사용 통과 노드에 `Cold quiz pending: yes` 표식을 붙이고 `Last quiz format`을 기록한다. Iron Rules에 R12를 신설.

**Requirements:** R4, R7, R8, R9, R12 (covers AE3 부분: "같은 세션 안에서 절대 understood로 가지 않는다", AE4)

**Dependencies:** U1 (스키마)

**Files:**
- Modify: `plugins/personal-tutor/skills/personal-tutor/SKILL.md` (Phase 4 섹션, Phase 5 Step 1, Iron Rules 섹션)

**Approach:**
- **Phase 4 변경**:
  - 현재 SKILL.md의 정확한 섹션 제목 `Phase 4: Verification Quiz`를 `Phase 4: Warm Quiz`로 rename. "Verification" 기능(노드의 진짜 검증)은 새 `Phase 2.0: Cold Quiz Sweep`(U4)으로 이전됨을 섹션 도입부에 한 줄로 명시. README.md "Session Flow"의 `Quiz: Feynman / Apply / Analyze (rotate)` 라인은 U4 README sync에서 같이 갱신.
  - 첫 줄에 명시: "이 단계는 *warm* quiz이며, 통과 효과는 `gap → partial`까지로 한정된다. 노드를 `understood`로 승급하지 않는다."
  - 기존 "Track hint usage" 섹션 유지, 단 force-hooks 추가:
    - 통과 시 `Last quiz format` 갱신
    - **모든 신개념 warm-pass(힌트 유무 무관) → `Cold quiz pending: yes`** (R5 scheduler — 단일 트리거. 힌트 사용은 R9에 의해 추가로 force되지만 결과는 동일).
    - **warm 실패 → `Cold quiz pending` set되지 않음.** R5는 통과 노드만 schedule. 실패 노드는 다음 세션에 agenda re-pick으로 재교육.
  - quiz history 기록 시 `warm:` prefix 사용
- **Phase 5 self-audit hook (drift 방지)**: knowledge-graph.md write 직전, 이번 세션에 `partial → understood`로 승급된 *모든* 노드를 점검. 각 노드의 quiz history에 다음 중 하나가 *반드시* 있어야 한다 — (a) prior session의 `cold: passed (no hint)` 항목 (path A), 또는 (b) prior session의 `cold:` 시도 이력 + 이번 세션의 review-slot warm pass (no hint) (path B). 없으면 승급 취소하고 `partial` 유지. Iron Rule #6의 mechanical enforcement.

- **Phase 5 Step 1 (Update node states) 변경**:
  - "Upgrade rules" 블록을 다음으로 갱신:
    - `gap → partial`: warm quiz 통과 (hint OK) — 기존 유지
    - `partial → understood` (path A — primary): **cold quiz 통과** AND no hint — *경로 명시*
    - `partial → understood` (path B — review-slot escape valve): **review-slot warm quiz 통과** AND no hint AND 노드가 이미 prior session에서 cold quiz 적어도 1회 시도된 이력 보유. 이는 cold-fail 누적 노드의 stranded-partial 방지용. review slot은 재교육 동반이라 worst case에도 fluency illusion 위험이 작음 (cold quiz 시도 이력이 retrieval 차원의 검증을 이미 거쳤음을 보장).
  - "Never downgrade a node" 룰은 유지하되, 강등 streak counter를 명시: quiz history의 *연속한 entries*만 본다. `passed (no hint)`는 prefix(warm/cold) 무관하게 streak reset. `failed`와 `passed (hint used)`는 둘 다 카운트 포함. (a) 2회 연속 `failed` (warm 또는 cold) → 강등, 또는 (b) 3회 연속 mix (`failed` + `passed (hint used)`, no-hint pass 0회) → 강등. 둘 중 하나라도 트리거되면 즉시 `partial → gap`.
  - Depth progression 룰("Quiz format이 Apply였고 통과 → depth toward `apply`") 유지 — warm/cold 양쪽 모두 적용.
- **Iron Rules 갱신**:
  - 신규 룰 #6 (rule statement만): `Never advance a node to \`understood\` within the same session it was first taught.`
  - Implementation note (별도 줄, Iron Rule 텍스트엔 포함되지 않음): 이 룰은 Phase 5 Upgrade rules의 path A(cold quiz no-hint pass — 다음 세션) / path B(review-slot escape valve — 다음 세션) 양쪽 모두 cross-session 게이트를 가짐으로써 enforced.
  - 기존 5개 룰은 그대로 유지, 신규 룰은 #6으로 추가.
- **README.md 동기화 검토**: "Session Flow" 다이어그램의 "Quiz: Feynman / Apply / Analyze (rotate)" 줄이 warm-only 동작이 됐다는 점 — 동기화 필요 여부 implementation 시점에 판단.

**Patterns to follow:**
- 현재 Iron Rules 번호 매김 형식(`1. **Never end...**`) 그대로 따라 #6 추가.
- 기존 "Upgrade rules" 두 줄 형식 유지, cold quiz 경로만 추가 명시.
- Phase 5 archive Step 1/2/3 구조 유지 — Step 1 텍스트만 변경, Step 2(세션 로그)와 Step 3(learner profile)은 변경 없음.

**Test scenarios:**
- *Walkthrough — Happy path (Covers AE3 part 1).* 학습자가 새 개념 `&mut`을 Phase 3에서 학습 → Phase 4 Warm quiz Feynman 통과 (no hint) → Phase 5: 노드 `gap → partial`, `Cold quiz pending: yes`, `Last quiz format: feynman`, history에 `warm: passed (no hint)`. **`understood`로 직접 승급되지 않는다.**
- *Walkthrough — Edge case (Covers AE4).* 학습자가 어제 'lifetime' warm quiz를 *힌트 한 번 받고* 통과 → Phase 5 archive에 `Cold quiz pending: yes`, history에 `warm: passed (hint used)`, status는 `partial`.
- *Walkthrough — Error path.* warm quiz 실패 → Phase 5에서 status 변경 없음 (gap 유지), history에 `warm: failed`, `Cold quiz pending: no` 유지.
- *Walkthrough — Iron Rule enforcement.* Claude가 같은 세션에서 가르친 신개념을 Phase 5에서 `understood`로 승급하려 시도 시, Iron Rule #6에 의해 차단 — 어떤 우회 경로(예: warm quiz format=Feynman + 학습자가 매우 잘 답했음)도 인정되지 않는다.
- *Walkthrough — Depth progression.* warm quiz 형식이 Apply였고 통과(no hint) → 노드 status `partial` (still), depth는 `recall → apply`로 갱신. depth는 cold quiz 게이트와 *독립적*으로 진행됨을 검증.

**Verification:**
- Phase 4 첫 줄이 warm quiz의 효과 한도(`gap → partial`까지)를 명시한다.
- Phase 5 Upgrade rules 블록이 `partial → understood`의 유일한 경로로 cold quiz를 명시한다.
- Iron Rules에 신규 룰 #6이 추가되어 있다.
- 한 세션 walkthrough 후 노드 sub-block의 6개 필드가 모두 적절히 채워진다(특히 `Cold quiz pending`).

---

- U4. **Phase 2.0 cold quiz sweep & session capacity policy**

**Goal:** Session Start와 Phase 2 사이에 새 step "Phase 2.0: Cold Quiz Sweep"을 추가해 직전 세션 신개념 + cold-quiz pending 노드를 *재교육 없이* cold retrieval로 검증하고, Phase 2 agenda planning에 cap 정책(잔고 있으면 신개념 cap=1, 한 세션 cold quiz 최대 2개)을 통합한다.

**Requirements:** R5, R6, R7 (승급 경로 완성), R8, R10, R11 (covers AE3 part 2, AE5; F2 전체)

**Dependencies:** U1 (스키마), U3 (warm quiz가 pending 표식을 채워주어야 sweep 대상 존재)

**Files:**
- Modify: `plugins/personal-tutor/skills/personal-tutor/SKILL.md` (Session Start 섹션, 새 Phase 2.0 섹션, Phase 2 섹션, Phase 5 Step 1 cold quiz 결과 처리 보강)
- Modify: `plugins/personal-tutor/README.md` — *의무*. (a) "Session Flow" 다이어그램에 Phase 2.0 노드 추가, (b) "Applied Learning Science" 표에 Generation Effect와 Desirable Difficulty 두 행 추가, (c) Phase 4 명칭 "Verification Quiz" → "Warm Quiz" 동기화.

**Approach:**
- **Session Start 변경**:
  - 기존 "Exists → load it + learner-profile.md → jump to Phase 2"에서 → 변경: "Exists → load → cold-quiz pending 노드가 1개 이상이면 **Phase 2.0** (Phase 2 앞단)으로, 잔고 0이면 직접 **Phase 2**로 (Phase 2.0 sweep 자체를 스킵하며 학습자에게 별도 announcement 없음)"
  - "Not exists → create → start Phase 1" — 변경 없음 (첫 세션엔 cold quiz 발생 안 함)
- **신규 섹션 "Phase 2.0: Cold Quiz Sweep"**:
  - **Trigger:** 노드 중 `Cold quiz pending: yes`가 1개 이상.
  - **Selection:** pending 노드 중 가장 오래된 것부터 최대 **2개**(R11). 직전 세션 신개념을 우선.
  - **Format selection (R6, deterministic):** 노드의 `Last quiz format`(통과 형식만 기록됨) 다음 단계로:
    - feynman → apply
    - apply → analyze
    - analyze → apply (고정 — Feynman으로 회귀하지 않음)
    - none(no prior pass) → feynman (default 시작 형식)
  - **Execution rule (재교육 금지):** Claude는 cold quiz 실행 *전에* 해당 개념을 다시 설명·요약·hint하지 않는다. 학습자에게 곧장 quiz 프롬프트만 제시.
  - **Pass/Fail 처리:**
    - 힌트 없이 통과 → `partial → understood`, `Cold quiz pending: no`, history에 `cold: passed (no hint)`, `Last quiz format` 갱신.
    - 힌트 사용 통과 → status 유지(`partial`), `Cold quiz pending: yes` 유지(다음 세션 재시도), history에 `cold: passed (hint used)`, `Last quiz format` 갱신.
    - **실패 → status 유지, `Cold quiz pending: yes` 유지, history에 `cold: failed`, `Last quiz format` *갱신하지 않음*** (직전 *통과* 형식만 기록되도록 보존). 기존 "2회 연속 실패 시 강등" 룰은 *cold quiz 실패도 카운트*에 포함.
  - **Fail 후 retry 형식 룰 (escalation 방지):** cold fail 노드의 다음 cold quiz는 (a) 같은 형식으로 retry (same-format), 또는 (b) 한 단계 down (Apply→Feynman, Analyze→Apply). escalation 절대 금지. Bloom-progression rotation은 *통과* 노드에만 적용.
- **Phase 2 변경 (capacity policy)**:
  - "Session composition" 첫 줄에 cap 룰 추가:
    - cold-quiz pending 잔고가 있는 세션: 신개념 cap = **1** (R10).
    - 잔고 없는 세션: 신개념 cap = **1-2** (기존 유지).
  - Review 슬롯 1개는 기존 그대로. Review 노드 선정 룰(oldest partial / 30일 stale understood) 변경 없음.
  - Agenda 발표는 Phase 2.0 cold quiz 결과를 알려준 *직후*에. 학습자가 해당 세션의 단위 수를 사전에 알 수 있도록.
- **Phase 5 Step 1 보강**: cold quiz 결과 처리 룰을 명시적으로 추가(위 "Pass/Fail 처리" 룰을 Phase 5 Upgrade rules와 일관되게 명문화). "Quiz history" 기록 시 `cold:` prefix 사용.
- **Early Session Exit 호환성**: 학습자가 Phase 2.0 cold quiz 실행 중 세션 중단 시, 이미 진행한 cold quiz 결과만 archive하고 미실행 pending은 그대로 유지(다음 세션에 sweep 재실행).

**Patterns to follow:**
- 새 섹션 "Phase 2.0"의 본문 형식은 기존 Phase 2-5와 동일한 H2 + 본문 + 코드블록 패턴.
- Format selection 룰은 표 또는 단순 화살표 표기 — 기존 Phase 4 quiz 표("| Format | Prompt style | Tests |") 형태와 mirror할지 implementation 시점 결정.

**Execution note:** 본 unit 변경 후 *반드시* 전체 SKILL.md를 새 토픽 시작 → 1세션 학습 → 다음 세션 cold quiz 시퀀스로 walkthrough하여 모든 R-ID가 protocol 차원에서 강제됨을 확인.

**Test scenarios:**
- *Walkthrough — Happy path (Covers AE3 part 2).* 지난 세션 `&mut`을 warm quiz Feynman 통과 → 이번 세션 시작: Session Start → Phase 2.0 cold quiz sweep → 노드 `&mut` 발견(`Cold quiz pending: yes`, `Last quiz format: feynman`) → format selection rule이 Apply 선택 → Claude가 *재교육 없이* 곧장 코드 한 토막의 버그 찾기 출제 → 학습자 힌트 없이 통과 → `partial → understood`, `Cold quiz pending: no`, history `cold: passed (no hint)`.
- *Walkthrough — Capacity rule (Covers AE5).* 학습자가 어제 신개념 2개를 학습해 cold-quiz pending 2개 → 이번 세션: (1) Session Start가 잔고 ≥ 1 감지 → Phase 2.0으로 진입, (2) Phase 2.0이 *재교육 없이* cold quiz 2개 실행, (3) cold 결과 확정 후 Phase 2 agenda planning 시작 — 이 시점에 잔여 잔고를 반영해 cap=1 결정 (예: cold 1개 통과 + 1개 실패면 pending 1 잔존), (4) Phase 2 agenda가 신개념 1개 + review 1개 발표. 학습자에게 announce: "오늘 cold(완료) 2 + 신개념 1 + review 1 = 4단위." 잔고 0이었다면 Session Start가 직접 Phase 2로 → 신개념 2개 + review 1개 = 3단위.
- *Walkthrough — Cold quiz fail.* cold quiz 실패 → status `partial` 유지, `Cold quiz pending: yes` 유지, history `cold: failed`. 다음 다음 세션 시작에 다시 sweep 대상.
- *Walkthrough — Cold quiz fail twice (Covers R8 강등).* 같은 노드가 cold quiz 2회 연속 실패 → 기존 "2회 연속 실패 시 partial→gap" 룰 적용 → status 강등, `Cold quiz pending` 자동 `no` (gap 노드는 sweep 대상 아님), 다음 세션엔 다른 각도로 재교육.
- *Walkthrough — First session edge case.* 새 토픽 첫 세션 → Session Start: not exists → Phase 1 Socratic Diagnostic 진행, Phase 2.0 발생하지 않음. 첫 세션 끝 시점에 신개념 노드들이 `Cold quiz pending: yes`로 표식 → 두 번째 세션 시작에서 Phase 2.0 첫 발동.
- *Walkthrough — Cold quiz pending 잔고 ≥ 3.* 학습자가 여러 세션 누적해 pending이 3개 이상 → 이번 세션 sweep은 oldest 2개만, 나머지는 다음 세션으로 carry-over. agenda는 cap=1로 강제.
- *Walkthrough — Format selection deterministic.* 노드 `Last quiz format: apply` → cold quiz 형식 Analyze 선택. Feynman을 절대 선택하지 않음.
- *Walkthrough — Re-teaching prevention.* Claude가 cold quiz 실행 전에 해당 개념을 요약·hint하지 않는지 SKILL.md 본문에서 명시적 금지 문구로 보장.

**Verification:**
- Session Start의 분기 처리가 "Exists → Phase 2.0"로 갱신되었다.
- Phase 2.0 섹션이 H2로 존재하고 trigger / selection / format selection / pass-fail 룰이 모두 명문화되어 있다.
- Phase 2 Session composition 첫 줄에 cap 정책이 명시되어 있다.
- 두 세션 walkthrough(첫 세션 신개념 학습 → 두 번째 세션 cold quiz)가 SKILL.md 본문 흐름만으로 한 번도 protocol 외 추측을 요구하지 않고 진행 가능하다.
- README.md의 "Session Flow" 다이어그램이 Phase 2.0을 명시적으로 포함한다.
- README.md의 "Applied Learning Science" 표가 Generation Effect와 Desirable Difficulty 두 행을 포함한다.
- README.md의 Phase 4 명칭이 "Warm Quiz"로 갱신되었다.

---

## System-Wide Impact

- **Interaction graph:** 본 변경은 `plugins/personal-tutor` 스킬 내부에 한정. `~/.claude/learning/` 디렉토리 구조 자체는 변경 없음 (sub-block 라인만 추가). 기존 사용자의 누적 `knowledge-graph.md`는 누락 필드를 default로 간주하는 read-time backward-compat(U2)로 호환.
- **Error propagation:** cold quiz 실패는 노드 강등으로 자연스럽게 흘러가도록 기존 룰 재사용. 새 실패 모드(예: `Cold quiz pending: yes`인데 노드가 강등되어 gap이 된 경우) → Phase 2.0 sweep이 gap 노드를 sweep 대상에서 제외(`partial`만 sweep)하므로 정합.
- **State lifecycle risks:** `Cold quiz pending: yes`인 노드가 학습자의 학습 중단으로 영원히 partial로 남는 시나리오는 origin Dependencies/Assumptions에서 의도된 정직성으로 수용. 추가 가드 불필요.
- **API surface parity:** 외부 API/CLI 없음 — 스킬 내부 protocol 변경.
- **Integration coverage:** 두 세션을 잇는 transition이 새로 도입된 가장 중요한 cross-layer 포인트. U4의 walkthrough 시나리오가 이를 검증.
- **Unchanged invariants:**
  - Phase 1 Socratic Diagnostic 흐름 (변경 없음).
  - Phase 2 Review 슬롯 진입·선정 룰 (oldest partial 재방문 — 변경 없음). 단 통과 효과는 Phase 5 Upgrade rules path B로 확장됨 (cold-fail 누적 노드의 escape valve).
  - Phase 5 Step 2(세션 로그)와 Step 3(learner profile 업데이트) (변경 없음).
  - Iron Rules #1-#5 (그대로 유지, #6만 추가).
  - 30일 stale check (변경 없음).

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| 학습자가 Phase 2.0 cold quiz를 매 세션 부담으로 느껴 학습을 중단할 위험 (desirable의 정의 = 능력 범위 내) | R10/R11이 cap을 강하게 누름. 추가로 학습자가 "오늘 cold quiz skip"을 명시 요청하면 1회 한정 허용하는 escape valve를 향후 검토 (현 plan 범위 밖). |
| (해소됨 — `Analyze → Apply` deterministic 결정으로 변경) | — |
| 기존 사용자의 `knowledge-graph.md`에 새 메타데이터 필드가 없는 상태에서 변경 후 첫 세션 동작 | U2의 read-time default 룰이 처리. 별도 마이그레이션 스크립트 불필요. |
| Review 슬롯의 fluency-illusion 위험은 본 plan에서 다루지 않아 부분 해결 인상 | Scope Boundaries에 명시. cold quiz가 신개념에 한정됨을 README/SKILL.md 모두에 명료히 설명. |
| Iron Rule #6 추가가 기존 Iron Rules의 강도를 희석 | 새 Rule 문구를 기존 5개와 동일한 톤·형식 *한 문장*으로만 작성 (implementation note는 별도). Phase 5 self-audit hook으로 mechanical enforcement. |
| Long-context drift로 Iron Rule이 dilute될 위험 (Claude 자체가 runtime) | Phase 5 self-audit hook이 매 세션 archive 시점에 mechanical 점검 — 승급 노드의 quiz history에 cross-session 이력 강제. |
| Format rotation의 deterministic이 systematic 형식 약점을 가진 학습자에게는 여전히 노출 | learner-profile에 format별 통과율을 누적해 추후 자동 캘리브레이션 검토 (현 plan 범위 밖). |
| Cross-topic pending opacity — topic A의 pending이 topic B 작업 중 invisible | learner-profile 또는 세션 시작 시 cross-topic 알림은 v1 이후 검토. v1은 topic-별 격리 유지. |
| Phase 2.0 setup-prompt가 Apply-format 코드 스니펫의 구조 단서를 leak할 위험 | implementation 시점에 prompt 디자인 가이드라인을 별도 doc로 정리 (변수명 일반화, 함수 시그니처 minimal). |
| Generation-first의 *partially-correct* 추측 처리(가장 흔한 실제 케이스) 미정의 | Phase 3 implementation 시 walkthrough로 "추측이 부분적으로 맞으면 Explain은 맞는 부분 명시 confirm + 틀린 부분만 정정" 패턴 정의. |

---

## Documentation / Operational Notes

- README.md "Session Flow" 다이어그램에 Phase 2.0(cold quiz)을 추가, "Applied Learning Science" 표에 Generation Effect / Desirable Difficulty 두 행 추가.
- SKILL.md "Sections" 네비 한 줄에 Phase 2.0 링크 추가.
- 기존 `~/.claude/learning/topics/{topic}/knowledge-graph.md` 파일은 read-time backward-compat으로 호환 — 사용자에게 마이그레이션 안내 불필요.
- 본 plan의 walkthrough 결과(특히 두 세션 transition)가 잘 작동하면 `docs/solutions/` 아래 학습 패턴 문서로 추출 가능 (별개 후속).

---

## Sources & References

- **Origin document:** [docs/brainstorms/2026-04-25-personal-tutor-desirable-difficulty-requirements.md](../brainstorms/2026-04-25-personal-tutor-desirable-difficulty-requirements.md)
- Related code: `plugins/personal-tutor/skills/personal-tutor/SKILL.md`, `plugins/personal-tutor/skills/personal-tutor/knowledge-graph-template.md`, `plugins/personal-tutor/README.md`
- Related prior plan: `docs/plans/2026-03-01-personal-tutor-plan.md` (원본 스킬 구현)
- External (carried from origin): Bjork (desirable difficulty), Roediger & Karpicke 2006 (retrieval practice), Slamecka & Graf 1978 (generation effect), Anderson (절차기억 3단계 모델), Sweller (인지부하)
