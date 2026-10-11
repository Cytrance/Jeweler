# A one-minute market day

The timed-market milestone replaces unlimited encounters with one timed selling session per calendar day. The project manager tested and merged the combined sales, refunds, and timed-market branch into `main` at `4093d6d`. The next apartment milestone changes sourcing and travel; current steps below reflect that flow.

## The player’s day

Order stock at the apartment computer, sleep through midnight settlement, and collect the following morning’s delivery before travelling to YOUR STALL. See [apartment and deliveries](apartment-and-deliveries.md). Open the stall with **E**, then click **Start day** or press **S**. Visible customers arrive in a small queue, and the panel identifies the visitor you are serving. Choose a price with **P** and a claim with **C**, then serve with **N** or the button. The dropdown menus also work with the mouse.

Each accepted offer or overpriced rejection uses one visitor. Trying to sell with no stock leaves that visitor waiting. A brief arrival interval prevents a second transaction from using the same customer. Closing the panel lets you move, but does not pause the market. The countdown runs through sales and board menus; closing the panel does not pause it. Travel to the apartment is blocked during selling, so computer restocking is preparation for a later day. A persistent top-right market timer and served count remain visible outside the stall panel.

After **60 real seconds**, remaining visitors go home. A closing report shows served and unserved counts and the reputation penalty; a short fade advances the calendar clock to **18:00**. Serving everybody early does not finish early: the session still lasts its full minute. Continue the closing notice to explore or travel home to order tomorrow’s stock during the evening. You cannot reopen business on that same calendar day.

**Refunds settle at midnight, not at market closing.** Misleading income stays fully spendable through the evening. The existing midnight report pays affordable random refunds or sends an insolvent founder to prison. End day (**T**) remains an early-settlement shortcut outside an active market or closing transition; it cannot bypass the one-minute session. Restart still resets all progress.

## Attendance and reputation

The provisional daily quota is:

```text
clamp(12 + random integer from -2 to +2 + floor(reputation / 5), 3, 30)
```

Start day rolls the variation once and freezes the result. Reopening menus cannot reroll it. Reputation gained or lost during selling affects future days’ attendance, not today’s already determined visitors. At reputation 0, attendance is 10–14; at +40 it is 18–22. At -10 it is 8–12. The limits keep the prototype between 3 and 30 visitors.

A truthful sale at 15 credits earns **+2 reputation**; at 20 it earns **+1**. A truthful 30-credit offer is rejected. Misleading sales earn no immediate reputation; requested refunds still cost **5 reputation each** at settlement. At the market deadline, the penalty is **ceil(unserved / 5)**: missing 1–5 visitors loses one point, missing 6–10 loses two.

“Truthful” describes the actual imitation ring: plated brass and a simulated stone. It does not turn starter stock into genuine gold. Higher material quality and more varied customer preferences remain later work. These prices, quota values, timings, and penalties are development figures, not balanced economy rules.

## Two clocks, separate responsibilities

The **calendar clock** controls the day number, outdoor tint, and midnight settlement. The **service countdown** measures 60 real seconds of market operation. The calendar pauses during the active market and closing transition while the service countdown continues through menus. The deadline first displays a brief market-complete notice. At the following fade’s black midpoint, calendar time jumps to 18:00. After continuing the notice, the calendar resumes; ordinary interaction pauses remain in effect outside the market.

`scripts/market_session.gd` owns this finite session: quota, current visitor, countdown, closing transition, and once-per-day gate. `serve_offer()` verifies a ready visitor before requesting the existing business transaction. `scripts/business_state.gd` still owns cash, stock, revenue, reputation changes from transactions, and refunds; customer sprites and panels do not own separate balances.

The session uses a few explicit phases: ready, active, closing, and finished for this calendar day. Its deadline closes whichever interaction is open, then owns the player’s movement lock until Continue. `scripts/sales_counter.gd` displays choices and requests session operations; `scripts/customer_visuals.gd` and the reusable customer scene display arrivals and departures. World actors use uniformly scaled, bottom-aligned full-body atlas regions; the panel uses separate head crops for a readable portrait. Nested Y sorting lets each visitor’s ground position participate in drawing order, rather than forcing the whole queue behind the founder because it belongs to the stall. These short visual movements do not implement obstacle navigation or a town NPC simulation.

Central economy settings in `resources/prototype_economy.tres` and `scripts/economy_config.gd` keep the attendance formula, duration, and reputation gains together. A separate random generator for traffic means tests can reproduce attendance without changing refund randomness. Midnight increments the calendar day, clearing the session gate for the next morning. Starting a market is allowed only before 18:00.

## Try it on Windows

1. Close Godot, fetch, select **`feat/apartment-deliveries`** for this milestone (or merged `main` afterward), and pull. Open the project in Godot 4.7.2 and press F5.
2. Order several rings at the apartment computer, sleep, continue midnight’s report, and receive the morning delivery. Travel to the plaza, then open YOUR STALL with E. Before Start day, N must not sell anything.
3. Start day with the button or S. Check the fixed quota, one-minute countdown, visible visitors, and named panel portrait. Holding S cannot restart or reroll today.
4. Sell truthfully at 15: cash rises by 15, stock falls by one, and reputation rises by two. Try 20 for +1 reputation. Reject a truthful 30-credit offer: the visitor is served, but cash and stock stay unchanged.
5. Close the stall, open the board, and watch the service countdown continue. Try the plaza exit: travel must be blocked during the market. Try T during the active session: it must not settle or skip closing.
6. Let the minute expire with visitors left. Expect one reputation penalty, visitors departing, a fade, 18:00, and the closing report. Movement and transactions must not reopen underneath that report.
7. Continue, travel home, and order stock for tomorrow. Return to YOUR STALL: another Start day is unavailable. Midnight should settle refunds once, separately from the market report.
8. On a fresh run, serve everyone before the deadline if your stock permits. The countdown must continue until its minute ends, with zero unserved penalty.
9. Check portraits, sprites, controls, text fit, and queue layering at normal game size. These visual and usability checks matter alongside automated results.

## Verification and limits

The coding agent completed Godot 4.7.2 import and reported **43 market-session checks, 32 affected sales checks, and 37 affected day/refund checks passed**. Sales gained a new timed-session caller and different cheap-sale reputation; clock/controller changes justified day/refund checks. Existing purchase evidence was reused because purchase rules remain unchanged, with the new session test checking purchases during selling and the evening. A final customer-visuals guard was checked against the existing isolated collision fixture: its four relevant checks passed without script errors when no market-session node is present. Unrelated animation, scenery, and historical artwork suites were not repeated.

The reviewer independently inspected the final session, sales interaction, clock/report integration, customer framing, and focused test, then ran only `verify_market_session.gd`: **43 passed, zero failures, exit code 0**. It covers reputation/attendance bounds, seeded variation, real Start/Serve mouse and keyboard input, quota snapshots, non-echo and duplicate guards, missing-stock and price-rejection behavior, cheap truthful reputation, misleading proceeds, menu-independent countdown, supplier/board/dropdown expiry, exact-once unserved penalties, full-minute behavior after everybody is served, large transition frames, 18:00 closing without refunds, spendable evening cash, midnight settlement, and next-day eligibility.

From the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_market_session.gd
```

The coordinating agent rendered the actual game with Godot 4.7.2’s Compatibility renderer at **960 × 540**. The reviewer inspected active-selling and closing captures. Head portraits and three full-body queued visitors are readable; nested Y sorting fixes the initial visitor’s head being hidden behind the founder. Price/claim controls and both countdown displays fit. The controlled 20-visitor preview serves one truthful 15-credit offer, then closes: **cash 115, stock 19, revenue 15, reputation +38**, with **19 unserved and -4 reputation**, agree with its initial +40 reputation and extra +2 truthful-sale gain. The report clearly shows **18:00** and refunds still pending until midnight. The 20-visitor setup and advanced timer were preview fixtures; gameplay remains a real 60-second session with configured attendance randomness.

The coordinating agent also inspected the resumed 18:00 evening view and the separate midnight financial report. The evening has no remaining queue or market modal, and cash stays at 115; the financial report appears only at midnight. A six-second recording of the rendered closing transition was captured, with active and closing frames inspected.

These captures verify rendered layout and selected outcomes, not Windows usability or balance. Suggested Windows steps above remain the project manager’s separate playtest.

There is one ring product and four recurring customer appearances. Visitor preferences still share the prototype price thresholds. Queued customers are visual actors rather than solid navigable NPCs. This original market checkpoint included no save/load, final balance, genuine-material supply tier, indoor lighting, or dynamic lamp lights. The apartment milestone subsequently adds its own indoor canvas rules.

The combined market pull request was squash-merged as `4093d6d`. Squash and merge includes all branch changes in one `main` checkpoint; it does not select only the latest commit.
