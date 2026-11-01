// Leeway app: rendering, events, storage and platform features.
// Planning logic lives in core.js; this file only wires it to the screen.
import * as Core from './core.js';

const {
  fmtMin, fmtTimer, fmtMult, dayKey, addDays, learnPace, planDay, capacityFor, todayTasks, laterTasks,
  scheduledTasks, droppedTasks, leftoverTasks, doneOn, runningTask, elapsedMs, multiplierFor, realMinutes,
} = Core;

const VERSION = '0.1.0';
const LS_KEY = 'leeway.v1';
const hasClaude = typeof window.claude === 'object' && window.claude !== null && typeof window.claude.use === 'function';
const use = (name) => (hasClaude ? Promise.resolve(window.claude.use(name)).catch(() => null) : Promise.resolve(null));

// ---------------------------------------------------------------------------
// Icons (inline, decorative)
// ---------------------------------------------------------------------------

const svg = (d, extra = '') => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" ${extra}>${d}</svg>`;
const I = {
  check: svg('<path d="M5 12.5l4.2 4.2L19 7"/>', 'stroke-width="3"'),
  play: svg('<path d="M8 5.5v13l10-6.5z" fill="currentColor" stroke="none"/>'),
  pause: svg('<path d="M8 5v14M16 5v14" stroke-width="3"/>'),
  more: svg('<circle cx="5" cy="12" r="1.6" fill="currentColor"/><circle cx="12" cy="12" r="1.6" fill="currentColor"/><circle cx="19" cy="12" r="1.6" fill="currentColor"/>'),
  close: svg('<path d="M6 6l12 12M18 6L6 18"/>'),
  gear: svg('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>'),
  sparkle: svg('<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/><path d="M19 15l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7z"/>'),
  up: svg('<path d="M12 19V5M6 11l6-6 6 6"/>'),
  down: svg('<path d="M12 5v14M6 13l6 6 6-6"/>'),
  top: svg('<path d="M5 4h14M12 20V9M7 13l5-5 5 5"/>'),
  sun: svg('<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'),
  tray: svg('<path d="M4 13h4l2 3h4l2-3h4"/><path d="M5.5 5h13L21 13v6H3v-6z"/>'),
  wave: svg('<path d="M2 12c2.5 0 2.5-3 5-3s2.5 3 5 3 2.5-3 5-3 2.5 3 5 3"/><path d="M2 18c2.5 0 2.5-3 5-3s2.5 3 5 3 2.5-3 5-3 2.5 3 5 3"/>'),
  trash: svg('<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>'),
  edit: svg('<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M14 6l4 4"/>'),
  copy: svg('<rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V5a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h3"/>'),
  image: svg('<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="10" r="2"/><path d="M21 16l-5-5-9 9"/>'),
  save: svg('<path d="M12 4v11M7 10l5 5 5-5M5 20h14"/>'),
  ok: svg('<path d="M5 12.5l4.2 4.2L19 7"/>', 'stroke-width="2.6"'),
  over: svg('<path d="M12 4l9 16H3z"/><path d="M12 10v4M12 17v.5"/>'),
  lock: svg('<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>'),
  heart: svg('<path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z"/>'),
};
const LOGO = `<svg viewBox="0 0 32 32" aria-hidden="true"><circle cx="16" cy="16" r="13" fill="none" stroke="var(--mark)" stroke-width="2.5"/><path d="M4.5 16h23" stroke="var(--limit)" stroke-width="3" stroke-linecap="round"/><path d="M7.5 21.5c2.1 0 2.1-1.6 4.2-1.6s2.1 1.6 4.3 1.6 2.1-1.6 4.2-1.6 2.1 1.6 4.3 1.6" fill="none" stroke="var(--mark)" stroke-width="2" stroke-linecap="round"/></svg>`;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

let real = null; // the person's own data (saved)
let demo = null; // the example day (memory only)
let mode = 'real';
let undo = null;
let aiBlocked = false;
const ui = {
  route: 'today',
  sheet: null,
  focusId: null,
  toast: null,
  drafts: { today: '', later: '' },
  chip: { today: 30, later: 30 },
  setup: { goodDayMin: 300, stopAt: '18:00', noStop: false },
  trend: [],
};

const S = () => (mode === 'sample' ? demo : real);
const now = () => Date.now();
const P = () => S().prefs;
const todayKey = () => dayKey(now(), P().dayStartHour);
const findTask = (id) => S().tasks.find((t) => t.id === id) || null;

function commit(next, { toast = null, withUndo = false, quiet = false } = {}) {
  const prev = S();
  const stamped = Core.pruneState({ ...next, updatedAt: now() }, now());
  if (mode === 'sample') demo = stamped;
  else {
    real = stamped;
    persist();
  }
  undo = withUndo ? { prev, mode } : null;
  if (toast) showToast(toast, withUndo);
  if (!quiet) render();
  ensureTicking();
}

// ---------------------------------------------------------------------------
// Storage: this browser always; the person's private Claude storage when the
// page runs inside Claude and the viewer may write there.
// ---------------------------------------------------------------------------

function readLocal() {
  try {
    const raw = localStorage.getItem(LS_KEY);
    return raw ? Core.normalizeState(JSON.parse(raw)) : null;
  } catch {
    return null;
  }
}

function writeLocal(state) {
  try {
    localStorage.setItem(LS_KEY, JSON.stringify(state));
    return true;
  } catch {
    return false;
  }
}

const cloud = { status: hasClaude ? 'connecting' : 'off', ref: null, timer: null, saving: false, dirty: false };

function persist() {
  writeLocal(real);
  scheduleCloudSave();
}

function cloudBody(state) {
  let s = state;
  let json = JSON.stringify(s);
  while (json.length > 240000 && s.history.length > 200) {
    s = { ...s, history: s.history.slice(Math.floor(s.history.length / 3)) };
    json = JSON.stringify(s);
  }
  return JSON.parse(json);
}

function scheduleCloudSave(delay = 1200) {
  if (!cloud.ref || cloud.status === 'readonly') return;
  clearTimeout(cloud.timer);
  cloud.timer = setTimeout(flushCloud, delay);
}

async function flushCloud(retry = true) {
  if (!cloud.ref || !real) return;
  if (cloud.saving) {
    cloud.dirty = true;
    return;
  }
  cloud.saving = true;
  try {
    await cloud.ref.set(cloudBody(real));
    cloud.status = 'on';
  } catch (e) {
    const code = e && e.code;
    if (code === 'invalid_argument' || code === 'not_granted' || code === 'revoked') cloud.status = 'readonly';
    else if (code === 'unavailable' && retry) {
      cloud.saving = false;
      setTimeout(() => flushCloud(false), 1500 + Math.random() * 2000);
      return;
    } else cloud.status = 'error';
  } finally {
    cloud.saving = false;
  }
  if (cloud.dirty) {
    cloud.dirty = false;
    scheduleCloudSave(400);
  }
  if (ui.route === 'prefs') render();
}

const hasData = (s) => !!s && (s.onboarded || s.tasks.length > 0 || s.history.length > 0);

async function connectCloud() {
  if (!hasClaude) return;
  try {
    const [db, user] = await Promise.all([use('db'), use('user')]);
    const id = db && user ? await user.id() : null;
    if (!id) {
      cloud.status = 'off';
      return;
    }
    cloud.ref = db.doc(`data/users/${id}/leeway`);
    const snap = await Promise.race([cloud.ref.get(), new Promise((resolve) => setTimeout(() => resolve('timeout'), 10000))]);
    if (snap === 'timeout') {
      cloud.status = 'error';
      return;
    }
    const remote = snap && snap.exists ? Core.normalizeState(snap.data()) : null;
    if (remote && hasData(remote) && (!real || remote.updatedAt > real.updatedAt)) {
      real = remote;
      writeLocal(real);
      if (mode === 'sample') {
        mode = 'real';
        showToast('Loaded your saved plan.');
      }
      render();
    } else if (hasData(real)) {
      scheduleCloudSave(0);
    }
    cloud.status = 'on';
  } catch (e) {
    cloud.status = e && e.code === 'invalid_argument' ? 'readonly' : 'error';
  } finally {
    if (ui.route === 'prefs') render();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const $ = (sel, root = document) => root.querySelector(sel);
const ESC = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ESC[c]);
const plural = (n, one, many = `${one}s`) => `${n} ${n === 1 ? one : many}`;
const pressed = (b) => `aria-pressed="${b ? 'true' : 'false'}"`;

const clockFmt = new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' });
const fmtClock = (ms) => clockFmt.format(new Date(ms));
function keyDate(key) {
  const [y, m, d] = key.split('-').map(Number);
  return new Date(y, m - 1, d, 12);
}
const longDay = (key) => keyDate(key).toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' });
function relDay(key) {
  const today = todayKey();
  if (key === today) return 'today';
  if (key === addDays(today, -1)) return 'yesterday';
  if (key === addDays(today, 1)) return 'tomorrow';
  return keyDate(key).toLocaleDateString(undefined, { weekday: 'long' });
}
const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);

function paceNow() {
  return learnPace(S().history, { now: now() });
}

function dayContext() {
  const s = S();
  const key = todayKey();
  const day = s.days[key] || {};
  const capacity = capacityFor(s.prefs.goodDayMin, day.energy || 'ok', day.adjust || 0);
  const done = doneOn(s.tasks, key, s.prefs.dayStartHour);
  const used = done.reduce((sum, t) => sum + (t.actual || 0), 0);
  const open = todayTasks(s.tasks, key);
  const pace = paceNow();
  const stopMs = Core.stopTimeMs(key, s.prefs.stopAt, s.prefs.dayStartHour);
  const plan = planDay(open, { pace, capacityMin: capacity, usedMin: used, now: now(), stopMs });
  return { s, key, day, capacity, done, used, open, pace, stopMs, plan };
}

// ---------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------

function render() {
  if (!S()) return;
  const active = document.activeElement;
  const activeId = active && active.id ? active.id : null;
  let sel = null;
  try {
    if (activeId && typeof active.selectionStart === 'number') sel = [active.selectionStart, active.selectionEnd];
  } catch {
    sel = null;
  }

  $('#top').innerHTML = renderTop();
  const main = $('#main');
  main.innerHTML = renderRoute();
  $('#overlay').innerHTML = renderFocus() + renderRunbar();
  $('#sheet-root').innerHTML = renderSheet();
  $('#toast-root').innerHTML = renderToast();
  document.body.style.overflow = ui.sheet || ui.focusId ? 'hidden' : '';

  if (activeId) {
    const el = document.getElementById(activeId);
    if (el && el !== document.activeElement) {
      el.focus({ preventScroll: true });
      if (sel && typeof el.setSelectionRange === 'function') {
        try {
          el.setSelectionRange(sel[0], sel[1]);
        } catch {
          /* not a text field */
        }
      }
    }
  }
  updateTitle();
}

function renderTop() {
  const s = S();
  const laterCount = laterTasks(s.tasks).length + scheduledTasks(s.tasks, todayKey()).length;
  const tab = (route, label) => `<a href="#${route}" ${ui.route === route ? 'aria-current="page"' : ''}>${label}</a>`;
  return `<div class="top-in">
    <a class="brand" href="#today" aria-label="Leeway, go to today">${LOGO}<span>Leeway</span></a>
    <nav class="tabs" aria-label="Views">
      ${tab('today', 'Today')}
      ${tab('later', `Later${laterCount ? ` <span class="count">${laterCount}</span>` : ''}`)}
      ${tab('pace', 'Your pace')}
      <a href="#prefs" ${ui.route === 'prefs' ? 'aria-current="page"' : ''} aria-label="Preferences" title="Preferences">${I.gear}</a>
    </nav>
  </div>`;
}

function renderRoute() {
  const banner = mode === 'sample' ? sampleBanner() : '';
  if (ui.route === 'later') return banner + renderLater();
  if (ui.route === 'pace') return banner + renderPace();
  if (ui.route === 'prefs') return banner + renderPrefs();
  if (mode === 'real' && !real.onboarded) return renderWelcome();
  return banner + renderToday();
}

function sampleBanner() {
  return `<div class="banner sample" role="note">
    <p><strong>This is an example day.</strong> Three weeks of made-up history so you can see how Leeway learns. Play with it freely. Nothing here is saved.</p>
    <button class="btn primary" data-act="start-own">Start my own day</button>
  </div>`;
}

// --- Welcome ---------------------------------------------------------------

function renderWelcome() {
  const st = ui.setup;
  const hours = [120, 180, 240, 300, 360, 420];
  return `<section class="welcome" aria-labelledby="welcome-h">
    <h1 id="welcome-h">Plan the day you actually have.</h1>
    <p class="lede">Most of us underestimate how long things take by about half. Leeway learns your real pace from the tasks you finish, then shows what truly fits today.</p>
    <ol class="how">
      <li><div><strong>Jot down today's tasks with a rough guess.</strong> Type something like “Email Sam 10m”.</div></li>
      <li><div><strong>See the line.</strong> Leeway turns your guesses into real time and marks where your day runs out.</div></li>
      <li><div><strong>Do one thing at a time.</strong> Every task you finish teaches Leeway your pace. Whatever is left rolls over without guilt.</div></li>
    </ol>
    <form class="setup" id="setup-form">
      <div class="field">
        <span>On a good day, how much focused work can you do?</span>
        <div class="chips" role="group" aria-label="Focused work on a good day">
          ${hours.map((m) => `<button type="button" class="chip-btn" data-act="setup-hours" data-min="${m}" ${pressed(st.goodDayMin === m)}>${fmtMin(m)}</button>`).join('')}
        </div>
        <p class="hint">Real focus, not hours at a desk. Most people land between 4 and 5.</p>
      </div>
      <div class="field">
        <span>When do you usually stop?</span>
        <div class="row">
          <input class="input" type="time" id="setup-stop" value="${esc(st.stopAt)}" ${st.noStop ? 'disabled' : ''} style="width:auto">
          <label class="check-line"><input type="checkbox" id="setup-nostop" ${st.noStop ? 'checked' : ''}> No fixed stop time</label>
        </div>
      </div>
      <div class="row">
        <button class="btn primary" type="submit">Start planning</button>
        <button class="btn quiet" type="button" data-act="show-sample">See an example day first</button>
      </div>
    </form>
  </section>`;
}

// --- Today -----------------------------------------------------------------

function renderToday() {
  const ctx = dayContext();
  const leftovers = leftoverTasks(ctx.s.tasks, ctx.key);
  return [
    leftovers.length ? leftoverBanner(leftovers) : '',
    dayHeader(ctx),
    gauge(ctx),
    addForm('today'),
    taskList(ctx),
    doneList(ctx),
    dayFooter(ctx),
  ].join('');
}

function leftoverBanner(leftovers) {
  const first = leftovers[0].day;
  const when = relDay(first);
  const from = leftovers.every((t) => t.day === first) ? `from ${when}` : 'from earlier days';
  return `<div class="banner leftover" role="note">
    <p><strong>${plural(leftovers.length, 'task')} ${from} ${leftovers.length === 1 ? 'is' : 'are'} still open.</strong> That is normal. Most days do not go to plan.</p>
    <div class="row">
      <button class="btn primary" data-act="leftovers-today">Bring ${leftovers.length === 1 ? 'it' : 'them'} to today</button>
      <button class="btn" data-act="leftovers-choose">Choose for each</button>
    </div>
  </div>`;
}

function dayHeader({ key, day, capacity }) {
  const energy = day.energy || null;
  const levels = Object.entries(Core.ENERGY);
  return `<section class="dayhead" aria-label="Today">
    <div>
      <h1>${esc(longDay(key))}</h1>
      <p class="sub">${energy ? `Energy: ${Core.ENERGY[energy].label.toLowerCase()}, so about ${fmtMin(capacity)} of focus.` : 'How much do you have in you today?'}</p>
    </div>
    <div class="energy">
      <span class="label" id="energy-label">Energy today</span>
      <div class="seg" role="group" aria-labelledby="energy-label">
        ${levels.map(([id, e]) => `<button data-act="energy" data-val="${id}" ${pressed(energy === id)} title="${esc(cap(e.hint))}">${e.label}</button>`).join('')}
      </div>
      <div class="row" style="gap:2px">
        <button class="btn quiet small" data-act="cap-adjust" data-delta="-15" aria-label="15 minutes less focus today">−15m</button>
        <span class="num hint" aria-live="polite">${fmtMin(capacity)}</span>
        <button class="btn quiet small" data-act="cap-adjust" data-delta="15" aria-label="15 minutes more focus today">+15m</button>
      </div>
    </div>
  </section>`;
}

function gauge({ plan, capacity, used, pace, stopMs, s }) {
  const rows = plan.rows;
  const total = Math.max(plan.available, plan.realTotal, 60);
  const pct = (m) => (m / total) * 100;
  const segs = rows
    .map((r) => {
      const cls = r.task.runStart ? 'running' : r.fits ? '' : 'below';
      const tip = `${r.task.title}`;
      const sub = `${fmtMin(r.remaining)} real time${r.fits ? '' : ', below the line'}`;
      return `<span class="bar-seg ${cls}" data-tip="${esc(tip)}" data-tip-sub="${esc(sub)}" style="left:${pct(r.start)}%;width:calc(${pct(r.remaining)}% - 2px)"></span>`;
    })
    .join('');
  const limitPos = pct(plan.available);
  const edge = limitPos < 18 ? 'at-start' : '';
  const step = total <= 150 ? 30 : total <= 480 ? 60 : 120;
  const ticks = [];
  for (let m = 0; m <= total; m += step) ticks.push(`<span style="left:${pct(m)}%">${m === 0 ? '0' : fmtMin(m)}</span>`);

  const over = plan.overBy > 0;
  const status = !rows.length
    ? `<span class="pill quiet">Nothing planned yet</span>`
    : over
      ? `<span class="pill over">${I.over}${fmtMin(plan.overBy)} more than fits</span>`
      : `<span class="pill ok">${I.ok}Everything fits</span>`;
  const conf = Core.paceConfidence(pace);
  const facts = [];
  if (rows.length) facts.push(`Your guesses add up to <strong>${fmtMin(plan.estTotal)}</strong>. At your pace that is <strong>${fmtMin(plan.realTotal)}</strong>.`);
  if (plan.fitCount && plan.available > 0) facts.push(`${plan.belowCount ? 'Everything above the line' : 'All of it'} should be done by about <strong>${fmtClock(plan.finishMs)}</strong> if you start now.`);
  if (stopMs && plan.byClock === 0) facts.push(`It is past your stop time of ${fmtClock(stopMs)}. Anything left can wait for tomorrow.`);
  else if (plan.limitedBy === 'clock') facts.push(`You stop at <strong>${fmtClock(stopMs)}</strong>, so the clock is the limit today, not your energy.`);
  if (used > 0) facts.push(`You have already put in ${fmtMin(used)} of focus today.`);
  const how = ['', 'still learning', 'getting there', 'calibrated'][conf.level];
  facts.push(pace.n ? `Using your pace: <a href="#pace">${fmtMult(pace.global.mult)}</a>, ${how}.` : `Using the research average, <a href="#pace">${fmtMult(pace.global.mult)}</a>, until Leeway learns your pace.`);

  const label = rows.length
    ? `Planned ${fmtMin(plan.realTotal)} of real time against ${fmtMin(plan.available)} left today. ${plan.fitCount} of ${rows.length} tasks fit.`
    : `${fmtMin(plan.available)} of focus left today, nothing planned.`;
  return `<section class="gauge" aria-label="Today's load">
    <div class="gauge-top">
      <p class="gauge-big">${fmtMin(plan.available)} <small>left today</small></p>
      ${status}
    </div>
    <div class="bar" role="img" aria-label="${esc(label)}">
      <div class="bar-track">${segs}<span class="bar-limit ${edge}" style="left:${limitPos}%"><span>Day ends</span></span></div>
      <div class="bar-axis" aria-hidden="true">${ticks.join('')}</div>
    </div>
    <div class="gauge-facts">${facts.map((f) => `<p>${f}</p>`).join('')}</div>
  </section>`;
}

function addForm(scope) {
  const id = `add-${scope}`;
  const est = ui.chip[scope];
  const placeholder = scope === 'today' ? 'Add a task, like “Email Sam 10m”' : 'Add something for later';
  return `<form class="add" id="${id}-form" data-scope="${scope}" autocomplete="off">
    <label class="sr-only" for="${id}">New task</label>
    <div class="add-row">
      <input class="input" id="${id}" name="title" placeholder="${esc(placeholder)}" value="${esc(ui.drafts[scope])}" maxlength="200" enterkeyhint="done">
      <button class="btn primary" type="submit">Add</button>
    </div>
    <div class="chips" role="group" aria-label="Your time guess">
      <span class="label">Guess</span>
      ${Core.ESTIMATE_CHIPS.map((m) => `<button type="button" class="chip-btn" data-act="chip" data-scope="${scope}" data-min="${m}" ${pressed(est === m)}>${fmtMin(m)}</button>`).join('')}
    </div>
  </form>`;
}

function taskMeta(task, real, spent) {
  const parts = [`guess ${fmtMin(task.est)}`, `<span class="real">really ~${fmtMin(real)}</span>`];
  if (spent >= 1) parts.push(`${fmtMin(spent)} in`);
  if (task.tag) parts.push(`<span class="tag">#${esc(task.tag)}</span>`);
  if (task.steps.length) parts.push(`${task.steps.filter((x) => x.done).length}/${task.steps.length} steps`);
  return parts.map((p) => `<span>${p}</span>`).join('');
}

function taskRow(row) {
  const t = row.task;
  const running = !!t.runStart;
  const go = running
    ? `<button class="btn small primary" data-act="open-focus" data-id="${esc(t.id)}">${I.play}Open</button>`
    : `<button class="btn small" data-act="start" data-id="${esc(t.id)}" aria-label="Start ${esc(t.title)}">${I.play}Start</button>`;
  const later = row.fits ? '' : `<button class="btn small quiet" data-act="to-tomorrow" data-id="${esc(t.id)}">Tomorrow</button>`;
  return `<li class="task ${running ? 'running' : ''}">
    <button class="check" data-act="done" data-id="${esc(t.id)}" aria-label="Mark done: ${esc(t.title)}">${I.check}</button>
    <div class="body">
      <div class="title">${esc(t.title)}</div>
      <div class="meta">${taskMeta(t, row.real, row.spent)}</div>
    </div>
    <div class="actions">${later}${go}<button class="icon-btn" data-act="menu" data-id="${esc(t.id)}" aria-label="More options for ${esc(t.title)}">${I.more}</button></div>
  </li>`;
}

function taskList({ plan }) {
  const rows = plan.rows;
  const head = `<div class="list-head"><h2>Today</h2><span class="muted">${rows.length ? plural(rows.length, 'task') : ''}</span></div>`;
  if (!rows.length) {
    return `<section aria-label="Today's tasks">${head}<ul class="list"><li class="empty"><strong>Your day is open.</strong><span>Add what you want to get done. Leeway shows how much of it really fits.</span></li></ul></section>`;
  }
  const fit = rows.filter((r) => r.fits);
  const below = rows.filter((r) => !r.fits);
  const line = below.length
    ? `<li class="loadline" role="separator" aria-label="Your day ends here"><span>Your day ends here</span></li>`
    : `<li class="loadline" role="separator" aria-label="Your day ends here"><span>Room for ${fmtMin(plan.freeMin)} more</span></li>`;
  const belowBlock = below.length
    ? `<li class="below-zone"><ul>${below.map(taskRow).join('')}</ul>
        <div class="below-note"><span>${below.length === 1 ? 'This one does not fit today.' : `These ${below.length} do not fit today.`} Move ${below.length === 1 ? 'it' : 'them'}, or move something else down.</span>
        <button class="btn small" data-act="below-tomorrow">Move ${below.length === 1 ? 'it' : 'them'} to tomorrow</button></div></li>`
    : '';
  return `<section aria-label="Today's tasks">${head}<ul class="list">${fit.map(taskRow).join('')}${line}${belowBlock}</ul></section>`;
}

function doneList({ done }) {
  if (!done.length) return '';
  const rows = done
    .map(
      (t) => `<li class="task done">
      <button class="check" data-act="reopen" data-id="${esc(t.id)}" aria-label="Not done yet: ${esc(t.title)}">${I.check}</button>
      <div class="body"><div class="title">${esc(t.title)}</div>
        <div class="meta"><span>${t.actual ? `took <span class="real">${fmtMin(t.actual)}</span>` : 'no time logged'}</span><span>guessed ${fmtMin(t.est)}</span>${t.learn ? '' : '<span>not counted</span>'}</div></div>
      <div class="actions"><button class="icon-btn" data-act="fix-time" data-id="${esc(t.id)}" aria-label="Fix the time for ${esc(t.title)}">${I.edit}</button></div>
    </li>`
    )
    .join('');
  return `<section aria-label="Done today"><div class="list-head"><h2>Done today</h2><span class="muted">${done.length}</span></div><ul class="list">${rows}</ul></section>`;
}

function dayFooter({ day, done, open }) {
  if (day.closedAt) {
    return `<div class="closed-note"><p><strong>Day closed at ${fmtClock(day.closedAt)}.</strong> Rest is part of the plan.</p><button class="btn small" data-act="reopen-day">Reopen today</button></div>`;
  }
  if (!done.length && !open.length) return '';
  return `<div class="section-foot"><p class="hint">Wrapping up? See what you did and decide what happens to the rest.</p><button class="btn" data-act="close-day">Close the day</button></div>`;
}

// --- Later -------------------------------------------------------------------

function simpleRow(t, buttons) {
  const pace = paceNow();
  const real = realMinutes(t.est, multiplierFor(pace, t).mult);
  return `<li class="task">
    <span class="check" aria-hidden="true" style="visibility:hidden"></span>
    <div class="body"><div class="title">${esc(t.title)}</div><div class="meta">${taskMeta(t, real, elapsedMs(t, now()) / 60000)}</div></div>
    <div class="actions">${buttons}<button class="icon-btn" data-act="menu" data-id="${esc(t.id)}" aria-label="More options for ${esc(t.title)}">${I.more}</button></div>
  </li>`;
}

function renderLater() {
  const s = S();
  const key = todayKey();
  const scheduled = scheduledTasks(s.tasks, key);
  const later = laterTasks(s.tasks);
  const dropped = droppedTasks(s.tasks);
  const toToday = (t) => `<button class="btn small" data-act="to-today" data-id="${esc(t.id)}">Today</button>`;
  const sched = scheduled.length
    ? `<section aria-label="Planned for later days"><div class="list-head"><h2>Coming up</h2></div><ul class="list">${scheduled
        .map((t) => simpleRow({ ...t, title: t.title }, `<span class="hint">${esc(cap(relDay(t.day)))}</span>${toToday(t)}`))
        .join('')}</ul></section>`
    : '';
  const list = later.length
    ? `<ul class="list">${later.map((t) => simpleRow(t, toToday(t))).join('')}</ul>`
    : `<ul class="list"><li class="empty"><strong>Nothing parked here.</strong><span>Later is for things that matter but not today. They never turn red and never nag.</span></li></ul>`;
  const gone = dropped.length
    ? `<details class="panel"><summary><strong>Let go</strong> <span class="muted">(${dropped.length})</span></summary>
        <p class="hint">Tasks you decided not to do. Letting go is a decision, not a failure.</p>
        <ul class="list">${dropped.map((t) => `<li class="task"><span></span><div class="body"><div class="title">${esc(t.title)}</div><div class="meta"><span>guess ${fmtMin(t.est)}</span></div></div><div class="actions"><button class="btn small" data-act="restore" data-id="${esc(t.id)}">Restore</button><button class="icon-btn" data-act="delete" data-id="${esc(t.id)}" aria-label="Delete ${esc(t.title)} for good">${I.trash}</button></div></li>`).join('')}</ul>
      </details>`
    : '';
  return `<section class="dayhead"><div><h1>Later</h1><p class="sub">Parked, not forgotten. Pull things into today when there is room.</p></div></section>
    ${addForm('later')}
    ${sched}
    <section aria-label="Later"><div class="list-head"><h2>Someday</h2><span class="muted">${later.length || ''}</span></div>${list}</section>
    ${gone}`;
}

// --- Your pace -----------------------------------------------------------------

function paceView() {
  const s = S();
  const pace = paceNow();
  const conf = Core.paceConfidence(pace);
  const table = Core.translationTable(pace);
  const tags = Object.entries(pace.byTag)
    .filter(([, g]) => g.n >= 2)
    .map(([tag, g]) => ({ name: `#${tag}`, mult: g.mult, n: g.n, est: 15 }))
    .sort((a, b) => b.mult - a.mult)
    .slice(0, 8);
  const sizes = Core.SIZES.map((z) => ({ name: z.label, range: z.range, ...(pace.bySize[z.id] || { mult: null, n: 0 }), est: z.id === 'quick' ? 10 : z.id === 'medium' ? 30 : 90 })).filter((z) => z.n >= 2);
  const trend = Core.paceTrend(s.history, { points: 40 });
  const test = Core.backtest(s.history);
  const focusMin = s.history.reduce((sum, h) => sum + h.a, 0);
  const closed = Object.values(s.days).filter((d) => d.closedAt).length;
  return { pace, conf, table, tags, sizes, trend, test, focusMin, closed };
}

// "56% longer than", "16% less time than", or null when within 5%.
function overrun(mult) {
  const pct = Math.round((mult - 1) * 100);
  if (Math.abs(pct) < 6) return null;
  return pct > 0 ? `${pct}% longer than` : `${-pct}% less time than`;
}

function claimFor(mult) {
  const o = overrun(mult);
  return o ? `On average, things take you <strong>${o}</strong> you guess.` : 'On average, your guesses are close to spot on.';
}

function renderPace() {
  const v = paceView();
  const m = v.pace.global.mult;
  const hero = `<section class="pace-hero" aria-labelledby="pace-h">
    <p class="eyebrow" id="pace-h">${v.pace.n ? 'Your reality multiplier' : 'Starting point'}</p>
    <p class="hero-num">${fmtMult(m)}</p>
    <p class="claim">${claimFor(m)} A “30 minute” task is closer to <strong>${fmtMin(realMinutes(30, m))}</strong>.</p>
    <p class="hint">${esc(v.conf.label)}. ${esc(v.conf.detail)}</p>
  </section>`;

  const table = `<section class="panel" aria-labelledby="tr-h">
    <h2 id="tr-h">What your guesses really mean</h2>
    <p class="hint">Adjusted for task size, because small tasks run over the most. Leeway does this every time you plan.</p>
    <table class="translate"><thead><tr><th scope="col">You say</th><th aria-hidden="true"></th><th scope="col">It takes you</th></tr></thead>
      <tbody>${v.table.map((r) => `<tr><td>${fmtMin(r.est)}</td><td class="arrow" aria-hidden="true">→</td><td>${fmtMin(r.real)}</td></tr>`).join('')}</tbody></table>
  </section>`;

  const accuracy = v.test
    ? `<section class="panel" aria-labelledby="acc-h"><h2 id="acc-h">Is it working?</h2>
        <p class="claim" style="font-size:var(--fs-lg)">On your last ${v.test.n} tasks, Leeway's times were <strong>${Math.max(0, Math.round(v.test.improvement * 100))}% closer to reality</strong> than your raw guesses.</p>
        <p class="hint">Average miss: ${fmtMin(v.test.rawErr)} with your guess, ${fmtMin(v.test.fixErr)} with Leeway's correction. Each task was predicted using only the tasks you finished before it.</p></section>`
    : '';

  const trend = v.trend.length >= 3 ? `<section class="panel" aria-labelledby="trend-h"><h2 id="trend-h">How your multiplier moved</h2>
      <p class="hint">One point per finished task. The line at ×1.0 is where guess and reality match.</p>
      <div class="spark-wrap" id="spark">${sparkline(v.trend)}</div></section>` : '';

  const bars = (items, title, id, note) =>
    items.length
      ? `<section class="panel" aria-labelledby="${id}"><h2 id="${id}">${title}</h2><p class="hint">${note}</p>${barList(items)}
          <p class="bars-legend"><i></i>marks ×1.0, where your guess would be exactly right</p></section>`
      : '';

  const stats = `<section class="panel" aria-label="Totals"><div class="stats">
      <div><b class="num">${v.pace.n}</b><span>tasks learned from</span></div>
      <div><b class="num">${fmtMin(v.focusMin)}</b><span>focus logged</span></div>
      <div><b class="num">${v.closed}</b><span>days closed</span></div></div></section>`;

  const share = v.pace.n >= 3
    ? `<section class="panel" aria-labelledby="share-h"><h2 id="share-h">Share your multiplier</h2>
        <p class="hint">Everyone underestimates. Saying your number out loud makes it easier for the people around you too.</p>
        <div class="row"><button class="btn" data-act="share">${I.image}Make a card</button><button class="btn quiet" data-act="share-copy">${I.copy}Copy as text</button></div></section>`
    : `<section class="panel"><h2>Nothing to learn from yet</h2><p class="hint">Finish a few tasks, with the timer or a quick “it took 20 minutes”, and this page fills in with your own numbers.</p></section>`;

  return hero + table + accuracy + trend + bars(v.tags, 'By kind of task', 'tags-h', 'From the #tags you add. The longer the bar, the more that kind of task runs over.') +
    bars(v.sizes, 'By size', 'size-h', 'Small tasks usually run over the most. Five minutes is rarely five minutes.') + stats + share;
}

function barList(items) {
  const max = Math.max(2, ...items.map((i) => i.mult)) * 1.05;
  const ref = (1 / max) * 100;
  return `<ul class="bars">${items
    .map((i) => {
      const real = realMinutes(i.est, i.mult);
      const sub = `${plural(i.n, 'task')}. Your ${fmtMin(i.est)} is really about ${fmtMin(real)}.`;
      return `<li tabindex="0" data-tip="${esc(`${fmtMult(i.mult)} ${i.name}`)}" data-tip-sub="${esc(sub)}" aria-label="${esc(`${i.name}: ${fmtMult(i.mult)}, ${sub}`)}">
        <span class="name">${esc(i.name)}</span>
        <span class="btrack" aria-hidden="true"><span class="bfill" style="width:${(i.mult / max) * 100}%"></span><span class="bref" style="left:${ref}%"></span></span>
        <span class="val">${fmtMult(i.mult)} <small>${i.n}</small></span>
      </li>`;
    })
    .join('')}</ul>`;
}

function sparkline(points) {
  const W = 640;
  const H = 180;
  const pad = { l: 34, r: 56, t: 14, b: 22 };
  const vals = points.map((p) => p.mult);
  const lo = Math.min(1, ...vals);
  const hi = Math.max(1.6, ...vals);
  const yMin = Math.floor(lo * 4) / 4;
  const yMax = Math.ceil(hi * 4) / 4;
  const x = (i) => pad.l + (points.length === 1 ? 0 : (i / (points.length - 1)) * (W - pad.l - pad.r));
  const y = (v) => pad.t + (1 - (v - yMin) / (yMax - yMin || 1)) * (H - pad.t - pad.b);
  const ticks = [];
  const stepV = yMax - yMin > 1.5 ? 0.5 : 0.25;
  for (let v = yMin; v <= yMax + 1e-9; v += stepV) ticks.push(Math.round(v * 100) / 100);
  const d = points.map((p, i) => `${i ? 'L' : 'M'}${x(i).toFixed(1)},${y(p.mult).toFixed(1)}`).join('');
  const area = `${d}L${x(points.length - 1).toFixed(1)},${(H - pad.b).toFixed(1)}L${x(0).toFixed(1)},${(H - pad.b).toFixed(1)}Z`;
  const last = points[points.length - 1];
  ui.trend = points.map((p, i) => ({ ...p, x: x(i), y: y(p.mult), i }));
  const first = new Date(points[0].t).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
  const end = new Date(last.t).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
  return `<svg class="spark" viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(`Multiplier over your last ${points.length} tasks, from ${fmtMult(points[0].mult)} to ${fmtMult(last.mult)}`)}">
    ${ticks.map((v) => `<line class="${Math.abs(v - 1) < 1e-9 ? 'base' : 'grid'}" x1="${pad.l}" x2="${W - pad.r}" y1="${y(v)}" y2="${y(v)}"/><text x="${pad.l - 6}" y="${y(v) + 4}" text-anchor="end">×${v.toFixed(v % 0.5 ? 2 : 1)}</text>`).join('')}
    <path class="area" d="${area}"/>
    <path class="line" d="${d}"/>
    <circle class="dot" cx="${x(points.length - 1)}" cy="${y(last.mult)}" r="5"/>
    <text class="end-label" x="${x(points.length - 1) + 10}" y="${y(last.mult) + 4}">${fmtMult(last.mult)}</text>
    <text x="${pad.l}" y="${H - 4}">${esc(first)}</text>
    <text x="${W - pad.r}" y="${H - 4}" text-anchor="end">${esc(end)}</text>
    <line class="cross" id="spark-cross" x1="0" x2="0" y1="${pad.t}" y2="${H - pad.b}" visibility="hidden"/>
    <circle class="dot" id="spark-dot" r="5" cx="0" cy="0" visibility="hidden"/>
    <rect id="spark-hit" x="${pad.l}" y="0" width="${W - pad.l - pad.r}" height="${H}" fill="transparent"/>
  </svg>`;
}

// --- Preferences -----------------------------------------------------------------

function renderPrefs() {
  const p = P();
  const opts = [];
  for (let m = 60; m <= 600; m += 30) opts.push(`<option value="${m}" ${p.goodDayMin === m ? 'selected' : ''}>${fmtMin(m)}</option>`);
  const starts = [0, 2, 3, 4, 5, 6].map((h) => `<option value="${h}" ${p.dayStartHour === h ? 'selected' : ''}>${h === 0 ? 'Midnight' : `${h}:00 am`}</option>`).join('');
  const every = [10, 15, 20, 30].map((m) => `<option value="${m}" ${p.checkinEvery === m ? 'selected' : ''}>Every ${m} min</option>`).join('');
  const store = mode === 'sample'
    ? 'You are looking at the example day. Nothing is saved until you start your own.'
    : cloud.status === 'on'
      ? 'Saved privately to your Claude account, and in this browser. Only you can see it.'
      : cloud.status === 'connecting'
        ? 'Saved in this browser. Connecting to your Claude account…'
        : 'Saved in this browser only. Use Export to keep a copy.';
  const row = (t, d, control) => `<div class="pref-row"><div><div class="t">${t}</div><div class="d">${d}</div></div>${control}</div>`;
  return `<section class="dayhead"><div><h1>Preferences</h1><p class="sub">Small settings. Leeway works fine with the defaults.</p></div></section>
  <div class="prefs">
    <section class="panel" aria-labelledby="pref-day"><h2 id="pref-day">Your day</h2>
      ${row('Focus on a good day', 'Low and Okay energy days scale down from this.', `<select class="input" id="pref-good" data-pref="goodDayMin">${opts.join('')}</select>`)}
      ${row('Usual stop time', 'After this, Leeway stops counting time as available.', `<div class="row"><input class="input" type="time" id="pref-stop" data-pref="stopAt" value="${esc(p.stopAt || '18:00')}" ${p.stopAt ? '' : 'disabled'}><label class="check-line"><input type="checkbox" id="pref-nostop" ${p.stopAt ? '' : 'checked'}> None</label></div>`)}
      ${row('A new day starts at', 'Late nights count toward the previous day until then.', `<select class="input" id="pref-start" data-pref="dayStartHour">${starts}</select>`)}
    </section>
    <section class="panel" aria-labelledby="pref-focus"><h2 id="pref-focus">Focus mode</h2>
      ${row('Gentle check-ins', 'A quiet line of company while the timer runs.', `<div class="row"><label class="check-line"><input type="checkbox" id="pref-checkins" ${p.checkins ? 'checked' : ''}> On</label><select class="input" id="pref-every" data-pref="checkinEvery" ${p.checkins ? '' : 'disabled'}>${every}</select></div>`)}
      ${row('Soft chime', 'Plays at check-ins and when you reach your guess.', `<label class="check-line"><input type="checkbox" id="pref-chime" ${p.chime ? 'checked' : ''}> On</label>`)}
      ${hasClaude ? row('Make it smaller with Claude', 'Breaks a stuck task into tiny steps. Uses your Claude account, and asks first.', `<label class="check-line"><input type="checkbox" id="pref-ai" ${p.ai ? 'checked' : ''}> On</label>`) : ''}
    </section>
    <section class="panel" aria-labelledby="pref-data"><h2 id="pref-data">Your data</h2>
      <p class="store-line">${I.lock}<span>${store}</span></p>
      <div class="row">
        <button class="btn" data-act="export" ${mode === 'sample' ? 'disabled' : ''}>${I.save}Export</button>
        <button class="btn" data-act="import-open" ${mode === 'sample' ? 'disabled' : ''}>Import</button>
        ${mode === 'sample' ? '<button class="btn primary" data-act="start-own">Start my own day</button>' : '<button class="btn" data-act="show-sample">Try the example day</button>'}
        <button class="btn danger" data-act="erase-open" ${mode === 'sample' || !hasData(real) ? 'disabled' : ''}>Erase everything</button>
      </div>
    </section>
    <div class="foot">
      <p>Leeway ${VERSION}. Built on the planning fallacy research of Kahneman, Tversky and Buehler: your past is the best forecast of your future.</p>
      <p>No account, no tracking, no ads. Made by Bablo.</p>
    </div>
  </div>`;
}

// --- Focus mode ----------------------------------------------------------------------

function companionLine(task, ms, real) {
  const p = P();
  const m = Math.floor(ms / 60000);
  if (!task.runStart) return ms > 0 ? 'Paused. Pick it back up when you are ready, or put it down for now. Both are fine.' : 'Only commit to 5 minutes. You can stop after that and it still counts.';
  if (m < 5) return 'Only commit to 5 minutes. You can stop after that and it still counts.';
  if (!p.checkins) return 'Keep going. One thing at a time.';
  if (m >= real) return 'You are past your usual time for this. Wrap it up, or make the rest smaller and save it for later.';
  if (m >= task.est) return `That was your guess. Your real time for this is usually ${fmtMin(real)}, so you are right on track.`;
  if (m < 8) return 'Five minutes in. Starting was the hard part.';
  const lines = ['Still here with you.', 'Nice and steady.', 'If you drifted, no problem. Just come back to this one thing.', 'You are doing it.'];
  return `${lines[Math.floor(m / p.checkinEvery) % lines.length]} ${m} minutes in.`;
}

function renderFocus() {
  const task = ui.focusId ? findTask(ui.focusId) : null;
  if (!task || task.list !== 'today') return '';
  const pace = paceNow();
  const { mult } = multiplierFor(pace, task);
  const real = realMinutes(task.est, mult);
  const ms = elapsedMs(task, now());
  const scale = Math.max(real, ms / 60000) * 1.08;
  const fill = Math.min(100, (ms / 60000 / scale) * 100);
  const nextStep = task.steps.findIndex((x) => !x.done);
  const steps = task.steps.length
    ? `<section aria-labelledby="steps-h"><h3 class="label" id="steps-h">Tiny steps</h3><ul class="steps">${task.steps
        .map((st, i) => `<li class="${st.done ? 'done' : i === nextStep ? 'next' : ''}"><input type="checkbox" id="step-${esc(st.id)}" data-step="${esc(st.id)}" data-id="${esc(task.id)}" ${st.done ? 'checked' : ''}><label for="step-${esc(st.id)}"><span>${esc(st.text)}</span></label></li>`)
        .join('')}</ul></section>`
    : '';
  const running = !!task.runStart;
  return `<div class="focus" role="dialog" aria-modal="true" aria-labelledby="focus-title">
    <div class="focus-in">
      <div class="focus-top">
        <button class="btn quiet" data-act="close-focus">${I.down}Back to the list</button>
        <span class="pill quiet">${running ? 'Focusing' : ms > 0 ? 'Paused' : 'Ready'}</span>
      </div>
      <div class="stack">
        <h2 id="focus-title">${esc(task.title)}</h2>
        <p class="meta"><span>Your guess: ${fmtMin(task.est)}</span><span>Usually takes you: <strong>${fmtMin(real)}</strong></span>${task.tag ? `<span>#${esc(task.tag)}</span>` : ''}</p>
      </div>
      <div>
        <p class="clock ${running ? '' : 'paused'}" data-elapsed aria-live="off">${fmtTimer(ms)}</p>
        <div class="fbar" aria-hidden="true">
          <div class="fbar-fill ${ms / 60000 > real ? 'over' : ''}" data-fill style="width:${fill}%"></div>
          ${marks(task.est / scale, real / scale)}
        </div>
        <div class="fbar-legend" aria-hidden="true"><span>0</span><span>${fmtMin(scale)}</span></div>
      </div>
      <p class="companion" data-companion aria-live="polite">${I.heart}<span>${esc(companionLine(task, ms, real))}</span></p>
      <div class="focus-actions">
        ${running ? `<button class="btn" data-act="pause" data-id="${esc(task.id)}">${I.pause}Pause</button>` : `<button class="btn" data-act="resume" data-id="${esc(task.id)}">${I.play}${ms > 0 ? 'Resume' : 'Start'}</button>`}
        <button class="btn primary" data-act="done" data-id="${esc(task.id)}">${I.check}Done</button>
      </div>
      ${steps}
      <div class="row">
        <button class="btn quiet" data-act="smaller" data-id="${esc(task.id)}">${I.sparkle}${task.steps.length ? 'New tiny steps' : 'Make it smaller'}</button>
        <button class="btn quiet" data-act="stop-for-now" data-id="${esc(task.id)}">Stop for now</button>
      </div>
    </div>
  </div>`;
}

function marks(guessAt, usualAt) {
  const mark = (at, label) => `<span class="fbar-mark ${at > 0.7 ? 'flip' : ''}" style="left:${at * 100}%"><span>${label}</span></span>`;
  if (Math.abs(usualAt - guessAt) < 0.12) return mark(usualAt, guessAt === usualAt ? 'guess' : 'guess ≈ usual');
  return mark(guessAt, 'guess') + mark(usualAt, 'usual');
}

function renderRunbar() {
  const r = runningTask(S());
  if (!r || ui.focusId) return '';
  return `<div class="runbar" role="region" aria-label="Running task"><div class="runbar-in">
    <span class="num" data-elapsed>${fmtTimer(elapsedMs(r, now()))}</span>
    <span class="t">${esc(r.title)}</span>
    <button class="btn small" data-act="open-focus" data-id="${esc(r.id)}">Open</button>
    <button class="btn small primary" data-act="done" data-id="${esc(r.id)}">Done</button>
  </div></div>`;
}

// --- Sheets ------------------------------------------------------------------------

function sheetFrame(title, body, { labelId = 'sheet-title' } = {}) {
  return `<div class="scrim" data-act="sheet-scrim"><div class="sheet" role="dialog" aria-modal="true" aria-labelledby="${labelId}">
    <div class="sheet-head"><h2 id="${labelId}">${title}</h2><button class="icon-btn" data-act="sheet-close" aria-label="Close">${I.close}</button></div>
    ${body}
  </div></div>`;
}

function renderSheet() {
  const sh = ui.sheet;
  if (!sh) return '';
  const task = sh.id ? findTask(sh.id) : null;
  switch (sh.type) {
    case 'menu': {
      if (!task) return '';
      const inToday = task.list === 'today' && task.day === todayKey();
      const items = [
        ['edit', I.edit, 'Edit'],
        ['smaller', I.sparkle, 'Make it smaller'],
        ...(inToday ? [['move-top', I.top, 'Move to the top'], ['move-up', I.up, 'Move up'], ['move-down', I.down, 'Move down'], ['to-tomorrow', I.sun, 'Do it tomorrow']] : [['to-today', I.sun, 'Do it today']]),
        ...(task.list !== 'later' ? [['to-later', I.tray, 'Move to Later']] : []),
        ['drop', I.wave, 'Let it go'],
        ['delete', I.trash, 'Delete'],
      ];
      return sheetFrame(esc(task.title), `<div class="menu-list">${items.map(([act, icon, label]) => `<button data-act="${act}" data-id="${esc(task.id)}" class="${act === 'delete' ? 'danger' : ''}">${icon}${label}</button>`).join('')}</div>`);
    }
    case 'edit': {
      if (!task) return '';
      return sheetFrame('Edit task', `<form id="edit-form" class="stack" data-id="${esc(task.id)}">
        <label class="field"><span>Task</span><input class="input" id="edit-title" value="${esc(sh.title)}" maxlength="200" required></label>
        <div class="field"><span>Your guess</span>
          <div class="chips">${Core.ESTIMATE_CHIPS.map((m) => `<button type="button" class="chip-btn" data-act="edit-est" data-min="${m}" ${pressed(sh.est === m)}>${fmtMin(m)}</button>`).join('')}</div>
          <label class="row"><input class="input" type="number" id="edit-est" min="1" max="720" value="${sh.est}" style="width:7rem"> <span class="hint">minutes</span></label>
        </div>
        <label class="field"><span>Tag</span><input class="input" id="edit-tag" value="${esc(sh.tag)}" placeholder="email, writing, errands" maxlength="24"></label>
        <div class="row end"><button type="button" class="btn quiet" data-act="sheet-close">Cancel</button><button class="btn primary" type="submit">Save</button></div>
      </form>`);
    }
    case 'quicklog': {
      if (!task) return '';
      const opts = Core.quickLogOptions(task.est);
      return sheetFrame('How long did it take?', `<p class="hint">You guessed ${fmtMin(task.est)}. A rough answer is perfect. This is how Leeway learns your pace.</p>
        <div class="chips">${opts.map((m) => `<button class="chip-btn" data-act="quicklog" data-id="${esc(task.id)}" data-min="${m}">${fmtMin(m)}</button>`).join('')}</div>
        <form id="quicklog-form" class="row" data-id="${esc(task.id)}"><label class="sr-only" for="quicklog-min">Minutes</label><input class="input" type="number" id="quicklog-min" min="1" max="1440" placeholder="Minutes" style="width:8rem"><button class="btn" type="submit">Save</button></form>
        <div class="row between"><button class="btn quiet" data-act="quicklog-skip" data-id="${esc(task.id)}">Skip, do not count this one</button></div>`);
    }
    case 'fixtime': {
      if (!task) return '';
      return sheetFrame('Fix the time', `<form id="fix-form" class="stack" data-id="${esc(task.id)}">
        <p class="hint">Forgot to pause the timer? Put in roughly how long it really took.</p>
        <label class="row"><input class="input" type="number" id="fix-min" min="1" max="1440" value="${task.actual || task.est}" style="width:8rem"><span class="hint">minutes, you guessed ${fmtMin(task.est)}</span></label>
        <label class="check-line"><input type="checkbox" id="fix-learn" ${task.learn !== false ? 'checked' : ''}> Count this task toward my pace</label>
        <div class="row end"><button type="button" class="btn quiet" data-act="sheet-close">Cancel</button><button class="btn primary" type="submit">Save</button></div>
      </form>`);
    }
    case 'smaller': {
      if (!task) return '';
      const body =
        sh.status === 'loading'
          ? `<p class="companion">${I.sparkle}<span>Thinking of tiny first steps…</span></p><div class="row end"><button class="btn quiet" data-act="sheet-close">Cancel</button></div>`
          : `${sh.note ? `<p class="hint">${esc(sh.note)}</p>` : ''}
            <ol class="steps">${sh.steps.map((st, i) => `<li><span class="num muted">${i + 1}</span><span>${esc(st)}</span></li>`).join('')}</ol>
            <p class="hint">${sh.source === 'claude' ? 'Suggested by Claude. ' : ''}The first step should feel almost too easy. That is the point.</p>
            <div class="row end">
              ${sh.source === 'claude' ? `<button class="btn quiet" data-act="smaller-again" data-id="${esc(task.id)}">Try again</button>` : ''}
              <button class="btn" data-act="smaller-use" data-id="${esc(task.id)}">Use these steps</button>
              <button class="btn primary" data-act="smaller-start" data-id="${esc(task.id)}">${I.play}Start step 1</button>
            </div>`;
      return sheetFrame(`Make it smaller`, `<p><strong>${esc(task.title)}</strong></p>${body}`);
    }
    case 'close':
    case 'triage': {
      const closing = sh.type === 'close';
      const ctx = dayContext();
      const tasks = Object.keys(sh.decisions).map(findTask).filter(Boolean);
      const choices = closing
        ? [['tomorrow', 'Tomorrow'], ['later', 'Later'], ['drop', 'Let go']]
        : [['today', 'Today'], ['tomorrow', 'Tomorrow'], ['later', 'Later'], ['drop', 'Let go']];
      const triage = tasks.length
        ? `<div><p class="label">${closing ? 'What happens to the rest?' : 'Where should each one go?'}</p>
            <ul class="triage">${tasks
              .map((t) => `<li><span>${esc(t.title)} <span class="muted num">${fmtMin(t.est)}</span></span>
                <div class="seg" role="group" aria-label="${esc(`Where ${t.title} goes`)}">${choices.map(([val, label]) => `<button data-act="triage-pick" data-id="${esc(t.id)}" data-val="${val}" ${pressed(sh.decisions[t.id] === val)}>${label}</button>`).join('')}</div></li>`)
              .join('')}</ul></div>`
        : '';
      if (!closing) {
        return sheetFrame('Open tasks from before', `${triage}<div class="row end"><button class="btn quiet" data-act="sheet-close">Cancel</button><button class="btn primary" data-act="triage-confirm">Done</button></div>`);
      }
      const sum = Core.summarizeDay(ctx.done);
      const pace = ctx.pace;
      const today = sum.ratio ? overrun(sum.ratio) : null;
      const usual = pace.n ? overrun(pace.global.mult) : null;
      const ratioLine = sum.ratio
        ? `${today ? `Today things took <strong>${today}</strong> you guessed.` : 'Today your guesses were <strong>spot on</strong>.'}${pace.n ? ` Usually it is ${usual || 'about what you guess'}.`.replace(' than.', ' than you guess.') : ''}`
        : 'No timed tasks today, so nothing new to learn. That is fine.';
      return sheetFrame('Close the day', `<div class="stack">
          <p class="summary-big">${sum.count ? `You finished ${plural(sum.count, 'task')}.` : 'Some days are like this.'}</p>
          <p>${sum.focusMin ? `${fmtMin(sum.focusMin)} of focus. ` : ''}${ratioLine}</p>
        </div>
        ${triage}
        <label class="field"><span>One line about today (optional)</span><textarea class="input" id="close-note" maxlength="280" placeholder="What helped, what got in the way">${esc(sh.note || '')}</textarea></label>
        <div class="row end"><button class="btn quiet" data-act="sheet-close">Not yet</button><button class="btn primary" data-act="close-confirm">Close the day</button></div>`);
    }
    case 'share': {
      return sheetFrame('Your multiplier card', `${sh.url ? `<img class="share-img" src="${sh.url}" alt="${esc(sh.alt || 'Your Leeway multiplier card')}">` : '<p class="hint">Drawing your card…</p>'}
        <div class="row end">
          <button class="btn" data-act="share-copy">${I.copy}Copy text</button>
          ${sh.canSave ? `<button class="btn primary" data-act="share-save">${I.save}Save image</button>` : ''}
        </div>
        ${sh.fallback ? `<label class="field"><span>Copy this</span><textarea class="input copy-area" id="share-text" readonly>${esc(sh.fallback)}</textarea></label>` : ''}`);
    }
    case 'export': {
      return sheetFrame('Export your data', `<p class="hint">A JSON file with your tasks and your learned pace. Keep it as a backup, or import it on another device.</p>
        <div class="row">${sh.canSave ? `<button class="btn primary" data-act="export-save">${I.save}Save file</button>` : ''}<button class="btn" data-act="export-copy">${I.copy}Copy</button></div>
        ${sh.fallback ? `<label class="field"><span>Your data</span><textarea class="input copy-area" id="export-text" readonly>${esc(sh.fallback)}</textarea></label>` : ''}`);
    }
    case 'import': {
      return sheetFrame('Import data', `<p class="hint">Choose a Leeway export, or paste its contents. This replaces what is here now.</p>
        <input class="input" type="file" id="import-file" accept="application/json,.json">
        <label class="field"><span>Or paste it</span><textarea class="input copy-area" id="import-text" placeholder='{"v":1, ...}'>${esc(sh.text || '')}</textarea></label>
        ${sh.error ? `<p class="hint" role="alert" style="color:var(--limit-text)">${esc(sh.error)}</p>` : ''}
        <div class="row end"><button class="btn quiet" data-act="sheet-close">Cancel</button><button class="btn primary" data-act="import-confirm">Replace my data</button></div>`);
    }
    case 'erase': {
      return sheetFrame('Erase everything?', `<p>This deletes your tasks and your learned pace${cloud.status === 'on' ? ' in this browser and in your Claude account' : ' in this browser'}. It cannot be undone.</p>
        <div class="row end"><button class="btn quiet" data-act="sheet-close">Keep my data</button><button class="btn primary" data-act="erase-confirm">Erase everything</button></div>`);
    }
    default:
      return '';
  }
}

function renderToast() {
  if (!ui.toast) return '';
  return `<div class="toast" role="status"><span>${esc(ui.toast.msg)}</span>${ui.toast.undo ? '<button class="btn small" data-act="undo">Undo</button>' : ''}<button class="icon-btn" data-act="toast-close" aria-label="Dismiss" style="color:inherit;width:30px;height:30px">${I.close}</button></div>`;
}

let toastTimer = null;
function showToast(msg, withUndo = false) {
  ui.toast = { msg, undo: withUndo };
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    ui.toast = null;
    undo = null;
    const root = $('#toast-root');
    if (root) root.innerHTML = '';
  }, withUndo ? 7000 : 4000);
}

function updateTitle() {
  const r = S() && runningTask(S());
  document.title = r ? `${fmtTimer(elapsedMs(r, now()))} · ${r.title} · Leeway` : 'Leeway';
}

// ---------------------------------------------------------------------------
// Ticking, check-ins, chime, wake lock
// ---------------------------------------------------------------------------

let tickTimer = null;
let lastMinute = -1;
let chimedAt = new Set();

function ensureTicking() {
  const r = S() && runningTask(S());
  if (r && !tickTimer) tickTimer = setInterval(tick, 1000);
  if (!r && tickTimer) {
    clearInterval(tickTimer);
    tickTimer = null;
  }
  holdWake(!!(r && ui.focusId === r.id));
}

function tick() {
  const r = runningTask(S());
  if (!r) return ensureTicking();
  const ms = elapsedMs(r, now());
  for (const el of document.querySelectorAll('[data-elapsed]')) el.textContent = fmtTimer(ms);
  const minute = Math.floor(ms / 60000);
  if (minute !== lastMinute) {
    const first = lastMinute === -1;
    lastMinute = minute;
    if (!first) {
      maybeChime(r, minute);
      const active = document.activeElement;
      const typing = active && /^(INPUT|TEXTAREA|SELECT)$/.test(active.tagName);
      if (!typing) render();
    }
  }
  updateTitle();
}

function maybeChime(task, minute) {
  const p = P();
  if (!p.chime || !p.checkins) return;
  const real = realMinutes(task.est, multiplierFor(paceNow(), task).mult);
  const key = `${task.id}:${minute}`;
  if (chimedAt.has(key)) return;
  if (minute === 5 || minute === task.est || minute === real || (minute > 0 && minute % p.checkinEvery === 0)) {
    chimedAt.add(key);
    chime();
  }
}

let audio = null;
function wakeAudio() {
  try {
    const Ctx = window.AudioContext || window.webkitAudioContext;
    if (!Ctx) return;
    audio = audio || new Ctx();
    if (audio.state === 'suspended') audio.resume();
  } catch {
    audio = null;
  }
}

function chime() {
  if (!audio) return;
  try {
    const t = audio.currentTime;
    [659.25, 987.77].forEach((f, i) => {
      const o = audio.createOscillator();
      const g = audio.createGain();
      o.type = 'sine';
      o.frequency.value = f;
      const at = t + i * 0.2;
      g.gain.setValueAtTime(0.0001, at);
      g.gain.exponentialRampToValueAtTime(0.1, at + 0.03);
      g.gain.exponentialRampToValueAtTime(0.0001, at + 1.1);
      o.connect(g).connect(audio.destination);
      o.start(at);
      o.stop(at + 1.2);
    });
  } catch {
    /* sound is optional */
  }
}

let wakeLock = null;
async function holdWake(on) {
  try {
    if (on && !wakeLock && navigator.wakeLock && document.visibilityState === 'visible') {
      wakeLock = await navigator.wakeLock.request('screen');
      wakeLock.addEventListener('release', () => {
        wakeLock = null;
      });
    } else if (!on && wakeLock) {
      const lock = wakeLock;
      wakeLock = null;
      await lock.release();
    }
  } catch {
    wakeLock = null;
  }
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

function addFromForm(scope) {
  const input = $(`#add-${scope}`);
  const raw = input ? input.value : '';
  const lines = raw.includes('\n') ? Core.parseBrainDump(raw, ui.chip[scope]) : [Core.parseQuickAdd(raw, ui.chip[scope])].filter((p) => p.title);
  if (!lines.length) {
    if (input) input.focus();
    return;
  }
  let s = S();
  const key = todayKey();
  for (const p of lines) s = Core.addTask(s, p, { list: scope === 'today' ? 'today' : 'later', day: scope === 'today' ? key : null, now: now() });
  ui.drafts[scope] = '';
  commit(s, { toast: lines.length > 1 ? `Added ${lines.length} tasks.` : null });
  const again = $(`#add-${scope}`);
  if (again) again.focus();
}

function startFocus(id) {
  wakeAudio();
  ui.focusId = id;
  lastMinute = -1;
  commit(Core.startTask(S(), id, now()));
}

function finish(id, { actualMin = null, learn = true } = {}) {
  const task = findTask(id);
  if (!task) return;
  const measured = elapsedMs(task, now());
  if (actualMin == null && learn && measured < 60000) {
    if (ui.focusId === id) commit(Core.pauseTask(S(), id, now()), { quiet: true });
    ui.focusId = null;
    ui.sheet = { type: 'quicklog', id };
    render();
    return;
  }
  const next = Core.completeTask(S(), id, { actualMin, learn, now: now() });
  const done = next.tasks.find((t) => t.id === id);
  if (ui.focusId === id) ui.focusId = null;
  ui.sheet = null;
  const msg = done.actual
    ? `Done in ${fmtMin(done.actual)}. You guessed ${fmtMin(task.est)}.${done.learn ? ' Leeway learned from it.' : ''}`
    : 'Done.';
  commit(next, { toast: msg, withUndo: true });
}

function move(id, where) {
  const key = todayKey();
  const task = findTask(id);
  if (!task) return;
  if (ui.focusId === id) ui.focusId = null;
  const target = {
    today: { list: 'today', day: key },
    tomorrow: { list: 'today', day: addDays(key, 1) },
    later: { list: 'later' },
    drop: { list: 'dropped' },
  }[where];
  const msg = { today: 'Moved to today.', tomorrow: 'Moved to tomorrow.', later: 'Moved to Later.', drop: 'Let go. You can restore it from Later.' }[where];
  ui.sheet = null;
  commit(Core.moveTask(S(), id, { ...target, now: now() }), { toast: msg, withUndo: true });
}

async function makeSmaller(id, { fresh = false } = {}) {
  const task = findTask(id);
  if (!task) return;
  ui.sheet = { type: 'smaller', id, status: 'loading', steps: [], source: null, note: '' };
  render();
  let steps = null;
  let source = 'local';
  let note = '';
  const sample = P().ai && !aiBlocked ? await use('sample') : null;
  if (sample) {
    try {
      const prompt = Core.stepsPrompt(task);
      const opts = { modelTier: 'quick', ...(fresh ? { cache: false } : {}) };
      const value = typeof sample.json === 'function' ? await sample.json(prompt, opts) : JSON.parse((await sample(prompt, opts)).text);
      steps = Core.parseStepsReply(value);
      if (steps) source = 'claude';
      else note = 'Claude’s answer was not usable, so here are quick steps instead.';
    } catch (e) {
      const code = e && e.code;
      if (['not_granted', 'sampling_disabled', 'not_declared', 'capability_disabled', 'capability_removed'].includes(code)) aiBlocked = true;
      else if (code === 'rate_limited') note = 'Claude is busy right now, so here are quick steps instead.';
      else if (code !== 'cancelled') note = 'Could not reach Claude, so here are quick steps instead.';
    }
  }
  if (!steps) steps = Core.localSteps(task.title);
  if (!ui.sheet || ui.sheet.type !== 'smaller' || ui.sheet.id !== id) return;
  ui.sheet = { type: 'smaller', id, status: 'ready', steps, source, note };
  render();
}

function useSteps(id, start) {
  const sh = ui.sheet;
  if (!sh || sh.type !== 'smaller') return;
  const steps = sh.steps.map((text) => ({ id: Core.uid(), text, done: false }));
  ui.sheet = null;
  let s = Core.updateTask(S(), id, { steps });
  const task = s.tasks.find((t) => t.id === id);
  if (start && task && task.list !== 'today') s = Core.moveTask(s, id, { list: 'today', day: todayKey(), now: now() });
  if (start) {
    wakeAudio();
    ui.focusId = id;
    s = Core.startTask(s, id, now());
  }
  commit(s, { toast: start ? null : 'Steps added.' });
}

function shareText() {
  const pace = paceNow();
  const m = pace.global.mult;
  const thirty = realMinutes(30, m);
  const o = overrun(m);
  const claim = o ? `things take me ${o} I guess` : 'my time guesses are close to spot on';
  const link = hasClaude ? '' : ` ${location.origin}${location.pathname}`;
  return `My Leeway reality multiplier is ${fmtMult(m)}: ${claim}. My “30 minutes” is really ${thirty}. What is yours?${link}`;
}

async function copyText(text, fallbackSheetPatch) {
  try {
    await navigator.clipboard.writeText(text);
    showToast('Copied.');
    render();
  } catch {
    ui.sheet = { ...(ui.sheet || {}), ...fallbackSheetPatch, fallback: text };
    render();
    const area = $('#share-text') || $('#export-text');
    if (area) {
      area.focus();
      area.select();
    }
  }
}

async function drawCard() {
  const pace = paceNow();
  const m = pace.global.mult;
  const thirty = realMinutes(30, m);
  const W = 1080;
  const H = 1350;
  const c = document.createElement('canvas');
  c.width = W;
  c.height = H;
  const g = c.getContext('2d');
  try {
    await document.fonts.ready;
  } catch {
    /* fall back to system fonts */
  }
  const face = getComputedStyle(document.body).fontFamily;
  const lineY = 860;
  g.fillStyle = '#0f2436';
  g.fillRect(0, 0, W, H);
  g.fillStyle = '#143654';
  g.fillRect(0, lineY, W, H - lineY);
  g.strokeStyle = 'rgba(255,255,255,0.08)';
  g.lineWidth = 3;
  for (let k = 0; k < 2; k++) {
    g.beginPath();
    for (let x = 0; x <= W; x += 8) {
      const y = lineY + 225 + k * 64 + Math.sin(x / 60 + k * 1.7) * 9;
      if (x === 0) g.moveTo(x, y);
      else g.lineTo(x, y);
    }
    g.stroke();
  }
  g.fillStyle = '#d4561c';
  g.fillRect(0, lineY - 4, W, 8);
  g.fillStyle = '#9fb6c9';
  g.font = `700 38px ${face}`;
  g.fillText('MY REALITY MULTIPLIER', 90, 200);
  g.fillStyle = '#ffffff';
  g.font = `800 290px ${face}`;
  g.fillText(fmtMult(m), 74, 500);
  const o = overrun(m);
  const claim = o ? `Things take me ${o} I guess.` : 'My guesses are close to spot on.';
  g.font = `700 46px ${face}`;
  const claimEnd = wrapText(g, claim, 90, 610, W - 180, 58);
  g.fillStyle = '#cfe0ee';
  g.font = `500 44px ${face}`;
  g.fillText(`My “30 minutes” is really ${thirty}.`, 90, Math.min(claimEnd + 96, 790));
  g.fillStyle = '#f0a37c';
  g.font = `700 30px ${face}`;
  g.textAlign = 'right';
  g.fillText('where my day really ends', W - 90, lineY - 22);
  g.textAlign = 'left';
  g.fillStyle = '#9fb6c9';
  g.font = `500 36px ${face}`;
  g.fillText(`Learned from ${plural(pace.n, 'finished task')}`, 90, 990);
  g.fillStyle = '#ffffff';
  g.font = `800 46px ${face}`;
  g.fillText('Leeway', 90, 1236);
  g.fillStyle = '#9fb6c9';
  g.font = `500 34px ${face}`;
  g.fillText('Plan the day you actually have.', 90, 1286);
  const blob = await new Promise((resolve) => c.toBlob(resolve, 'image/png'));
  return { blob, alt: `${fmtMult(m)}. ${claim} My 30 minutes is really ${thirty}.` };
}

function wrapText(g, text, x, y, maxWidth, lineHeight) {
  const words = text.split(' ');
  let line = '';
  for (const w of words) {
    const test = line ? `${line} ${w}` : w;
    if (g.measureText(test).width > maxWidth && line) {
      g.fillText(line, x, y);
      line = w;
      y += lineHeight;
    } else line = test;
  }
  if (line) g.fillText(line, x, y);
  return y;
}

let shareBlob = null;
async function openShare() {
  const downloads = await use('downloads');
  ui.sheet = { type: 'share', url: null, canSave: !!downloads || !hasClaude };
  render();
  const { blob, alt } = await drawCard();
  shareBlob = blob;
  if (!ui.sheet || ui.sheet.type !== 'share') return;
  ui.sheet = { ...ui.sheet, url: blob ? URL.createObjectURL(blob) : null, alt };
  render();
}

async function saveFile(filename, data) {
  const downloads = await use('downloads');
  if (downloads) {
    try {
      await downloads.save({ filename, data });
      showToast('Saved.');
    } catch (e) {
      if (!e || e.code !== 'declined') showToast('Could not save the file here. Use Copy instead.');
    }
    render();
    return;
  }
  if (!hasClaude) {
    const blob = data instanceof Blob ? data : new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 4000);
  }
}

function exportJson() {
  return JSON.stringify({ app: 'leeway', exportedAt: new Date().toISOString(), ...real }, null, 2);
}

async function importData() {
  const sh = ui.sheet;
  let text = ($('#import-text') && $('#import-text').value) || '';
  const file = $('#import-file') && $('#import-file').files && $('#import-file').files[0];
  if (file) text = await file.text();
  try {
    const raw = JSON.parse(text);
    const state = Core.normalizeState(raw, now());
    if (!state.tasks.length && !state.history.length) throw new Error('empty');
    state.onboarded = true;
    mode = 'real';
    ui.sheet = null;
    commit(state, { toast: `Imported ${plural(state.tasks.length, 'task')} and ${plural(state.history.length, 'learned time')}.` });
  } catch {
    ui.sheet = { ...sh, text, error: 'That does not look like a Leeway export. Check that you copied all of it.' };
    render();
  }
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

function onClick(e) {
  const el = e.target.closest('[data-act]');
  if (!el) return;
  const act = el.dataset.act;
  const id = el.dataset.id;
  if (act === 'sheet-scrim') {
    if (e.target === el) closeSheet();
    return;
  }
  const s = S();
  switch (act) {
    case 'start-own':
      mode = 'real';
      if (!real) real = Core.emptyState(now());
      writeLocal(real);
      ui.sheet = null;
      ui.focusId = null;
      location.hash = '#today';
      ui.route = 'today';
      render();
      ensureTicking();
      window.scrollTo(0, 0);
      break;
    case 'show-sample':
      demo = Core.buildSampleState(now());
      mode = 'sample';
      ui.route = 'today';
      if (location.hash !== '#today') location.hash = '#today';
      render();
      window.scrollTo(0, 0);
      break;
    case 'setup-hours':
      ui.setup.goodDayMin = Number(el.dataset.min);
      render();
      break;
    case 'energy':
      commit(Core.setDay(s, todayKey(), { energy: el.dataset.val, adjust: 0 }));
      break;
    case 'cap-adjust': {
      const day = s.days[todayKey()] || {};
      const capNow = capacityFor(s.prefs.goodDayMin, day.energy || 'ok', day.adjust || 0);
      const delta = Number(el.dataset.delta);
      if (capNow + delta < 0) return;
      commit(Core.setDay(s, todayKey(), { adjust: (day.adjust || 0) + delta, ...(day.energy ? {} : { energy: 'ok' }) }));
      break;
    }
    case 'chip':
      ui.chip[el.dataset.scope] = Number(el.dataset.min);
      render();
      break;
    case 'start':
      startFocus(id);
      break;
    case 'resume':
      wakeAudio();
      lastMinute = -1;
      commit(Core.startTask(s, id, now()));
      break;
    case 'open-focus':
      ui.focusId = id;
      lastMinute = -1;
      render();
      ensureTicking();
      break;
    case 'close-focus':
      ui.focusId = null;
      render();
      ensureTicking();
      break;
    case 'pause':
      commit(Core.pauseTask(s, id, now()));
      break;
    case 'stop-for-now':
      ui.focusId = null;
      commit(Core.pauseTask(s, id, now()), { toast: 'Paused. Your time so far is kept.' });
      break;
    case 'done':
      finish(id);
      break;
    case 'quicklog':
      finish(id, { actualMin: Number(el.dataset.min) });
      break;
    case 'quicklog-skip':
      finish(id, { learn: false });
      break;
    case 'reopen':
      commit(Core.reopenTask(s, id, todayKey()), { toast: 'Back on today’s list.', withUndo: true });
      break;
    case 'fix-time':
      ui.sheet = { type: 'fixtime', id };
      render();
      $('#fix-min') && $('#fix-min').focus();
      break;
    case 'menu':
      ui.sheet = { type: 'menu', id };
      render();
      break;
    case 'edit': {
      const t = findTask(id);
      if (!t) return;
      ui.sheet = { type: 'edit', id, title: t.title, est: t.est, tag: t.tag || '' };
      render();
      $('#edit-title') && $('#edit-title').focus();
      break;
    }
    case 'edit-est':
      ui.sheet.est = Number(el.dataset.min);
      render();
      break;
    case 'move-top':
    case 'move-up':
    case 'move-down':
      ui.sheet = null;
      commit(Core.reorderTask(s, id, act.slice(5)));
      break;
    case 'to-today':
      move(id, 'today');
      break;
    case 'to-tomorrow':
      move(id, 'tomorrow');
      break;
    case 'to-later':
      move(id, 'later');
      break;
    case 'drop':
      move(id, 'drop');
      break;
    case 'restore':
      commit(Core.reopenTask(s, id, todayKey()), { toast: 'Restored to today.', withUndo: true });
      break;
    case 'delete':
      ui.sheet = null;
      if (ui.focusId === id) ui.focusId = null;
      commit(Core.removeTask(s, id), { toast: 'Deleted.', withUndo: true });
      break;
    case 'below-tomorrow': {
      const { plan, key } = dayContext();
      const decisions = Object.fromEntries(plan.rows.filter((r) => !r.fits && !r.task.runStart).map((r) => [r.task.id, 'tomorrow']));
      const n = Object.keys(decisions).length;
      if (!n) return;
      commit(Core.resolveTasks(s, decisions, { baseKey: key, now: now() }), { toast: `Moved ${plural(n, 'task')} to tomorrow.`, withUndo: true });
      break;
    }
    case 'smaller':
      makeSmaller(id);
      break;
    case 'smaller-again':
      makeSmaller(id, { fresh: true });
      break;
    case 'smaller-use':
      useSteps(id, false);
      break;
    case 'smaller-start':
      useSteps(id, true);
      break;
    case 'close-day': {
      const { open } = dayContext();
      ui.sheet = { type: 'close', decisions: Object.fromEntries(open.filter((t) => !t.runStart).map((t) => [t.id, 'tomorrow'])), note: '' };
      render();
      break;
    }
    case 'leftovers-today': {
      const left = leftoverTasks(s.tasks, todayKey());
      commit(Core.resolveTasks(s, Object.fromEntries(left.map((t) => [t.id, 'today'])), { baseKey: todayKey(), now: now() }), {
        toast: `Brought ${plural(left.length, 'task')} into today.`,
        withUndo: true,
      });
      break;
    }
    case 'leftovers-choose': {
      const left = leftoverTasks(s.tasks, todayKey());
      ui.sheet = { type: 'triage', decisions: Object.fromEntries(left.map((t) => [t.id, 'today'])) };
      render();
      break;
    }
    case 'triage-pick':
      ui.sheet.decisions[id] = el.dataset.val;
      render();
      break;
    case 'triage-confirm': {
      const decisions = ui.sheet.decisions;
      ui.sheet = null;
      commit(Core.resolveTasks(s, decisions, { baseKey: todayKey(), now: now() }), { toast: 'Sorted.', withUndo: true });
      break;
    }
    case 'close-confirm': {
      const note = ($('#close-note') && $('#close-note').value) || '';
      const decisions = ui.sheet.decisions;
      ui.sheet = null;
      ui.focusId = null;
      commit(Core.closeDay(s, todayKey(), { decisions, note, now: now() }), { toast: 'Day closed. Rest well.', withUndo: true });
      window.scrollTo(0, 0);
      break;
    }
    case 'reopen-day': {
      const day = { ...(s.days[todayKey()] || {}) };
      delete day.closedAt;
      commit({ ...s, days: { ...s.days, [todayKey()]: day } });
      break;
    }
    case 'sheet-close':
      closeSheet();
      break;
    case 'undo':
      if (undo) {
        if (undo.mode === 'sample') demo = undo.prev;
        else {
          real = undo.prev;
          persist();
        }
        undo = null;
        ui.toast = null;
        render();
        ensureTicking();
      }
      break;
    case 'toast-close':
      ui.toast = null;
      render();
      break;
    case 'share':
      openShare();
      break;
    case 'share-copy':
      copyText(shareText(), { type: 'share' });
      break;
    case 'share-save':
      if (shareBlob) saveFile('my-leeway-multiplier.png', shareBlob);
      break;
    case 'export':
      use('downloads').then((d) => {
        ui.sheet = { type: 'export', canSave: !!d || !hasClaude };
        render();
      });
      break;
    case 'export-save':
      saveFile(`leeway-${todayKey()}.json`, exportJson());
      break;
    case 'export-copy':
      copyText(exportJson(), { type: 'export' });
      break;
    case 'import-open':
      ui.sheet = { type: 'import', text: '', error: '' };
      render();
      break;
    case 'import-confirm':
      importData();
      break;
    case 'erase-open':
      ui.sheet = { type: 'erase' };
      render();
      break;
    case 'erase-confirm':
      ui.sheet = null;
      ui.focusId = null;
      real = Core.emptyState(now());
      real.updatedAt = now();
      persist();
      mode = 'real';
      location.hash = '#today';
      render();
      ensureTicking();
      showToast('Erased. Fresh start.');
      render();
      break;
    default:
      break;
  }
}

function closeSheet() {
  ui.sheet = null;
  render();
}

function onSubmit(e) {
  const form = e.target;
  e.preventDefault();
  if (form.id === 'add-today-form') return addFromForm('today');
  if (form.id === 'add-later-form') return addFromForm('later');
  if (form.id === 'setup-form') {
    const st = ui.setup;
    const stopEl = $('#setup-stop');
    const stopAt = st.noStop ? null : (stopEl && stopEl.value) || '18:00';
    if (!real) real = Core.emptyState(now());
    mode = 'real';
    commit({ ...real, onboarded: true, prefs: { ...real.prefs, goodDayMin: st.goodDayMin, stopAt } });
    const input = $('#add-today');
    if (input) input.focus();
    return;
  }
  if (form.id === 'edit-form') {
    const id = form.dataset.id;
    const title = $('#edit-title').value.trim();
    const est = Number($('#edit-est').value) || ui.sheet.est;
    const tag = $('#edit-tag').value.replace(/^#/, '').trim().toLowerCase() || null;
    if (!title) return;
    ui.sheet = null;
    return commit(Core.updateTask(S(), id, { title, est, tag }), { toast: 'Saved.' });
  }
  if (form.id === 'quicklog-form') {
    const min = Number($('#quicklog-min').value);
    if (min > 0) finish(form.dataset.id, { actualMin: min });
    return;
  }
  if (form.id === 'fix-form') {
    const min = Number($('#fix-min').value);
    const learn = $('#fix-learn').checked;
    ui.sheet = null;
    return commit(Core.fixActual(S(), form.dataset.id, { actualMin: min, learn }), { toast: 'Time fixed.' });
  }
}

function onInput(e) {
  const t = e.target;
  if (t.id === 'add-today') ui.drafts.today = t.value;
  else if (t.id === 'add-later') ui.drafts.later = t.value;
  else if (t.id === 'close-note' && ui.sheet) ui.sheet.note = t.value;
  else if (t.id === 'import-text' && ui.sheet) ui.sheet.text = t.value;
  else if (t.id === 'edit-est' && ui.sheet) ui.sheet.est = Number(t.value) || ui.sheet.est;
  else if (t.id === 'edit-title' && ui.sheet) ui.sheet.title = t.value;
  else if (t.id === 'edit-tag' && ui.sheet) ui.sheet.tag = t.value;
  else if (t.id === 'setup-stop') ui.setup.stopAt = t.value;
}

function setPrefs(patch) {
  commit({ ...S(), prefs: { ...S().prefs, ...patch } });
}

function onChange(e) {
  const t = e.target;
  if (t.dataset.step) {
    const task = findTask(t.dataset.id);
    if (!task) return;
    const steps = task.steps.map((st) => (st.id === t.dataset.step ? { ...st, done: t.checked } : st));
    return commit(Core.updateTask(S(), task.id, { steps }));
  }
  switch (t.id) {
    case 'setup-nostop':
      ui.setup.noStop = t.checked;
      return render();
    case 'pref-good':
      return setPrefs({ goodDayMin: Number(t.value) });
    case 'pref-stop':
      return t.value && setPrefs({ stopAt: t.value });
    case 'pref-nostop':
      return setPrefs({ stopAt: t.checked ? null : ($('#pref-stop') && $('#pref-stop').value) || '18:00' });
    case 'pref-start':
      return setPrefs({ dayStartHour: Number(t.value) });
    case 'pref-checkins':
      return setPrefs({ checkins: t.checked });
    case 'pref-every':
      return setPrefs({ checkinEvery: Number(t.value) });
    case 'pref-chime':
      if (t.checked) {
        wakeAudio();
        chime();
      }
      return setPrefs({ chime: t.checked });
    case 'pref-ai':
      return setPrefs({ ai: t.checked });
    default:
      return undefined;
  }
}

function onKey(e) {
  const typing = /^(INPUT|TEXTAREA|SELECT)$/.test((e.target && e.target.tagName) || '');
  if (e.key === 'Escape') {
    if (ui.sheet) return closeSheet();
    if (ui.focusId) {
      ui.focusId = null;
      render();
      return ensureTicking();
    }
  }
  if (typing || e.metaKey || e.ctrlKey || e.altKey) return;
  if ((e.key === 'n' || e.key === '/') && !ui.sheet && !ui.focusId) {
    const input = $('#add-today') || $('#add-later');
    if (input) {
      e.preventDefault();
      input.focus();
    }
  }
  if (e.key === ' ' && ui.focusId && !ui.sheet && !(e.target && e.target.closest && e.target.closest('button'))) {
    const t = findTask(ui.focusId);
    if (!t) return;
    e.preventDefault();
    commit(t.runStart ? Core.pauseTask(S(), t.id, now()) : Core.startTask(S(), t.id, now()));
  }
}

function onPaste(e) {
  const t = e.target;
  if (!t || (t.id !== 'add-today' && t.id !== 'add-later')) return;
  const text = (e.clipboardData && e.clipboardData.getData('text')) || '';
  if (!text.includes('\n')) return;
  e.preventDefault();
  const scope = t.id === 'add-today' ? 'today' : 'later';
  const items = Core.parseBrainDump(text, ui.chip[scope]);
  if (!items.length) return;
  let s = S();
  for (const p of items) s = Core.addTask(s, p, { list: scope === 'today' ? 'today' : 'later', day: scope === 'today' ? todayKey() : null, now: now() });
  commit(s, { toast: `Added ${plural(items.length, 'task')} from your list.`, withUndo: true });
}

const ROUTES = new Set(['today', 'later', 'pace', 'prefs']);
function onRoute() {
  const r = location.hash.replace('#', '');
  const next = ROUTES.has(r) ? r : 'today';
  if (next === ui.route) return;
  ui.route = next;
  render();
  window.scrollTo(0, 0);
}

// Tooltips for chart marks and the sparkline crosshair.
function setupTips() {
  const tip = $('#tip');
  const show = (title, sub, x, y) => {
    tip.innerHTML = '';
    const strong = document.createElement('strong');
    strong.textContent = title;
    tip.appendChild(strong);
    if (sub) tip.appendChild(document.createTextNode(sub));
    tip.hidden = false;
    const w = tip.offsetWidth;
    const h = tip.offsetHeight;
    tip.style.left = `${Math.max(8, Math.min(window.innerWidth - w - 8, x - w / 2))}px`;
    tip.style.top = `${Math.max(8, y - h - 12)}px`;
  };
  const hide = () => {
    tip.hidden = true;
  };
  document.addEventListener('pointermove', (e) => {
    const hit = e.target.closest && e.target.closest('#spark-hit');
    if (hit && ui.trend.length) {
      const svgEl = hit.ownerSVGElement;
      const pt = svgEl.createSVGPoint();
      pt.x = e.clientX;
      pt.y = e.clientY;
      const local = pt.matrixTransform(svgEl.getScreenCTM().inverse());
      let best = ui.trend[0];
      for (const p of ui.trend) if (Math.abs(p.x - local.x) < Math.abs(best.x - local.x)) best = p;
      const cross = $('#spark-cross');
      const dot = $('#spark-dot');
      cross.setAttribute('x1', best.x);
      cross.setAttribute('x2', best.x);
      cross.setAttribute('visibility', 'visible');
      dot.setAttribute('cx', best.x);
      dot.setAttribute('cy', best.y);
      dot.setAttribute('visibility', 'visible');
      const screen = svgEl.createSVGPoint();
      screen.x = best.x;
      screen.y = best.y;
      const sp = screen.matrixTransform(svgEl.getScreenCTM());
      show(fmtMult(best.mult), `after task ${best.i + 1} of ${ui.trend.length}, ${new Date(best.t).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}`, sp.x, sp.y);
      return;
    }
    const mark = e.target.closest && e.target.closest('[data-tip]');
    if (mark) {
      show(mark.dataset.tip, mark.dataset.tipSub || '', e.clientX, e.clientY);
      return;
    }
    if (!tip.hidden) {
      hide();
      const cross = $('#spark-cross');
      if (cross) cross.setAttribute('visibility', 'hidden');
      const dot = $('#spark-dot');
      if (dot) dot.setAttribute('visibility', 'hidden');
    }
  });
  document.addEventListener('focusin', (e) => {
    const mark = e.target.closest && e.target.closest('[data-tip]');
    if (mark) {
      const r = mark.getBoundingClientRect();
      show(mark.dataset.tip, mark.dataset.tipSub || '', r.left + r.width / 2, r.top);
    } else hide();
  });
  document.addEventListener('scroll', hide, { passive: true });
}

// ---------------------------------------------------------------------------
// Boot
// ---------------------------------------------------------------------------

function boot() {
  real = readLocal();
  if (hasData(real) || (real && real.updatedAt)) mode = 'real';
  else {
    mode = 'sample';
    demo = Core.buildSampleState(now());
  }
  if (!real) real = null;
  const r = location.hash.replace('#', '');
  ui.route = ROUTES.has(r) ? r : 'today';
  if (mode === 'real' && !real) real = Core.emptyState(now());

  document.addEventListener('click', onClick);
  document.addEventListener('submit', onSubmit);
  document.addEventListener('input', onInput);
  document.addEventListener('change', onChange);
  document.addEventListener('keydown', onKey);
  document.addEventListener('paste', onPaste);
  window.addEventListener('hashchange', onRoute);
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      render();
      ensureTicking();
    }
  });
  window.addEventListener('storage', (e) => {
    if (e.key !== LS_KEY || !e.newValue) return;
    try {
      const incoming = Core.normalizeState(JSON.parse(e.newValue));
      if (!real || incoming.updatedAt > real.updatedAt) {
        real = incoming;
        if (mode === 'real') render();
      }
    } catch {
      /* ignore */
    }
  });
  setupTips();
  // Re-plan once a minute so the line follows the clock (and the day rolls over at night).
  setInterval(() => {
    const a = document.activeElement;
    if (document.visibilityState === 'visible' && !(a && /^(INPUT|TEXTAREA|SELECT)$/.test(a.tagName))) render();
  }, 60000);

  const running = runningTask(S());
  if (running) ui.focusId = running.id;
  render();
  ensureTicking();
  connectCloud();

  if (!hasClaude && 'serviceWorker' in navigator && location.protocol === 'https:') {
    navigator.serviceWorker.register('sw.js').catch(() => {});
  }
}

boot();
