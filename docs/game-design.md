# Jewel RPG: modern jewellery business

## Direction

A modern 2D business RPG about growing from a modest market pop-up into a globally recognised jewellery brand. Business decisions should have understandable consequences; dialogue, customers, and industry absurdity provide playful humour. Stardew Valley, Chef RPG, and Graveyard Keeper inform the approachable pacing and characterful world, not historical fantasy aesthetics or copied assets.

Learning agentic coding, Git, and Godot remains a project goal. Small learning milestones must also build a readable, coherent, enjoyable game.

## Player journey

1. Pop-up seller: inexpensive imitation goods, limited cash, stock, prices, customer conversations.
2. Independent designer: better materials, reliable suppliers, tools, authenticity knowledge, original designs.
3. Boutique owner: displays, staff, customer service, reputation, shop costs.
4. Growing brand: multiple shops, production, supply chains, stock allocation.
5. Luxury challenger: prestigious collections and rivalry with an original fictional luxury group.

The rival's name and currency identity are undecided. Use no real luxury logos or branded counterfeit assets. Tech trees, staff, boutiques, and logistics are future design goals, not requirements for the first prototype.

## Materials, claims, and choices

The player initially cannot afford precious materials and can source only imitation goods. Start with plated brass and simulated stones. These can be sold honestly as costume jewellery; poor starting capital does not force deception.

Keep actual composition separate from the sales claim. The same ring can be truthfully labelled "Gold-tone plated brass; simulated stone" or misleadingly described as "Solid gold; genuine gemstone". Price and claim are separate decisions. Expensive pricing alone is not proof of fraud.

Questionable sourcing and misleading claims are player choices. They may produce immediate sales opportunities but later refunds, distrust, complaints, and supplier problems. Genuine materials do not automatically mean responsible sourcing. Supplier ethics and authenticity complexity are deferred beyond the first loop.

## First playable business loop

One contemporary market stall, one apartment computer, one product, and one customer encounter at a time:

1. Inspect the product's actual materials and order stock at the apartment computer. Orders consume cash immediately and arrive the next day at 08:00.
2. Set a price and choose a sales claim.
3. Start a 60-real-second market session at the stall; serve arriving customers and hear purchase or rejection responses.
4. See cash, stock, sales revenue, and reputation update.
5. Close at the session deadline, skip to 18:00, then explore or reinvest before midnight resolves requested refunds.
6. Travel home, order tomorrow's stock, and sleep until 08:00. Midnight refunds settle before waking and delivery. Save and Continue preserve the run between sessions; starting a new game deliberately replaces it.

The first encounter checkpoint used a repeatable explicit Serve action. The timed-market revision supersedes that unlimited flow: Start day freezes one reputation-dependent quota, sprites arrive one at a time, and each valid offer serves one visitor. A sale or price rejection consumes that visitor; lacking stock does not. Customers communicate why an offer succeeds or fails. Decorative customer movement is not navigation or pathfinding.

## Placeholder economy v0

All figures below are deliberately artificial development values in credits. They are not balanced, real material prices, or a final economy. Keep implementation values together in a small economy configuration rather than scattered through UI scripts.

| Parameter | Prototype value |
|---|---|
| Starting cash | 100 credits |
| Starting stock | 0 rings |
| Product | Plated brass ring with a simulated stone |
| Supplier unit cost | 10 credits |
| Purchase quantity | 1 ring per action |
| Price options | 15, 20, or 30 credits |
| Default price / claim | 20 credits / truthful |
| Customer maximum, truthful description | 20 credits |
| Customer maximum, misleading description | 30 credits |
| Starting reputation | 0; signed integer with no prototype clamp |
| Successful truthful sale | +2 reputation at 15 credits; +1 at 20 |
| Daily visitor quota | clamp(12 + integer jitter from -2 to +2 + floor(reputation / 5), 3, 30) |
| Market session | 60 real seconds, including time in menus |
| Unserved visitor penalty | -ceil(unserved / 5) reputation at closing |
| Complaint resolution | Full refund, item returned, -5 reputation |

At day end, draw one daily complaint probability uniformly between **10% and 25%**, then independently roll that probability for each misleading sale recorded that day. Truthful sales cannot produce this complaint. The range describes a probability, not a quota: a small day's actual fraction can be zero, all, or anywhere between. Do not guarantee one refund per misleading sale or reroll settled sales. These remain placeholder risk values, not a final balance.

All sale proceeds immediately become spendable cash. Nothing is reserved for possible refunds. Before paying any day-end refunds, add their full sale prices and compare the total with current cash. If cash covers the total, settle the whole batch once: subtract the total, return one ring for each refund, reverse the corresponding sales revenue, and apply -5 reputation per refunded sale. If requests exceed cash, the founder goes to prison and the run stops; do not partially pay refunds or silently forgive the shortfall. No purchases, sales, player movement, or time progression continue in prison. A confirmed restart creates a fresh run. Continue preserves prison and cannot bypass it.

A rejection changes no cash, stock, or reputation. A sale requires stock, subtracts one ring, and adds the asking price to cash. An order requires cash >= 10 and immediately subtracts 10 cash per ring. It creates pending stock for the following day at 08:00; available inventory changes only when delivery arrives. Cash and stock never become negative; rapid repeated input must not duplicate a single transaction.

Example: start with 100 and order one ring (cash 90, available stock 0, pending 1). After the next 08:00 delivery, stock is 1. Sell truthfully for 20 (cash 110, stock 0, reputation 1). Net trading profit is 10. A misleading sale for 30 instead leaves cash 120, stock 0, revenue 30, reputation 0; all 120 credits can be spent. If that sale produces no refund at day end, those figures remain. If its refund is requested and affordable, cash becomes 90, stock 1, revenue 0, reputation -5. If the founder spent cash below 30 first, that requested refund instead ends the run in prison. The returned ring retains its real composition.

## Market time

A configured full 24-hour day lasts eight real minutes and begins at 08:00. Without opening the market, the initial remaining sixteen game hours take five minutes twenty seconds. A market session instead holds the clock for its minute and skips to 18:00 at closing; the six-hour evening then takes two real minutes outside paused interactions. Later days begin at midnight. Outside the active market, the calendar clock pauses during an interaction or report and stops after imprisonment. The calendar clock pauses throughout the active market and its closing transition; its separate 60-second countdown keeps running through interactions. Once the deadline expires, a closing notice and fade advance the clock to 18:00. Refunds remain unsettled during this evening. Midnight automatically settles the day; the existing manual End day shortcut can settle early only outside the active market and transition. Both settlement paths use the same operation and cannot settle a day twice.

Outdoor world colour moves smoothly through daylight, sunset, and night. A Godot `CanvasModulate` changes the world canvas tint, while HUD and panels in separate `CanvasLayer`s remain readable. This supplies ambient colour rather than new lamp beams or dynamic shadows. The apartment uses a separate indoor canvas without the outdoor tint, while the same calendar continues across both areas.

Cash balance, sales revenue, and profit are different. Buying stock lowers cash but creates inventory; selling generates revenue; refunds reverse revenue. Prototype realised trading profit counts unrefunded sales minus the cost of their sold units. A full refund with the item returned reverses both its sale revenue and its recognition as a sold unit's cost, restoring that cost to inventory. Unsold or returned stock is not automatically a realised loss. Rent, wages, taxes, and full accounting are deferred.

## Acceptance for the first loop

- The scene reads as a present-day modest jewellery stall; the founder and merchandise are readable at normal game size.
- The player can buy, price, choose a claim, sell, resolve a complaint, and repeat.
- Actual materials remain visible to the player regardless of sales claim.
- Acceptance/rejection matches the prototype price thresholds and stock requirements.
- Cash, stock, revenue, reputation, and transaction feedback agree; all sale proceeds are spendable.
- Truthful and misleading routes are both testable; eligible misleading sales persist until day end, refunds are rolled once, and unpaid totals lead to prison.
- Start day freezes a quota based on current reputation and one random variation; reopening menus cannot reroll it. A market can run only once per calendar day.
- Market time lasts 60 real seconds even through menus. Unserved customers leave at the deadline with a small reputation penalty; a fade skips to 18:00, leaving refunds for midnight.
- Midnight and permitted manual day end share settlement; calendar time pauses during interactions/reports and the market, and stops in prison. World tint changes smoothly while UI remains readable.
- Insufficient funds or stock gives clear feedback and does not corrupt state.
- Focused transaction checks cover changed business rules; Windows playtesting covers readability, navigation, feedback, and enjoyment.

## Delivery order

1. Review this brief and [the modern art guide](art-guide.md).
2. Replace fantasy-styled founder and workshop direction with one modern market-stall scene; preserve useful movement and interaction code.
3. Implement purchases and visible cash/stock only.
4. Implement prices, claims, one explicit customer sale/rejection, and truthful-sale reputation.
5. Implement day/night progression, uncertain day-end complaints, refund/item return, revenue reversal, reputation penalties, and prison for an unaffordable refund batch.
6. Refine selling into one finite 60-second session per day, with reputation-dependent attendance, visible customer arrivals, closing feedback, and evening before midnight settlement.

7. Add a modest apartment, reusable indoor tiles and furniture, computer ordering with next-morning delivery, shared travel destinations, and a bed that advances through midnight settlement before waking.

The first sales checkpoint used guaranteed complaints and cash reservations. The project manager superseded that rule before merging the combined market milestone at `4093d6d`; proceeds are fully spendable with random day-end risk. The apartment milestone supersedes instant supplier purchases in playable sessions; the legacy purchase implementation remains available to historical isolated checks.

Each step normally has its own branch, focused checks, independent review, and project-manager approval. The project manager may authorize several separately committed checkpoints on one branch for a combined pull request; this does not skip focused review or final merge approval. The entire business loop is the destination across several milestones, not the next single coding assignment.


## Apartment, travel, and deliveries

Start a fresh run in a small, worn modern apartment. Reusable floor and wall tiles, a bed, table, TV, and computer desk establish a starter interior rather than a finished housing/decorating system. Solid furniture blocks movement by default. The computer displays actual imitation-ring materials and the unit cost. Ordering pays immediately and queues stock for **08:00 on the following calendar day**; it does not hand over rings immediately. Delivery adds inventory and gives a notification whether the founder is indoors or in the plaza.

The apartment door and plaza exit open one reusable destination menu. Each exposes only the other location for now. Travel advances **30 game minutes**, preserves inventory, cash, reputation, refund exposure, and today's market status, and activates only the destination area's rendering, input, and collision. Neither travel nor sleeping can bypass an active market, closing transition, financial report, or prison.

The bed advances to the next 08:00, including midnight settlement first. An affordable refund report must be continued before the remaining sleep time and delivery are applied. Insolvency ends the run before wake-up or delivery. Ordering before midnight is therefore a choice between tomorrow's stock and keeping enough cash for possible refunds; the prototype deliberately reserves no refund money. Orders placed on day D are due on day D+1 at 08:00, including orders placed early on day D. Cutoff and timing are explicit placeholder rules. The save/continue checkpoint preserves this state between sessions. There is no placement editor or housing upgrade system yet.


## Save and continue

One local save slot preserves the complete business session, including pending paid stock, refund exposure, the financial report, and the once-per-day market gate. The start screen offers Continue or a confirmed New game. Save (F6), Save & Quit, and normal window closing write the current state. Calendar and market time do not advance while the application is closed. Ordinary interaction menus close on loading; the founder resumes in the saved location. Financial and closing reports retain their decisions and required Continue action.

Saving during a market retains its remaining countdown and frozen attendance rather than reopening a new session. Refund and attendance random-generator states are preserved, so an ordinary save/reload does not reroll them. A prior valid snapshot is retained as a backup; recovery warns that the latest progress may be missing. Force-killing the process or stopping it through the editor can bypass window-close saving, so use F6 before those actions. This is local persistence, not cloud synchronization, anti-cheat, or crash-proof transaction storage. See [the walkthrough](save-and-continue.md).
