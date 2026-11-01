# Leeway launch kit

Everything needed to launch, written and ready. Post from a real person's account, reply to every comment within the first two hours, and never post the same text in two places.

## Positioning

- **Name:** Leeway
- **Tagline:** Plan the day you actually have.
- **One-liner:** Leeway learns how long things actually take you, then shows what really fits today.
- **The hook:** your *reality multiplier*. "My 30 minutes is really 45. What is yours?"
- **Proof point:** Sunsama's request to compare planned vs. actual time has had 404 votes since 2020. Leeway is that feature, done properly, for free.
- **Never say:** "AI-powered productivity", "10x", "hustle", "never miss a deadline". The audience has heard it all and is tired.

## Channel rules (read before posting)

| Channel | Rule | Plan |
|---|---|---|
| r/ADHD | Strict self-promotion rules; posts that advertise get removed | Do not post the app. Answer existing "time blindness" and "to-do list paralysis" threads with the method (track guesses vs. actual, multiply), and mention the tool only if asked. Earn it |
| r/productivity | Self-promotion is limited to the designated weekly thread | Post in the weekly thread with the text below |
| r/SideProject, r/InternetIsBeautiful | Show-and-tell is welcome | Post with the share card image |
| r/ADHD_Programmers | Tool discussions are common; follow the rules sidebar | Lead with the model (log-space ratios, prior, backtest) |
| Hacker News | Show HN must be something people can try, without signup walls | Show HN, Tuesday to Thursday, 8 to 10am US Eastern |
| Product Hunt | Launch day 12:01am Pacific; a gallery of 3 to 5 images | Gallery: the gauge, the load line, Your pace, the share card, focus mode |

## Show HN

**Title:** Show HN: Leeway, a planner that learns how long your tasks really take

**Text:**

> I kept planning 8 hours of work into 5 hours of day, falling behind by noon, and feeling like a failure by 6. It turns out this is one of the most replicated findings in psychology: in Buehler et al. (1994), students predicted their thesis would take 34 days, and it took 56.
>
> The known fix is "reference class forecasting": correct your estimate with how long similar things actually took. Every planner I tried trusts my guesses instead. Sunsama's warning adds up my own estimates, and its "compare planned vs actual" request has 404 votes since 2020.
>
> Leeway does the obvious thing. Every task you finish gives a ratio of actual to guess. It averages those in log space, weighted toward recent weeks, starting from a ×1.5 research prior worth 3 tasks so day one is not noise. It learns per tag (#email ×2.1 for me) and per size (5-minute tasks are never 5 minutes). Then it lays today's tasks end to end in *real* time and draws a line where your day actually ends. The "Your pace" page backtests itself: each past task is predicted using only earlier tasks, so the "26% closer to reality" number is honest.
>
> No signup. It opens on an example day so you can see it working. Data stays in your browser (or your private Claude storage if you open it there). It is one HTML file with no dependencies; the core is pure functions with tests.
>
> I would love feedback on the model, especially the prior strength and the half-life.

## r/productivity (weekly self-promotion thread)

> **I built a planner that tells you what actually fits in your day, using your own track record**
>
> My to-do lists were always 50% too long, so I spent every afternoon feeling behind. Leeway learns how much longer things take *you* than you guess (mine is ×1.6, and my "30 minutes" is really 45), then draws a line under the tasks that truly fit today.
>
> - Tell it your energy (low, okay, good) and it sizes the day
> - Type "Email Sam 10m" and it shows the real time
> - One-tap "move the rest to tomorrow", with no red overdue badges, ever
> - "Make it smaller" breaks a stuck task into tiny steps
>
> Free, no signup, opens on an example day. Would love to hear what your multiplier turns out to be.

## r/SideProject / r/InternetIsBeautiful

> **Leeway: your to-do list, in honest hours**
>
> Everyone underestimates how long things take, by about 60% on average. Leeway learns your personal multiplier from the tasks you finish and plans your day with it. No account, works offline, data stays on your device. [share card image]

## Product Hunt

- **Name:** Leeway
- **Tagline (60 chars):** A planner that learns how long your tasks really take
- **Description:** Most of us underestimate how long things take by about half, so our days never fit. Leeway learns your real pace from the tasks you finish, then shows what truly fits today, with a line where your day runs out. Energy check-ins, a calm focus mode, AI "make it smaller" for stuck tasks, and no guilt: leftovers roll to tomorrow with one tap. Free, private, no signup.
- **First comment (maker):** the Show HN story above, shortened, ending with "What is your multiplier?"
- **Gallery:** 1. the gauge with the line; 2. focus mode; 3. Your pace; 4. the share card; 5. close the day.

## X / Bluesky / Threads

1. You don't have a discipline problem. You have a planning fallacy problem. Your "30 minutes" is really 45, and you plan 8 of them into a day that has 5.
2. 1994: students said their thesis would take 34 days. It took 56. Only 30% finished on time. This is one of the most replicated results in psychology, and every planner app ignores it.
3. So I built Leeway. Every task you finish teaches it your real pace. Then it draws a line where your day *actually* ends. [gauge image]
4. Low energy today? Tap it. The day shrinks to fit. Didn't finish? One tap, tomorrow. No red. No streaks. No guilt.
5. It's free, no signup, opens on an example day. Mine says ×1.6. What's yours? [link] [share card]

## Launch email (to friends, beta list)

> **Subject:** I built the planner I needed
>
> Hi,
>
> For years I've planned days that couldn't fit, then blamed myself at 4pm. I finally built the fix: Leeway learns how long things *actually* take you and plans your day with that, not your optimism.
>
> It's free and takes 10 seconds to try: [link]
>
> Two favors: use it for 3 days, then tell me your multiplier and one thing that annoyed you. That's the whole feedback form.

## Four-week plan

| Week | Do | Measure |
|---|---|---|
| 0 | 20 hand-picked testers (ADHD friends, students, freelancers). Watch 5 of them use it live. Fix the top 3 confusions | Activation (3 timed tasks in 2 days) |
| 1 | Show HN; r/SideProject; r/productivity weekly thread; personal X thread | Visitors to activation rate; top objection |
| 2 | Product Hunt; answer 10 genuine time-blindness questions on Reddit with the method | Share-card saves per activated user |
| 3 | Ship the most-requested fix (likely calendar import); write "What 1,000 people's multipliers taught us" (aggregate only if users opt in) | D7 retention |
| 4 | Decide: double down, change the hook, or stop | See kill criteria |

## Kill criteria (decided in advance)

- Activation below 20% of visitors who start their own day: the first-run experience is wrong. Fix it before marketing more.
- D30 below 10% of activated users: people like the idea but not the habit. Interview churned users before building anything new.
- Share rate below 2%: the multiplier is not the hook. Test "what fits today" as the lead message instead.
