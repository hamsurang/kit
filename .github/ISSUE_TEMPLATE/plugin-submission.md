---
name: Plugin Submission
about: Submit a new plugin to the kit marketplace
title: '[PLUGIN] your-plugin-name'
labels: ['plugin-submission']
assignees: ''
---

## Plugin Information

**Plugin name** (kebab-case):
<!-- e.g. my-awesome-plugin -->

**Description** (one sentence):
<!-- What does this plugin do? -->

## Why is this plugin useful?

<!-- Who would use this and why? What problem does it solve? -->

## Installation & Usage Example

```bash
claude plugin install YOUR_PLUGIN_NAME@hamsurang/kit
```

<!-- Show an example of how to use the plugin -->

## Plugin Repository (optional)

<!-- Link to your plugin's source if hosted separately -->

## Submission Checklist

- [ ] I have tested this plugin locally
- [ ] `plugin.json` has all required fields
- [ ] Markdown frontmatter has required fields (`commands`: `description`, `skills`/`agents`: `name`, `description`)
- [ ] `README.md` is present with usage examples
- [ ] No secrets or credentials are hardcoded
- [ ] The plugin follows [PLUGIN_SPEC.md](../../docs/contributors/plugin-spec.md)
