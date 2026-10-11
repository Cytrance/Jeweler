# Prices, claims, and customer sales

This walkthrough records the first sales checkpoint. The current [timed-market revision](market-session.md) adds Start day, visible customer arrivals, and a finite daily quota, so its playtest supersedes the unlimited encounter steps below.

The founder's original stall first introduced an explicit **Serve next customer** interaction. Mina, a commuter with a taste for bargains, responds to your offer. There is no autonomous queue or walking customer sprite: a deliberate action starts one predictable encounter. This keeps the first sales rule easy to understand before adding crowds or varied customers.

The ring remains **plated brass with a simulated stone**. Its real materials, asking price, and sales claim are three separate facts. Raising the price does not change the materials or automatically make a claim dishonest.

## Prototype rules

| Choice | Result |
|---|---|
| Truthful claim, price 15 or 20 | Sell one stocked ring; gain the price in cash and revenue, plus 2 reputation at 15 or 1 at 20 |
| Truthful claim, price 30 | Customer rejects; business values stay unchanged |
| Misleading claim, price 15, 20, or 30 | Sell one stocked ring; gain fully spendable cash and revenue, record the sale for a possible day-end refund |
| Any offer without stock | No sale; customer asks you to buy stock |

The default is **20 credits, truthful**. These are dummy figures and deterministic thresholds, not a balanced simulation. Misleading sales now have a chance of a refund at day end. This revises the original guaranteed-complaint/reserved-cash checkpoint before its merge; see [day and refunds](day-and-refunds.md).

With the panel open, **P** cycles through the prices, **C** switches the claim, and **N** serves. You can also use the two dropdown menus and Serve button with the mouse. Each key requires a fresh press; holding it does not cycle choices or serve repeatedly. **E** or **Escape** closes the panel.

## Cash, revenue, and refund risk

**Cash** is the current spendable balance. **Sales revenue** is successful sales minus refunded sales; it is not profit, because stock purchases also cost money. Misleading sale proceeds are immediately available to buy stock. Possible future refunds are a risk, not a cash hold or credit balance.

Start with 100 credits. Buy one ring for 10: cash 90, stock 1. Sell truthfully for 20: cash 110, stock 0, revenue 20, reputation +1. The completed trade earned 10 after its stock cost.

Alternatively, sell that ring misleadingly for 30: cash 120, stock 0, revenue 30, reputation 0. All 120 credits are spendable. At day end, the sale independently rolls against that day's 10–25% complaint probability. No refund leaves these business values unchanged. An affordable refund subtracts 30 cash, returns the ring, reverses 30 revenue, and loses 5 reputation. An unaffordable total refund batch sends the founder to prison and ends the run.

The 10–25% range is a probability, not a guaranteed fraction of customers. With only one misleading sale, that day's result is necessarily either zero refunds or one refund.

## Try it on Windows

1. Preserve local edits, close Godot, fetch in GitHub Desktop, select **`feat/customer-sales`**, and pull if offered.
2. Open `jewel-rpg/project.godot` with Godot 4.7.2 and press F5. Each fresh run begins with 100 credits, zero rings, zero revenue, and zero reputation.
3. Approach **YOUR STALL**, press E, and serve with N or the button. With no stock, Mina should explain why there is no sale. Cash, revenue, and reputation stay unchanged.
4. Close with E or Escape. At **SUPPLIER**, buy one ring for 10, then return to your stall.
5. Leave the default truthful claim and 20-credit price. Serve once: cash **110**, stock **0**, revenue **20**, reputation **+1**. Holding N should not repeat the transaction.
6. Buy another ring. Choose a truthful claim and price 30, then serve. Mina should reject the price without consuming the ring or changing cash, revenue, or reputation. Change the price to 15 or 20 and try again.
7. Restart for a clean misleading-sale example. Buy one ring, choose price 30 and the misleading claim, then serve. Actual materials must still say plated brass and simulated stone. Expect cash **120**, stock **0**, revenue **30**, reputation **0**, and feedback explaining possible day-end complaints.
8. Back at the supplier, all 120 credits can buy twelve rings. A thirteenth purchase fails at cash 0. End the day to observe refund risk: a requested refund at cash 0 leads to prison; no request allows the next day. Random play does not guarantee either outcome on any one run.
9. Check the price/claim controls, feedback, and all figures at normal game size. Opening a panel stops movement and animation; closing it resumes control. The supplier, sales panel, and board should not open over one another.
10. Stop and restart. All business values and recorded misleading sales reset; save/load is still absent. Report errors or confusing feedback before approving the merge.

## Follow one transaction through the code

`scenes/props/sales_counter.tscn` combines the existing reusable stall artwork/collision with an `Area2D` interaction range and a panel. The level links its player and business-state paths. The script `scripts/sales_counter.gd` reads the selected price and claim, requests a transaction, and displays the customer response.

`scripts/business_state.gd` owns `serve_customer(price, misleading)`. It checks the configured prices, stock, and customer's threshold before changing anything. A successful transaction changes stock, cash, revenue, reputation or the day’s eligible misleading sales together, then emits `changed`. The HUD and supplier/sales panels read the completed state; they do not maintain separate business balances.

This is why the new sales rule also needs focused purchase verification: both features use the same state, and purchasing must use all cash while refusing transactions during a day report or prison outcome. The unrelated animation and prop artwork do not need every old check repeated.

`scripts/economy_config.gd` and `resources/prototype_economy.tres` keep the prototype's price options, descriptions, thresholds, and reputation gain together. The selected offer is a panel choice; it never rewrites the actual-material field.

## Limits and verification

The evidence below records the **original sales commit** (`664702d`), whose reservation rule is superseded by the day/refunds revision. Its historical counts are not evidence for the revised risk rules. Current verification is recorded in [day and refunds](day-and-refunds.md).

This historical checkpoint added one product and one repeatable named encounter; the timed-market revision now limits encounters and supplies visible visitors. It does not add customer pathfinding, varied preferences, save/load, or final accounting. The following revision on this same branch adds [day progression and complaint resolution](day-and-refunds.md); its state persists only within the running session. Keyboard and mouse controls request the same state operation; echoed key events must not create extra transactions.

The coding agent completed the Godot 4.7.2 editor import and reported **32 sales checks and 25 purchase checks passed**. Purchase checks were relevant because shared business state and affordability changed. Wrapping the existing stall in the new interaction scene also moved its artwork/collider paths under `Obstacle/Stall`; three older test fixtures were updated to follow that hierarchy. The coding agent ran their affected checks only: **4 collision-only movement checks, 4 market checks, and 27 market-art checks passed**. These were dependency checks caused by changed scene paths, rather than an automatic rerun of all historical tests. Unchanged animation and scenery suites were not repeated.

The reviewer inspected the state, sales/supplier interaction scripts, scene integration, HUD, and input actions, then independently ran only `verify_sales.gd`: **32 passed, zero failures, exit code 0**. It covers stock/invalid-price/overprice rejections, all truthful and misleading price options, unchanged real materials, revenue and reservation totals, protected and exact-available-cash purchases, state signals, actual keyboard/mouse dispatch, non-echo input, reachable solid stall, movement locking/resumption, range exit, and preservation of supplier/board locks.

From the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_sales.gd
```

The coordinating agent also rendered the actual scene using Godot's Compatibility renderer on the cloud virtual display. The reviewer inspected the misleading-sale capture at 960 × 540: actual composition and the false claim remain visible together, all transaction figures agree, the pending-refund message is legible, and the panel fits the viewport. A final rejection capture shows the P/C/N controls fitting on one line and explicitly explains the 20-credit threshold; cash stays 90, stock 1, revenue 0, and reputation 0 after rejecting a truthful 30-credit offer. Windows playtesting remains the project manager's check of readability, navigation, feedback, and enjoyment.
