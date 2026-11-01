# Market research: why Leeway

*November 2026. Method: web search across Reddit (r/productivity, r/ADHD, r/ADHD_Programmers, r/getdisciplined, r/selfimprovement, r/Notion, r/todoist, r/nosurf), competitor documentation, public roadmaps, app store data and the research literature. Reddit blocks automated access to reddit.com, so threads were read through public snapshot mirrors. Quotes are verbatim; scores are as captured.*

## 1. What people are struggling with

Eight recurring pain clusters. The first five are tightly linked: they are the same failure seen from different sides.

| # | Pain | What it sounds like |
|---|------|---------------------|
| 1 | **Plans that cannot fit** | "The moment I started planning 8+ things, I'd avoid all of them." (r/selfimprovement) |
| 2 | **Time blindness / underestimation** | "ADHD itself causes inaccurate time estimation." (Ari Tuckman, Psy.D., ADDitude) |
| 3 | **Capacity changes day to day** | "pretending my capacity is the same every day ... When I plan as if every day should look the same, I freeze or avoid everything." (r/ADHD) |
| 4 | **The list becomes a source of guilt** | "When I see 20 tasks, my brain treats them like 20 lions attacking me at once." / "Does anyone else have a 'To-Do List Grave'?" (r/ADHD) |
| 5 | **Paralysis: can't start** | "So much to do that I'm paralyzed" (r/ADHD, 58 points). Top answer: "Try picking literally the smallest task on your list and just do that one thing" (21 points) |
| 6 | App-hopping and system tinkering | "Why does every productivity app make me less productive?" (r/productivity, Aug 2025). People report spending more time tweaking Notion than working |
| 7 | Streak anxiety | Habit apps that reset to zero after one missed day make people quit the habit, not just the app |
| 8 | Lonely focus | "what I need in a body-double would be to just be present ... check in on me occasionally ... I'm really not comfortable talking to strangers in any other way than just text" (r/ADHD_Programmers) |

**The shared root cause of 1 to 5:** people plan with guesses that are systematically too optimistic, against a fixed capacity that isn't fixed. The plan fails by early afternoon, the failure lands as guilt, and guilt produces avoidance. Planning harder makes it worse.

## 2. The science says this is predictable, and fixable

- **The planning fallacy is large and universal.** Students estimated their thesis would take 33.9 days; it took 55.5. Only about 30% finished by their own estimate ([Buehler, Griffin & Ross 1994](https://bear.warrington.ufl.edu/brenner/mar7588/Papers/buehler-et-al-1994.pdf); [summary](https://en.wikipedia.org/wiki/Planning_fallacy)). That is a ×1.64 multiplier.
- **It is worse with ADHD.** "Chances are that you often underestimate more than overestimate how much time you need" ([ADDitude](https://www.additudemag.com/time-estimation-planning-fallacy-adhd/)). About 15.5 million US adults (6.0%) have a current ADHD diagnosis ([CDC data via CHADD](https://chadd.org/about-adhd/general-prevalence-adults/)).
- **The proven cure is the "outside view".** Reference class forecasting means correcting a forecast with the actual outcomes of similar past work. It is the standard debiasing method from Kahneman and Tversky's work, used for megaprojects ([Flyvbjerg](https://arxiv.org/pdf/1302.3642)). For a single person, the best reference class is their own history. Nobody applies it automatically to a personal day plan.

## 3. Demand signals

- **Sunsama's own customers have been asking for five years.** "Compare actual time vs planned time": **404 votes**, open since September 2020. "I can't use the aggregate data to better understand how off I am." "It would eliminate such a huge source of stress in my life." ([roadmap](https://roadmap.sunsama.com/improvements/p/compare-actual-time-vs-planned-time)). Per-task tracking shipped in 2020 ([88 votes](https://roadmap.sunsama.com/improvements/p/track-actual-time-separately-from-estimated-time)); the learning loop never did. A 2025 request asks to "automatically calculate if there is enough time in the day" ([roadmap](https://roadmap.sunsama.com/improvements/p/total-time-available-for-work)).
- **Overdue anxiety at scale.** Todoist has reported that roughly 70% of its active users carry at least one overdue task, and its CEO called long overdue lists a source of anxiety (reported by [Fast Company](https://www.fastcompany.com/3065714/todoists-ai-task-scheduler-could-help-you-procrastinate-less); the page refused automated access, so this is from secondary summaries).
- **People pay for planners that respect them.** Tiimo: 50,000+ paying subscribers and 500,000 free users by August 2024, $4.8M raised ([tech.eu](https://tech.eu/2024/08/28/neurodivergent-focused-app-tiimo-secures-16m-in-funding-round/)). Structured: 4.8 stars from about 165,000 App Store ratings ([review](https://habitbox.app/blog/structured-app-review)).
- **Zero-friction tools spread by word of mouth.** Goblin Tools (free AI task breakdown, no account) went viral in ADHD communities; searches for "goblin tools" grew 4,900% ([Exploding Topics](https://www.explodingtopics.com/topic/goblin-tools-8mxg3Jo8)).
- **Market.** Productivity apps were estimated at $12.0B in 2025, growing to $18.1B by 2030 ([Research and Markets](https://www.researchandmarkets.com/reports/6260384/productivity-apps-market-share-analysis)).

## 4. Competitive landscape

| Product | Price | Learns your real pace? | Shows what fits today? | Guilt-free leftovers? | Signup? |
|---|---|---|---|---|---|
| Sunsama | ~$16 to $25/mo, no free tier ([pricing](https://www.morgen.so/blog-posts/sunsama-pricing)) | No. Warns using your own guesses ([docs](https://help.sunsama.com/docs/daily-planning)) | Yes (by guesses) | Manual rollover | Yes |
| Motion | $49/mo solo month-to-month ([review](https://www.usecarly.com/blog/motion-ai-review/)) | No. Auto-reschedules; users complain the plan "keeps reshuffling itself" | Yes | Auto-moves | Yes |
| Amazing Marvin | ~$8 to $12/mo | Partly. Capacity estimator plus estimate tracking, buried among 100+ "strategies" ([features](https://amazingmarvin.com/features/time-estimates)) | Yes | Configurable | Yes |
| Tiimo | Freemium | No. AI suggests *generic* durations ([AI planning](https://www.tiimoapp.com/product/ai-planning)) | Visual timeline | Yes | Yes |
| Llama Life | Freemium | No. Shows finish time from guesses ([review](https://makerstack.co/reviews/llama-life-review/)) | Partly | n/a | Yes |
| Goblin Tools | Free | No. Breakdown only, no planning | No | n/a | No |
| TODO Better, TimeBoxer | Small | Yes, emerging ([TODO Better](https://www.todobetter.it.com/about), [TimeBoxer](https://apps.apple.com/lc/app/timeboxer-time-estimator/id6720741072)) | Partly | Unknown | Yes |
| Plimsoll (iOS) | Freemium, 4 ratings | Unknown. "Respects your mental capacity", no red badges ([listing](https://appshunter.io/ios/app/plimsoll-burnout-and-focus/id6751366557)) | Yes | Yes | iOS only |
| **Leeway** | **Free core** | **Yes, per person, per tag, per size, with an honest backtest** | **Yes, by real time and energy** | **Yes, by design** | **No** |

**Reading the map.** The incumbents trust guesses. The newcomers (TODO Better, TimeBoxer, Plimsoll) prove the direction but are small, platform-locked or unfocused. Nobody combines the learned multiplier, energy-adjusted capacity, guilt-free rollover and zero signup in one calm loop.

## 5. Opportunity scoring

Scored 1 to 5. Feasibility means "can a tiny team ship a credible v1 now".

| Opportunity | Pain | Breadth | Underserved | Willingness to pay | Feasibility | Hook | Total |
|---|---|---|---|---|---|---|---|
| **Plan vs. reality gap (Leeway)** | 5 | 5 | 4 | 4 | 5 | 5 | **28** |
| Task paralysis / AI breakdown | 5 | 3 | 2 | 2 | 5 | 3 | 20 |
| Distraction blocking | 4 | 5 | 2 | 3 | 2 | 2 | 18 |
| Body doubling without strangers | 4 | 2 | 3 | 3 | 3 | 3 | 18 |
| Forgiving habit tracker | 3 | 4 | 2 | 2 | 5 | 2 | 18 |

Paralysis help and gentle companionship are folded into Leeway as features (Make it smaller, focus check-ins) rather than built as separate products.

## 6. Decision

Build **Leeway**: a planner that learns your real pace and plans the day you actually have. Beachhead: overwhelmed knowledge workers and students, starting with adults with ADHD and time blindness, who are the most vocal, the most underserved and the quickest to share tools that work.

Design principles taken straight from the research:

1. **Honest about time** (the multiplier), **kind about failure** (no red, no streaks, "let it go" is a first-class action).
2. **Zero friction:** no signup, works in 10 seconds, shows an example day before asking for anything (the Goblin Tools lesson).
3. **Radically small:** one screen, one line, one task at a time (the app-hopping lesson).
4. **Private by default:** data stays with the person.
