# Contributing to kit

kit is an open community marketplace. Anyone can submit a plugin — no gatekeeper, just quality checks.

## Ways to Contribute

- **Submit a new plugin** — Share a plugin you built
- **Improve an existing plugin** — Fix bugs, add features, improve docs
- **Report issues** — File bug reports or feature requests at [GitHub Issues](https://github.com/hamsurang/kit/issues)
- **Review PRs** — Help validate community plugins

## Submitting a New Plugin

### Step 1: Fork and clone the repo

1. Fork [hamsurang/kit](https://github.com/hamsurang/kit) on GitHub (click **Fork** in the top right)
2. Clone your fork:

```bash
git clone https://github.com/<your-username>/kit
cd kit
```

### Step 2: Scaffold your plugin

```bash
bash scripts/scaffold-plugin.sh
```

This interactive script creates the plugin directory structure and template files for you.

### Step 3: Develop your plugin

Edit the generated files in `plugins/<your-plugin>/`. Refer to [plugin-spec.md](./plugin-spec.md) for format details.

Test locally by installing the plugin from your local path:

```bash
claude plugin install ./plugins/<your-plugin>
```

### Step 4: Open a Pull Request

```bash
git checkout -b add-<plugin-name>
git add plugins/<plugin-name>/
git commit -m "feat: add <plugin-name> plugin"
gh pr create --title "feat: add <plugin-name> plugin"
```

Your PR will be automatically validated by CI and reviewed by a maintainer within 7 days.

## Plugin Requirements Checklist

Before submitting, verify all items:

- [ ] `plugin.json` has all required fields: `name`, `version`, `description`, `author`, `category`, `license`
- [ ] Plugin name is unique and kebab-case (no spaces, lowercase)
- [ ] `README.md` is present and explains what the plugin does
- [ ] Markdown files have valid YAML frontmatter (no syntax errors)
- [ ] No hardcoded secrets or credentials in any file
- [ ] MCP server URLs use HTTPS (except `localhost` / `127.0.0.1`)
- [ ] License is declared and compatible with open source distribution

## Plugin Quality Standards

### Must Have
- Clear, accurate `description` in `plugin.json`
- `README.md` with installation command and usage examples
- Valid semantic version (e.g. `1.0.0`)
- Tested locally before submitting

### Should Have
- `keywords` for discoverability (up to 5)
- `repository` link to source
- `argument-hint` in command frontmatter if commands accept arguments
- Example output or screenshot in README

### Must Not Have
- Hardcoded credentials, API keys, or tokens
- Commands that destructively modify files without user confirmation
- MCP servers at non-HTTPS URLs (except localhost for dev tools)
- Copyrighted content or licensed code without attribution
- `name` field that doesn't match the directory name

## Review Process

1. **CI validates** — GitHub Actions automatically checks plugin structure and frontmatter on every PR
2. **Maintainer reviews** — A maintainer will review the PR within 7 days
3. **Feedback** — Any required changes are provided as inline PR comments
4. **Merge** — Approved plugins are merged and available immediately via `claude plugin install`

## Updating Existing Plugins

To update a plugin you maintain:

1. Make your changes
2. Bump the version in `plugin.json` (follow [semver](https://semver.org/))
3. Open a PR describing what changed

Please include in the PR description:
- What changed and why
- Whether it's a breaking change
- The new version number

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you agree to uphold these standards.

Report unacceptable behavior to the maintainers via GitHub Issues.
