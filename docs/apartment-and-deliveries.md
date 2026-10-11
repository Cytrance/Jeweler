# Apartment, travel, and next-morning stock

This milestone on **`feat/apartment-deliveries`** extends the merged market prototype with two areas. A fresh run starts in the founder's small, worn apartment; the existing plaza remains the selling location. The implementation and focused checks below are complete; Windows playtesting remains the project manager’s review step. Pushing a branch does not merge it into `main`.

## The player’s routine

Approach the apartment computer and press **E**. Inspect the real product materials and order imitation rings. Each ring costs **10 credits**, paid immediately. Ordered rings are pending goods: they do not become sellable stock until **08:00 on the following calendar day**. Multiple affordable orders can share that delivery morning. The arrival notification and inventory update occur even if you are in the plaza.

Approach the door and press **E** to choose the plaza. The plaza exit opens the same destination menu with the apartment as its destination. A journey advances **30 game minutes** and keeps your cash, available stock, reputation, pending orders, and calendar day. Returning to the plaza cannot reroll attendance or reopen a market that already ran today.

Approach the bed and choose sleep to advance to the next **08:00**. Sleep still crosses midnight: the financial report resolves any requested refunds before you wake. Continue an affordable report to complete the skip and receive morning stock. If refunds exceed your cash, prison ends the run before waking or delivery. Buying tomorrow's goods can therefore leave too little money for tonight's possible refunds.

There are still two different clocks. Travel and sleep advance calendar time; the active market's real 60-second countdown remains its own system. You cannot travel or sleep through the selling minute, closing transition, financial report, or prison. Ordinary interaction pauses remain in effect outside the market.

Orders on day D always arrive on day D+1 at 08:00. Ordering at 23:59 is for the approaching morning; ordering at 00:01 is for the morning after that. These explicit cutoff, price, travel, and delivery values are prototypes rather than a balanced final economy. The plaza supplier's old instant-buy flow is no longer the playable sourcing route.

## Scenes and shared state

A **scene** is a reusable collection of Godot nodes. A table scene can combine artwork and a solid footprint once, then be instanced in many interiors. Its copies inherit those defaults. Visual size and collision footprint serve different purposes: artwork can extend above or around the grounded base without making every visible pixel an invisible wall.

A **TileMapLayer** paints a grid using reusable floor or wall tiles. Furniture remains separately placed scene instances. This distinction makes rooms reusable without baking tables, beds, or computers into a flat background. The starter scene fills a 21 × 11 floor rectangle and a 21 × 3 wall strip in `apartment_tiles.gd` at runtime only when each layer is empty. Width and floor/wall heights are exported settings. Manually painted layers are preserved, so a custom room can reuse the TileSet resources and paint its own layout. Resizing tiles does not automatically resize the room shell collision or reposition furniture; those still need to match the chosen layout. The new kit is a first interior set, not a player decorating or furniture-snapping editor.

Changing area does not create a new business run. Shared business state, clock, market controller, delivery queue, and UI stay alive; the active environment changes. The inactive environment must stop drawing and receiving interaction input, and its collision must be disabled. Simply hiding a picture would leave invisible obstacles behind. A `CanvasLayer` used by a panel also needs explicit handling because it is drawn separately from world scenery.

Indoor lighting stays independent of the plaza's outdoor day/night tint. The calendar continues indoors, but night does not paint the apartment with the outdoor blue overlay. This is ambient presentation, not a new dynamic lighting system.

The shared controller scripts have separate responsibilities:

- `scripts/area_travel.gd`: the common destination/order/sleep panel, area activation, and any minutes still owed after a midnight report.
- `scripts/delivery_orders.gd`: paid pending quantities, due calendar days, exactly-once arrival, and the delivery notification.
- `scripts/market_clock.gd`: game time, midnight boundaries, and indoor/outdoor ambient colour.
- `scripts/day_cycle.gd`: financial reports and resuming an interrupted journey or sleep after Continue.
- `scripts/room_interaction.gd`: reusable proximity prompts that request an action from the shared controller.
- `scripts/apartment_tiles.gd`: painting the reusable indoor floor and wall layers.

The first area manager marks world roots with `playable_area` metadata and recursively toggles them. A new area will need its scene, destination entry, arrival position, and lighting choice registered in that manager. This is a small two-area implementation, not a generic streaming-town framework.

## Try it on Windows

1. Close Godot. In GitHub Desktop fetch, select **`feat/apartment-deliveries`**, and pull. Reopen the project in Godot 4.7.2 and press F5.
2. Confirm the apartment appears first. Walk around each furniture footprint; check artwork proportions, clear routes, interaction prompts, and text readability at normal game size.
3. Order a ring at the computer. Cash should fall by 10 immediately; available stock should stay unchanged. Check pending stock and its due day/time. Try an unaffordable order: balances must not change.
4. Use the door to travel to the plaza. Confirm 30 minutes pass and cash/stock remain shared. Use the plaza exit to return; the same menu should offer only the apartment.
5. Sleep at the bed. Continue the midnight financial report. At next-day 08:00, expect one delivery notification and one inventory increase; reopening menus must not deliver it again.
6. Travel to the plaza with delivered stock, start and finish a market, then make a round trip. Starting a second market on the same day must remain unavailable. Travel/sleep must be blocked during the market or closing report.
7. Order more stock in the evening, then sleep. Any randomly requested refunds are paid before morning delivery. If you cannot cover them, prison must stop the run rather than delivering goods or waking normally.
8. On another run, let 08:00 arrive while in the plaza. Delivery should still update the inventory and notification. Check that apartment collision/panels do not interfere with plaza movement, or vice versa.

Misleading-sales refund requests are random in normal play; an automated deterministic boundary check can verify prison ordering without promising that any one Windows run will request a refund.

## Verification and limitations

The coding agent completed the Godot 4.7.2 import and reported **41 apartment/travel/delivery checks**, **43 affected market-session checks**, and **37 affected clock/refund checks passed**. The latter two exercise shared time, reports, and the once-per-day market gate. Their historical fixtures explicitly start in the plaza; the market fixture enables its legacy supplier locally, without restoring instant buying in the playable game. A final startup audit also adapted three existing `main.tscn` fixtures to the new apartment default: `verify_market.gd` starts in the plaza, while `verify_sales.gd` and `verify_purchases.gd` additionally enable their legacy supplier locally. Their directly affected checks passed: **4 plaza collision, 32 sales, and 25 purchase checks**. This preserves runnable historical checks without restoring the old supplier in the playable game. The reviewer inspected those fixture-only diffs and reused the coding agent’s results; the apartment suite was not rerun for fixture-only edits. Unchanged animation, exterior artwork, and other historical suites were not automatically repeated.

The reviewer independently inspected the new controllers, room composition, area activation, pending-order flow, and shared clock/report changes, then ran `verify_apartment.gd`: **41 passed, zero failures, exit code 0**. It covers actual nearby E interactions, B ordering and echo rejection, Escape releasing the owned lock, mouse activation of bed and destination buttons, real movement blocked by a bed, active/inactive physics queries, prompt invalidation, actual material text, immediate costs versus delayed stock, insufficient cash/invalid quantities, accumulated orders, 08:00 arrival once in the plaza, the 30-minute travel cost, a journey crossing midnight, remaining travel after financial Continue, sleep across midnight and from after midnight, modal/market guards, preservation of today’s market, and insolvency preventing wake-up or delivery. A standalone unconfigured interaction safely disables input.

From the repository root:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_apartment.gd
```

The coordinator rendered the actual game at **960 × 540** with Godot 4.7.2’s Compatibility renderer. The reviewer inspected the apartment, computer, sleep, destination, midnight report, morning delivery, and plaza captures. The furniture and founder have coherent scale, the routes are visible, and the final opaque plum/gold panels with teal buttons keep composition, order timing, pending stock, and actions readable. One repeated input-driven sequence starts from the real 100-credit/zero-ring state, orders three rings with E/B (cash 70, stock 0, pending 3), sleeps using the bed button, continues the midnight report, receives three rings at day 2 08:00 (cash 70, stock 3), and uses the door menu to reach the plaza at 08:30. The plaza exit offers Apartment in the same menu. The delivery notification and figures agree; the inactive apartment does not appear behind the plaza.

For stable captures, the coordinator paused automatic calendar progression and positioned the founder near each interaction before sending actual keyboard/mouse events. These captures verify rendered layout and selected transitions; they do not establish full manual route navigation or Windows usability. The Windows steps above remain the project manager’s separate playtest.

Progress is in memory only: closing or restarting the game resets balances, pending orders, and areas. Only the apartment and plaza are destinations. There is no furniture placement interface, save/load, rent, shipping cost, supplier tier, or final economy balance. Pending purchases are not available inventory and no money is reserved for possible refunds.
