---
date: 2026-04-25
topic: personal-tutor-desirable-difficulty
---

# Personal Tutor — Desirable Difficulty 강화

## Problem Frame

`personal-tutor` 스킬은 한 세션 안에서 가르침(Phase 3) 직후 같은 세션 퀴즈(Phase 4)로 노드를 승급한다. 이 구조에서는 정답이 학습자의 워킹메모리에 echo된 상태에서 retrieval이 일어나기 때문에, Bjork가 명명한 **fluency illusion** 그대로 — "이해한 것처럼 느끼는 단기 자가복제"가 `understood` 승급으로 이어진다. 사용자가 직접 사용 중 "세션에 정답지가 있어서 퀴즈가 너무 쉽다, 어려움 수준이 낮다"고 보고했으며, 이는 학습 사이클 어디에도 **desirable difficulty**(인지심리학에서 장기 보존·전이를 향상시키는 적정 수준의 마찰)가 의도적으로 배치되지 않은 결과다.

본 작업은 글의 세 가지 핵심 원리 — Generation Effect, Spacing, Retrieval depth — 를 protocol의 세 지점에 분포시켜 "통과 = 학습"의 등식을 끊고, 장기 보존을 보장하는 retrieval만이 노드를 승급시키도록 한다.

---

## Actors

- A1. **학습자 (사용자)** — 본인의 기술 학습을 위해 Claude와 멀티세션 튜터링을 진행. 한 번의 세션 길이가 길어지는 것보다 *진짜 남는 학습*을 우선시한다.
- A2. **Claude (튜터)** — 5단계 protocol을 실행하고, 노드 상태(`gap | partial | understood`)와 cross-topic learner profile을 갱신. 본 작업 후에는 generation/cold quiz/hint follow-through 세 가지 후크를 추가로 책임진다.

---

## Key Flows

- F1. **신개념 학습 세션 (Phase 3-5 변경)**
  - **Trigger:** 학습자가 새 개념 학습을 위해 세션 시작, agenda가 신개념을 포함
  - **Actors:** A1, A2
  - **Steps:**
    1. (Phase 3 시작) Claude가 학습자에게 **추측 1턴**을 먼저 요청 — "이 개념이 어떻게 동작할 거 같으세요? 한 줄이라도 좋습니다"
    2. 학습자 추측을 듣고, Claude는 그 추측을 *명시적으로 비교/연결*하며 Explain 진행
    3. Socratic Q&A → 이해 확인 (기존)
    4. (Phase 4) **Warm quiz** 실행 — 통과 시 `gap → partial`까지만 인정 (`understood`로 직접 승급 불가)
    5. 힌트 사용 여부 기록 → 힌트 사용 통과 노드는 **다음 세션 cold quiz pending** 표식
    6. (Phase 5 archive) 노드 상태 갱신, 세션 로그 기록
  - **Outcome:** 신개념 노드는 최대 `partial` 상태로 종료. 노드별 cold-quiz 예약 여부가 결정됨
  - **Failure path:** Generation 단계에서 학습자가 "전혀 모르겠다"고 답하면 R2의 strategic-hint 룰 적용

- F2. **다음 세션 시작 cold quiz (신규 흐름)**
  - **Trigger:** 학습자가 같은 topic의 다음 세션을 시작, 직전 세션이 신개념 학습이었거나 cold-quiz pending 노드가 있음
  - **Actors:** A1, A2
  - **Steps:**
    1. Claude가 agenda 발표 *전*에 cold quiz를 먼저 실행 (Phase 2 앞단)
    2. 대상 노드는 직전 세션의 신개념 + cold-quiz pending 표식이 붙은 노드
    3. 출제 형식은 직전 warm quiz와 *다른 형식*을 의무 사용 (Feynman→Apply, Apply→Analyze 등)
    4. 힌트 없이 통과 → `partial → understood`. 힌트 사용/실패 → `partial` 유지 + 실패 기록
    5. cold quiz 종료 후 평소 Phase 2 agenda planning 진행
  - **Outcome:** `understood` 승급의 *유일한* 경로가 cold quiz 통과로 게이트됨
  - **Failure path:** cold quiz 2회 연속 실패 시 기존 룰("partial→gap 강등 후 다른 각도로 재교육") 적용

---

## Requirements

**Generation-first teaching (Phase 3)**
- R1. Claude는 새 개념을 Explain하기 *전*에 학습자에게 명시적인 추측·시도 1턴을 요청한다.
- R2. 학습자가 빈 답이나 "모르겠다"로 답한 경우, Claude는 전체 답이 아닌 **strategic hint(최소 정보) 한 줄**만 주고 다시 시도를 유도한다 — 답을 그대로 흘려서 generation 효과를 무산시키지 않는다.
- R3. Explain 단계는 학습자의 추측을 *명시적으로 인용·비교·연결*하며 진행한다 — generation 단계가 별도 의식이 아니라 Explain의 발판이 되도록 한다.

**Cold-quiz verification (Phase 4 + 다음 세션 시작)**
- R4. Phase 4의 같은 세션 퀴즈는 "warm quiz"로 명명되며, 통과 효과는 `gap → partial`까지로 한정된다.
- R5. 신개념을 다룬 세션의 *다음 세션*은 시작 시 cold quiz를 먼저 실행한다 (Phase 2 agenda planning보다 앞).
- R6. cold quiz는 직전 warm quiz와 *다른 형식*으로 출제한다 (Feynman·Apply·Analyze 셋 중에서 회전).
- R7. `partial → understood` 승급의 *유일한 경로*는 힌트 없는 cold quiz 통과다 — warm quiz가 아무리 잘 통과해도 같은 세션 안에서는 `understood`로 갈 수 없다.
- R8. cold quiz 실패는 노드를 강등하지 않으나 quiz history에 명시 기록한다. 기존 "2회 연속 실패 시 강등" 룰은 cold quiz 실패에도 그대로 적용된다.

**Hint follow-through**
- R9. warm quiz를 힌트 사용해 통과한 노드는 `partial`로 기록되되, 다음 세션 cold quiz 대상으로 **자동 예약**된다 (hint 없이 다시 검증되지 않으면 progress가 더 이상 일어나지 않음).

**Session capacity policy**
- R10. 다음 세션 시작 시 cold quiz pending 잔고가 있으면, 그 세션의 신개념 cap을 **1**로 낮춘다 (기본 1-2에서 하향). 잔고가 0개일 때만 신개념 2개 학습이 허용된다 — Cognitive Load 보호와 세션 길이 일관성 우선 (사용자 결정).
- R11. 한 세션의 cold quiz는 최대 **2개**로 제한한다. 잔고가 그보다 많으면 가장 오래된 pending 노드부터 우선.

**Iron Rules 갱신**
- R12. 기존 Iron Rule "Never end a session without a quiz"는 유지하되, "Never advance a node to `understood` within the same session it was first taught"를 신규 Iron Rule로 추가한다.

---

## Acceptance Examples

- AE1. **Covers R1, R3.** 학습자가 Rust `borrow`를 처음 배운다. Claude는 Explain 전에 "ref와 borrow가 어떻게 다를 거 같으세요? 한 줄 추측이라도"라고 묻는다. 학습자가 "값을 빌려주는데 소유권은 안 넘긴다고 생각합니다"라고 답하면, Claude는 Explain에서 "추측한 대로 소유권은 그대로지만, 추가로 lifetime이 추적됩니다"라고 *추측을 명시적으로 비교*하며 가르친다.
- AE2. **Covers R2.** Generation 단계에서 학습자가 "전혀 모르겠어요"라고 답한다. Claude는 즉시 Explain으로 넘어가지 않고 "한 글자 힌트: 이 키워드는 'borrow'와 짝을 이룹니다. 다시 추측?"이라며 minimal hint만 준다.
- AE3. **Covers R5, R6, R7.** 지난 세션에서 `&mut`을 Feynman 형식으로 가르치고 warm quiz 통과 → `partial`. 이번 세션 시작 cold quiz는 *Apply 형식*(코드 한 토막의 버그 찾기)으로 출제. 힌트 없이 통과하면 `partial → understood`. 같은 세션 Phase 4에서 통과만으로는 절대 `understood`가 되지 않는다.
- AE4. **Covers R9.** 학습자가 어제 세션에서 'lifetime' warm quiz를 *힌트 한 번 받고* 통과 → `partial` + cold-quiz pending. 오늘 세션 시작 첫 항목이 'lifetime' cold quiz로, agenda 발표보다 앞에 위치한다.
- AE5. **Covers R10.** 학습자가 어제 신개념 2개를 학습해 cold-quiz pending이 2개. 오늘 세션의 신개념 cap은 1로 자동 하향, 평소라면 2개 신개념을 다룰 수 있던 자리를 cold quiz 2개 + 신개념 1개 + review 1개가 차지.

---

## 학습 사이클 변경 한눈 비교

| 시점 | 현재 | 변경 후 |
|------|------|---------|
| Phase 3 시작 | Explain → Socratic Q&A | **Predict 1턴** → Explain (추측과 비교) → Q&A |
| Phase 4 결과 | 통과 시 `partial→understood` 가능 | Warm quiz, `gap→partial` *까지만* |
| 같은 세션 → `understood` | 가능 | **불가** (Iron Rule 신설) |
| 다음 세션 시작 | (cold quiz 없음) | **Cold quiz** (다른 형식) → 통과 시 `partial→understood` |
| 힌트 사용 후 통과 | 그냥 기록만 | 다음 세션 cold quiz **자동 예약** |
| 신개념 cap | 항상 1-2 | cold-quiz pending 있으면 1로 하향 |

---

## Success Criteria

- 학습자가 한 단원을 마친 뒤 *다음 주에 다시 봐도* 같은 개념을 hint 없이 설명·적용할 수 있다 — fluency illusion 신호("정답지가 있어서 쉬웠다") 재발하지 않음.
- ce-plan이 "어디에 어떤 어려움 후크가 들어가는지"를 invent 없이 알 수 있다: Phase 3 시작 / Phase 4 결과 의미 / 다음 세션 시작 첫 절차 / 힌트 노드 후속 / 세션 capacity 룰.
- 같은 세션 안에서 노드가 `understood`로 승급되는 일이 protocol 차원에서 차단된다 (Iron Rule).
- cold quiz 형식이 warm quiz와 동일한 형식으로 반복되지 않는다 (R6 검증 가능).

---

## Scope Boundaries

- **Closed-book 모드(답 참조 차단) 도입 안 함** — Option D의 핵심. 효과는 크지만 매 세션 부담이 커서 학습 *지속성*을 해칠 수 있고, desirable difficulty의 정의는 "학습자 능력 *내*에서의 도전"이라 v1에서 보류.
- **다음 세션 첫 5분 "기억으로 코드 재작성"** — Option D의 절차기억 강화 후크. 효과적이지만 의무화하지 않고, 학습자가 원할 때 옵션 후크로 보조.
- **새 quiz 형식 추가** (현재 Feynman/Apply/Analyze 외) — variation 풀을 늘리는 별개 작업.
- **학습자별 "어려움 적정선" 자동 캘리브레이션** — `learner-profile.md`에 desirable difficulty 학습자별 임계값을 학습하는 작업은 v1 이후.
- **Spaced repetition 간격 동적 조정** — 30일 stale check를 cold quiz 결과 기반으로 재조정하는 것은 본 작업 범위 밖.
- **다른 personal-tutor 외 스킬에 본 원리 이식** — 본 작업은 personal-tutor 한정.

---

## Key Decisions

- **어려움을 한 곳이 아니라 세 곳에 분포**: Generation / Cold quiz / Hint follow-through. 이유: desirable difficulty의 본질은 *분포*이며, 글이 강조한 "학습 사이클 곳곳의 의식적 마찰"과 일치. 한 곳(예: Phase 4만 어렵게)에 몰면 나머지 단계는 여전히 passive consumption으로 남음.
- **Cold quiz는 형식 변경 의무**: 같은 형식 반복은 패턴 매칭이 되어 다시 fluency illusion으로 회귀. Bjork의 *variation* 원리.
- **Closed-book 보류**: desirable의 정의(능력 범위 *내*)와 학습 지속성을 우선.
- **`partial → understood`의 단일 경로 = cold quiz no-hint 통과**: "통과 = 학습"의 등식을 protocol 차원에서 끊는 가장 강한 한 줄.
- **힌트 사용 통과는 cold quiz로 강제 follow-up**: 힌트가 "있어도 되고 없어도 되는 옵션"이 아니라 "다음 세션 비용을 발생시키는 행위"가 되도록 설계.
- **세션 cap = 1 when cold-quiz pending**: cold quiz 잔고가 있을 때만 신개념 cap을 1로 하향. 이유는 (1) 세션 길이 일관성 — 잔고 유무와 무관하게 한 세션의 단위 수가 폭발적으로 변동하지 않음, (2) Cognitive Load 보호 — cold retrieval은 작업기억 부하가 높으므로 신개념을 줄여 균형, (3) 학습자가 "오늘은 깊이 / 오늘은 폭" 같은 매 세션 결정을 안 해도 됨.

---

## Dependencies / Assumptions

- 학습자가 *언젠가는* 다음 세션을 연다는 전제. 학습 중단 시 partial 노드는 영원히 `partial`로 남음 (이건 의도된 정직성 — 검증되지 않은 학습은 검증되지 않았다고 표시되어야 함).
- Claude가 같은 개념을 *다른 형식*으로 출제할 능력이 있다는 가정 — 현재 `SKILL.md` Phase 4에 형식 rotation 가이드는 있으나 *직전 형식과 다른 형식 자동 선택* 룰은 없음. 본 작업의 R6에서 그 룰을 명문화한다.
- `~/.claude/learning/topics/{topic}/knowledge-graph.md`가 cold-quiz pending 메타데이터를 보유할 수 있다는 가정 — 현재 스키마에는 없으며 plan 단계에서 표현 결정 필요.

---

## Outstanding Questions

### Resolve Before Planning

- (해소됨) R10 신개념 cap 정책 → "잔고 있으면 cap=1"로 결정 (Key Decisions 참조)

### Deferred to Planning

- [Affects R5, R6][Technical] cold quiz 형식 자동 선택 룰: "직전 형식과 다른 형식 무작위" vs "Bloom 깊이 진행 방향 고려"(Feynman 통과한 노드는 Apply로, Apply 통과한 노드는 Analyze로). 후자가 학습 깊이 progression과 정합적이지만 구현 복잡도 증가.
- [Affects R4-R9][Technical] `knowledge-graph.md` 스키마 확장: `last-quiz-format`, `cold-quiz-pending`, `cold-quiz-history` 등 메타데이터를 노드에 어떻게 표현할지 (별도 컬럼? sub-block?).
- [Affects R8][Technical] cold quiz 실패 시 quiz history 기록 형식 — warm/cold 구분 표기.
- [Affects F2][Technical] cold quiz가 "다음 세션 시작" 위치를 점유하는 게 Phase 1(첫 세션 Socratic Diagnostic)과 충돌하지 않는지 확인 — 첫 세션엔 직전 세션이 없어 cold quiz 자체가 발생 안 함 (논리적으로 OK이지만 protocol 텍스트에서 명시 필요).

---

## Next Steps

→ `/ce-plan` for structured implementation planning.
