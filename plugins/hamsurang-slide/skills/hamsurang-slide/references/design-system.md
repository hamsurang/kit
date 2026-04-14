# Design System — Principles & Patterns

Design philosophy and component patterns for Hamsurang Soft Modern.
**No hardcoded values in this file.** All implementable values live in `generation-rules.md` (CSS SSOT).

## 1. Visual Atmosphere

Soft Modern — soft gradients, rounded corners, glassmorphism cards, subtle green-tinted shadows.

- Text, badges, and labels use `var(--primary)` **solid color** (not rgba tints)
- All typography and spacing use `clamp()` for responsive scaling
- Elevation is expressed through 3 levels of shadow depth (defined as `--shadow-sm`, `--shadow`, `--shadow-lg`)
- Default border-radius is `var(--radius-xl)` for cards, `var(--radius-full)` for badges/pills, `var(--radius-lg)` for code blocks
- Display headings use `letter-spacing: -0.02em`; labels use `letter-spacing: 0.03em`

## 2. Color Roles

| Role | Usage |
|------|-------|
| `--primary` | Heading-2, badges, progress bar, links, agenda numbers |
| `--primary-dark` | Hover and active states |
| `--primary-light` | Secondary emphasis |
| `--accent-warm` | Warnings, function-name highlighting (`--code-fn`), warm badges |
| `--accent-cool` | Keyword highlighting (`--code-kw`), cool badges |
| `--danger` | Errors, comparison "bad" panel, danger badges |
| `--text` | Body copy |
| `--text-muted` | Secondary descriptions |
| `--text-subtle` | Meta information |
| `--heading` | Titles, headings |
| `--surface-card` | Glassmorphism card backgrounds |
| `--border` | Card and component borders |
| `--background-code` | Code blocks (always dark in both themes) |

## 3. Typography Usage

| Scale | Context |
|-------|---------|
| display | Title / Closing h1 only |
| heading-1 | Key Point, Section Divider titles |
| heading-2 | Slide titles — **always `color: var(--primary)`** |
| heading-3 | Card / component titles |
| body | Body text |
| body-small | Secondary descriptions |
| caption | Meta information |
| label | Badges, tags |
| code | Code blocks |

## 4. Component Patterns

These describe **structure and behavior**. Exact CSS is in `generation-rules.md`.

### Cards (Glassmorphism)

- Background: `var(--surface-card)` + `backdrop-filter: blur(8px)`
- Border: `1px solid var(--border)`, radius `var(--radius-xl)`
- Shadow: `var(--shadow)` at rest, `var(--shadow-lg)` on hover
- Hover: lift `translateY(-3px)` + shadow upgrade
- Icon: emoji 28px, margin-bottom 12px
- Title: heading-3 scale
- Description: body-small, `var(--text-muted)`
- Card Grid container (`.card-grid`): wraps all cards, centered with `align-content: center`, uses CSS grid (2-col or 3-col)

### Badges (Pill)

- Shape: `var(--radius-full)`, padding `5px 14px`
- Font: label scale, weight 700, letter-spacing 0.03em
- Variants: primary / warm / cool / danger
- Dark theme: lighter text colors and higher-opacity backgrounds for contrast (defined in generation-rules.md)

### Quote Block

- Left border: 3px solid `var(--primary)`
- Background: subtle green-tinted gradient toward transparent
- Radius: `0 var(--radius-lg) var(--radius-lg) 0`
- Quote text: heading-3 scale, italic, `var(--heading)`
- Attribution: body-small, `var(--text-muted)`, `—` prefix

### Code Block

- Background: `var(--background-code)` (dark in both themes)
- Radius: `var(--radius-lg)`
- Max height with vertical scroll to prevent overflow
- Font: JetBrains Mono, code scale
- 4-color highlighting: keyword (`--code-kw`), function (`--code-fn`), string (`--code-str`), variable (`--code-var`)
- Language label: top-left, label scale, `var(--code-str)` color, uppercase
- Auto-highlighted via highlight.js CDN

### Comparison (Versus)

- Two-panel horizontal flex, vertically centered in slide (`flex: 1; margin: auto 0`)
- Good panel: subtle primary-tinted background + primary-tinted border
- Bad panel: subtle danger-tinted background + danger-tinted border
- Dark theme: higher-opacity tints for visible contrast (defined in generation-rules.md)
- Panel label: label scale, respective color

### Flow / Steps

- Horizontal flex, vertically centered in slide (flex: 1, margin: auto 0)
- Each step: glassmorphism card with generous padding, min-width for readability
- Step title: slightly larger than heading-3 for emphasis
- Arrow: `→`, `var(--primary)`, 48px width, enlarged font
- 3–6 steps recommended

### Table

- Full width, collapsed borders
- Header: `var(--primary)`, weight 700, label scale, 2px solid bottom border
- Cell: body-small scale, 1px solid `var(--border)` bottom

### Lists

- Custom marker: 8px filled circle in `var(--primary)`, vertically centered
- No default list-style; items have left padding for the marker

## 5. Layout Principles

- Fullscreen viewport, 1280×720 base with scale transform
- Content padding: 60px top/bottom, 80px left/right
- Centering: flexbox center/center
- Title / Key Point: center-aligned; Code / Comparison: left-aligned
- Max content width: 1000–1200px
- Grid gaps: 2-column 40px, 3-column 24px
- Max 6–8 bullet points per slide
- Whitespace reinforces the message — be generous with margins
