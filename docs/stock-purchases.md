# Starter-stock purchases

**Historical checkpoint:** instant buying at the plaza supplier has been replaced in playable sessions by [apartment computer orders and next-morning delivery](apartment-and-deliveries.md). The original interaction and checks below describe the earlier purchase milestone; they are not the current sourcing walkthrough.

This checkpoint introduces the first business operation: buying imitation rings from a supplier. Each new run starts with **100 credits and zero rings**. One ring costs **10 credits** and is genuinely **plated brass with a simulated stone**. These are dummy balancing figures, not final material prices.

The supplier uses our existing modular stall artwork. A reusable scene adds proximity detection and an interaction panel to that prop; artwork alone does not determine whether an object can be used. The founder's original stall now hosts [customer sales](customer-sales.md).

## One state, several views

`scripts/business_state.gd`, attached to the level’s `BusinessState` node, owns cash and stock. The purchase rule checks affordability, subtracts the cost, and adds one ring together. The interface requests that operation instead of changing those numbers itself. This separates the **domain model**—the game's business rules—from the **UI**, which displays information and accepts input.

`scripts/economy_config.gd` defines the exported fields of a Godot `Resource`; `resources/prototype_economy.tres` stores this prototype’s starting cash, product description, and unit cost. Later balancing can change those figures in one place instead of hunting through labels and input handlers.

After `purchase_one()` succeeds, its `changed` signal informs `scripts/business_hud.gd` and `scripts/supplier_counter.gd` that state changed. Both refresh from the same state. They are views of one balance, rather than separate balances that need to be kept in sync.

An unaffordable purchase changes nothing. The panel explains the failure, and cash and stock cannot become negative. Purchases are one ring per action; holding a keyboard key does not repeatedly spend money.

## Historical Windows playtest

1. Preserve local edits, close Godot, and fetch in GitHub Desktop.
2. Select **`main`** for the accepted purchase checkpoint, or **`feat/customer-sales`** to review purchases alongside the new sales rules; pull if offered.
3. Open `jewel-rpg/project.godot` in Godot 4.7.2 and press F5.
4. Check the HUD: **100 credits, 0 rings**. Walk to the supplier counter and press E when its prompt appears.
5. Read the actual materials and price. Try moving: the founder should remain still, without walking or bobbing.
6. Press B once: cash should become **90** and stock **1**. Click the Buy button once: **80** and **2**.
7. Hold B briefly. Only its initial press should buy; release and press again to make another deliberate purchase.
8. Buy until cash reaches **0** and stock **10**. Attempt another purchase using B and the button. Both values should stay unchanged, with insufficient-funds feedback.
9. Close with E or Escape and walk away. Pressing B with the panel closed should not purchase. Try reopening, then test the existing board dialogue separately.
10. Stop and restart. Cash and stock reset to **100** and **0**; save/load is not implemented.

## Learn from the scene

Inspect `scenes/props/supplier_counter.tscn` and compare it with `scenes/props/jewellery_stall.tscn`: reusable artwork and collision are combined with behaviour appropriate to this instance. Then follow the purchase request from the panel to the business state and its change signal back to the HUD. This is a small example of keeping rules in one place while allowing several interfaces to display them.

The supplier panel temporarily owns the movement lock. Its scene exposes paths to the player and business-state nodes, which the level assigns to the appropriate instances. Opening it stops the animation immediately. Another interaction must not take over or accidentally release that lock; otherwise the founder could walk while a panel is open or open two competing interfaces.

## Several commits, one pull request

The project manager authorized continuing before merging the animation. We keep using **the same branch**, but save purchases as **a separate commit**. That keeps the two checkpoints visible during review without requiring two merges.

A suitable combined pull-request title is **Add directional walking and starter-stock purchases**. Its Files changed view compares the branch's combined result with `main`. **Squash and merge includes both checkpoints' final changes**, not just the newest commit. It creates one new checkpoint on `main`; the branch's individual commits remain useful while reviewing.

The project manager tested and squash-merged this combined branch into `main` at `37f1681`. Fetching and pulling `main` on each computer supplies both features. The combined sales, day-end consequences, and timed-market branch was subsequently merged at `4093d6d`.

## Limits and verification

The original purchase checkpoint handled one product per action, without customer sales. The following [sales checkpoint](customer-sales.md) adds claims, revenue, and reputation. Its original refund reservation rule was superseded at the project manager’s request: purchasing now uses **all current cash**, including misleading-sale proceeds. [Day-end refunds](day-and-refunds.md) can therefore exceed money left after purchasing and send the founder to prison. While a report or prison outcome is open, purchases are blocked. Supplier ethics simulation and save/load remain deferred. Restarting resets the session.

The coding agent completed a Godot 4.7.2 editor import and **25 focused purchase checks passed**. The reviewer inspected the new scripts, configuration, scenes, input action, and actual input-dispatch tests, then independently reran only `verify_purchases.gd`: **25 passed, zero failures, exit code 0**.

These checks exercise keyboard and real GUI mouse dispatch, rejected key echoes, exact-last-cash and insufficient-cash transactions, shared HUD/panel updates, configuration-driven cost, reachable solid-counter placement, immediate movement/animation locking, resumption, closing outside range, and preservation of the existing board’s lock. Existing animation and prop-art suites were not repeated: player and sign scripts and their art are unchanged, and the focused purchase suite covers the new interaction dependency.

From the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_purchases.gd
```

Automated checks do not replace the project manager’s Windows review of navigation, panel readability, controls, and feedback.

The coordinating agent also rendered the actual game through Godot 4.7.2’s Compatibility renderer on the cloud virtual display. The reviewer inspected the final open-panel capture after a rejected eleventh purchase: the compact HUD and panel agree at **0 credits and 10 rings**, with clear insufficient-cash feedback. The nearly opaque plum panel, gold heading, and teal button give the text sufficient contrast against the busy plaza; materials, price, feedback, and controls fit. After these final panel/button style changes, the reviewer reran the same focused purchase suite: **25 passed, zero failures, exit code 0**, including actual GUI mouse dispatch. This is rendered-game evidence, not a concept image; Windows feedback and navigation review remains pending.
