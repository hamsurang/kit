# Generation Rules — CSS Single Source of Truth

All design token values and CSS implementations live in this file.
The agent copies **all CSS from sections 1–14** into the `<style>` tag when generating HTML.
No other file contains implementable style values.

## 1. CSS Variables — Light Theme

```css
:root {
  --background: #ffffff;
  --background-alt: #f7faf9;
  --background-code: #1a1f2e;
  --text: #111111;
  --text-muted: #555555;
  --text-subtle: #999999;
  --heading: #111111;
  --primary: #009972;
  --primary-dark: #007f5f;
  --primary-light: #2bca9b;
  --accent-warm: #f59e0b;
  --accent-cool: #6366f1;
  --danger: #ef4444;
  --surface-card: rgba(255,255,255,0.8);
  --border: #e8edeb;
  --text-on-primary: #ffffff;

  --code-kw: #818cf8;
  --code-fn: #f59e0b;
  --code-str: #2bca9b;
  --code-var: #7dd3fc;
  --code-cm: #555;
  --code-text: #e0e0e0;

  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-2xl: 20px;
  --radius-full: 999px;

  --shadow-sm: 0 1px 4px rgba(0,153,114,0.06);
  --shadow: 0 2px 12px rgba(0,153,114,0.08);
  --shadow-lg: 0 6px 20px rgba(0,153,114,0.12);
}
```

## 2. CSS Variables — Dark Theme

```css
[data-theme="dark"] {
  --background: #0c1410;
  --background-alt: #121d18;
  --background-code: #0e1a16;
  --text: #f0f0f0;
  --text-muted: #8a9e96;
  --text-subtle: #5a7a70;
  --heading: #ffffff;
  --primary: #2bca9b;
  --primary-dark: #009972;
  --primary-light: #8ce0cb;
  --accent-warm: #f59e0b;
  --accent-cool: #818cf8;
  --danger: #f87171;
  --surface-card: rgba(0,153,114,0.06);
  --border: rgba(0,153,114,0.12);
  --text-on-primary: #0c1410;

  --code-kw: #818cf8;
  --code-fn: #f59e0b;
  --code-str: #2bca9b;
  --code-var: #7dd3fc;
  --code-cm: #5a7a70;
  --code-text: #e0e0e0;
}
```

## 3. Base Styles

```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
  background: #000;
  overflow: hidden;
}

.presentation {
  width: 100vw; height: 100vh;
  display: flex; align-items: center; justify-content: center;
  background: #000; overflow: hidden;
}

.slides-container {
  width: 1280px; height: 720px;
  position: relative; overflow: hidden;
  transform-origin: center center;
  background: var(--background);
}

.slide {
  position: absolute; top: 0; left: 0;
  width: 100%; height: 100%;
  display: flex; flex-direction: column;
  padding: 60px 80px;
  background: var(--background);
  opacity: 0; transform: translateY(8px);
  pointer-events: none;
  transition: opacity 0.4s ease, transform 0.4s ease;
}

.slide.active {
  opacity: 1; transform: none; pointer-events: auto;
}

h1 { font-size: clamp(2.4rem, 3vw, 3.6rem); font-weight: 700; line-height: 1.1; letter-spacing: -0.02em; color: var(--heading); }
h2 { font-size: clamp(1.6rem, 2.2vw, 2rem); font-weight: 700; line-height: 1.3; color: var(--primary); margin-bottom: clamp(28px, 2vw, 32px); }
h3 { font-size: clamp(1.3rem, 1.6vw, 1.5rem); font-weight: 600; line-height: 1.4; color: var(--heading); }
p, li { font-size: clamp(1.15rem, 1.5vw, 1.4rem); line-height: 1.7; color: var(--text); }
```

## 4. Title Slide

```css
.slide--title { padding: 11% 7% 5%; }
.slide--bg .mountain-bg {
  position: absolute; bottom: 0; right: 0;
  width: 65%; max-height: 70%;
  opacity: 1;
  pointer-events: none; z-index: 0;
}
.slide--bg .mountain-bg svg { width: 100%; height: auto; }
.mountain-bg { overflow: hidden; }
.mountain-bg svg { transform: scale(1.02); transform-origin: bottom right; }
.mountain-light { display: block; }
.mountain-dark { display: none; }
[data-theme="dark"] .mountain-light { display: none; }
[data-theme="dark"] .mountain-dark { display: block; }
.logo-badge {
  display: flex; align-items: center; gap: clamp(10px, 0.6vw, 12px);
  margin-bottom: clamp(14px, 1vw, 18px); position: relative; z-index: 1;
}
.logo-badge img { width: clamp(1.8rem, 2vw, 2.2rem); height: clamp(1.8rem, 2vw, 2.2rem); border-radius: clamp(0.4rem, 0.3vw, 0.5rem); }
.logo-badge span { font-size: clamp(1.4rem, 1.6vw, 1.8rem); font-weight: 600; color: var(--heading); letter-spacing: -0.02em; }
.slide--title h1 { position: relative; z-index: 1; max-width: 80%; }
[data-theme="dark"] .slide--title h1 { color: var(--heading); }
.meta {
  position: absolute; bottom: 13%; left: 7%;
  font-size: clamp(1.4rem, 1.8vw, 1.8rem); line-height: 1.6; z-index: 1;
}
.meta strong { color: var(--heading); font-weight: 700; font-size: clamp(1.5rem, 1.9vw, 1.9rem); }
.meta span { color: var(--text-muted); font-size: clamp(1.3rem, 1.6vw, 1.6rem); }
```

## 5. Closing Slide

```css
.slide--closing { padding: 10% 7% 5%; }
.closing-hero {
  display: flex; align-items: center;
  gap: clamp(0.8rem, 0.8vw, 1rem);
  margin-top: 12%; position: relative; z-index: 1;
}
.closing-hero img { width: clamp(2.8rem, 3.2vw, 3.8rem); height: clamp(2.8rem, 3.2vw, 3.8rem); border-radius: clamp(0.6rem, 0.5vw, 0.8rem); flex-shrink: 0; }
.closing-hero h1 { line-height: 1; }
[data-theme="dark"] .closing-hero h1 { color: var(--heading); }
.closing-body {
  margin-top: clamp(1.4rem, 1.8vw, 2rem);
  font-size: clamp(1.2rem, 1.4vw, 1.5rem);
  line-height: 1.7; max-width: 80%; position: relative; z-index: 1;
  color: var(--heading);
}
```

## 6. Section Divider Slide

```css
.slide--section-divider {
  justify-content: center; align-items: center; text-align: center;
}
.slide--section-divider h2 {
  display: inline-block; position: relative;
  margin-bottom: clamp(24px, 2.4vw, 36px); color: var(--heading);
  font-size: clamp(2.2rem, 3vw, 2.8rem);
}
.slide--section-divider h2::after {
  content: ''; position: absolute;
  left: -20px; right: -20px;
  height: clamp(0.6rem, 0.8vw, 0.9rem);
  bottom: 2px;
  background: rgba(0,153,114,0.25);
  z-index: -1; border-radius: 2px;
}
.slide--section-divider p { color: var(--text-muted); font-size: clamp(1.15rem, 1.5vw, 1.4rem); max-width: none; }
```

## 7. Component Styles

```css
.card {
  background: var(--surface-card);
  backdrop-filter: blur(8px);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: clamp(20px, 2vw, 28px);
  box-shadow: var(--shadow);
  transition: transform 0.2s, box-shadow 0.2s;
}
.card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow-lg);
}

.card-grid {
  display: grid;
  gap: clamp(20px, 2vw, 40px);
  flex: 1;
  align-content: center;
  justify-content: center;
  width: 100%;
}
.card-grid.cols-2 { grid-template-columns: repeat(2, 1fr); }
.card-grid.cols-3 { grid-template-columns: repeat(3, 1fr); }

.badge {
  display: inline-block;
  padding: 5px 14px;
  border-radius: var(--radius-full);
  font-size: clamp(0.8rem, 0.95vw, 0.95rem);
  font-weight: 700;
  letter-spacing: 0.03em;
}
.badge-primary { background: rgba(0,153,114,0.15); color: var(--primary); }
.badge-warm { background: rgba(245,158,11,0.15); color: var(--accent-warm); }
.badge-cool { background: rgba(99,102,241,0.15); color: var(--accent-cool); }
.badge-danger { background: rgba(239,68,68,0.15); color: var(--danger); }
[data-theme="dark"] .badge-primary { background: rgba(43,202,155,0.2); color: #2bca9b; }
[data-theme="dark"] .badge-warm { background: rgba(245,158,11,0.2); color: #fbbf24; }
[data-theme="dark"] .badge-cool { background: rgba(129,140,248,0.2); color: #a5b4fc; }
[data-theme="dark"] .badge-danger { background: rgba(248,113,113,0.2); color: #fca5a5; }

.quote-block {
  border-left: 3px solid var(--primary);
  background: linear-gradient(135deg, rgba(0,153,114,0.04) 0%, transparent 100%);
  border-radius: 0 var(--radius-lg) var(--radius-lg) 0;
  padding: clamp(20px, 2vw, 28px);
}

pre {
  background: var(--background-code);
  border-radius: var(--radius-lg);
  padding: clamp(20px, 2vw, 28px);
  font-family: 'JetBrains Mono', monospace;
  font-size: clamp(1rem, 1.2vw, 1.2rem);
  line-height: 1.7;
  position: relative;
  overflow-x: auto;
  overflow-y: auto;
  max-height: 480px;
}

.versus { display: flex; gap: clamp(16px, 1.2vw, 20px); width: 100%; flex: 1; align-items: center; margin: auto 0; }
.versus .panel { flex: 1; border-radius: var(--radius-xl); padding: clamp(20px, 2vw, 28px); border: 1px solid var(--border); }
.versus .panel.good { background: rgba(0,153,114,0.05); border-color: rgba(0,153,114,0.3); }
.versus .panel.bad { background: rgba(239,68,68,0.05); border-color: rgba(239,68,68,0.3); }
[data-theme="dark"] .versus .panel.good { background: rgba(43,202,155,0.08); border-color: rgba(43,202,155,0.25); }
[data-theme="dark"] .versus .panel.bad { background: rgba(248,113,113,0.08); border-color: rgba(248,113,113,0.25); }

.flow { display: flex; align-items: center; justify-content: center; gap: 0; flex-wrap: wrap; flex: 1; margin: auto 0; }
.flow .step { background: var(--surface-card); backdrop-filter: blur(8px); border: 1px solid var(--border); border-radius: var(--radius-xl); padding: clamp(24px, 2.5vw, 36px) clamp(28px, 3vw, 44px); text-align: center; min-width: clamp(140px, 12vw, 180px); }
.flow .step h3 { font-size: clamp(1.4rem, 1.8vw, 1.7rem); }
.flow .step p { font-size: clamp(1rem, 1.3vw, 1.25rem); margin-top: 6px; }
.flow .arrow { color: var(--primary); font-size: clamp(1.8rem, 2.4vw, 2.6rem); width: 48px; text-align: center; }

table { width: 100%; border-collapse: collapse; }
th { color: var(--primary); font-weight: 700; font-size: clamp(0.8rem, 0.95vw, 0.95rem); border-bottom: 2px solid var(--primary); padding: clamp(12px, 1vw, 16px); text-align: left; }
td { font-size: clamp(1rem, 1.2vw, 1.15rem); border-bottom: 1px solid var(--border); padding: clamp(12px, 1vw, 16px); color: var(--text); }

ul { list-style: none; padding: 0; }
ul li { padding: 8px 0 8px 28px; position: relative; }
ul li::before { content: ''; width: 8px; height: 8px; border-radius: 50%; background: var(--primary); position: absolute; left: 2px; top: 50%; transform: translateY(-50%); }
```

## 8. Logo Theme Toggle

```css
.logo-light { display: inline; }
.logo-dark { display: none; }
[data-theme="dark"] .logo-light { display: none; }
[data-theme="dark"] .logo-dark { display: inline; }
```

## 9. Staggered Animation

```css
.slide.active .a { animation: fadeInUp 0.4s ease forwards; opacity: 0; }
.slide.active .a:nth-child(1) { animation-delay: 0.05s; }
.slide.active .a:nth-child(2) { animation-delay: 0.10s; }
.slide.active .a:nth-child(3) { animation-delay: 0.15s; }
.slide.active .a:nth-child(4) { animation-delay: 0.20s; }
.slide.active .a:nth-child(5) { animation-delay: 0.25s; }
.slide.active .a:nth-child(6) { animation-delay: 0.30s; }
.slide.active .a:nth-child(7) { animation-delay: 0.35s; }
.slide.active .a:nth-child(8) { animation-delay: 0.40s; }

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}
```

## 10. highlight.js Theme Override

```css
.hljs { background: var(--background-code) !important; color: var(--code-text) !important; }
.hljs-keyword, .hljs-selector-tag, .hljs-built_in { color: var(--code-kw) !important; }
.hljs-title, .hljs-title.function_ { color: var(--code-fn) !important; }
.hljs-string, .hljs-attr { color: var(--code-str) !important; }
.hljs-variable, .hljs-params { color: var(--code-var) !important; }
.hljs-comment { color: var(--code-cm) !important; font-style: italic; }
.hljs-number, .hljs-literal { color: var(--code-var) !important; }
.hljs-type, .hljs-class { color: var(--code-fn) !important; }
```

## 11. Print Styles

```css
@media print {
  .controls, .progress-bar, .slide-counter { display: none !important; }
  .presentation { background: none; width: auto; height: auto; overflow: visible; display: block; }
  .slides-container { width: auto; height: auto; overflow: visible; transform: none !important; display: block; }
  .slide {
    position: relative !important; display: flex !important;
    width: 1280px; height: 720px;
    opacity: 1 !important; transform: none !important;
    pointer-events: auto !important;
    page-break-after: always; break-after: page;
    animation: none !important;
  }
  .slide:last-child { page-break-after: auto; break-after: auto; }
  @page { size: 1280px 720px landscape; margin: 0; }
}
```

## 12. Progress Bar & Slide Counter

```css
.progress-bar {
  position: absolute; top: 0; left: 0;
  height: 3px; background: var(--primary);
  transition: width 0.3s ease; z-index: 100;
}
.slide-counter {
  position: absolute; bottom: 16px; right: 24px;
  font-size: clamp(0.85rem, 1vw, 1rem);
  color: var(--text-subtle); z-index: 100;
}
```

## 13. Mermaid Container

```css
.mermaid {
  width: 100%;
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}
```

## 14. Do's and Don'ts

### Do's

- Use `var(--primary)` solid color for text, badges, and labels; Amber/Indigo for semantic emphasis
- Express status with badges (primary / warm / cool / danger)
- Quote blocks: 3px left border `var(--primary)` + green-tinted gradient
- Code blocks: language label + highlight.js auto-highlighting
- Glassmorphism cards: `backdrop-filter: blur(8px)`, `var(--surface-card)`, `1px solid var(--border)`, `var(--radius-xl)`
- Card hover: `translateY(-3px)` + `var(--shadow-lg)`
- Card Grid: wrap cards in `.card-grid` container, centered in available space
- Comparison: side-by-side panels (good = primary tint, bad = danger tint)
- Flow: enlarged cards + `→` arrows, vertically centered in slide
- fadeInUp animation via `.a` class
- Pretendard + JetBrains Mono CDN
- Define light/dark CSS variable pairs
- Mountain SVG: **opacity 1 in both themes**, light uses `mountain-white.svg` (`.mountain-light`), dark uses `mountain.svg` (`.mountain-dark`)
- Presenter name/title in heading-3+ size for visibility
- Agenda always single column (no 2-column split)
- Architecture (mermaid) diagrams fill ≥80% of available slide area

### Don'ts

- No white-background mermaid nodes in dark theme — use dark theme variables with light text
- No badge, caption, or gradient text on Title slide
- No badge or gradient text on Closing slide
- No decorative use of accent colors
- No full-background gradients — solid backgrounds only
- No 900 font weight
- No more than 8 bullet points per slide
- No auto-searching/inserting external images
- No light backgrounds on code blocks — always dark in both themes
- Keep content within 1280×720 — reduce spacing/font when items overflow. Code blocks have max-height with scroll.
- No 2-column Agenda — use font/spacing reduction instead
