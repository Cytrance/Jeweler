# Market time and uncertain refunds

This revision follows the tested customer-sales commit on **`feat/customer-sales`**. The project manager asked for uncertain complaints, fully spendable proceeds, a consequence for unpaid refunds, and a repeating day/night cycle before merging. It supersedes the first sales commit's guaranteed-refund and reserved-cash rule.

## What changes in the business

A misleading sale adds its full price to cash immediately, exactly like a truthful sale. The supplier can spend all current cash. The state also records that misleading sale's price until day end, without deciding yet whether its customer complains.

At midnight settlement (or permitted manual End day), one probability is drawn uniformly between **10% and 25%**. Each recorded misleading sale independently rolls against that probability. Truthful sales have no chance of this complaint. The range is a probability, not a forced fraction: one misleading customer can yield zero or one refund, and a small sample can fall outside 10–25%.

The requested sale prices are added together before anything is paid. If cash covers the total, the entire batch settles: pay those prices, return one ring per refund, reverse the corresponding sales revenue, and lose **5 reputation per refund**. Uncomplaining customers keep their rings. If the total exceeds current cash, the founder goes to prison and this run ends. The game neither pays a partial batch nor makes cash negative.

For example, buy one ring for 10 from the initial 100 credits, then sell it misleadingly for 30. Cash is **120**, stock **0**, revenue **30**, reputation **0**. No complaint preserves those figures. A paid refund produces cash **90**, stock **1**, revenue **0**, reputation **-5**. Spending cash below 30 first risks prison if that refund is requested. Price and claim do not change the ring's actual plated-brass/simulated-stone composition.

Cash is money available now; revenue is sales minus refunds. Neither is the same as profit. Refunded stock returns to inventory; unsold stock is not automatically a realised loss.

## The clock and outdoor colour

A full 24-hour game day takes **eight real minutes**. Day 1 starts at **08:00**. Without the later timed-market interaction, its remaining sixteen hours take **five minutes twenty seconds**; the timed-market revision holds time during selling, then skips to 18:00. Following days begin at midnight. The top-right HUD shows the day and time.

Time pauses while the board, supplier, or sales interaction is open, while a day report is open, and permanently after imprisonment. Outside the timed market, this gives you time to read and choose. The newer [market-session revision](market-session.md) freezes the calendar clock during selling while its separate 60-second timer continues through all menus. Market closing advances to 18:00 and leaves complaints pending for midnight. Midnight ends the calendar day automatically. At YOUR STALL, the **End day button or T** closes the sales panel and performs the same settlement early, provided a market session or closing transition is not active. Continuing the report starts the next day; report dismissal cannot roll or pay again.

`CanvasModulate` supplies a smooth outdoor tint through dawn, daylight, sunset, and night. It multiplies the colours of the world canvas, much like applying ambient shading. The HUD and panels use separate `CanvasLayer`s so their text stays bright. This is not a simulation of shadows or new lamp lights. Existing lamp glow is baked into its artwork and is tinted with the world; local night illumination can be added as a separate asset/lighting milestone. Indoor lighting will need separate scene/canvas rules when interiors exist.

## Try it on Windows

1. Preserve local work, close Godot, fetch, select **`feat/customer-sales`**, and pull. This branch also contains the timed-market revision; use its [current playtest](market-session.md) for selling and closing. The steps below describe the preceding time/refund checkpoint.
2. Open the project in Godot 4.7.2 and press F5. Check initial cash **100**, stock **0**, and **Day 1, 08:00**.
3. Walk around: time advances. Open the board or supplier panel, wait briefly, and confirm time pauses. Close it and confirm time resumes.
4. Buy one ring, then sell truthfully for 20 at YOUR STALL. End the day with T or the button. Expect no refund, cash **110**, stock **0**, revenue **20**, reputation **+1**. Continue: the next day begins at midnight, with the same balances.
5. Let time run while walking or standing outside a panel. Look for smooth changes from day through dusk into night. The HUD should remain readable. At midnight, one report appears; waiting on that report must not generate extra reports or transactions.
6. On another run, buy and sell misleadingly. All proceeds are spendable at the supplier. End the day and read the count and total of actual refund requests. A single misleading sale may not produce any complaint; repeated runs are not proof of a particular quota.
7. To explore insolvency, spend the misleading proceeds on stock before closing. A requested total exceeding cash must show a prison outcome. Movement and transactions stop; **Start a fresh business** resets the run. Random play does not guarantee prison on any one attempt.
8. Check controls, panels, tints, and routes at normal game size. At the original checkpoint, stop/restart reset the run. With [save/continue](save-and-continue.md), Continue preserves values, eligible sales, financial reports, and prison; a confirmed New game deliberately resets the run.

## Follow the responsibilities

`scripts/business_state.gd` owns purchases, sales, eligible misleading-sale prices, and `settle_day(day_id)`. Its `last_settled_day` and cached report protect a settled day from a second random roll or payment. Its `day_closed` and `imprisoned` gates also reject purchases and sales in the state itself; hiding a button is not the rule’s only protection. Continuing calls `begin_day()` to reopen transactions. `refund_rng` is a `RandomNumberGenerator`: normal play randomizes it, while tests can set a seed for repeatable evidence. Probability bounds and the reputation penalty live in the economy resource configuration.

`scripts/market_clock.gd` owns elapsed time, day number, pause conditions, and outdoor tint. It converts real seconds to game hours and emits `day_ended` at closing. A large frame is clamped at that closing boundary, so it cannot skip through several days while their reports are unresolved. It contains no refund accounting.

`scripts/day_cycle.gd` and `scenes/day_cycle.tscn` connect the clock to the shared business state and display the report or prison outcome. The sales counter closes its own interaction before handing over to this report. Continuing starts the next day; imprisonment offers a fresh-run restart instead. Panels request operations and read the shared state, rather than carrying independent balances.

This split makes a rule change reviewable: changing complaint risk belongs to the economy/state, changing day length belongs to the clock, and changing report layout belongs to its scene. Focused verification follows those dependencies instead of rerunning every historical artwork or movement test.

## Verification and limits

The following evidence records the preceding day/refund commit (`c8fc1b5`), rather than proving the later timed-market revision. Current evidence is recorded in [market session](market-session.md).

The coding agent completed the Godot 4.7.2 import and reported **37 day/refund checks, 32 revised sales checks, and 25 purchase checks passed**. Shared business-state changes justify the sales and purchase dependency checks; unchanged artwork, animation, and historical suites were not rerun.

The reviewer inspected the actual state, clock, controller, interaction handoff, input, and scene integration, then independently ran only the new `verify_day_cycle.gd`: **37 passed, zero failures, exit code 0**. It covers zero/certain boundary probabilities, fixed-seed reproducibility, partial complaints under the configured range, exact sale-price refunds, exact-cash solvency, atomic insolvency, ring/revenue/reputation effects, closed/prison transaction guards, unchanged RNG state on repeated settlement, older-day protection, time conversion, interaction/report/prison pauses, a large frame, world tint, separate UI canvases, echoed T, actual mouse End day/Continue/restart controls, and movement-lock handoff. Boundary probabilities are test fixtures; normal play remains configured to 10–25%.

From the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_day_cycle.gd
```

The coordinating agent rendered the actual game using Godot 4.7.2’s Compatibility renderer at **960 × 540**. The reviewer inspected noon, dusk, night, sales, paid-refund, and prison captures. The world changes from warm daylight through sunset to a darker cool night; HUD and clock stay readable. The sales panel shows actual and claimed materials separately, fully spendable cash, risk feedback, and End day controls without overflowing. The paid-refund capture agrees at **cash 90, stock 1, revenue 0, reputation -5**. The prison capture shows a **30-credit refund due against cash 0**, with the fresh-run button replacing Continue and no partial settlement. The render driver forced complaint probability to 1 only for those consequence previews; normal gameplay configuration remains 10–25%.

These captures establish rendered layout and selected outcomes, not Windows usability or a balanced economy. Suggested Windows playtests above remain the project manager’s separate check. At this historical checkpoint there was one product, one repeatable customer, no saved progress, no spatial prison scene, no indoor lighting rules, and no dynamic lamp illumination. Its eight-minute day and economy figures are placeholders for later balance.

One combined pull request can use **Add customer sales, day/night time, and refund consequences**. Its Files changed view includes every branch checkpoint's final result. Squash and merge would produce one `main` checkpoint containing the full branch result; no checkpoint is merged merely because it was pushed.
