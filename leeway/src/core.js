// Leeway core: pure planning logic.
// No DOM, no storage, no hidden clock reads (callers pass `now`).
// Everything in this file is covered by test/core.test.mjs.

// ---------------------------------------------------------------------------
// Model constants
// ---------------------------------------------------------------------------

// Research prior. People finish tasks ~1.5-1.6x later than they predict
// (Buehler, Griffin & Ross 1994: predicted 33.9 days, took 55.5). Leeway
// starts every new user here and moves toward their own pace as they finish
// tasks.
export const PRIOR_MULTIPLIER = 1.5;
// How many "virtual tasks" the prior is worth before your data outweighs it.
export const PRIOR_STRENGTH = 3;
// Tag- and size-specific multipliers shrink toward your global pace.
export const GROUP_PRIOR_STRENGTH = 3;
export const GROUP_MIN_SAMPLES = 3;
// Recent tasks count more: a task from 3 weeks ago counts half.
export const HALF_LIFE_DAYS = 21;
// One wild outlier (a 5-minute task you left running overnight) must not
// wreck the model.
export const RATIO_BOUNDS = [0.2, 5];
export const MULT_BOUNDS = [0.5, 4];

export const DAY_MS = 86400000;
export const MAX_HISTORY = 2000;
export const KEEP_FINISHED_DAYS = 45;
export const STATE_VERSION = 1;

export const ENERGY = {
  low: { label: 'Low', factor: 0.5, hint: 'about half a good day' },
  ok: { label: 'Okay', factor: 0.75, hint: 'most of a good day' },
  good: { label: 'Good', factor: 1, hint: 'a full good day' },
};

export const SIZES = [
  { id: 'quick', label: 'Quick tasks', range: '15 min or less', max: 15 },
  { id: 'medium', label: 'Medium tasks', range: '16 to 60 min', max: 60 },
  { id: 'big', label: 'Big tasks', range: 'over an hour', max: Infinity },
];

export const ESTIMATE_CHIPS = [5, 15, 30, 45, 60, 120];

// ---------------------------------------------------------------------------
// Small utilities
// ---------------------------------------------------------------------------

export const clamp = (x, lo, hi) => Math.min(hi, Math.max(lo, x));
export const roundTo = (x, step) => Math.round(x / step) * step;
const pad2 = (n) => String(n).padStart(2, '0');

export function uid() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
}

export const byOrder = (a, b) => (a.order - b.order) || (a.created - b.created);

// ---------------------------------------------------------------------------
// Days. A "day" starts at dayStartHour (default 4am), so working past
// midnight still counts as the same day.
// ---------------------------------------------------------------------------

export function isoDate(d) {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
}

export function dayKey(ts, startHour = 4) {
  return isoDate(new Date(ts - startHour * 3600000));
}

export function addDays(key, n) {
  const [y, m, d] = key.split('-').map(Number);
  return isoDate(new Date(y, m - 1, d + n, 12));
}

export function dayStartMs(key, startHour = 4) {
  const [y, m, d] = key.split('-').map(Number);
  return new Date(y, m - 1, d, startHour, 0, 0, 0).getTime();
}

// "18:00" on the calendar date of `key`. A stop time earlier than the day
// start (e.g. "01:30" with a 4am day start) belongs to the next calendar day.
export function stopTimeMs(key, stopAt, startHour = 4) {
  if (!stopAt || !/^\d{1,2}:\d{2}$/.test(stopAt)) return null;
  const [hh, mm] = stopAt.split(':').map(Number);
  const [y, m, d] = key.split('-').map(Number);
  const nextDay = hh < startHour ? 1 : 0;
  return new Date(y, m - 1, d + nextDay, hh, mm, 0, 0).getTime();
}

// ---------------------------------------------------------------------------
// Quick add: "Email Sam about the contract 10m #email"
// ---------------------------------------------------------------------------

const UNIT_H = '(?:h|hr|hrs|hour|hours)';
const UNIT_M = '(?:m|min|mins|minute|minutes)';
const DURATION_RE = new RegExp(
  `(^|\\s)(?:~\\s*|about\\s+|for\\s+|takes?\\s+)?` +
    `(?:(\\d+(?:[.,]\\d+)?)\\s*${UNIT_H}(?:\\s*(\\d{1,2})\\s*${UNIT_M}?)?|(\\d{1,3})\\s*${UNIT_M})` +
    `(?=$|[\\s.,;!?)])`,
  'gi'
);
const TAG_RE = /(^|\s)#([\p{L}\p{N}_-]{1,24})(?=$|\s)/gu;

export function parseQuickAdd(raw, fallbackEst = 30) {
  let text = String(raw ?? '').replace(/\s+/g, ' ').trim();
  let tag = null;
  text = text
    .replace(TAG_RE, (_m, pre, name) => {
      if (!tag) tag = name.toLowerCase();
      return pre;
    })
    .replace(/\s+/g, ' ')
    .trim();

  let est = null;
  let last = null;
  for (const m of text.matchAll(DURATION_RE)) last = m;
  if (last) {
    const [whole, pre, hours, extraMin, mins] = last;
    const minutes =
      hours != null
        ? parseFloat(hours.replace(',', '.')) * 60 + (extraMin ? parseInt(extraMin, 10) : 0)
        : parseInt(mins, 10);
    if (minutes >= 1 && minutes <= 720) {
      est = Math.round(minutes);
      // Strip the duration only when it trails the title ("Email Sam 10m").
      // "Do 10 minutes of yoga" keeps its wording and still gets est = 10.
      if (last.index + whole.length >= text.length) {
        text = text.slice(0, last.index + pre.length).trim();
      }
    }
  }
  text = text.replace(/[\s,;:–—-]+$/u, '').trim();
  return { title: text, est: est ?? fallbackEst, explicitEst: est != null, tag };
}

// A pasted brain dump: one task per line, bullets and checkboxes removed.
export function parseBrainDump(raw, fallbackEst = 30) {
  return String(raw ?? '')
    .split(/\r?\n/)
    .map((line) => line.replace(/^\s*(?:(?:[-*•]|\d+[.)]|\[[ xX]?\])\s*)+/, '').trim())
    .filter(Boolean)
    .map((line) => parseQuickAdd(line, fallbackEst))
    .filter((p) => p.title);
}

// ---------------------------------------------------------------------------
// Pace model: personal reference-class forecasting.
// history entries: { i: taskId, t: finishedAt ms, e: guess min, a: actual min, g: tag|null }
// ---------------------------------------------------------------------------

export function isValidSample(h) {
  return (
    !!h &&
    Number.isFinite(h.t) &&
    Number.isFinite(h.e) &&
    Number.isFinite(h.a) &&
    h.e > 0 &&
    h.a > 0
  );
}

export function sizeOf(est) {
  for (const s of SIZES) if (est <= s.max) return s.id;
  return 'big';
}

function fitGroup(samples, priorMu, k, now, halfLifeDays) {
  let sw = 0;
  let swl = 0;
  for (const h of samples) {
    const ageDays = Math.max(0, (now - h.t) / DAY_MS);
    const w = Math.pow(0.5, ageDays / halfLifeDays);
    sw += w;
    swl += w * Math.log(clamp(h.a / h.e, RATIO_BOUNDS[0], RATIO_BOUNDS[1]));
  }
  const mu = (k * priorMu + swl) / (k + sw);
  return { mult: clamp(Math.exp(mu), MULT_BOUNDS[0], MULT_BOUNDS[1]), n: samples.length, weight: sw };
}

export function learnPace(
  history,
  { now = Date.now(), prior = PRIOR_MULTIPLIER, priorStrength = PRIOR_STRENGTH, halfLifeDays = HALF_LIFE_DAYS } = {}
) {
  const samples = (history || []).filter(isValidSample);
  const global = fitGroup(samples, Math.log(prior), priorStrength, now, halfLifeDays);
  const gmu = Math.log(global.mult);
  const group = (keyOf) => {
    const map = new Map();
    for (const h of samples) {
      const key = keyOf(h);
      if (!key) continue;
      if (!map.has(key)) map.set(key, []);
      map.get(key).push(h);
    }
    const out = {};
    for (const [key, list] of map) out[key] = fitGroup(list, gmu, GROUP_PRIOR_STRENGTH, now, halfLifeDays);
    return out;
  };
  return {
    global,
    byTag: group((h) => h.g || null),
    bySize: group((h) => sizeOf(h.e)),
    n: samples.length,
    prior,
  };
}

// The most specific multiplier that has enough evidence behind it.
export function multiplierFor(pace, task) {
  const tag = task && task.tag;
  const byTag = tag && pace.byTag[tag];
  if (byTag && byTag.n >= GROUP_MIN_SAMPLES) return { mult: byTag.mult, basis: 'tag' };
  const bySize = pace.bySize[sizeOf((task && task.est) || 30)];
  if (bySize && bySize.n >= GROUP_MIN_SAMPLES) return { mult: bySize.mult, basis: 'size' };
  return { mult: pace.global.mult, basis: pace.n ? 'you' : 'prior' };
}

// A guess, translated into real time. Nothing real takes under 5 minutes.
export function realMinutes(est, mult) {
  return Math.max(5, Math.round((est * mult) / 5) * 5);
}

export function paceConfidence(pace) {
  const n = pace.n;
  if (n === 0) {
    return {
      level: 0,
      label: 'Research average',
      detail: `Most people underestimate by about ${fmtMult(pace.prior)}. Leeway starts there and learns your own pace from every task you finish.`,
    };
  }
  if (n < 5) {
    return {
      level: 1,
      label: 'Learning your pace',
      detail: `Based on ${n} finished task${n === 1 ? '' : 's'}, blended with the research average until there is more.`,
    };
  }
  if (n < 15) return { level: 2, label: 'Getting to know you', detail: `Based on ${n} finished tasks.` };
  return { level: 3, label: 'Calibrated', detail: `Based on ${n} finished tasks, weighted toward the last few weeks.` };
}

export function translationTable(pace, ests = [5, 15, 30, 60, 120]) {
  return ests.map((est) => {
    const { mult } = multiplierFor(pace, { est });
    return { est, real: realMinutes(est, mult), mult };
  });
}

function chronological(history) {
  return (history || []).filter(isValidSample).slice().sort((a, b) => a.t - b.t);
}

// How your global multiplier moved as Leeway learned (one point per task).
export function paceTrend(history, { points = 30 } = {}) {
  const sorted = chronological(history);
  const out = [];
  for (let i = Math.max(1, sorted.length - points + 1); i <= sorted.length; i++) {
    out.push({ t: sorted[i - 1].t, mult: learnPace(sorted.slice(0, i), { now: sorted[i - 1].t }).global.mult });
  }
  return out;
}

// Honest accuracy check: for each finished task, what would Leeway have said
// using only the tasks finished before it? Compare that with the raw guess.
export function backtest(history, { minPrior = 3, window = 200 } = {}) {
  const sorted = chronological(history);
  let rawErr = 0;
  let fixErr = 0;
  let n = 0;
  for (let i = Math.max(minPrior, sorted.length - window); i < sorted.length; i++) {
    const h = sorted[i];
    const pace = learnPace(sorted.slice(0, i), { now: h.t });
    const { mult } = multiplierFor(pace, { est: h.e, tag: h.g });
    rawErr += Math.abs(h.e - h.a);
    fixErr += Math.abs(h.e * mult - h.a);
    n++;
  }
  if (n < 3 || rawErr === 0) return null;
  return { n, rawErr: rawErr / n, fixErr: fixErr / n, improvement: 1 - fixErr / rawErr };
}

// ---------------------------------------------------------------------------
// Capacity and the line
// ---------------------------------------------------------------------------

export function capacityFor(goodDayMin, energy, adjustMin = 0) {
  const factor = (ENERGY[energy] || ENERGY.ok).factor;
  return Math.max(0, roundTo(goodDayMin * factor, 15) + (adjustMin || 0));
}

export function elapsedMs(task, now) {
  return (task.elapsedMs || 0) + (task.runStart ? Math.max(0, now - task.runStart) : 0);
}

// Lay today's open tasks end to end in real time and cut the list where the
// day runs out. The cut is a single line: reorder tasks to choose what fits.
export function planDay(tasks, { pace, capacityMin, usedMin = 0, now, stopMs = null, gapMin = 5, tolerance = 4 }) {
  const byCapacity = Math.max(0, capacityMin - usedMin);
  const byClock = stopMs == null ? Infinity : Math.max(0, Math.floor((stopMs - now) / 60000));
  const available = Math.min(byCapacity, byClock);
  const limitedBy = byClock < byCapacity ? 'clock' : 'capacity';
  let cursor = 0;
  let crossed = false;
  let fitCount = 0;
  let fitReal = 0;
  let estTotal = 0;
  let realTotal = 0;
  const rows = tasks.map((task) => {
    const { mult, basis } = multiplierFor(pace, task);
    const real = realMinutes(task.est, mult);
    const spent = elapsedMs(task, now) / 60000;
    const remaining = spent > 0 ? Math.max(1, Math.ceil(real - spent)) : real;
    const start = cursor;
    const end = cursor + remaining;
    const fits = !crossed && end <= available + tolerance;
    if (!fits) crossed = true;
    else {
      fitCount++;
      fitReal += remaining;
    }
    cursor = end;
    estTotal += task.est;
    realTotal += remaining;
    return { task, mult, basis, real, remaining, spent, start, end, fits };
  });
  return {
    rows,
    available,
    byCapacity,
    byClock,
    limitedBy,
    estTotal,
    realTotal,
    overBy: Math.max(0, realTotal - available),
    freeMin: Math.max(0, available - fitReal),
    fitCount,
    belowCount: rows.length - fitCount,
    finishMs: now + (fitReal + Math.max(0, fitCount - 1) * gapMin) * 60000,
  };
}

// One-tap answers to "how long did it take?" when no timer ran.
export function quickLogOptions(est) {
  return [...new Set([1, 1.5, 2, 3].map((f) => Math.max(5, roundTo(est * f, 5))))];
}

// ---------------------------------------------------------------------------
// Task selectors
// ---------------------------------------------------------------------------

export const todayTasks = (tasks, key) => tasks.filter((t) => t.list === 'today' && t.day === key).sort(byOrder);
export const leftoverTasks = (tasks, key) =>
  tasks.filter((t) => t.list === 'today' && t.day && t.day < key).sort((a, b) => a.day.localeCompare(b.day) || byOrder(a, b));
export const scheduledTasks = (tasks, key) =>
  tasks.filter((t) => t.list === 'today' && t.day && t.day > key).sort((a, b) => a.day.localeCompare(b.day) || byOrder(a, b));
export const laterTasks = (tasks) => tasks.filter((t) => t.list === 'later').sort(byOrder);
export const droppedTasks = (tasks) => tasks.filter((t) => t.list === 'dropped').sort((a, b) => (b.doneAt || 0) - (a.doneAt || 0));
export const doneOn = (tasks, key, startHour = 4) =>
  tasks.filter((t) => t.list === 'done' && t.doneAt && dayKey(t.doneAt, startHour) === key).sort((a, b) => a.doneAt - b.doneAt);
export const runningTask = (state) => state.tasks.find((t) => t.runStart) || null;

export function summarizeDay(done) {
  const learned = done.filter((t) => t.actual > 0 && t.est > 0 && t.learn !== false);
  const sumE = learned.reduce((s, t) => s + t.est, 0);
  const sumA = learned.reduce((s, t) => s + t.actual, 0);
  return {
    count: done.length,
    focusMin: done.reduce((s, t) => s + (t.actual || 0), 0),
    ratio: sumE ? sumA / sumE : null,
    learnedCount: learned.length,
  };
}

// ---------------------------------------------------------------------------
// State: shape, validation, pruning
// ---------------------------------------------------------------------------

export function defaultPrefs() {
  return { goodDayMin: 300, stopAt: '18:00', dayStartHour: 4, checkins: true, checkinEvery: 15, chime: false, ai: true };
}

export function emptyState(now = Date.now()) {
  return { v: STATE_VERSION, createdAt: now, updatedAt: 0, onboarded: false, tasks: [], history: [], days: {}, prefs: defaultPrefs() };
}

const LISTS = new Set(['today', 'later', 'done', 'dropped']);
const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;

export function normalizeTask(t) {
  if (!t || typeof t !== 'object' || typeof t.title !== 'string' || !t.title.trim()) return null;
  return {
    id: String(t.id || uid()),
    title: t.title.trim().slice(0, 200),
    est: clamp(Math.round(Number(t.est) || 30), 1, 720),
    tag: typeof t.tag === 'string' && t.tag.trim() ? t.tag.trim().slice(0, 24).toLowerCase() : null,
    list: LISTS.has(t.list) ? t.list : 'later',
    day: typeof t.day === 'string' && DAY_RE.test(t.day) ? t.day : null,
    order: Number.isFinite(t.order) ? t.order : 0,
    created: Number(t.created) || Date.now(),
    doneAt: Number(t.doneAt) || null,
    actual: Number(t.actual) > 0 ? Math.round(Number(t.actual)) : null,
    learn: t.learn !== false,
    elapsedMs: Math.max(0, Number(t.elapsedMs) || 0),
    runStart: Number(t.runStart) || null,
    steps: Array.isArray(t.steps)
      ? t.steps
          .filter((s) => s && typeof s.text === 'string' && s.text.trim())
          .slice(0, 12)
          .map((s) => ({ id: String(s.id || uid()), text: s.text.trim().slice(0, 140), done: !!s.done }))
      : [],
  };
}

export function normalizeState(raw, now = Date.now()) {
  const base = emptyState(now);
  if (!raw || typeof raw !== 'object') return base;
  const p = { ...base.prefs, ...(raw.prefs && typeof raw.prefs === 'object' ? raw.prefs : {}) };
  const prefs = {
    goodDayMin: clamp(Math.round(Number(p.goodDayMin) || 300), 30, 16 * 60),
    stopAt: typeof p.stopAt === 'string' && /^\d{1,2}:\d{2}$/.test(p.stopAt) ? p.stopAt : null,
    dayStartHour: Number.isFinite(Number(p.dayStartHour)) ? clamp(Math.round(Number(p.dayStartHour)), 0, 12) : 4,
    checkins: p.checkins !== false,
    checkinEvery: clamp(Math.round(Number(p.checkinEvery) || 15), 5, 60),
    chime: p.chime === true,
    ai: p.ai !== false,
  };
  const days = {};
  if (raw.days && typeof raw.days === 'object') {
    for (const [k, d] of Object.entries(raw.days)) {
      if (!DAY_RE.test(k) || !d || typeof d !== 'object') continue;
      days[k] = {
        ...(ENERGY[d.energy] ? { energy: d.energy } : {}),
        ...(Number.isFinite(d.adjust) ? { adjust: clamp(Math.round(d.adjust), -600, 600) } : {}),
        ...(Number(d.closedAt) ? { closedAt: Number(d.closedAt) } : {}),
        ...(typeof d.note === 'string' && d.note ? { note: d.note.slice(0, 280) } : {}),
      };
    }
  }
  return {
    v: STATE_VERSION,
    createdAt: Number(raw.createdAt) || now,
    updatedAt: Number(raw.updatedAt) || 0,
    onboarded: !!raw.onboarded,
    tasks: Array.isArray(raw.tasks) ? raw.tasks.map(normalizeTask).filter(Boolean) : [],
    history: Array.isArray(raw.history)
      ? raw.history.filter(isValidSample).map((h) => ({ i: h.i ? String(h.i) : null, t: h.t, e: h.e, a: h.a, g: h.g ? String(h.g) : null }))
      : [],
    days,
    prefs,
  };
}

export function pruneState(state, now = Date.now()) {
  const cutoff = now - KEEP_FINISHED_DAYS * DAY_MS;
  const tasks = state.tasks.filter((t) => !((t.list === 'done' || t.list === 'dropped') && (t.doneAt || t.created) < cutoff));
  const history = state.history.length > MAX_HISTORY ? state.history.slice(-MAX_HISTORY) : state.history;
  const days = {};
  for (const k of Object.keys(state.days).sort().slice(-120)) days[k] = state.days[k];
  return { ...state, tasks, history, days };
}

// ---------------------------------------------------------------------------
// State transitions (pure: return a new state)
// ---------------------------------------------------------------------------

const samePlace = (list, day) => (t) => t.list === list && (list !== 'today' || t.day === day);

function nextOrder(tasks, pred, top = false) {
  const orders = tasks.filter(pred).map((t) => t.order);
  if (!orders.length) return 0;
  return top ? Math.min(...orders) - 1 : Math.max(...orders) + 1;
}

export function addTask(state, input, { list = 'today', day = null, now = Date.now(), top = false } = {}) {
  const title = String((input && input.title) || '').trim();
  if (!title) return state;
  const task = normalizeTask({
    id: input.id || uid(),
    title,
    est: input.est,
    tag: input.tag,
    list,
    day: list === 'today' ? day : null,
    order: nextOrder(state.tasks, samePlace(list, day), top),
    created: now,
    steps: input.steps || [],
  });
  return { ...state, tasks: [...state.tasks, task] };
}

export function updateTask(state, id, patch) {
  return { ...state, tasks: state.tasks.map((t) => (t.id === id ? normalizeTask({ ...t, ...patch }) || t : t)) };
}

export function removeTask(state, id) {
  return { ...state, tasks: state.tasks.filter((t) => t.id !== id), history: state.history.filter((h) => h.i !== id) };
}

// Only one task runs at a time; starting one pauses the other.
export function startTask(state, id, now) {
  return {
    ...state,
    tasks: state.tasks.map((t) => {
      if (t.id === id) return t.runStart ? t : { ...t, runStart: now };
      if (t.runStart) return { ...t, elapsedMs: elapsedMs(t, now), runStart: null };
      return t;
    }),
  };
}

export function pauseTask(state, id, now) {
  return {
    ...state,
    tasks: state.tasks.map((t) => (t.id === id && t.runStart ? { ...t, elapsedMs: elapsedMs(t, now), runStart: null } : t)),
  };
}

// actualMin: minutes it really took. Omit it to use the timer.
// learn: false keeps a weird task (interrupted, forgot the timer) out of the model.
export function completeTask(state, id, { actualMin = null, learn = true, now = Date.now() } = {}) {
  const task = state.tasks.find((t) => t.id === id);
  if (!task) return state;
  const spent = elapsedMs(task, now);
  const measured = Math.round(spent / 60000);
  const actual = actualMin != null ? Math.max(1, Math.round(actualMin)) : measured >= 1 ? measured : null;
  const done = { ...task, list: 'done', doneAt: now, runStart: null, elapsedMs: spent, actual, learn: learn && actual != null };
  const history = state.history.filter((h) => h.i !== id);
  if (done.learn) history.push({ i: id, t: now, e: task.est, a: actual, g: task.tag || null });
  return { ...state, tasks: state.tasks.map((t) => (t.id === id ? done : t)), history };
}

// Correct a finished task's time afterwards ("I forgot to pause the timer").
export function fixActual(state, id, { actualMin, learn = true }) {
  const task = state.tasks.find((t) => t.id === id && t.list === 'done');
  if (!task) return state;
  const actual = Number(actualMin) > 0 ? Math.min(1440, Math.round(Number(actualMin))) : null;
  const keep = learn && actual != null;
  const history = state.history.filter((h) => h.i !== id);
  if (keep) history.push({ i: id, t: task.doneAt, e: task.est, a: actual, g: task.tag || null });
  history.sort((a, b) => a.t - b.t);
  return { ...state, tasks: state.tasks.map((t) => (t.id === id ? { ...t, actual, learn: keep } : t)), history };
}

export function reopenTask(state, id, todayKey) {
  const task = state.tasks.find((t) => t.id === id);
  if (!task) return state;
  const others = state.tasks.filter((t) => t.id !== id);
  const reopened = {
    ...task,
    list: 'today',
    day: todayKey,
    doneAt: null,
    actual: null,
    learn: true,
    order: nextOrder(others, samePlace('today', todayKey)),
  };
  return { ...state, tasks: state.tasks.map((t) => (t.id === id ? reopened : t)), history: state.history.filter((h) => h.i !== id) };
}

export function moveTask(state, id, { list, day = null, now = Date.now(), top = false }) {
  const others = state.tasks.filter((t) => t.id !== id);
  const order = nextOrder(others, samePlace(list, day), top);
  return {
    ...state,
    tasks: state.tasks.map((t) =>
      t.id === id
        ? {
            ...t,
            list,
            day: list === 'today' ? day : null,
            elapsedMs: elapsedMs(t, now),
            runStart: null,
            doneAt: list === 'dropped' ? now : list === 'done' ? t.doneAt : null,
            order,
          }
        : t
    ),
  };
}

export function reorderTask(state, id, how) {
  const task = state.tasks.find((t) => t.id === id);
  if (!task) return state;
  const peers = state.tasks.filter(samePlace(task.list, task.day)).sort(byOrder);
  const idx = peers.findIndex((t) => t.id === id);
  const last = peers.length - 1;
  const target = { top: 0, up: Math.max(0, idx - 1), down: Math.min(last, idx + 1), bottom: last }[how];
  if (target == null || target === idx) return state;
  const reordered = peers.filter((t) => t.id !== id);
  reordered.splice(target, 0, task);
  const orderOf = new Map(reordered.map((t, i) => [t.id, i]));
  return { ...state, tasks: state.tasks.map((t) => (orderOf.has(t.id) ? { ...t, order: orderOf.get(t.id) } : t)) };
}

export function setDay(state, key, patch) {
  return { ...state, days: { ...state.days, [key]: { ...(state.days[key] || {}), ...patch } } };
}

// decisions: { [taskId]: 'today' | 'tomorrow' | 'later' | 'drop' }
// 'tomorrow' means the day after `baseKey`.
export function resolveTasks(state, decisions, { baseKey, now = Date.now() }) {
  let s = state;
  const tomorrow = addDays(baseKey, 1);
  for (const [id, choice] of Object.entries(decisions || {})) {
    if (!s.tasks.some((t) => t.id === id)) continue;
    if (choice === 'today') s = moveTask(s, id, { list: 'today', day: baseKey, now });
    else if (choice === 'tomorrow') s = moveTask(s, id, { list: 'today', day: tomorrow, now });
    else if (choice === 'later') s = moveTask(s, id, { list: 'later', now });
    else if (choice === 'drop') s = moveTask(s, id, { list: 'dropped', now });
  }
  return s;
}

export function closeDay(state, key, { decisions = {}, note = '', now = Date.now() } = {}) {
  const s = resolveTasks(state, decisions, { baseKey: key, now });
  return setDay(s, key, { closedAt: now, ...(note && note.trim() ? { note: note.trim().slice(0, 280) } : {}) });
}

// ---------------------------------------------------------------------------
// "Make it smaller": local fallback steps, and the prompt for Claude.
// ---------------------------------------------------------------------------

const STEP_RULES = [
  [/\b(write|draft|essay|report|post|update|blog|article|proposal|letter|thesis|paper|newsletter)\b/i,
    ['Open a blank doc and give it a title', 'List the 3 things it has to say', 'Write one rough sentence for the first point', 'Keep going for 10 minutes, messy is fine', 'Read it once and fix only the worst bit']],
  [/\b(email|emails|reply|respond|message|text|dm|slack|inbox)\b/i,
    ['Open the message', 'Write the one-line answer first', 'Add only what they need to act on it', 'Send it']],
  [/\b(call|phone|ring|book|appointment|dentist|doctor|vet)\b/i,
    ['Find the number or the booking page', 'Write down the one thing you need to ask', 'Make the call or open the form', 'Write down the date or outcome']],
  [/\b(clean|tidy|wash|laundry|dishes|kitchen|room|vacuum|declutter)\b/i,
    ['Set a 10-minute timer', 'Put one thing away', 'Clear one surface completely', 'Move to the next most visible spot', 'Stop when the timer ends']],
  [/\b(study|learn|read|chapter|revise|notes|course|lecture|exam|homework)\b/i,
    ['Open the material to the right page', 'Skim just the headings', 'Read one section', 'Write 3 bullet points from memory', 'Mark where you stopped']],
  [/\b(fix|bug|debug|code|implement|refactor|build|deploy|pr|test|feature)\b/i,
    ['Open the project and the relevant file', 'Reproduce the problem once', 'Write down expected versus actual', 'Try the smallest change that could work', 'Run it again and note what changed']],
  [/\b(pay|bill|bills|invoice|tax|taxes|budget|bank|expense|expenses|refund)\b/i,
    ['Open the account or the bill', 'Check the amount and the due date', 'Pay it or schedule the payment', 'Save the confirmation']],
  [/\b(plan|organize|organise|prepare|prep|slides|deck|presentation|meeting|agenda|offsite)\b/i,
    ['Open a blank page or slide', 'Write the goal in one sentence', 'List the 3 main parts', 'Rough out the first part', 'Note what is still missing']],
  [/\b(buy|shop|shopping|groceries|grocery|order|errand|errands|pick up)\b/i,
    ['Write the list on your phone', 'Grab keys, bag and wallet', 'Go to the first stop', 'Check the list before you leave']],
  [/\b(apply|application|job|resume|cv|form|forms|paperwork|renew|passport|visa)\b/i,
    ['Open the form or website', 'Gather the documents it asks for', 'Fill in the easy fields first', 'Do one hard field', 'Save or submit it']],
];

const GENERIC_STEPS = ['Get what you need in front of you', 'Do the smallest visible piece, 2 minutes', 'Decide the next step', 'Work on it for 10 minutes', 'Write down where you stopped'];

export function localSteps(title) {
  const rule = STEP_RULES.find(([re]) => re.test(String(title || '')));
  return (rule ? rule[1] : GENERIC_STEPS).slice();
}

export function stepsPrompt(task) {
  return [
    'You help people who feel stuck get started on a task. Break the task below into 3 to 6 small, concrete steps.',
    'Rules:',
    '- The first step takes under 2 minutes and is almost impossible to fail, for example "Open the document".',
    '- Each step is one short instruction of at most 10 words that starts with a verb.',
    '- Use plain, friendly language. No numbering, no emoji, no commentary.',
    '- Make the steps specific to this task.',
    '',
    `Task: ${JSON.stringify(String(task.title || ''))}`,
    `Their time guess: ${task.est} minutes`,
    '',
    'Reply with only JSON in this shape: {"steps": ["first step", "second step"]}',
  ].join('\n');
}

export function parseStepsReply(value) {
  const arr = Array.isArray(value) ? value : value && Array.isArray(value.steps) ? value.steps : null;
  if (!arr) return null;
  const steps = arr
    .map((s) => (typeof s === 'string' ? s : s && typeof s.text === 'string' ? s.text : ''))
    .map((s) => s.replace(/^\s*(?:[-*•]|\d+[.)])\s*/, '').trim())
    .filter(Boolean)
    .map((s) => s.slice(0, 120))
    .slice(0, 6);
  return steps.length >= 2 ? steps : null;
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

export function fmtMin(min) {
  const m = Math.max(0, Math.round(min));
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  const r = m % 60;
  return r ? `${h}h ${r}m` : `${h}h`;
}

export function fmtTimer(ms) {
  const s = Math.max(0, Math.floor(ms / 1000));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  return h ? `${h}:${pad2(m)}:${pad2(s % 60)}` : `${pad2(m)}:${pad2(s % 60)}`;
}

export function fmtMult(x) {
  return `×${(Math.round(x * 10) / 10).toFixed(1)}`;
}

// ---------------------------------------------------------------------------
// Sample data: a realistic three weeks so a first-time visitor sees the
// product working. Deterministic (seeded), never saved as the user's data.
// ---------------------------------------------------------------------------

export function mulberry32(seed) {
  let a = seed >>> 0;
  return function next() {
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function gauss(rng) {
  let u = 0;
  let v = 0;
  while (u === 0) u = rng();
  while (v === 0) v = rng();
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v);
}

const SAMPLE_HABITS = [
  { title: 'Reply to client emails', est: 15, tag: 'email', bias: 2.1 },
  { title: 'Clear the inbox', est: 20, tag: 'email', bias: 2.3 },
  { title: 'Write the weekly update', est: 45, tag: 'writing', bias: 1.4 },
  { title: 'Draft the blog post intro', est: 30, tag: 'writing', bias: 1.5 },
  { title: 'Fix the login bug', est: 60, tag: 'code', bias: 1.8 },
  { title: 'Review a pull request', est: 20, tag: 'code', bias: 1.6 },
  { title: 'Pay the bills', est: 10, tag: 'admin', bias: 1.9 },
  { title: 'Book an appointment', est: 5, tag: 'admin', bias: 2.4 },
  { title: 'Grocery run', est: 30, tag: 'errands', bias: 1.3 },
  { title: 'Prep slides', est: 90, tag: 'writing', bias: 1.35 },
  { title: 'Study one chapter', est: 60, tag: 'study', bias: 1.5 },
  { title: 'Clean the kitchen', est: 20, tag: 'home', bias: 1.25 },
];

export function buildSampleState(now = Date.now(), seed = 7) {
  const rng = mulberry32(seed);
  const state = emptyState(now);
  state.onboarded = true;
  state.prefs.stopAt = null;
  const startHour = state.prefs.dayStartHour;
  const today = dayKey(now, startHour);
  let n = 0;
  const id = () => `sample-${++n}`;

  for (let d = 20; d >= 1; d--) {
    const key = addDays(today, -d);
    let t = dayStartMs(key, startHour) + 5 * 3600000;
    const count = 2 + Math.floor(rng() * 4);
    const done = [];
    for (let k = 0; k < count; k++) {
      const habit = SAMPLE_HABITS[Math.floor(rng() * SAMPLE_HABITS.length)];
      const improving = 1 - (20 - d) * 0.006;
      const ratio = clamp(Math.exp(Math.log(habit.bias * improving) + gauss(rng) * 0.28), 0.6, 4.5);
      const actual = Math.max(2, Math.round(habit.est * ratio));
      t = Math.min(t + actual * 60000 + Math.round(rng() * 40) * 60000, dayStartMs(key, startHour) + 19 * 3600000);
      const taskId = id();
      state.history.push({ i: taskId, t, e: habit.est, a: actual, g: habit.tag });
      done.push({ id: taskId, title: habit.title, est: habit.est, tag: habit.tag, list: 'done', doneAt: t, actual, created: t - actual * 60000, order: k });
    }
    if (d <= 6) state.tasks.push(...done.map(normalizeTask));
    state.days[key] = { energy: ['low', 'ok', 'good'][Math.floor(rng() * 3)], closedAt: t + 3600000 };
  }

  const dayOpen = dayStartMs(today, startHour);
  const earlier = (minutes) => Math.max(dayOpen + 60000, now - minutes * 60000);
  state.tasks.push(
    normalizeTask({ id: id(), title: 'Standup notes', est: 10, tag: 'work', list: 'done', doneAt: earlier(95), actual: 15, created: earlier(120), order: 0 }),
    normalizeTask({ id: id(), title: 'Pay the electricity bill', est: 10, tag: 'admin', list: 'done', doneAt: earlier(50), actual: 20, created: earlier(120), order: 1 })
  );
  state.history.push({ i: `sample-${n - 1}`, t: earlier(95), e: 10, a: 15, g: 'work' }, { i: `sample-${n}`, t: earlier(50), e: 10, a: 20, g: 'admin' });

  const plan = [
    { title: 'Reply to Sam about the contract', est: 10, tag: 'email' },
    { title: 'Write the project update for Friday', est: 45, tag: 'writing' },
    { title: 'Book the dentist', est: 5, tag: 'admin' },
    { title: 'Fix the checkout bug', est: 60, tag: 'code' },
    { title: 'Prep slides for Monday', est: 90, tag: 'writing' },
    { title: 'Grocery run', est: 30, tag: 'errands' },
  ];
  plan.forEach((p, i) => state.tasks.push(normalizeTask({ id: id(), ...p, list: 'today', day: today, order: i, created: earlier(130) })));
  [
    { title: 'Plan the team offsite', est: 120, tag: 'work' },
    { title: 'Renew passport', est: 30, tag: 'admin' },
    { title: 'Call grandma', est: 20, tag: 'home' },
  ].forEach((p, i) => state.tasks.push(normalizeTask({ id: id(), ...p, list: 'later', order: i, created: earlier(600) })));
  state.days[today] = { energy: 'ok' };
  state.updatedAt = now;
  return state;
}
