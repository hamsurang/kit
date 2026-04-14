# Slide Catalog

14 slide types. The agent writes HTML/CSS directly for each type.
Copy all CSS from `generation-rules.md` into `<style>`, then follow the **HTML structure** below for each slide.

**Overflow rule:** Slide area is fixed at 1280×720px. Content must not overflow. Reduce font size and spacing when there are many items.

All style values referenced below (colors, sizes, spacing) are CSS variables defined in `generation-rules.md`. Do not hardcode values — use `var(--name)` in any inline or additional CSS.

---

## 1. Title

Opening slide. Logo badge + large title + presenter info + mountain illustration.

**CSS classes:** `slide slide--title slide--bg active`

**HTML structure:**
- `.logo-badge.a` — flex row: logo image (height matches text) + "함수랑산악회" span
  - Two logo images: `.logo-light` + `.logo-dark` (CSS toggle shows one)
  - Span: heading-3 scale, `var(--heading)`, weight 600
- `h1.a` — presentation title, display scale, max-width 80%, `var(--heading)`
- `.meta.a` — presenter name + title, positioned absolute bottom-left
  - Name: `<strong>`, larger than heading-3, weight 700
  - Title: `<span>`, body scale, `var(--text-muted)`
  - Separated by `<br>`
- `.mountain-bg` — mountain SVG, absolute bottom-right, width 65%
  - `aria-hidden="true"`, opacity 1 in both themes
  - `.mountain-light` (light) / `.mountain-dark` (dark), CSS toggle

**Asset placeholders:**
- `{{LOGO_DATA_URI}}` → `references/images/logo.svg`
- `{{LOGO_WHITE_DATA_URI}}` → `references/images/logo-white.svg`
- `{{MOUNTAIN_SVG_INLINE}}` → `references/images/mountain.svg` (dark)
- `{{MOUNTAIN_WHITE_SVG_INLINE}}` → `references/images/mountain-white.svg` (light)

**Forbidden:** badge, caption, gradient text, 900 weight

---

## 2. Closing

Ending slide. Large logo + "감사합니다!" + closing message + mountain illustration.

**CSS classes:** `slide slide--closing slide--bg`

**HTML structure:**
- `.closing-hero.a` — flex row: large logo + h1 "감사합니다!"
  - Two logo images: `.logo-light` + `.logo-dark` (same pattern as Title)
  - h1 color: `var(--heading)` in both themes
  - margin-top ~12%
- `.closing-body.a` — closing message paragraphs
  - `var(--heading)` color in both themes
  - Last `<p>` includes a farewell like "함바! ⛰️"
- `.mountain-bg` — same as Title

**Asset placeholders:** same as Title

**Forbidden:** gradient text, badge

---

## 3. Agenda

Numbered list of presentation sections.

**CSS classes:** `slide slide--agenda`

**HTML structure:**
- `h2.a` — "목차" or "Agenda", heading-2 style, `var(--primary)`
- Numbered list: `<ol>` or custom flex list
  - Number: `var(--primary)`, weight 700
  - Title: body scale, `var(--text)`
  - Spacing adapts to item count (generous for ≤5, compact for ≥9)
- **Always single column** — no 2-column split
- **No border / card container** — minimal, text-only

---

## 4. Section Divider

Full-page slide announcing a new section.

**CSS classes:** `slide slide--section-divider`

**HTML structure:**
- `h2.a` — section title, heading-1 scale, `var(--heading)`
  - `::after` pseudo-element: highlight underline bar with primary tint
- `p.a` — optional section description, body scale, `var(--text-muted)`
- Vertically and horizontally centered

---

## 5. Key Point

One bold message, centered.

**HTML structure:**
- Message: heading-1 scale, optionally `var(--primary)`
- Description: body scale, `var(--text-muted)`, 1–2 lines
- Minimal elements — whitespace carries the message

---

## 6. Quote

Quotation + attribution.

**HTML structure:**
- Quote block with left border `var(--primary)` + subtle green gradient background
  - Rounded right corners
- Quote text: heading-3 scale, italic, `var(--heading)`
- Attribution: body-small, `var(--text-muted)`, `—` prefix
- Center or left aligned

---

## 7. Comparison (Versus)

Side-by-side comparison of two things.

**HTML structure:**
- `h2` — slide title
- `.versus` container: two-panel horizontal flex, vertically centered (`flex: 1; margin: auto 0`)
- Good panel: subtle primary-tinted background + border, primary label
- Bad panel: subtle danger-tinted background + border, danger label
- Each panel: `var(--radius-xl)` corners
- Panel label: label scale, weight 700, letter-spacing 0.03em
- Panel content: list or description text

---

## 8. Flow (Steps)

Step-by-step process.

**HTML structure:**
- `h2` — slide title
- `.flow` container: horizontal flex, vertically centered in available space (flex: 1, margin: auto 0)
- Each `.flow .step`: glassmorphism card with generous padding and min-width
  - Number: label scale, `var(--primary)`
  - Title: enlarged heading-3 scale
  - Description: body-small (optional)
- `.flow .arrow` between steps: `→`, `var(--primary)`, 48px width, enlarged font
- 3–6 steps recommended, flex-wrap for longer flows

---

## 9. Card Grid

Multiple items in a grid.

**HTML structure:**
- `h2` — slide title
- `.card-grid` wrapper: CSS grid centered in available space (flex: 1, align-content: center)
  - `.card-grid.cols-2` for 2-column, `.card-grid.cols-3` for 3-column
- Each `.card`: glassmorphism (see design-system.md §4)
  - Icon: emoji 28px, margin-bottom 12px
  - Title: heading-3
  - Description: body-small, `var(--text-muted)`
- Hover lift + shadow upgrade
- 3–6 cards recommended

---

## 10. Content

General text content — lists, paragraphs.

**HTML structure:**
- `h2` — slide title
- Custom list: circle marker in `var(--primary)` + text
- Paragraphs: body scale
- Badges: optional, pill shape
  - Variants: `.badge-primary`, `.badge-warm`, `.badge-cool`, `.badge-danger`
- Max 6–8 bullet points

---

## 11. Code

Code block + explanation.

**HTML structure:**
- `h2` — slide title
- `pre > code.language-xxx` — code block
  - Background: `var(--background-code)` (dark in both themes)
  - Font: JetBrains Mono, code scale
- Language label: top-left of `pre`, label scale, `var(--code-str)`, uppercase
- 4-color highlighting: `--code-kw`, `--code-fn`, `--code-str`, `--code-var`
- highlight.js CDN required when ≥1 Code slide exists
- Optional supplementary text: body-small, `var(--text-muted)`

---

## 12. Architecture

System diagrams via mermaid.js.

**HTML structure:**
- `h2` — slide title
- `<div class="mermaid">` — mermaid syntax
  - Diagram should fill **≥80%** of available slide area
  - Container: full width, min-height 400px, flex centered
  - Node/edge text: fontSize ≥16 for readability
- Dark theme: `theme: 'dark'` with custom themeVariables for green-tinted dark nodes and light text (see html-spec.md §6)
- Light theme: `theme: 'default'`
- Fallback: `<pre><code>` on render failure
- mermaid.js CDN required when ≥1 Architecture slide exists
- Optional supplementary text: body-small, `var(--text-muted)`

---

## 13. Timetable

Schedule displayed as a table.

**HTML structure:**
- `h2` — slide title
- `<table>` — full width, collapsed borders
- `<th>` — `var(--primary)`, weight 700, label scale, 2px solid bottom
- `<td>` — body-small scale, 1px solid `var(--border)` bottom
- 3–5 columns, 4–8 rows recommended

---

## 14. Timeline

Chronological events in a vertical timeline.

**HTML structure:**
- `h2` — slide title
- Vertical layout with left vertical line (`var(--primary)`, 2px)
- Each event: circular marker (`var(--primary)`, 12px) + date (heading-3) + description (body-small, `var(--text-muted)`)
- padding-left 32px
- 4–8 events recommended
