// End-to-end test of the built app in Chromium, with a controlled clock.
// Usage: npm run e2e   (SHOTS=dir to keep screenshots)
import { createRequire } from 'node:module';
import { createServer } from 'node:http';
import { readFile, mkdir } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const dist = fileURLToPath(new URL('../dist/', import.meta.url));
const shots = process.env.SHOTS || null;
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.svg': 'image/svg+xml', '.webmanifest': 'application/manifest+json', '.png': 'image/png' };

const server = createServer(async (req, res) => {
  const path = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname)).replace(/^(\.\.[/\\])+/, '');
  try {
    const body = await readFile(join(dist, path === '/' ? 'index.html' : path));
    res.writeHead(200, { 'content-type': types[extname(path)] || 'text/html' });
    res.end(body);
  } catch {
    res.writeHead(404);
    res.end('not found');
  }
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const base = `http://127.0.0.1:${server.address().port}/`;
if (shots) await mkdir(shots, { recursive: true });

const browser = await chromium.launch();
const failures = [];
let passed = 0;

async function scenario(name, fn, { viewport = { width: 390, height: 844 }, colorScheme = 'light', time = '2026-11-02T14:00:00Z' } = {}) {
  const context = await browser.newContext({ viewport, colorScheme, timezoneId: 'America/New_York', locale: 'en-US', deviceScaleFactor: 2 });
  // Fonts come from Google; keep tests hermetic and fast.
  await context.route(/fonts\.(googleapis|gstatic)\.com/, (route) => route.abort());
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
  page.on('console', (m) => {
    if (m.type() === 'error' && !/Failed to load resource|ERR_FAILED/.test(m.text())) errors.push(`console: ${m.text()}`);
  });
  await page.clock.install({ time: new Date(time) });
  try {
    await fn(page, { shot: async (file) => shots && page.screenshot({ path: join(shots, file), fullPage: true, animations: 'disabled' }) });
    assert.deepEqual(errors, [], 'no console or page errors');
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    assert.ok(overflow <= 0, `no horizontal scroll (overflow ${overflow}px)`);
    passed++;
    console.log(`ok - ${name}`);
  } catch (err) {
    failures.push(name);
    console.log(`not ok - ${name}\n  ${String(err && err.stack ? err.stack : err).split('\n').slice(0, 6).join('\n  ')}`);
    if (shots) await page.screenshot({ path: join(shots, `FAIL-${name.replace(/\W+/g, '-')}.png`), fullPage: true }).catch(() => {});
  } finally {
    await context.close();
  }
}

const stored = (page) => page.evaluate(() => JSON.parse(localStorage.getItem('leeway.v1') || 'null'));

// 1. A first-time visitor sees a working example day, not an empty shell.
await scenario('first visit shows the example day with the load line', async (page, { shot }) => {
  await page.goto(base);
  await page.getByText('This is an example day.').waitFor();
  assert.equal(await page.locator('main .task:not(.done)').count(), 6);
  await page.locator('.loadline', { hasText: 'Your day ends here' }).waitFor();
  assert.ok((await page.locator('.below-zone .task').count()) >= 1, 'some tasks fall below the line');
  assert.match(await page.locator('.gauge-big').innerText(), /left today/);
  assert.match(await page.locator('.pill').first().innerText(), /more than fits/);
  assert.equal(await stored(page), null, 'example data is never saved');
  await shot('01-example-phone-light.png');
});

await scenario('example day on desktop in dark mode', async (page, { shot }) => {
  await page.goto(base);
  await page.locator('.gauge').waitFor();
  const bg = await page.evaluate(() => getComputedStyle(document.body).backgroundColor);
  assert.equal(bg, 'rgb(11, 22, 34)');
  await shot('02-example-desktop-dark.png');
}, { viewport: { width: 1280, height: 900 }, colorScheme: 'dark' });

// 2. The insights page explains the multiplier and its charts respond to hover.
await scenario('your pace page: multiplier, translation table, trend hover, bars', async (page, { shot }) => {
  await page.goto(`${base}#pace`);
  await page.locator('.hero-num').waitFor();
  assert.match(await page.locator('.hero-num').innerText(), /^×\d\.\d$/);
  assert.equal(await page.locator('.translate tbody tr').count(), 5);
  await page.getByText('Is it working?').waitFor();
  assert.match(await page.locator('#acc-h + p').innerText(), /% closer to reality/);
  const hit = page.locator('#spark-hit');
  await hit.scrollIntoViewIfNeeded();
  await page.evaluate(() => new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r))));
  const box = await hit.boundingBox();
  await page.mouse.move(box.x + box.width * 0.5, box.y + box.height / 2);
  await page.locator('#tip:not([hidden])').waitFor();
  assert.match(await page.locator('#tip').innerText(), /×\d\.\d/);
  assert.ok((await page.locator('.bars li').count()) >= 3);
  await shot('03-pace-desktop.png');
}, { viewport: { width: 1280, height: 900 } });

// 3. The core loop, start to finish, on a phone.
await scenario('own day: onboarding, add, focus timer, done, learn, close the day', async (page, { shot }) => {
  await page.goto(base);
  await page.getByRole('button', { name: 'Start my own day' }).first().click();
  await page.getByRole('heading', { name: 'Plan the day you actually have.' }).waitFor();
  await shot('04-welcome.png');
  await page.getByRole('button', { name: '4h', exact: true }).click();
  await page.getByRole('button', { name: 'Start planning' }).click();
  await page.getByText('How much do you have in you today?').waitFor();
  await page.getByRole('button', { name: 'Good', exact: true }).click();
  await page.getByText('4h of focus').first().waitFor();

  const input = page.locator('#add-today');
  await input.fill('Write the launch post 45m #writing');
  await input.press('Enter');
  await input.fill('Reply to Sam 10m #email');
  await input.press('Enter');
  await input.fill('Plan the week 2h');
  await page.getByRole('button', { name: 'Add', exact: true }).click();
  assert.equal(await page.locator('main .list .task').count(), 3);
  // Research prior x1.5: 45 -> 1h 10m, 10 -> 15m, 2h -> 3h
  assert.match(await page.locator('main .task').first().innerText(), /guess 45m[\s\S]*really ~1h 10m[\s\S]*#writing/);
  await page.getByText('Your guesses add up to 2h 55m').waitFor();
  let s = await stored(page);
  assert.equal(s.tasks.length, 3);
  assert.equal(s.prefs.goodDayMin, 240);
  await shot('05-planned.png');

  // Focus on the first task and let 26 minutes pass.
  await page.getByRole('button', { name: 'Start Write the launch post' }).click();
  await page.locator('.focus').waitFor();
  await page.getByText('Only commit to 5 minutes').waitFor();
  await page.clock.fastForward('06:10');
  await page.getByText('Five minutes in. Starting was the hard part.').waitFor();
  await page.clock.fastForward('20:00');
  assert.match(await page.locator('.clock').innerText(), /^26:1\d$/);
  assert.match(await page.title(), /^26:1\d · Write the launch post · Leeway$/);
  await shot('06-focus.png');
  await page.locator('.focus').getByRole('button', { name: 'Done' }).click();
  await page.getByText(/Done in 26m\. You guessed 45m\. Leeway learned from it\./).waitFor();
  s = await stored(page);
  assert.equal(s.history.length, 1);
  assert.equal(s.history[0].a, 26);

  // Finish one without a timer: Leeway asks once, in one tap.
  await page.getByRole('button', { name: 'Mark done: Reply to Sam' }).click();
  await page.getByRole('heading', { name: 'How long did it take?' }).waitFor();
  await page.getByRole('button', { name: '20m', exact: true }).click();
  await page.getByText('Done in 20m. You guessed 10m.').waitFor();
  assert.equal((await stored(page)).history.length, 2);
  assert.equal(await page.locator('section[aria-label="Done today"] .task').count(), 2);

  // Persistence across reloads.
  await page.reload();
  await page.locator('section[aria-label="Done today"] .task').first().waitFor();
  assert.equal(await page.locator('main .list .task:not(.done)').count(), 1);

  // Close the day: the leftover goes to tomorrow.
  await page.getByRole('button', { name: 'Close the day' }).click();
  await page.getByText('You finished 2 tasks.').waitFor();
  await page.getByText('Today things took 16% less time than you guessed. Usually it is 31% longer than you guess.').waitFor();
  await page.locator('#close-note').fill('Launch post went faster than I feared.');
  await shot('07-close-day.png');
  await page.locator('.sheet').getByRole('button', { name: 'Close the day' }).click();
  await page.getByText(/Day closed at/).waitFor();
  s = await stored(page);
  const leftover = s.tasks.find((t) => t.title === 'Plan the week');
  assert.equal(leftover.day, '2026-11-03');
  assert.equal(s.days['2026-11-02'].note, 'Launch post went faster than I feared.');

  // Next morning the leftover is simply on today's list.
  await page.clock.fastForward('24:00:00');
  await page.reload();
  await page.getByRole('heading', { name: /Tuesday, November 3/ }).waitFor();
  assert.match(await page.locator('main .list .task').first().innerText(), /Plan the week/);
});

// 4. Unfinished days roll over without guilt.
await scenario('leftovers from an unclosed day can be brought into today', async (page) => {
  await page.goto(base);
  await page.getByRole('button', { name: 'Start my own day' }).first().click();
  await page.getByRole('button', { name: 'Start planning' }).click();
  await page.locator('#add-today').fill('Renew the passport 30m');
  await page.locator('#add-today').press('Enter');
  await page.clock.fastForward('26:00:00');
  await page.reload();
  await page.getByText(/1 task from yesterday is still open/).waitFor();
  await page.getByRole('button', { name: 'Bring it to today' }).click();
  await page.getByText('Brought 1 task into today.').waitFor();
  assert.equal(await page.locator('main .list .task').count(), 1);
  assert.equal(await page.locator('.banner.leftover').count(), 0);
});

// 5. Make it smaller works offline with local steps, and steps show in focus mode.
await scenario('make it smaller adds tiny steps and starts step one', async (page, { shot }) => {
  await page.goto(base);
  await page.getByRole('button', { name: 'More options for Write the project update for Friday' }).click();
  await page.locator('.sheet').getByRole('button', { name: 'Make it smaller' }).click();
  await page.getByText('Open a blank doc and give it a title').waitFor();
  await page.getByRole('button', { name: 'Start step 1' }).click();
  await page.locator('.focus .steps li').first().waitFor();
  assert.equal(await page.locator('.focus .steps li').count(), 5);
  await page.locator('.focus .steps input').first().check();
  assert.ok(await page.locator('.focus .steps li').first().evaluate((el) => el.classList.contains('done')));
  await shot('08-focus-steps.png');
});

// 6. Brain dump: paste a list, get tasks.
await scenario('pasting a multi-line list creates one task per line', async (page) => {
  await page.goto(base);
  await page.getByRole('button', { name: 'Start my own day' }).first().click();
  await page.getByRole('button', { name: 'Start planning' }).click();
  await page.locator('#add-today').focus();
  await page.evaluate(() => {
    const dt = new DataTransfer();
    dt.setData('text/plain', '- Email the landlord 10m\n- [ ] Groceries 30m #errands\n- Call mom');
    document.querySelector('#add-today').dispatchEvent(new ClipboardEvent('paste', { clipboardData: dt, bubbles: true, cancelable: true }));
  });
  await page.getByText('Added 3 tasks from your list.').waitFor();
  assert.equal(await page.locator('main .list .task').count(), 3);
});

// 7. Preferences, export and the task menu.
await scenario('preferences change the plan; export and menus open', async (page, { shot }) => {
  await page.goto(base);
  await page.getByRole('button', { name: 'Start my own day' }).first().click();
  await page.getByRole('button', { name: 'Start planning' }).click();
  await page.goto(`${base}#prefs`);
  await page.locator('#pref-good').selectOption('180');
  await page.locator('#pref-nostop').check();
  let s = await stored(page);
  assert.equal(s.prefs.goodDayMin, 180);
  assert.equal(s.prefs.stopAt, null);
  await page.getByRole('button', { name: 'Export' }).click();
  await page.getByRole('heading', { name: 'Export your data' }).waitFor();
  await shot('09-prefs.png');
  await page.keyboard.press('Escape');
  await page.goto(`${base}#today`);
  await page.locator('#add-today').fill('Big thing 3h');
  await page.locator('#add-today').press('Enter');
  // Energy not set yet counts as Okay: 75% of 3h.
  await page.getByText('2h 15m left today').waitFor();
  await page.getByRole('button', { name: 'More options for Big thing' }).click();
  await page.locator('.sheet').getByRole('button', { name: 'Move to Later' }).click();
  await page.getByText('Moved to Later.').waitFor();
  await page.getByRole('button', { name: 'Undo' }).click();
  assert.equal(await page.locator('main .list .task').count(), 1);
});

await browser.close();
server.close();
console.log(`\n${passed} passed, ${failures.length} failed`);
if (failures.length) process.exit(1);
