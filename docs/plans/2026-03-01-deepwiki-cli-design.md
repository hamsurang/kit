# DeepWiki CLI — Design

**Date:** 2026-03-01
**Status:** Approved
**Approach:** B — rmcp 기반 Rust CLI + hamkit skill

---

## Problem Statement

DeepWiki MCP를 Claude Code에 MCP로 연결하면 initialize 핸드셰이크, tool listing, tool call 응답이 모두 대화 컨텍스트에 올라가 토큰 비용이 높아진다. 대신 Rust CLI 바이너리로 동일한 API를 호출하고 `Bash` 도구로 실행하면 결과 텍스트만 컨텍스트에 들어가 토큰을 절약할 수 있다.

---

## Goals

- DeepWiki API를 MCP 오버헤드 없이 CLI로 호출
- hamkit에는 skill/command만 두고 CLI는 별도 레포로 분리
- grep-app-cli와 동일한 검증된 패턴 사용

---

## Two-Repo Architecture

```
[별도 repo] deepwiki-cli          [이 repo] hamkit
   Rust 바이너리 CLI          ─────▶  plugins/deepwiki/
   (DeepWiki HTTP 호출)               skill + command만 존재
```

**데이터 흐름:**

```
사용자 요청
    │
    ▼
Claude Code (skill 자동 활성화 또는 /deepwiki:ask 호출)
    │
    ▼ Bash tool
$ deepwiki ask facebook/react "useEffect 동작 원리"
    │
    ▼ rmcp (MCP-over-HTTP)
https://mcp.deepwiki.com/mcp
    │
    ▼ 포맷된 텍스트 출력 (stdout)
Claude Code 컨텍스트에 텍스트로 추가됨
```

---

## `deepwiki-cli` (Rust — 별도 레포)

### CLI 인터페이스

```bash
deepwiki ask <owner/repo> "<question>"    # AI 기반 질문 답변
deepwiki structure <owner/repo>           # 위키 주제 목록 조회
deepwiki read <owner/repo>                # 전체 위키 내용 조회
```

### 기술 스택

| 크레이트 | 역할 |
|---------|------|
| `rmcp` | MCP 클라이언트 프로토콜 |
| `tokio` | 비동기 런타임 |
| `clap` | CLI 인자 파싱 |
| `serde` + `serde_json` | JSON 직렬화 |
| `anyhow` | 에러 처리 |

### 출력 원칙 (토큰 효율)

- 마크다운 그대로 출력 (Claude가 파싱하기 최적)
- 불필요한 메타데이터 제거 (프로세스 ID, 타임스탬프 등)
- 에러는 `stderr`, 결과는 `stdout`

### 배포

```bash
cargo install deepwiki-cli    # 또는 brew tap
```

---

## `plugins/deepwiki` (hamkit — 이 레포)

### 디렉토리 구조

```
plugins/deepwiki/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 매니페스트
├── skills/
│   └── deepwiki/
│       └── SKILL.md         # Auto-invoked skill
├── commands/
│   └── ask.md               # /deepwiki:ask 슬래시 커맨드
└── README.md
```

### Auto-invoked skill 동작

- **트리거**: 사용자가 GitHub 레포지토리에 대해 질문할 때
- **동작**: Claude에게 `deepwiki ask <repo> <question>` 실행 안내
- **전제조건**: `deepwiki` 바이너리가 PATH에 설치되어 있어야 함

### 슬래시 커맨드

```bash
/deepwiki:ask <owner/repo> <question>
```

---

## 설치 흐름

```bash
# 1. CLI 설치
cargo install deepwiki-cli

# 2. hamkit 플러그인 설치
claude plugin install deepwiki@hamsurang/hamkit
```

---

## Out of Scope (YAGNI)

- 로컬 캐시 레이어 (필요 시 나중에 추가)
- 인증 (개인 레포 접근) — DeepWiki 계정 연동
- 결과 포맷 옵션 (--json, --markdown 플래그)

---

## Success Criteria

- [ ] `deepwiki ask <repo> <question>` 실행 시 DeepWiki 응답을 텍스트로 출력
- [ ] MCP 연결 없이 동작 (MCP 서버 설정 불필요)
- [ ] Claude Code에서 skill 자동 활성화됨
- [ ] `/deepwiki:ask` 슬래시 커맨드 동작
- [ ] 설치 가이드가 README에 명확히 기술됨
