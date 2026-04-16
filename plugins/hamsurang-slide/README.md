# hamsurang-slide

> Brand presentation generator for Hamsurang (함수랑산악회) with Soft Modern design.

## Themes

**Light theme**
![light theme](../../docs/assets/hamsurang-slide/images/light.png)


[-> Go to sample-light.html](../../docs/assets/hamsurang-slide/html/sample-light.html)



**Dark theme**

![dark theme](../../docs/assets/hamsurang-slide/images/dark.png)

[-> Go to sample-dark.html](../../docs/assets/hamsurang-slide/html/sample-dark.html)


## Features

- **Soft Modern** design — glassmorphism cards, green-tinted gradients, soft shadows
- **Light / Dark themes** — green-tinted dark mode included
- **14 slide types** — Title, Agenda, Section Divider, Key Point, Quote, Comparison, Flow, Card Grid, Content, Code, Architecture, Timetable, Timeline, Closing
- **4-color code highlighting** — custom highlight.js theme
- **mermaid.js diagrams** support
- **Speaker notes** — `S` key opens popup window
- **Single HTML file** output — opens directly in browser

## Installation

```bash
claude plugin install hamsurang-slide@hamsurang/kit
```

Or copy `plugins/hamsurang-slide/` into your project. Pi auto-detects `.claude-plugin/plugin.json`.

## Trigger Phrases

- `hamsurang 발표` / `hamsurang PPT` / `hamsurang slide`
- `함수랑 발표` / `함수랑 슬라이드` / `함수랑 PPT`

## Workflow

1. Analyze input (topic, duration, audience)
2. Generate outline → user confirmation
3. Select theme → user confirmation
4. Generate HTML (sequential reference loading)
5. Write speaker notes
6. Inline SVG assets → save file

## File Structure

```
plugins/hamsurang-slide/
├── .claude-plugin/plugin.json
├── README.md
└── skills/hamsurang-slide/
    ├── SKILL.md
    ├── references/
    │   ├── generation-rules.md    (CSS SSOT — all design values)
    │   ├── design-system.md       (philosophy, component patterns)
    │   ├── slide-catalog.md       (14 slide type HTML structures)
    │   ├── html-spec.md           (HTML structure, JS, CDN)
    │   └── images/                (SVG brand assets)
    └── scripts/
        └── inline_assets.mjs
```

### SSOT Principle

**`generation-rules.md`** is the single source of truth for all CSS values (colors, typography, spacing, radii, shadows). Other reference files describe _patterns and structure_ but never hardcode style values — they reference CSS variables defined in generation-rules.md.

## Requirements

- Node.js

## License

MIT
