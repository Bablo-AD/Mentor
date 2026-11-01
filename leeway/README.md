# Leeway

**Plan the day you actually have.**

Leeway is a daily planner that learns how long things *actually* take you, draws a line where your day really runs out, and lets the rest go without guilt.

- **Live app (claude.ai):** https://claude.ai/artifact/HBn5ifP4TA9DcjY8okY34g
- **Founder memo (research, decision, launch plan):** https://claude.ai/artifact/YP4xb4RkwM84bmgRPjN6Wv
- **Why we built it:** [docs/market-research.md](docs/market-research.md)
- **What it is:** [docs/product-spec.md](docs/product-spec.md)
- **How we launch it:** [docs/launch-kit.md](docs/launch-kit.md)

## The problem

Everyone underestimates how long tasks take. In the classic study, students predicted their thesis would take 34 days; it took 56 ([Buehler, Griffin & Ross, 1994](https://en.wikipedia.org/wiki/Planning_fallacy)). So we plan days that cannot fit, we fall behind by lunch, the list turns red, we feel like failures, and we stop opening the app.

Every planner on the market trusts your guesses. Sunsama's workload warning adds up *your own estimates*. A request on Sunsama's public roadmap to compare planned vs. actual time has **404 votes and has been open since 2020**. One user wrote: *"I can't use the aggregate data to better understand how off I am."*

## How Leeway works

1. **Check in.** Low, Okay or Good energy sets how much focus today really has.
2. **Jot down tasks with a rough guess.** `Email Sam 10m #email`. Paste a whole list and every line becomes a task.
3. **See the line.** Leeway converts each guess into real time using your personal multiplier and marks where your day ends. Everything below the line does not fit, and Leeway says so before 4pm does.
4. **Do one thing.** A calm focus mode with a timer, gentle check-ins, and **Make it smaller**: Claude (or offline rules) breaks a stuck task into tiny first steps.
5. **Close the day.** See what you did, then send each leftover to tomorrow, Later, or let it go. No red overdue badges and no streaks.

Every finished task teaches the model. **Your pace** shows your multiplier, what your guesses really mean ("your 30 minutes is really 45"), a trend line, per-tag and per-size breakdowns, an honest backtest of whether Leeway's corrections beat your raw guesses, and a shareable card.

### The model

Personal [reference class forecasting](https://arxiv.org/pdf/1302.3642), the standard fix for the planning fallacy, applied to one person's day:

- Each finished task gives a ratio `actual / guess`, clamped to [0.2, 5] so one runaway timer cannot wreck it.
- Ratios are averaged in log space, weighted toward recent weeks (half-life 21 days).
- New users start at the research prior (×1.5, worth 3 tasks) and move toward their own pace as evidence arrives.
- Tag-specific and size-specific multipliers (`#email` runs ×2.1, quick tasks run over the most) shrink toward your global pace and kick in after 3 samples.
- `backtest()` predicts each past task using only the tasks before it, so the accuracy claim on the Your pace page is honest.

All of it lives in [`src/core.js`](src/core.js) as pure functions with unit tests.

## Privacy

No account and no tracking. In claude.ai, data is saved to the viewer's own private storage (`data/users/<id>/`, which not even the artifact owner can read) and mirrored in the browser. Hosted anywhere else, it stays in the browser. Export and import are JSON.

## Develop

No dependencies. Node 20+.

```sh
npm test          # 37 unit tests for the planning core
npm run build     # dist/index.html (PWA) + dist/leeway.artifact.html (claude.ai)
npm run e2e       # build, then 8 Chromium scenarios with a controlled clock (needs Playwright)
```

- `src/core.js`: planning logic (pace model, the line, parsing, state transitions)
- `src/app.js`: UI, storage, focus mode, Claude features
- `src/styles.css`: design tokens and components, light and dark
- `scripts/build.mjs`: inlines everything into single-file pages
- `scripts/make-assets.cjs`: regenerates `public/` icons and the social image
- `test/`: unit tests and end-to-end tests

## Deploy

- **claude.ai artifact:** publish `dist/leeway.artifact.html` with capabilities `{db, user, sample, downloads}`.
- **GitHub Pages:** `.github/workflows/leeway.yml` runs the unit tests, the browser tests and the build on every push. To deploy `leeway/dist` from `master`, set Settings > Pages > Source to *GitHub Actions* and add the repository variable `LEEWAY_PAGES=true` (one time).
- **Anywhere static:** copy `dist/`. It is an installable, offline-capable PWA.

## License

GPL-3.0, same as the rest of this repository.
