# hamkit

> A community-driven plugin & skills marketplace for [Claude Code](https://claude.ai/code)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](docs/contributors/contributing.md)

[한국어](./README.ko.md)

---

## Using Plugins

Install a plugin from the marketplace:

```bash
claude plugin install <plugin-name>@hamsurang/hamkit
```

Or install individual skills:

```bash
npx skills add hamsurang/hamkit
```

→ [Full installation guide](docs/users/getting-started.md)

---

## Building Plugins

Scaffold a new plugin interactively:

```bash
git clone https://github.com/hamsurang/hamkit
cd hamkit
bash scripts/scaffold-plugin.sh
```

→ [Contributing guide](docs/contributors/contributing.md) · [Plugin spec](docs/contributors/plugin-spec.md)

---

## Plugin & Skills Directory

| Plugin | Category | Description | Author |
|--------|----------|-------------|--------|
| [vitest](./plugins/vitest) | code-quality | Auto-invoked skill for writing, debugging, and configuring Vitest tests | [hamsurang](https://github.com/hamsurang) |

*Have a plugin to share? See [Contributing](docs/contributors/contributing.md).*

---

## Security Notice

hamkit does not audit or sandbox plugins. Review any plugin — especially `.mcp.json` and shell commands — before installing. Only install from authors you trust.

## License

MIT — see [LICENSE](./LICENSE)
