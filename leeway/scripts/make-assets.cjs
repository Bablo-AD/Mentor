// Renders the PWA icons and the social preview image into public/.
// Run once after changing the brand (needs Playwright): node scripts/make-assets.cjs
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const pub = path.join(__dirname, '..', 'public');
const icon = fs.readFileSync(path.join(__dirname, '..', 'dist', 'icon.svg'), 'utf8');
(async () => {
  const browser = await chromium.launch();
  for (const size of [192, 512]) {
    const page = await browser.newPage({ viewport: { width: size, height: size } });
    await page.setContent(`<style>html,body{margin:0;background:#0f2436}svg{display:block;width:${size}px;height:${size}px}</style>${icon}`);
    await page.screenshot({ path: path.join(pub, `icon-${size}.png`) });
    await page.close();
  }
  const og = await browser.newPage({ viewport: { width: 1200, height: 630 } });
  await og.setContent(`<!doctype html><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible+Next:wght@500;800&display=swap">
  <style>body{margin:0;width:1200px;height:630px;background:#0f2436;font-family:"Atkinson Hyperlegible Next",system-ui,sans-serif;color:#fff;position:relative;overflow:hidden}
  .water{position:absolute;left:0;right:0;top:430px;bottom:0;background:#143654}.line{position:absolute;left:0;right:0;top:426px;height:8px;background:#d4561c}
  .in{position:absolute;left:80px;top:70px;right:80px}.brand{display:flex;align-items:center;gap:16px;font-weight:800;font-size:40px}.brand svg{width:58px;height:58px}
  h1{font-size:76px;line-height:1.02;margin:44px 0 0;letter-spacing:-0.02em;font-weight:800}.sub{position:absolute;left:80px;top:470px;font-size:31px;color:#cfe0ee;font-weight:500;max-width:1000px}
  .tag{position:absolute;right:80px;top:384px;color:#f0a37c;font-weight:800;font-size:24px}</style>
  <div class="water"></div><div class="line"></div>
  <div class="in"><div class="brand">${icon}<span>Leeway</span></div><h1>Plan the day you<br>actually have.</h1></div>
  <div class="tag">where your day really ends</div>
  <div class="sub">Learns how long things really take you, then shows what fits today. Free, private, no sign-up.</div>`, { waitUntil: 'networkidle' }).catch(() => {});
  await og.waitForTimeout(500);
  await og.screenshot({ path: path.join(pub, 'og.png') });
  await browser.close();
  console.log('wrote public/icon-192.png, public/icon-512.png, public/og.png');
})();
