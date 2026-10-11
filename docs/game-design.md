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

One contemporary market stall, one supplier interaction, one product, and one customer encounter at a time:

1. Inspect the product's actual materials and buy stock.
2. Set a price and choose a sales claim.
3. Start a customer encounter and hear the purchase or rejection response.
4. See cash, stock, sales revenue, and reputation update.
5. Resolve any scheduled complaint when ending the prototype market day.
6. Reinvest or start another day. Restart is available while save/load is absent.

Use an explicit "Serve next customer" interaction initially rather than autonomous crowds, queues, pathfinding, or timers. Customers can have short humorous dialogue and visible reactions. They must communicate why an offer succeeds or fails.

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
| Successful truthful sale | +1 reputation |
| Complaint resolution | Full refund, item returned, -5 reputation |

For predictable verification, every successful misleading sale schedules one complaint for the end of that prototype day. This intentionally exposes the consequence path; it makes deception financially unattractive in this first model and is not a final risk/reward design. Later balance can introduce varied customer knowledge, detection chances, timing, and recovery opportunities.

Hold each pending refund amount as reserved cash: available cash = cash - pending refunds. Purchasing cannot spend reserved cash. "End day" resolves each complaint exactly once, subtracts the sale price, returns one ring, applies the penalty, and clears its reservation. No mandatory day-end fee or automatic stock order. The player can always end the day without making a purchase.

A rejection changes no cash, stock, or reputation. A sale requires stock, subtracts one ring, and adds the asking price to cash. A purchase requires available cash >= 10, subtracts 10 cash, and adds one ring. Cash and stock never become negative; rapid repeated input must not duplicate a single transaction.

Example: start with 100, buy one ring (cash 90, stock 1), sell truthfully for 20 (cash 110, stock 0, reputation 1). Net trading profit is 10. A misleading sale for 30 instead leaves cash 120, stock 0, available cash 90, reputation 0; end-day refund leaves cash 90, stock 1, reputation -5. The returned ring retains its real composition.

Cash balance, sales revenue, and profit are different. Buying stock lowers cash but creates inventory; selling generates revenue; refunds reverse revenue. Prototype realised trading profit counts unrefunded sales minus the cost of their sold units. A full refund with the item returned reverses both its sale revenue and its recognition as a sold unit's cost, restoring that cost to inventory. Unsold or returned stock is not automatically a realised loss. Rent, wages, taxes, and full accounting are deferred.

## Acceptance for the first loop

- The scene reads as a present-day modest jewellery stall; the founder and merchandise are readable at normal game size.
- The player can buy, price, choose a claim, sell, resolve a complaint, and repeat.
- Actual materials remain visible to the player regardless of sales claim.
- Acceptance/rejection matches the prototype price thresholds and stock requirements.
- Cash, reserved refunds, available cash, stock, reputation, and transaction feedback agree.
- Truthful and misleading routes are both testable; scheduled complaints persist within the running session and resolve once.
- Insufficient funds or stock gives clear feedback and does not corrupt state.
- Focused transaction checks cover changed business rules; Windows playtesting covers readability, navigation, feedback, and enjoyment.

## Delivery order

1. Review this brief and [the modern art guide](art-guide.md).
2. Replace fantasy-styled founder and workshop direction with one modern market-stall scene; preserve useful movement and interaction code.
3. Implement purchases and visible cash/stock only.
4. Implement prices, claims, one explicit customer sale/rejection, truthful-sale reputation, and immediate refund reservations so purchasing cannot spend protected cash.
5. Implement day-end complaint resolution, refund/item return, revenue reversal, and reputation penalties.

Each step normally has its own branch, focused checks, independent review, and project-manager approval. The project manager may authorize several separately committed checkpoints on one branch for a combined pull request; this does not skip focused review or final merge approval. The entire business loop is the destination across several milestones, not the next single coding assignment.
