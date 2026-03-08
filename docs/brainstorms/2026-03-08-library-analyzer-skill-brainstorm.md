---
date: 2026-03-08
topic: library-analyzer-skill
---

# Library Analyzer Skill

## What We're Building

오픈소스 라이브러리에 기여하고자 하는 사용자를 위한 Claude 스킬.
`/analyze-library` 실행 후 URL 또는 로컬 경로를 입력받아, 라이브러리 구조·모듈·라이프사이클·기여 방법·이슈 현황·필수 키워드를 병렬 서브 에이전트로 분석하고 Markdown 파일로 저장한다.

## Why This Approach

### 입력 전략
- **URL 입력 시** → deepwiki-cli 사용 (원격 분석)
- **로컬 경로 입력 시** → 정적 코드 분석 (파일 탐색, 구조 파악)
- AskUserQuestion으로 사용자가 직접 선택

### 실행 전략: 병렬 팬아웃 (Approach B)
데이터 수집 완료 후 6개 분석 섹션을 동시에 서브 에이전트로 팬아웃. 각 에이전트가 독립적으로 분석하고 결과를 오케스트레이터가 취합해 하나의 Markdown 파일로 조립.

순차 방식 대비 빠름. 에이전트별 전문화 가능.

### 이슈 분석 전략
GitHub API (gh cli) 실시간 호출로 최신 이슈 목록 수집 → Claude가 온도/시급도/기여 난이도 분류.

## Key Decisions

- **호출 방식**: `/analyze-library` → AskUserQuestion으로 URL/로컬 경로 선택
- **원격 분석 도구**: deepwiki-cli (URL 케이스)
- **정적 분석**: 로컬 파일 탐색 + 코드 구조 파악 (로컬 경로 케이스)
- **이슈 수집**: GitHub API / gh cli 실시간 호출
- **실행 방식**: 병렬 팬아웃 — 6개 섹션 동시 실행
- **출력**: Markdown 파일 → `docs/library-analysis/<library-name>-<date>.md`

## Analysis Sections (6개 서브 에이전트)

| 에이전트 | 담당 섹션 |
|---------|---------|
| structure-agent | 디렉토리 구조, 주요 파일 역할 |
| lifecycle-agent | 호출 흐름, 초기화~종료 라이프사이클 |
| modules-agent | 모듈 목록 및 각 모듈의 역할 |
| contribution-agent | 기여 방법, CONTRIBUTING.md 분석, 추천 첫 기여 방식 |
| issues-agent | 오픈 이슈 수집 + 온도/시급도/기여 난이도 분류 |
| keywords-agent | 기여에 필요한 도메인 키워드 및 핵심 개념 정리 |

## Open Questions

- deepwiki-cli가 없는 환경에서의 폴백 전략은? (web search fallback?)
- 이슈가 너무 많을 경우 (수백 개) 샘플링 전략은?
- 분석 결과 저장 경로를 사용자가 커스터마이즈할 수 있어야 하나?

## Next Steps

→ `/ce:plan` 으로 구현 계획 수립
