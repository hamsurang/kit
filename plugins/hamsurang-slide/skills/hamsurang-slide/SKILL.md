---
name: hamsurang-slide
description: "Use when the user mentions 'hamsurang presentation', 'hamsurang PPT', 'hamsurang slide', '함수랑 발표', '함수랑 슬라이드', '함수랑 PPT', 'hamsurang 발표', or any presentation request in a Hamsurang (함수랑산악회) context — even if they don't explicitly say 'slide'."
---

# hamsurang-slide — Hamsurang HTML Presentation Generator

## Overview

Generates single-file HTML presentations with Hamsurang brand Soft Modern design.
Light/dark themes, 14 slide types, 4-color code highlighting, glassmorphism cards.
Output is always a single `.html` file — opens directly in a browser.

## When to Use

Activate when the request matches any of:
- "hamsurang 발표", "hamsurang PPT", "hamsurang slide"
- "함수랑 발표", "함수랑 슬라이드", "함수랑 PPT"
- Any mention of "presentation", "slide", or "PPT" in a Hamsurang context

## Workflow

### Step 1: Analyze Input

Extract from the user's request:
- Topic
- Duration (→ slide count mapping)
- Audience
- Language (generate content in the user's conversation language)

Default duration is 10 minutes.

| Duration | Slide Count |
|----------|-------------|
| 5 min | 8–12 |
| 10 min | 12–18 (default) |
| 15 min | 18–25 |
| 20 min | 25–30 |
| 30 min | 30–40 |

### Step 2: Generate Outline & Confirm

**Get user confirmation before proceeding.**

Present as a table:

| # | Type | Title | Key Points |
|---|------|-------|------------|
| 1 | Title | ... | ... |
| 2 | Agenda | ... | ... |
| ... | ... | ... | ... |
| N | Closing | ... | ... |

Incorporate edits and re-confirm if requested.

### Step 3: Choose Theme & Confirm

> **Choose a theme:**
> - **Light** — bright background, informative and open
> - **Dark** — green-tinted dark background, immersive

Default: Light.

### Step 4: Generate HTML

**Reference loading order (read in this exact order):**

1. `references/generation-rules.md` — **CSS single source of truth.** Copy all CSS from §1–14 into `<style>`.
2. `references/design-system.md` — Design philosophy, component patterns (no hardcoded values — all refer back to generation-rules.md)
3. `references/slide-catalog.md` — 14 slide type HTML structures
4. `references/html-spec.md` — HTML document structure, navigation JS, CDN

**References Loading Guide:**

| Situation | Load |
|-----------|------|
| Always (Step 4 start) | `references/generation-rules.md` |
| Applying design patterns, component styles | `references/design-system.md` |
| Building slide HTML for any of the 14 types | `references/slide-catalog.md` |
| Assembling final HTML document, adding JS, CDN links | `references/html-spec.md` |

**Generation rules:**

Build HTML for all 14 slide types following slide-catalog.md's **HTML structure** specs.
There is no fixed HTML template. Instead, follow the CSS classes, element hierarchy, and structure rules for each type.

**CSS rules:**
- Copy generation-rules.md §1–14 CSS into the `<style>` tag **verbatim**
- For flexible slide types (types 5–14), write any additional CSS **after** the copied CSS
- All style values must use `var(--name)` CSS variables — never hardcode color/size values

**Conditional CDN:**
- Code type slide present → include highlight.js CDN + `hljs.highlightAll()`
- Architecture type slide present → include mermaid.js CDN + init code
- Neither present → omit those CDN links

**Content overflow prevention:**
- Slide area is fixed at 1280×720px
- When there are many items, reduce font size and spacing to fit
- Agenda with 9+ items: reduce font/spacing (still single column)

### Step 5: Speaker Notes

Add `data-notes` attribute to each slide:
- Conversational tone
- Expand on slide content without repeating it
- Timing hints: `[2 min]`, `[PAUSE]`

### Step 6: Inline Assets & Save

Requires Python 3.7+ (standard library only — no pip packages).

1. Save `index.html` (or requested filename) to the user's working directory
2. Run `scripts/inline_assets.py`:
   ```
   python3 <skill_dir>/scripts/inline_assets.py <output.html> <skill_dir>/references/images/
   ```
3. Tell the user: "Open directly in your browser."

## Output Rules

1. Single `.html` file, all CSS/JS inlined
2. `<html lang="ko" data-theme="light|dark">`
3. 16:9 aspect ratio (1280×720 base, scale transform)
4. CDN: Pretendard, JetBrains Mono (always), highlight.js (conditional), mermaid.js (conditional)
5. Vanilla JS/CSS only — no frameworks
6. Max 6–8 bullet points per slide
7. Generate content in the user's conversation language

## Reference Architecture

```
references/
├── generation-rules.md   ← CSS SSOT (all values live here)
├── design-system.md      ← Design philosophy & patterns (no values)
├── slide-catalog.md      ← 14 slide type HTML structures
├── html-spec.md          ← HTML structure, JS, CDN
└── images/               ← SVG brand assets
```

## Slide Types

14 types. Details in `references/slide-catalog.md`.

**Core 4:** Title, Closing, Agenda, Section Divider
**Flexible 10:** Key Point, Quote, Comparison, Flow, Card Grid, Content, Code, Architecture, Timetable, Timeline
