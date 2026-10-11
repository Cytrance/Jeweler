# Learning roadmap

## Completed baseline

- GitHub repository cloned on the project manager's Windows PC.
- Empty Godot project created in `jewel-rpg/` and opened locally.
- Initial project committed and pushed; cloud access verified.

## Working agreements checkpoint

Project entry point, role definitions, and roadmap established. Continue using task branches and independent review for each milestone.

## Completed milestone: first running scene

Created one simple 2D scene, designated it as the main scene, and ran it. The project manager confirmed the rectangle on Windows, approved the branch, and the milestone was merged into `main`.

Acceptance checks:

- Cloud agent: verify that the intended main scene loads with Godot 4.7.2 without errors; report the actual checks performed.
- Project manager: run the project on Windows and confirm a visible placeholder appears with no errors.
- Project manager: repeat the steps in [the first-scene walkthrough](first-scene.md).
- Documentation: explain scenes, nodes, the main scene, and editor versus running game.

## Completed milestone: four-direction movement

Move the existing placeholder using WASD and arrow keys. Learn GDScript, input actions, vectors, and physics updates. The project manager tested movement on Windows, approved the change, and merged it into `main` at `1e15da4`.

Acceptance checks:

- Both control sets move the placeholder in all four directions.
- Releasing the keys stops movement immediately.
- Diagonal movement has the same speed as straight movement.
- Cloud verification reports actual import, runtime, and movement checks performed; headless checks do not replace the Windows playtest.
- Independent review checks the actual diff and updates the [movement walkthrough](player-movement.md).

At that checkpoint, collision, boundaries, animation, and finished sprites were deferred.

## Completed milestone: one obstacle and collision

Convert the moving placeholder into a character physics body and add one visible, stationary obstacle. Learn physics bodies, collision shapes, velocity, and sliding. The project manager tested collision on Windows, approved the change, and merged it into `main` at `4d913c3`.

Acceptance checks:

- WASD and arrow keys still move the player; releasing input stops movement.
- The player cannot pass through the orange obstacle from either side, above, or below.
- Diagonal movement into a face slides along it; moving away works immediately.
- Free-space diagonal speed remains equal to straight speed.
- Cloud verification reports actual import, runtime, and automated checks; independent review inspects the final code and tests.
- The project manager runs the [collision walkthrough](player-collision.md) on Windows and reports any errors.

No screen boundaries, animation, interaction, or finished sprites are included. The player can still move offscreen; restarting restores its starting position.

## Completed milestone: sign interaction and short dialogue

Add one sign with a proximity prompt and one fixed message. Learn detection areas, signals, input handling, and UI. The project manager tested the sign on Windows, approved the change, and merged it into `main` at `7b7ae25`.

Acceptance checks:

- Existing movement and solid obstacle collision still work.
- A prompt appears only while the player is near the sign.
- Pressing E nearby opens the message; pressing E elsewhere does nothing.
- Movement stops while the dialogue is open.
- E or Escape closes the dialogue; movement then resumes.
- Cloud verification reports actual checks, and independent review inspects final code and tests.
- The project manager follows [the sign-dialogue walkthrough](sign-dialogue.md) on Windows before approving the merge.

No inventory, dialogue choices, animation, sprites, or screen boundaries are included.

## Completed milestone: one static player sprite

The project manager reviewed the sprite, requested a larger readable character, and merged the correction at `6d2f0bd`. This established the asset handoff and focused-verification workflow. The fantasy-styled clothing is superseded by the modern business setting.

## Superseded experiment: wooden workshop

`feat/workshop-room` was tested locally but remains unmerged. It explored scene composition, boundaries, and collision layers. Do not merge its historical workshop visuals into the modern-market direction. Reuse useful techniques in a separately reviewed change when needed.

## Completed milestone: modern business design brief

The project manager reviewed and merged the brief into `main`. It documents the approved setting, tone, ethical choices, first business loop, placeholder economy, and revised art direction. That documentation milestone included no application or asset changes.

Acceptance checks:

- [Game design](game-design.md) reflects a modern jewellery-business RPG with meaningful simulation and playful humour.
- Initial imitation goods can be sold honestly or misrepresented; composition and sales claims are distinct.
- Prototype values and worked examples are internally consistent and explicitly unbalanced.
- [Art guide](art-guide.md) supersedes the fantasy visual direction and preserves historical import information.
- Planned features are distinguished from the currently running prototype.
- Independent review checks documents; no gameplay suites are rerun for this documentation-only milestone.

## Previous milestone: modern market visual reset

The initial modern setting was playtested on Windows. The project manager then approved the combined cosy concept, and the refined visual checkpoint was merged into `main` at `aaf5da0`. It introduced a chibi founder, warm textured pavement, neighbouring market stalls, and a modest jewellery pop-up while retaining movement, collision, and nearby E/Escape interaction. The merge records inclusion in the shared baseline; it does not establish that every visual acceptance check was separately reported. No economy was implemented.

Acceptance checks:

- The founder reads as a contemporary person in casual clothes and is readable at normal game size.
- The folding table, jewellery trays, price information, stock boxes, and card-payment device communicate a modest modern business.
- Founder, table, and board have coherent proportions; the character is not reduced to the earlier unreadable 48-pixel size.
- The table blocks movement from all four sides, supports sliding, and permits moving away.
- The nearby board opens the modern fixed message; movement locks while reading and resumes on closing.
- The combined scene has acceptable layering, framing, colour contrast, and UI text fit on Windows.
- Independent review inspects the actual scene and assets; focused checks cover changed scene dependencies rather than automatically repeating every historical suite.
- Follow [the modern-market walkthrough](modern-market.md) and report the visual playtest before approving the merge.

## Completed milestone: reusable modular plaza kit

The project manager confirmed collision, adding new prop instances, and the tilemap on Windows, then merged the kit into `main` at `1a9b871`. The merged level also includes the project manager's saved placement and paving edits.

Replace the fixed plaza backdrop with repeatable ground and separately placed objects. Extract the existing stall and board into reusable scenes, and add a flower planter with its own solid footprint. This is a small asset workflow checkpoint before the business loop; it does not promise a complete town or convert every pictured object into a game asset.

Acceptance checks:

- Ground uses a `TileMapLayer` with 192-game-pixel cells and is walkable.
- A reusable planter scene combines artwork and a solid base footprint; multiple instances inherit those settings.
- The existing stall scene includes its collision by default; the board includes proximity detection, dialogue, and a small solid base by default.
- The board works without assuming its parent contains a specifically named player sibling.
- Player, stall, board, and planters layer coherently; foliage can extend over walkable space outside a planter's base.
- Repeated paving looks coherent at gameplay size, and the founder and props retain the approved warm, cute direction.
- Relevant physics, interaction, and asset checks run; unchanged suites are reused when justified.
- The project manager follows [the modular-plaza walkthrough](modular-plaza.md), judges appearance and collision fit on Windows, and approves the merge.

## Completed milestone: flowering trees and streetlamps

The project manager tested and merged this checkpoint into `main` at `4128dae`. Restore some of the approved cosy atmosphere with two tall reusable prop designs, each combining its artwork and a solid grounded base. This builds on the tested modular kit rather than returning to a flat background.

Acceptance checks:

- Two flowering-tree instances and two streetlamp instances share their respective source scenes and inherit collision.
- Tree collision covers the trunk/base; its broader canopy does not become an invisible wall. Lamp collision covers its small base.
- Ground-contact points, uniform display scales, and Y sorting allow the founder to walk behind tall artwork and appear in front when below it.
- Tree, lamp, founder, stall, and planter scales and lighting fit the approved warm modern-market direction.
- The initial player position and routes to the board and stall remain usable.
- Focused checks cover new prop integration and physics. Existing checks that depend on level layout remain usable without automatically repeating every historical suite.
- The project manager follows [the scenery walkthrough](plaza-scenery.md), checks visual quality and routes on Windows, and approves the merge.

## Completed milestone: directional founder walking animation

The project manager accepted the animation, authorized purchases as another commit on the same branch, then tested and squash-merged the combined result into `main` at `37f1681`. Replace the static founder with down, up, and side poses and a simple alternating-leg walk cycle. Mirror the side view for left movement. Keep the existing physical movement, map placements, collision, and board interaction.

Acceptance checks:

- WASD and arrows select the appropriate facing; equal diagonal input consistently uses the side view.
- Walking visibly alternates leg poses, with a small visual bob. Up shows the back; side movement uses a side pose.
- Releasing input keeps the last facing and returns to idle. Pressing into a blocking wall stops the stride when there is no actual displacement.
- Dialogue immediately stops the animation and bob; closing it allows movement to resume.
- Frame crops share a canvas and uniform scale so changing poses does not resize the body or slide its grounding point.
- Existing player speed, diagonal normalization, solid collision, and scene placements remain intact.
- Relevant animation, movement, and interaction checks run; unchanged prop-art suites are not automatically repeated.
- The project manager follows [the animation walkthrough](player-animation.md), judges the cycle at gameplay size, and approves the merge.

## Completed milestone: starter-stock purchases

The project manager tested the purchases and merged the combined animation/purchase branch into `main` at `37f1681`. Add a reachable supplier counter, a cash/stock HUD, and one-ring purchases using the placeholder figures: 100 starting credits, zero rings, and 10 credits per ring. The two separate feature commits demonstrated batching several checkpoints into one pull request and one squash merge.

Acceptance checks:

- The supplier displays the real plated-brass and simulated-stone composition and unit cost.
- E opens/closes nearby; Escape closes; B or the Buy button purchases exactly one ring per deliberate action.
- Each successful purchase subtracts 10 credits and adds one ring; insufficient funds leave both unchanged and produce feedback.
- Purchasing while closed or away from the counter is prevented; held keys do not generate repeated purchases.
- The HUD and open supplier panel agree with one shared business state.
- Movement, walking animation, and bob stop immediately while the panel is open and resume after closing. Board and supplier interactions do not unlock or overlap one another.
- Focused purchase checks and independent review cover the new rules and interaction dependencies; previous animation and prop-art evidence is reused where unchanged.
- The project manager follows [the stock-purchases walkthrough](stock-purchases.md) before approving the combined pull request.

## Completed milestone: prices, claims, and customer sales

At the founder's stall, set a price of 15, 20, or 30 credits, choose a truthful or misleading description, and explicitly serve the next customer. Keep the product's actual composition visible independently of the chosen claim. This checkpoint uses predictable prototype thresholds, rather than autonomous crowds or a balanced customer simulation.

Acceptance checks:

- E opens the sales panel nearby; E or Escape closes it. Price and claim controls work with keyboard and mouse.
- Serving is one deliberate action per customer; keyboard echoes and closed-panel input do not create transactions.
- A sale requires stock. Truthful claims sell at prices up to 20; misleading claims sell at prices up to 30. Rejection leaves business values unchanged and explains why.
- Successful sales consume one ring, add the price to cash and sales revenue, and give clear customer feedback. The first sales checkpoint gave truthful sales one reputation point; the timed-market revision gives +2 at 15 credits and +1 at 20.
- Each misleading sale records its price for a possible day-end refund; its full proceeds remain spendable. This supersedes the first sales commit’s reservation rule before merging.
- HUD and panels agree with the central business state. Movement and animation stop while interacting, without overlapping the supplier or board's lock.
- Relevant sales and purchase checks run because business state is shared; unchanged animation and prop-art evidence is reused.
- The project manager follows [the customer-sales walkthrough](customer-sales.md), checks panel readability and feedback on Windows, and approves the branch.

## Completed revision: day/night and uncertain refunds

The project manager tested sales, requested revised risk and time, and later merged the combined branch into `main` at `4093d6d`. This was a separate checkpoint commit within that combined pull request.

Acceptance checks:

- Misleading sale proceeds are fully spendable; no guaranteed complaint or cash reservation remains.
- Day end draws a uniform 10–25% daily probability and independently checks each misleading sale once. Truthful sales never generate this complaint. Small samples need not yield a 10–25% actual fraction.
- An affordable total refund batch deducts full prices, returns rings, reverses refunded revenue, and applies -5 reputation per refund. No partial settlement occurs.
- Requested refunds exceeding current cash lead to a terminal prison outcome. Purchases, sales, movement, and time stop; restart begins a fresh session.
- A repeating clock starts at 08:00, using an eight-real-minute full day. Midnight and the manual End day control share exactly-once settlement.
- Interactions and reports pause time; continue begins the next day, while large elapsed frames cannot skip multiple reports.
- Smooth outdoor canvas tint supplies daylight, dusk, and night, with legible untinted HUD and panels.
- Focused deterministic refund/time checks use seeded randomness and boundary probabilities; affected shared sales/purchase checks run. Existing art/animation evidence is reused.
- The project manager follows [day and refunds](day-and-refunds.md), tests daylight transitions and report/prison feedback on Windows, and approves the combined branch.

## Completed revision: one-minute market and reputation-driven attendance

The project manager chose midnight refund settlement so the 18:00 evening remains available for exploration and spending, tested the timed session, and merged the combined branch into `main` at `4093d6d`. Three feature commits became one shared checkpoint through squash and merge.

Acceptance checks:

- Start day at YOUR STALL freezes one quota: base 12, integer random variation -2..+2, plus floor(reputation / 5), clamped to 3..30. Reputation changes affect future days, not today’s frozen attendance.
- Visible customer sprites arrive one at a time; only the current ready visitor can be served. Accepted and rejected offers consume a visitor; lacking stock does not.
- Truthful 15-credit sales gain +2 reputation, while truthful 20-credit sales gain +1. Truthful describes the actual imitation materials, not genuine gold.
- A 60-real-second countdown continues through all menus; closing or reopening the stall cannot pause or reset it. Serving everyone early does not shorten the session.
- At the deadline, all remaining visitors leave and reputation falls by ceil(unserved / 5). Sales stop, other interactions close safely, and closing feedback plus a fade skip the calendar clock to 18:00.
- Closing is not refund settlement. Evening purchases remain available; midnight retains random refunds, revenue/item return, reputation penalties, and insolvency prison.
- Start day cannot repeat on the same calendar day. End day cannot bypass an active market or closing transition.
- Focused deterministic checks cover attendance, customers, deadline, ownership, transition, and midnight boundaries. The project manager follows [the timed-market walkthrough](market-session.md) before approving the combined branch.

## Completed milestone: apartment, travel, orders, and sleep

The project manager confirmed the market works and requested two playable areas, next-morning computer orders, reusable indoor artwork and furniture, and a sleep interaction. The preceding combined market milestone is merged into `main` at `4093d6d`. The project manager approved the checkpoint, and `9053091` was fast-forward merged and published to `main` after independent cloud verification. This does not claim an additional Windows playtest.

Acceptance checks:

- A fresh run starts in a modest, worn apartment with reusable floor/wall tiles and solid bed, TV, table, and computer desk scenes. Routes to the computer, bed, and door remain usable.
- Apartment door and plaza exit share a destination menu; travel costs 30 game minutes, with only the other area selectable for now.
- Cash, stock, reputation, calendar, refund exposure, and once-per-day market status persist across travel. Inactive scenery cannot render, receive input, or collide with the founder. Indoor lighting is separate from outdoor tint.
- Orders spend cash immediately, add no immediate rings, and deliver once at 08:00 the following day, with inventory and notification updated in either area. Playable instant supplier buying is superseded.
- Sleeping advances through midnight refunds before waking at 08:00 and delivering stock. An unaffordable refund batch blocks the remaining skip, wake-up, travel, and delivery.
- Market phases, modals, reports, and prison prevent conflicting travel/sleep/order actions. Calendar skips crossing midnight cannot bypass the financial report.
- Independent review inspects the shared clock/state/area boundaries and performs relevant focused checks; unchanged historical art and movement suites are reused.
- The project manager follows [apartment and deliveries](apartment-and-deliveries.md) on Windows, checks visual quality, collisions, paths, menus, timing, and feedback, then approves the branch.

## Completed milestone: save and continue

The project manager approved preserving money, inventory, pending paid deliveries, and game time across quitting. The project manager tested the save checkpoint and its empty-stock/plaza-boundary fix, then merged the combined result into `main` at `df67f0a`.

Acceptance checks:

- Continue / New game offers one local save slot. Missing saves disable Continue; replacing an existing run requires confirmation.
- Save (F6), Save & Quit, and normal window closing preserve business values, refund exposure, calendar, area/position, pending orders, price/claim choices, and market eligibility.
- An active market retains its attendance, processed visitors, arrival delay, and remaining countdown. Closing penalties, deliveries, and settled refunds cannot repeat after loading.
- Financial reports, interrupted travel/sleep, and prison resume coherently; continuing a saved report applies only the remaining work.
- Save data is validated before changing the game. A valid backup can recover an unreadable primary with a warning; unreadable files are not overwritten just by launching. Failed saves report the failure and prevent Save & Quit from closing.
- The pre-merge stock fix prevents a zero-inventory market from starting, including when paid orders are pending, without changing attendance RNG, timer, or today’s eligibility. Rejected opening leaves travel available; exhausting stock during a valid session retains its countdown and travel guard.
- Reusable physical plaza edges keep the whole founder on screen while allowing access to the exit. They disable in the apartment; older out-of-bounds plaza save positions restore inside the safe area without changing save format or business data.
- Relevant regression checks, separate-process save/quit/reload checks, and rendered interface inspection run. The project manager follows [save and continue](save-and-continue.md) on Windows before approving this checkpoint.

## Current milestone: business UI and modular interior polish

Work is on `feat/business-ui-interiors`, based on merged `df67f0a`. The project manager requested clearer business UI and reusable indoor wall borders, drywall/window tiles, and additional furniture. Existing save data, delivery timing, refund rules, and market duration must remain compatible.

Acceptance checks:

- HUD distinguishes spendable cash, available inventory, pending delivery, reputation, and calendar time.
- Computer previews quantity, total price, and delivery date; keyboard and mouse cannot bypass affordability or award stock immediately.
- Stall shows the visitor, offer choices, and countdown clearly; zero-stock opening stays disabled.
- Market closing at 18:00 and midnight refund settlement remain visibly distinct.
- Four visible room edges match solid boundaries; routes to bed, computer, and door remain clear.
- Drywall/windows and furniture are separate reusable resources/scenes. Solid furniture inherits collision; a floor mat remains walkable.
- Focused checks and actual rendered inspection run; Windows visual quality and merge approval remain the project manager's checkpoint.

See [business UI and interiors](business-ui-and-interiors.md) for the current implementation and review evidence.

## Later milestones

Customer variation and further indoor environments need separate scoped design and review. The [design brief](game-design.md) defines acceptance across the first complete business loop. Research, precious-material suppliers, staff, boutiques, supply chains, and luxury competition remain later goals. Multiple save slots, cloud synchronization, and a final balanced economy remain deferred.

## Task handoff template

- Goal and what the project manager will observe.
- Included work and deferred work.
- Assigned role and branch.
- Acceptance checks and who runs each check.
- Files or systems likely to change.
- Review findings, fixes, and remaining limitations.

Each completed milestone should teach a small concept and leave a checkpoint that is easy to review and maintain.
