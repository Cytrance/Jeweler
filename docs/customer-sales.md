# Prices, claims, and customer sales

The founder's original stall now has an explicit **Serve next customer** interaction. Mina, a commuter with a taste for bargains, responds to your offer. There is no autonomous queue or walking customer sprite: a deliberate action starts one predictable encounter. This keeps the first sales rule easy to understand before adding crowds or varied customers.

The ring remains **plated brass with a simulated stone**. Its real materials, asking price, and sales claim are three separate facts. Raising the price does not change the materials or automatically make a claim dishonest.

## Prototype rules

| Choice | Result |
|---|---|
| Truthful claim, price 15 or 20 | Sell one stocked ring; gain the price in cash and revenue, plus 1 reputation |
| Truthful claim, price 30 | Customer rejects; business values stay unchanged |
| Misleading claim, price 15, 20, or 30 | Sell one stocked ring; gain the price in cash and revenue, record one pending refund, and reserve that price |
| Any offer without stock | No sale; customer asks you to buy stock |

The default is **20 credits, truthful**. These are dummy figures and deterministic thresholds, not a balanced simulation. Every successful misleading sale schedules a complaint in this prototype. Actual complaint resolution is the next milestone; this checkpoint cannot end the day or return refunded rings yet.

With the panel open, **P** cycles through the prices, **C** switches the claim, and **N** serves. You can also use the two dropdown menus and Serve button with the mouse. Each key requires a fresh press; holding it does not cycle choices or serve repeatedly. **E** or **Escape** closes the panel.

## Cash, revenue, and reserved refunds

**Cash** is the current balance. **Sales revenue** is the sum of successful sales in this session; it is not profit, because stock purchases also cost money. **Reserved cash** is the total of pending refund amounts. **Available cash = cash − reserved cash** is what the supplier lets you spend.

Start with 100 credits. Buy one ring for 10: cash 90, stock 1. Sell truthfully for 20: cash 110, stock 0, revenue 20, reputation +1. The completed trade earned 10 after its stock cost.

Alternatively, sell that ring misleadingly for 30: cash 120, stock 0, revenue 30, reputation 0, held refunds 30, available cash 90. The 30-credit refund reservation is recorded immediately, before the interface refreshes. It cannot fund another stock purchase. This protects the later refund operation from overspending, even though the operation itself is not implemented yet.

## Try it on Windows

1. Preserve local edits, close Godot, fetch in GitHub Desktop, select **`feat/customer-sales`**, and pull if offered.
2. Open `jewel-rpg/project.godot` with Godot 4.7.2 and press F5. Each fresh run begins with 100 credits, zero rings, zero revenue, and zero reputation.
3. Approach **YOUR STALL**, press E, and serve with N or the button. With no stock, Mina should explain why there is no sale. Cash, revenue, and reputation stay unchanged.
4. Close with E or Escape. At **SUPPLIER**, buy one ring for 10, then return to your stall.
5. Leave the default truthful claim and 20-credit price. Serve once: cash **110**, stock **0**, revenue **20**, reputation **+1**. Holding N should not repeat the transaction.
6. Buy another ring. Choose a truthful claim and price 30, then serve. Mina should reject the price without consuming the ring or changing cash, revenue, or reputation. Change the price to 15 or 20 and try again.
7. Restart for a clean misleading-sale example. Buy one ring, choose price 30 and the misleading claim, then serve. Actual materials must still say plated brass and simulated stone. Expect cash **120**, available **90**, held **30**, stock **0**, revenue **30**, reputation **0**, and a pending-complaint message.
8. Back at the supplier, buy nine rings. Cash should reach **30**, available cash **0**, held refunds **30**, stock **9**. Another purchase must fail without spending the held money.
9. Check the price/claim controls, feedback, and all figures at normal game size. Opening a panel stops movement and animation; closing it resumes control. The supplier, sales panel, and board should not open over one another.
10. Stop and restart. All business values and pending complaints reset; save/load is still absent. Report errors or confusing feedback before approving the merge.

## Follow one transaction through the code

`scenes/props/sales_counter.tscn` combines the existing reusable stall artwork/collision with an `Area2D` interaction range and a panel. The level links its player and business-state paths. The script `scripts/sales_counter.gd` reads the selected price and claim, requests a transaction, and displays the customer response.

`scripts/business_state.gd` owns `serve_customer(price, misleading)`. It checks the configured prices, stock, and customer's threshold before changing anything. A successful transaction changes stock, cash, revenue, reputation or pending refunds together, then emits `changed`. The HUD and supplier/sales panels read the completed state; they do not maintain separate business balances.

This is why the new sales rule also needs focused purchase verification: both features use the same state, and purchasing now depends on reserved refunds. The unrelated animation and prop artwork do not need every old check repeated.

`scripts/economy_config.gd` and `resources/prototype_economy.tres` keep the prototype's price options, descriptions, thresholds, and reputation gain together. The selected offer is a panel choice; it never rewrites the actual-material field.

## Limits and verification

This checkpoint adds one product and one repeatable named encounter. It does not add customer pathfinding, varied preferences, day progression, complaint resolution, save/load, or final accounting. Reservations persist only within the running session. Keyboard and mouse controls request the same state operation; echoed key events must not create extra transactions.

The coding agent completed the Godot 4.7.2 editor import and reported **32 sales checks and 25 purchase checks passed**. Purchase checks were relevant because shared business state and affordability changed. Wrapping the existing stall in the new interaction scene also moved its artwork/collider paths under `Obstacle/Stall`; three older test fixtures were updated to follow that hierarchy. The coding agent ran their affected checks only: **4 collision-only movement checks, 4 market checks, and 27 market-art checks passed**. These were dependency checks caused by changed scene paths, rather than an automatic rerun of all historical tests. Unchanged animation and scenery suites were not repeated.

The reviewer inspected the state, sales/supplier interaction scripts, scene integration, HUD, and input actions, then independently ran only `verify_sales.gd`: **32 passed, zero failures, exit code 0**. It covers stock/invalid-price/overprice rejections, all truthful and misleading price options, unchanged real materials, revenue and reservation totals, protected and exact-available-cash purchases, state signals, actual keyboard/mouse dispatch, non-echo input, reachable solid stall, movement locking/resumption, range exit, and preservation of supplier/board locks.

From the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_sales.gd
```

The coordinating agent also rendered the actual scene using Godot's Compatibility renderer on the cloud virtual display. The reviewer inspected the misleading-sale capture at 960 × 540: actual composition and the false claim remain visible together, all transaction figures agree, the pending-refund message is legible, and the panel fits the viewport. A final rejection capture shows the P/C/N controls fitting on one line and explicitly explains the 20-credit threshold; cash stays 90, stock 1, revenue 0, and reputation 0 after rejecting a truthful 30-credit offer. Windows playtesting remains the project manager's check of readability, navigation, feedback, and enjoyment.
