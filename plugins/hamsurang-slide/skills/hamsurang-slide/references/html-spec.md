# HTML Specification

HTML document structure, CDN dependencies, keyboard navigation, progress bar, speaker notes, fullscreen, 16:9 letterboxing, mermaid/highlight.js integration.

## 1. File Structure

- Single `.html` file
- All CSS inside `<style>` tag
- All JS inside `<script>` tag
- Only CDN links are external

## 2. Required CDN

Always include:

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.min.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap">
```

Include only when Code slides exist:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
```

Include only when Architecture slides exist:

```html
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
```

Do not include highlight.js stylesheet — the custom theme override in generation-rules.md §10 replaces it.

## 3. HTML Document Structure

```html
<!DOCTYPE html>
<html lang="ko" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Presentation Title — Hamsurang</title>
  <!-- CDN links -->
  <style>
    /* Copy all CSS from generation-rules.md §1–14 */
  </style>
</head>
<body>
  <noscript>
    <style>
      body { background: #fff !important; overflow: visible !important; }
      .presentation { background: #fff !important; width: auto !important; height: auto !important; overflow: visible !important; display: block !important; }
      .slides-container { width: 1280px; height: auto !important; overflow: visible !important; transform: none !important; display: block !important; }
      .slide { position: relative !important; opacity: 1 !important; transform: none !important; display: flex !important; width: 1280px; height: 720px; margin-bottom: 20px; }
    </style>
  </noscript>
  <div class="presentation">
    <div class="progress-bar"></div>
    <div class="slides-container">
      <!-- Slides -->
    </div>
    <div class="slide-counter"><span class="current">1</span> / <span class="total">N</span></div>
  </div>
  <script>
    /* Navigation JS (see §4) */
  </script>
</body>
</html>
```

For dark theme, change to `data-theme="dark"`.

## 4. Navigation JS

Complete JavaScript code to copy:

```javascript
(function() {
  const slides = document.querySelectorAll('.slide');
  const progressBar = document.querySelector('.progress-bar');
  const currentEl = document.querySelector('.slide-counter .current');
  const totalEl = document.querySelector('.slide-counter .total');
  let currentIndex = 0;
  let notesWindow = null;

  totalEl.textContent = slides.length;

  function goTo(index) {
    if (index < 0 || index >= slides.length) return;
    slides[currentIndex].classList.remove('active');
    currentIndex = index;
    slides[currentIndex].classList.add('active');
    currentEl.textContent = currentIndex + 1;
    progressBar.style.width = ((currentIndex + 1) / slides.length * 100) + '%';
    updateNotes();
  }

  function updateNotes() {
    if (notesWindow && !notesWindow.closed) {
      const notes = slides[currentIndex].getAttribute('data-notes') || '';
      notesWindow.document.body.innerHTML =
        '<div style="font-family:Pretendard,system-ui,sans-serif;padding:40px;max-width:800px;margin:0 auto;line-height:1.8;font-size:18px;">' +
        '<h2 style="color:#009972;margin-bottom:16px;">Slide ' + (currentIndex + 1) + ' / ' + slides.length + '</h2>' +
        '<p>' + notes + '</p></div>';
    }
  }

  document.addEventListener('keydown', function(e) {
    switch(e.key) {
      case 'ArrowRight': case ' ':
        e.preventDefault(); goTo(currentIndex + 1); break;
      case 'ArrowLeft':
        e.preventDefault(); goTo(currentIndex - 1); break;
      case 'f': case 'F':
        if (!document.fullscreenElement) { document.documentElement.requestFullscreen(); }
        else { document.exitFullscreen(); }
        break;
      case 's': case 'S':
        if (!notesWindow || notesWindow.closed) {
          notesWindow = window.open('', 'notes', 'width=600,height=400');
          notesWindow.document.title = 'Speaker Notes';
        }
        updateNotes();
        break;
      case 'Escape':
        if (document.fullscreenElement) { document.exitFullscreen(); }
        break;
    }
  });

  function resize() {
    const container = document.querySelector('.slides-container');
    const scaleX = window.innerWidth / 1280;
    const scaleY = window.innerHeight / 720;
    const scale = Math.min(scaleX, scaleY);
    container.style.transform = 'scale(' + scale + ')';
  }

  window.addEventListener('resize', resize);
  resize();
  goTo(0);
})();
```

**Keyboard mapping:**

| Key | Action |
|-----|--------|
| `→` / `Space` | Next slide |
| `←` | Previous slide |
| `F` | Toggle fullscreen |
| `S` | Speaker notes popup |
| `Escape` | Exit fullscreen |

## 5. highlight.js Integration

Append to script:

```javascript
if (typeof hljs !== 'undefined') { hljs.highlightAll(); }
```

Do not include highlight.js CSS — generation-rules.md §10 custom override replaces it.

## 6. mermaid.js Integration

Append to script:

```javascript
if (typeof mermaid !== 'undefined') {
  const theme = document.documentElement.getAttribute('data-theme');
  mermaid.initialize({
    startOnLoad: false,
    theme: 'base',
    securityLevel: 'loose',
    themeVariables: theme === 'dark' ? {
      primaryColor: '#1a3a2e',
      primaryTextColor: '#e0e0e0',
      primaryBorderColor: '#2bca9b',
      lineColor: '#2bca9b',
      secondaryColor: '#1e2d28',
      tertiaryColor: '#162420',
      nodeBorder: '#2bca9b',
      mainBkg: '#1a3a2e',
      nodeTextColor: '#e0e0e0',
      edgeLabelBackground: '#0c1410'
    } : {
      primaryColor: '#f7faf9',
      primaryTextColor: '#111111',
      primaryBorderColor: '#009972',
      lineColor: '#009972',
      secondaryColor: '#f7faf9',
      tertiaryColor: '#f7faf9',
      nodeBorder: '#009972',
      mainBkg: '#f7faf9',
      nodeTextColor: '#111111',
      edgeLabelBackground: '#ffffff'
    }
  });

  async function renderMermaid() {
    const elements = document.querySelectorAll('.mermaid');
    for (let i = 0; i < elements.length; i++) {
      const el = elements[i];
      const code = el.textContent;
      try {
        const { svg } = await mermaid.render('mermaid-' + i, code);
        el.innerHTML = svg;
      } catch (err) {
        el.innerHTML = '<pre><code>' + code + '</code></pre>';
      }
    }
  }

  renderMermaid();
}
```

## 7. Print / PDF

Print rules are defined in generation-rules.md §11.

Browser print (`Ctrl+P`) for PDF export:
- Overrides `body` background to white and `overflow` to visible
- Hides controls, progress bar, counter
- Reflows all slides to visible with `print-color-adjust: exact`
- Page-break per slide
- 1280×720 page size (`@page { size: 1280px 720px }` — do not add `landscape`; combining custom lengths with an orientation keyword makes browsers ignore the entire `size` declaration)

## 8. Accessibility

- All images require `alt` text
- Decorative SVGs get `aria-hidden="true"`
- All navigation is keyboard-accessible
- Use semantic HTML elements (h1, h2, h3, p, ul, ol, table, blockquote)
- Color contrast: WCAG AA (body 4.5:1, large text 3:1)
- `lang="ko"` attribute required
