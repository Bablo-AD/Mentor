// Zero-dependency build. Inlines src/ into single-file pages:
//   dist/index.html            full PWA page (GitHub Pages or any static host)
//   dist/leeway.artifact.html  body-only page for a claude.ai Artifact
// plus manifest, service worker and icons for the PWA.
import { readFile, writeFile, mkdir, readdir, copyFile } from 'node:fs/promises';

const root = new URL('../', import.meta.url);
const read = (p) => readFile(new URL(p, root), 'utf8');
const out = (p, data) => writeFile(new URL(`dist/${p}`, root), data);

// Turn an ES module into a scoped script exposing its exports as one object.
function moduleToScript(src, name) {
  const exported = [];
  const body = src
    .replace(/^export\s+(async\s+function|function|const|let|class)\s+([A-Za-z_$][\w$]*)/gm, (_m, kind, id) => {
      exported.push(id);
      return `${kind} ${id}`;
    })
    .replace(/^import\s.+?;\s*$/gm, '');
  if (/^\s*export\s/m.test(body)) throw new Error(`${name}: unsupported export form`);
  return `const ${name} = (() => {\n${body}\nreturn Object.freeze({ ${exported.join(', ')} });\n})();\n`;
}

const [core, app, css, pkg] = await Promise.all([read('src/core.js'), read('src/app.js'), read('src/styles.css'), read('package.json')]);
const version = JSON.parse(pkg).version;
const appBody = app.replace(/^import \* as Core from '\.\/core\.js';\s*$/m, '');
if (/^\s*import\s/m.test(appBody)) throw new Error('app.js: only `import * as Core` is supported');
const js = `${moduleToScript(core, 'Core')}\n${appBody}`;
if (/<\/script/i.test(js) || /<\/style/i.test(css)) throw new Error('Inline code must not contain closing script/style tags');

const description = 'Leeway learns how long things actually take you, then shows what really fits today. Free, private, no sign-up.';
const fonts = `<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible+Mono:wght@400;600;700&family=Atkinson+Hyperlegible+Next:wght@400;500;600;700;800&display=swap">`;
const body = `<header class="top" id="top"></header>
<main id="main" tabindex="-1"></main>
<div id="overlay"></div>
<div id="sheet-root"></div>
<div id="toast-root" class="toast-wrap" aria-live="polite"></div>
<div id="tip" class="tip" role="tooltip" hidden></div>
<noscript><p style="padding:24px;font-family:system-ui">Leeway needs JavaScript to run.</p></noscript>`;

// The artifact host wraps the page in its own doctype, head and reset.
const artifact = `<title>Leeway</title>
<meta name="claude:viewport-fit-sides" content="cover">
${fonts}
<style>
${css}
</style>
${body}
<script type="module">
${js}
</script>
`;

const reset = `:root{color-scheme:light;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}[hidden]{display:none!important}`;
const page = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Leeway · Plan the day you actually have</title>
<meta name="description" content="${description}">
<meta name="theme-color" content="#f3f6f8" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0b1622" media="(prefers-color-scheme: dark)">
<meta property="og:title" content="Leeway · Plan the day you actually have">
<meta property="og:description" content="${description}">
<meta property="og:type" content="website">
<meta property="og:image" content="og.png">
<meta name="twitter:card" content="summary_large_image">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" href="icon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="icon-192.png">
${fonts}
<style>${reset}
${css}
</style>
</head>
<body>
${body}
<script type="module">
${js}
</script>
</body>
</html>
`;

const icon = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="112" fill="#0f2436"/><circle cx="256" cy="256" r="150" fill="none" stroke="#4b92cc" stroke-width="28"/><path d="M96 256h320" stroke="#d4561c" stroke-width="34" stroke-linecap="round"/><path d="M148 322c25 0 25-19 50-19s25 19 52 19 25-19 50-19 25 19 52 19" fill="none" stroke="#4b92cc" stroke-width="22" stroke-linecap="round"/></svg>
`;

const manifest = {
  name: 'Leeway',
  short_name: 'Leeway',
  description,
  start_url: './#today',
  scope: './',
  display: 'standalone',
  background_color: '#f3f6f8',
  theme_color: '#1f5f92',
  icons: [
    { src: 'icon.svg', sizes: 'any', type: 'image/svg+xml', purpose: 'any' },
    { src: 'icon-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
    { src: 'icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' },
  ],
};

const sw = `// Leeway offline support. Network first for the page so deploys arrive, cache as fallback.
const CACHE = 'leeway-${version}';
const ASSETS = ['./', './index.html', './manifest.webmanifest', './icon.svg', './icon-192.png', './icon-512.png'];
self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (req.mode === 'navigate') {
    e.respondWith(fetch(req).then((res) => { const copy = res.clone(); caches.open(CACHE).then((c) => c.put('./index.html', copy)); return res; }).catch(() => caches.match('./index.html')));
    return;
  }
  const fontHost = url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com';
  if (url.origin === self.location.origin || fontHost) {
    e.respondWith(caches.open(CACHE).then(async (c) => {
      const hit = await c.match(req);
      const net = fetch(req).then((res) => { if (res.ok || res.type === 'opaque') c.put(req, res.clone()); return res; }).catch(() => hit);
      return hit || net;
    }));
  }
});
`;

await mkdir(new URL('dist/', root), { recursive: true });
for (const f of await readdir(new URL('public/', root)).catch(() => [])) await copyFile(new URL(`public/${f}`, root), new URL(`dist/${f}`, root));
await Promise.all([
  out('index.html', page),
  out('leeway.artifact.html', artifact),
  out('manifest.webmanifest', `${JSON.stringify(manifest, null, 2)}\n`),
  out('icon.svg', icon),
  out('sw.js', sw),
]);
console.log(`Built Leeway ${version}: dist/index.html (${(page.length / 1024).toFixed(1)} KB), dist/leeway.artifact.html (${(artifact.length / 1024).toFixed(1)} KB)`);
