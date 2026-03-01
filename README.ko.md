# hamkit

> [Claude Code](https://claude.ai/code)를 위한 커뮤니티 플러그인 & 스킬 마켓플레이스

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](docs/contributors/contributing.md)

[English](./README.md)

---

## 플러그인 사용하기

마켓플레이스에서 플러그인 설치:

```bash
claude plugin install <플러그인-이름>@hamsurang/hamkit
```

또는 개별 스킬 설치:

```bash
npx skills add hamsurang/hamkit
```

→ [전체 설치 가이드](docs/users/getting-started.md)

---

## 플러그인 만들기

대화형으로 새 플러그인 스캐폴딩:

```bash
git clone https://github.com/hamsurang/hamkit
cd hamkit
bash scripts/scaffold-plugin.sh
```

→ [기여 가이드](docs/contributors/contributing.md) · [플러그인 스펙](docs/contributors/plugin-spec.md)

---

## 플러그인 & 스킬 목록

| 플러그인 | 카테고리 | 설명 | 작성자 |
|---------|---------|------|--------|
| [vitest](./plugins/vitest) | code-quality | Vitest 테스트 작성·디버깅·설정을 위한 자동 활성화 스킬 | [hamsurang](https://github.com/hamsurang) |

*플러그인을 기여하고 싶으신가요? [기여 방법](docs/contributors/contributing.md)을 확인하세요.*

---

## 보안 안내

hamkit은 플러그인을 별도로 감사하거나 샌드박스 처리하지 않습니다. 특히 `.mcp.json`과 셸 커맨드가 포함된 플러그인은 설치 전 반드시 내용을 검토하세요. 신뢰할 수 있는 작성자의 플러그인만 설치하시기 바랍니다.

## 라이선스

MIT — [LICENSE](./LICENSE) 참고
