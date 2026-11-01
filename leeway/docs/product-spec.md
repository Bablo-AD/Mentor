# Leeway product spec (v0.1)

## One line

A daily planner that learns how long things actually take you, shows what really fits today, and lets the rest go without guilt.

## Who it is for

**Beachhead:** knowledge workers and students who chronically overplan, especially adults with ADHD or time blindness. They have tried Todoist, Notion or paper and abandoned them, and they find Sunsama or Motion too expensive or too heavy.

**Job to be done:** "When I plan my day, help me commit to an amount I can actually finish, so I end the day feeling capable instead of behind."

## The core loop

| Step | What the person does | What Leeway does |
|---|---|---|
| Check in | Taps Low, Okay or Good energy | Sets today's focus capacity (50%, 75% or 100% of a good day, adjustable ±15m) and caps it at the stop time |
| Plan | Types `Email Sam 10m #email`, or pastes a list | Parses guess and tag, converts each guess into real time with the person's multiplier, draws the line |
| Decide | Reorders, or moves below-the-line tasks to tomorrow in one tap | Shows the finish time for everything above the line |
| Do | Starts one task | Focus mode: timer, guess and usual markers, gentle check-ins, optional chime, wake lock, "Make it smaller" |
| Finish | Taps Done | Logs actual time; if no timer ran, asks once with one-tap answers. Undo is always available |
| Close | Closes the day | Summary, honest guess-vs-reality line, leftovers sent to Tomorrow, Later or Let go, optional one-line note |
| Learn | Nothing | Updates the multiplier and per-tag and per-size multipliers |

## Features in v0.1

- Example day on first visit (memory only, never saved), then a two-question setup.
- Today: energy check-in, the gauge (tasks laid end to end in real time, orange load line, hour axis, hover details), the list cut by the load line with a water-tinted below-the-line zone, Done today, Close the day.
- Leftovers from unclosed days: "That is normal." Bring them to today, or choose for each. Nothing ever turns red.
- Later: Someday list, Coming up (scheduled for future days), Let go (restorable).
- Focus mode: one task, big timer, guess and usual markers, companion line, tiny steps checklist, pause, stop for now, done.
- Make it smaller: Claude via the page's `sample` capability (quick tier, JSON reply, consent-gated), falling back to offline rule-based steps.
- Your pace: multiplier hero, translation table, backtested accuracy, trend sparkline with crosshair, per-tag and per-size bars, totals, share card (1080×1350 PNG) and share text.
- Preferences: good-day focus, stop time, day start hour (late nights count toward yesterday), check-ins, chime, Claude on or off, export, import, erase.
- Storage: browser always; in claude.ai, the viewer's private per-user document, last writer wins by `updatedAt`.
- Accessibility: Atkinson Hyperlegible type (designed for low-vision readers), WCAG AA contrast in both themes, validated colorblind-safe chart colors, keyboard shortcuts (`n` to add, `Space` to pause or resume in focus, `Esc` to close), visible focus, reduced motion respected.

## Not in v0.1, on purpose

Calendar sync, recurring tasks, reminders and push notifications, collaboration, native apps, integrations. Each adds setup, and setup is what kills productivity apps. Calendar import is the first candidate for v0.2 because meetings are the biggest hidden drain on capacity.

## Success metrics

- **North star:** *honest days per active user per week*, meaning days where the plan fit (real time at or under capacity at the moment the person started work) and at least one task was finished.
- **Activation:** 3 tasks finished with a logged time within the first 2 days (the model needs data, and the person needs to see "×1.4" become *theirs*).
- **Retention:** D7 and D30 of activated users. Target D30 of 25% or more.
- **Quality:** median backtest improvement (Leeway's corrected times versus raw guesses). Target 25% or more after 20 tasks. The example data shows 26%.
- **Virality:** share-card saves and copies per activated user.

## Business model hypothesis

- **Free forever:** the full core loop, local and private. Free is the distribution strategy.
- **Leeway Plus, $4/month or $36/year:** calendar-aware capacity, multi-device sync outside claude.ai, AI weekly review ("your email tasks ran ×2.1, try batching them"), history beyond 45 days, themes. Priced below Sunsama ($16 to $25) and Motion ($49), in line with what Tiimo and Structured users already pay.
- **Later, B2B:** ADHD coaches and neuro-inclusive workplaces, through a coach view of anonymized pace trends shared by the client.

## Risks

| Risk | Mitigation |
|---|---|
| People forget timers, so no data | One-tap "how long did it take?" with sensible options; fix-time afterwards; tasks without data are simply not counted |
| Early multipliers are noisy | Research prior worth 3 tasks, clamped ratios, log-space averaging, group multipliers only after 3 samples |
| "Another planner" fatigue | No setup, example day first, one screen, nothing to configure |
| Crowded ADHD app market | A measurable, personal, shareable number nobody else gives you |
| Guilt creeps back in | No red, no streaks, "Let it go" as a first-class action, kind copy everywhere |
