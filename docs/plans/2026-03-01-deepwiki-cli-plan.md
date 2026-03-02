# DeepWiki CLI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** DeepWiki HTTP API를 MCP 프로토콜 오버헤드 없이 호출하는 Rust CLI + hamkit skill/command 플러그인을 만든다.

**Architecture:** `deepwiki-cli` (Rust, 별도 레포)는 rmcp의 `StreamableHttpClientTransport`로 `https://mcp.deepwiki.com/mcp`에 직접 연결해 tool call을 실행한다. `hamkit`의 `plugins/deepwiki`는 auto-invoked skill과 slash command 마크다운만 포함한다. Claude Code는 MCP 서버로 연결하는 대신 `Bash` 도구로 `deepwiki` 바이너리를 실행한다.

**Tech Stack:** Rust 2024, rmcp 0.1 (transport-streamable-http-client-reqwest feature), clap 4, tokio, serde_json, anyhow

---

## 사전 조건

- Rust toolchain 설치됨 (`rustup`)
- `deepwiki-cli` 레포는 이 hamkit 레포와 **별개의 디렉토리**에서 작업
- 두 파트는 독립적으로 진행 가능

---

## Part 1: `deepwiki-cli` (별도 Rust 레포)

> 새 터미널에서 별도 디렉토리에 진행. 예: `~/projects/deepwiki-cli`

---

### Task 1: 프로젝트 초기화

**Files:**
- Create: `Cargo.toml`
- Create: `src/main.rs`

**Step 1: 프로젝트 생성**

```bash
cargo new deepwiki-cli
cd deepwiki-cli
```

**Step 2: `Cargo.toml`에 의존성 추가**

```toml
[package]
name = "deepwiki-cli"
version = "0.1.0"
edition = "2024"
description = "CLI for DeepWiki — query GitHub repo wikis without MCP overhead"
license = "MIT"

[[bin]]
name = "deepwiki"
path = "src/main.rs"

[dependencies]
anyhow = "1.0"
clap = { version = "4", features = ["derive"] }
rmcp = { version = "0.1", features = ["transport-streamable-http-client-reqwest", "client"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1", features = ["full"] }

[profile.dist]
inherits = "release"
lto = "thin"
```

**Step 3: 빌드 확인**

```bash
cargo build
```

Expected: 컴파일 오류 없이 빌드 성공

**Step 4: 커밋**

```bash
git init
git add Cargo.toml src/main.rs
git commit -m "chore: initialize deepwiki-cli project"
```

---

### Task 2: CLI 인자 파싱

**Files:**
- Create: `src/cli.rs`
- Modify: `src/main.rs`

**Step 1: `src/cli.rs` 작성**

```rust
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "deepwiki", about = "Query GitHub repo wikis via DeepWiki")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand)]
pub enum Command {
    /// Ask an AI-powered question about a repository
    Ask {
        /// Repository name (e.g. facebook/react)
        repo: String,
        /// Question to ask
        question: String,
    },
    /// List wiki topics for a repository
    Structure {
        /// Repository name (e.g. facebook/react)
        repo: String,
    },
    /// Read full wiki contents for a repository
    Read {
        /// Repository name (e.g. facebook/react)
        repo: String,
    },
}
```

**Step 2: `src/main.rs` 업데이트**

```rust
mod cli;

use anyhow::Result;
use clap::Parser;
use cli::Cli;

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    println!("{:?}", std::mem::discriminant(&cli.command));
    Ok(())
}
```

**Step 3: 수동 확인**

```bash
cargo run -- ask facebook/react "useEffect란?"
cargo run -- structure facebook/react
cargo run -- --help
```

Expected: help 텍스트 출력, subcommand 인식됨

**Step 4: 커밋**

```bash
git add src/cli.rs src/main.rs
git commit -m "feat: add CLI argument parsing with clap"
```

---

### Task 3: MCP 클라이언트 모듈

**Files:**
- Create: `src/client.rs`

**Step 1: `src/client.rs` 작성**

grep-app-cli와 동일한 패턴으로 DeepWiki MCP 엔드포인트에 연결.

```rust
use anyhow::{Context, Result};
use rmcp::{
    model::{CallToolRequestParams, ClientCapabilities, ClientInfo, Implementation},
    service::ServiceExt,
    transport::StreamableHttpClientTransport,
};
use serde_json::json;

const MCP_ENDPOINT: &str = "https://mcp.deepwiki.com/mcp";

pub struct DeepWikiClient {
    service: rmcp::service::RunningService<rmcp::RoleClient, ()>,
}

impl DeepWikiClient {
    pub async fn connect() -> Result<Self> {
        let transport = StreamableHttpClientTransport::from_uri(MCP_ENDPOINT);

        let client_info = ClientInfo {
            meta: None,
            protocol_version: Default::default(),
            capabilities: ClientCapabilities::default(),
            client_info: Implementation {
                name: "deepwiki-cli".into(),
                version: env!("CARGO_PKG_VERSION").into(),
            },
        };

        let service = client_info
            .serve(transport)
            .await
            .context("Failed to connect to mcp.deepwiki.com")?;

        Ok(Self { service })
    }

    pub async fn ask_question(&self, repo: &str, question: &str) -> Result<String> {
        let result = self
            .service
            .call_tool(CallToolRequestParams {
                meta: None,
                name: "ask_question".into(),
                arguments: Some(
                    json!({ "repoName": repo, "question": question })
                        .as_object()
                        .cloned()
                        .unwrap(),
                ),
                task: None,
            })
            .await
            .context("Failed to call ask_question")?;

        extract_text(result)
    }

    pub async fn read_wiki_structure(&self, repo: &str) -> Result<String> {
        let result = self
            .service
            .call_tool(CallToolRequestParams {
                meta: None,
                name: "read_wiki_structure".into(),
                arguments: Some(
                    json!({ "repoName": repo })
                        .as_object()
                        .cloned()
                        .unwrap(),
                ),
                task: None,
            })
            .await
            .context("Failed to call read_wiki_structure")?;

        extract_text(result)
    }

    pub async fn read_wiki_contents(&self, repo: &str) -> Result<String> {
        let result = self
            .service
            .call_tool(CallToolRequestParams {
                meta: None,
                name: "read_wiki_contents".into(),
                arguments: Some(
                    json!({ "repoName": repo })
                        .as_object()
                        .cloned()
                        .unwrap(),
                ),
                task: None,
            })
            .await
            .context("Failed to call read_wiki_contents")?;

        extract_text(result)
    }

    pub async fn cancel(self) -> Result<()> {
        self.service.cancel().await?;
        Ok(())
    }
}

fn extract_text(result: rmcp::model::CallToolResult) -> Result<String> {
    let text = result
        .content
        .into_iter()
        .filter_map(|c| {
            if let rmcp::model::RawContent::Text(t) = c.raw {
                Some(t.text)
            } else {
                None
            }
        })
        .collect::<Vec<_>>()
        .join("\n");

    Ok(text)
}
```

> **주의:** rmcp API가 버전마다 다를 수 있음. 컴파일 에러 발생 시 `cargo doc --open`으로 실제 타입 확인 후 수정.

**Step 2: 빌드 확인**

```bash
cargo build
```

Expected: 컴파일 성공. 타입 에러 발생 시 `rmcp` 문서 확인 후 수정.

**Step 3: 커밋**

```bash
git add src/client.rs
git commit -m "feat: add DeepWiki MCP client using rmcp"
```

---

### Task 4: `main.rs` 연결 — 전체 동작 구현

**Files:**
- Modify: `src/main.rs`

**Step 1: `src/main.rs` 완성**

```rust
mod cli;
mod client;

use anyhow::Result;
use clap::Parser;
use cli::{Cli, Command};
use client::DeepWikiClient;

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    let client = DeepWikiClient::connect().await?;

    let output = match &cli.command {
        Command::Ask { repo, question } => {
            client.ask_question(repo, question).await?
        }
        Command::Structure { repo } => {
            client.read_wiki_structure(repo).await?
        }
        Command::Read { repo } => {
            client.read_wiki_contents(repo).await?
        }
    };

    println!("{}", output);
    client.cancel().await?;

    Ok(())
}
```

**Step 2: 실제 API 호출 수동 확인**

```bash
cargo run -- ask facebook/react "What is React?"
```

Expected: DeepWiki의 응답 텍스트가 stdout에 출력됨

```bash
cargo run -- structure facebook/react
```

Expected: 위키 주제 목록 출력

**Step 3: 에러 케이스 확인**

```bash
cargo run -- ask invalid/repo-does-not-exist-xyz "test"
```

Expected: stderr에 에러 메시지, exit code 1

**Step 4: 커밋**

```bash
git add src/main.rs
git commit -m "feat: wire CLI commands to DeepWiki MCP client"
```

---

### Task 5: 출력 포맷 최적화 (토큰 효율)

**Files:**
- Create: `src/output.rs`
- Modify: `src/main.rs`

**Step 1: 단위 테스트 먼저 작성**

```rust
// src/output.rs
pub fn format_for_claude(text: &str, repo: &str, query_type: &str) -> String {
    format!("## DeepWiki: {} ({})\n\n{}", repo, query_type, text.trim())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_adds_header() {
        let result = format_for_claude("some content", "facebook/react", "ask");
        assert!(result.starts_with("## DeepWiki: facebook/react (ask)"));
        assert!(result.contains("some content"));
    }

    #[test]
    fn test_format_trims_whitespace() {
        let result = format_for_claude("  content  \n\n", "owner/repo", "structure");
        assert!(result.ends_with("content"));
    }
}
```

**Step 2: 테스트 실패 확인**

```bash
cargo test
```

Expected: FAIL — `format_for_claude` not yet defined in a way tests can find

**Step 3: 테스트 통과 확인**

```bash
cargo test output
```

Expected: 2 tests PASS

**Step 4: `main.rs`에 적용**

```rust
mod output;

// ... Command::Ask 분기에서:
let formatted = output::format_for_claude(&output, repo, "ask");
println!("{}", formatted);
```

**Step 5: 커밋**

```bash
git add src/output.rs src/main.rs
git commit -m "feat: add token-efficient output formatting"
```

---

### Task 6: 에러 처리 & UX 마무리

**Files:**
- Modify: `src/main.rs`

**Step 1: 에러를 stderr로, 정상 출력을 stdout으로 분리**

`main.rs` 에러 핸들러:

```rust
#[tokio::main]
async fn main() {
    if let Err(e) = run().await {
        eprintln!("Error: {:#}", e);
        std::process::exit(1);
    }
}

async fn run() -> anyhow::Result<()> {
    // ... 기존 main 내용
}
```

**Step 2: 연결 실패 시 명확한 메시지 확인**

네트워크를 끊고 실행:

```bash
cargo run -- ask facebook/react "test"
```

Expected: `Error: Failed to connect to mcp.deepwiki.com: ...` (stderr)

**Step 3: 커밋**

```bash
git add src/main.rs
git commit -m "fix: route errors to stderr, exit code 1 on failure"
```

---

### Task 7: `cargo install` 준비

**Files:**
- Modify: `Cargo.toml`
- Create: `README.md`

**Step 1: `Cargo.toml` 메타데이터 완성**

```toml
[package]
name = "deepwiki-cli"
version = "0.1.0"
edition = "2024"
description = "CLI for DeepWiki — query GitHub repo wikis without MCP overhead"
license = "MIT"
repository = "https://github.com/<your-username>/deepwiki-cli"
keywords = ["deepwiki", "github", "wiki", "mcp", "cli"]
```

**Step 2: `README.md` 작성**

```markdown
# deepwiki-cli

Query GitHub repository wikis via [DeepWiki](https://deepwiki.com) without MCP overhead.

## Install

```bash
cargo install deepwiki-cli
```

## Usage

```bash
deepwiki ask facebook/react "How does useEffect work?"
deepwiki structure facebook/react
deepwiki read facebook/react
```

## Token Savings

Use with hamkit's deepwiki plugin instead of MCP connection:
- MCP: adds initialize + tool listing tokens to every session
- CLI: only the result text enters Claude's context
```

**Step 3: 최종 빌드 검증**

```bash
cargo build --release
./target/release/deepwiki ask facebook/react "What is React?"
```

**Step 4: 커밋**

```bash
git add Cargo.toml README.md
git commit -m "chore: add package metadata and README for cargo install"
```

---

## Part 2: `plugins/deepwiki` (이 hamkit 레포)

> hamkit 레포의 `deepwiki` 브랜치에서 진행.

---

### Task 8: 플러그인 매니페스트

**Files:**
- Create: `plugins/deepwiki/.claude-plugin/plugin.json`

**Step 1: 디렉토리 생성 및 `plugin.json` 작성**

```bash
mkdir -p plugins/deepwiki/.claude-plugin
```

```json
{
  "name": "deepwiki",
  "version": "1.0.0",
  "description": "Query GitHub repository wikis via DeepWiki CLI without MCP token overhead.",
  "author": {
    "name": "hamsurang",
    "github": "hamsurang"
  },
  "category": "productivity",
  "license": "MIT",
  "keywords": ["deepwiki", "github", "wiki", "token-saving"],
  "repository": "https://github.com/hamsurang/hamkit",
  "skills": "./skills/"
}
```

**Step 2: JSON 유효성 확인**

```bash
cat plugins/deepwiki/.claude-plugin/plugin.json | python3 -m json.tool
```

Expected: 파싱 오류 없음

**Step 3: 커밋**

```bash
git add plugins/deepwiki/.claude-plugin/plugin.json
git commit -m "feat(deepwiki): add plugin manifest"
```

---

### Task 9: Auto-invoked Skill

**Files:**
- Create: `plugins/deepwiki/skills/deepwiki/SKILL.md`

**Step 1: 디렉토리 생성**

```bash
mkdir -p plugins/deepwiki/skills/deepwiki
```

**Step 2: `SKILL.md` 작성**

```markdown
---
description: Use deepwiki CLI to query GitHub repository documentation without MCP overhead
trigger: automatic
---

# DeepWiki CLI Skill

When the user asks questions about a specific GitHub repository (e.g., "how does X work in facebook/react?", "explain the architecture of vercel/next.js"), use the `deepwiki` CLI tool instead of reading repository files directly.

## When to activate

- User references a GitHub repository by name (owner/repo format)
- User asks about how a library or framework works
- User needs to understand a codebase they haven't read

## How to use

Run via Bash tool:

```bash
# Ask a question about a repository
deepwiki ask <owner/repo> "<question>"

# List wiki topics
deepwiki structure <owner/repo>

# Read full wiki
deepwiki read <owner/repo>
```

## Examples

```bash
deepwiki ask facebook/react "How does the reconciler work?"
deepwiki ask vercel/next.js "What is the App Router architecture?"
deepwiki structure rust-lang/rust
```

## Prerequisites

The `deepwiki` binary must be installed:

```bash
cargo install deepwiki-cli
```

If the binary is not found, inform the user to install it first.

## Why this saves tokens

Using the CLI via Bash outputs only the result text to Claude's context.
Connecting DeepWiki as an MCP server adds initialize handshake + tool listing overhead on every session.
```

**Step 3: 커밋**

```bash
git add plugins/deepwiki/skills/deepwiki/SKILL.md
git commit -m "feat(deepwiki): add auto-invoked skill"
```

---

### Task 10: 슬래시 커맨드

**Files:**
- Create: `plugins/deepwiki/commands/ask.md`

**Step 1: 디렉토리 생성**

```bash
mkdir -p plugins/deepwiki/commands
```

**Step 2: `ask.md` 작성**

```markdown
---
description: Ask a question about a GitHub repository using DeepWiki
argument-hint: <owner/repo> <question>
allowed-tools: [Bash]
---

Ask a question about a GitHub repository using the DeepWiki CLI.

Usage: /deepwiki:ask <owner/repo> <question>

Run the following command:

```bash
deepwiki ask $ARGUMENTS
```

If the `deepwiki` command is not found, inform the user to install it:

```bash
cargo install deepwiki-cli
```
```

**Step 3: 커밋**

```bash
git add plugins/deepwiki/commands/ask.md
git commit -m "feat(deepwiki): add /deepwiki:ask slash command"
```

---

### Task 11: Plugin README

**Files:**
- Create: `plugins/deepwiki/README.md`

**Step 1: `README.md` 작성**

```markdown
# deepwiki

> Query GitHub repository wikis via DeepWiki — without MCP token overhead.

## Prerequisites

Install the `deepwiki` CLI:

```bash
cargo install deepwiki-cli
```

## Install plugin

```bash
claude plugin install deepwiki@hamsurang/hamkit
```

## Usage

### Auto-invoked

Ask Claude about any GitHub repository — the skill activates automatically:

> "How does useEffect work in facebook/react?"

### Slash command

```
/deepwiki:ask facebook/react "What is the reconciler?"
```

## Token savings

| Method | Overhead |
|--------|----------|
| MCP server connection | initialize + tool listing per session |
| deepwiki CLI (this plugin) | result text only |
```

**Step 2: 커밋**

```bash
git add plugins/deepwiki/README.md
git commit -m "docs(deepwiki): add plugin README"
```

---

## End-to-End 검증

**Step 1: CLI 설치 후 동작 확인**

```bash
cargo install --path /path/to/deepwiki-cli
deepwiki ask facebook/react "What is React fiber?"
```

Expected: DeepWiki 응답 텍스트가 stdout에 출력됨

**Step 2: Claude Code에서 skill 동작 확인**

Claude Code에서 입력:
> "facebook/react의 reconciler 아키텍처를 설명해줘"

Expected: skill이 자동 활성화되어 `deepwiki ask facebook/react "..."` 실행

**Step 3: 슬래시 커맨드 확인**

```
/deepwiki:ask vercel/next.js "App Router vs Pages Router 차이"
```

Expected: `deepwiki ask` 실행 결과 출력

---

## 파일 체크리스트

### deepwiki-cli (별도 레포)
- [ ] `Cargo.toml`
- [ ] `src/main.rs`
- [ ] `src/cli.rs`
- [ ] `src/client.rs`
- [ ] `src/output.rs`
- [ ] `README.md`

### plugins/deepwiki (hamkit)
- [ ] `plugins/deepwiki/.claude-plugin/plugin.json`
- [ ] `plugins/deepwiki/skills/deepwiki/SKILL.md`
- [ ] `plugins/deepwiki/commands/ask.md`
- [ ] `plugins/deepwiki/README.md`
