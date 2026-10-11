# Business UI and reusable interiors

This review milestone is on **`feat/business-ui-interiors`**, based on merged **`df67f0a`**. It improves presentation and reusable room construction. Existing prices, next-morning deliveries, midnight refunds, 60-second selling, and version-1 saves remain the baseline.

## Business screens

The HUD separates **cash**, **reputation**, **available rings**, and **on-order rings**. Pending goods are paid for but cannot be sold. The calendar and active market countdown remain visible separately. Total sales are revenue, not profit: stock costs and refunds are separate cash movements.

At the apartment computer, choose a quantity before ordering. The default is one ring, and the button previews its total cost. Clicking it or pressing **B** uses the selected quantity. Unaffordable batches are disabled, and keyboard input cannot bypass the underlying affordability check. Payment remains immediate; the order arrives on the following calendar day at **08:00**. Ordering after midnight means the morning after that new calendar day, rather than that morning.

The stall keeps **S/P/C/N** for Start, Price, Claim, and Serve. Its panel identifies materials, customer, selected offer, and remaining service time. Closing it with **E/Escape** does not stop an active countdown. Available stock is required to start; paid pending orders do not qualify.

The **6pm market report** describes attendance and missed-customer reputation loss. The **midnight settlement report** describes requested refunds and cash before/after settlement. Closing the market does not settle refunds or reserve sale proceeds.

## Reusable Godot pieces

A `Theme` resource provides shared colours, rounded panel borders, spacing, and button states. Screens retain their existing scene paths and transaction controllers; changing presentation does not serialize visual nodes into a save. `Control` containers arrange text and actions rather than requiring every label to have a fixed position.

The apartment's cutaway room shell is a separate scene. Its exported local floor rectangle and wall thickness define four physical edges. Continuous opaque wood/plaster profiles draw the cutaway borders, with matching straight endpoints. A copied room can reuse that scene; resizing its boundary still requires matching its tile layers and furniture placement. The shell is visible in the editor, while its solid bodies are created when gameplay starts. Inactive areas disable those bodies along with the rest of their scenery.

Floor and wall `TileSet` resources remain reusable. The wall atlas has named source IDs **0 drywall**, **1 window**, and **2 doorway**, each occupying a common 96 × 72 game-pixel face in the starter layout, beneath one continuous header. Standalone solid scenes expose each wall variant as a **96 × 108** panel with its header/base, plus matching front, side, and corner pieces. A doorway texture alone does not implement travel: the existing door proximity interaction owns that behavior. The empty starter floor receives default painting. The empty wall layer receives only its two window cells; continuous plaster comes from the shared underlay. Drywall source 0 remains available for manual painting. A nonempty manually painted layer is preserved. Furniture stays in separate prop scenes rather than becoming part of a flat room image. The new sink, dining table, and floor lamp scenes inherit grounded solid footprints; the floor mat is walkable and draws beneath the player. Existing bed, TV, table, desk, and travel-door scenes remain reusable. The lamp has decorative illumination in its artwork, without dynamic light beams. This is an interior construction kit, not a player decorating or furniture-snapping system.

## Reuse the kit in Godot

1. Open an indoor scene and drag a prop scene from `scenes/props` into its scene tree. Instances of `sink.tscn`, `dining_table.tscn`, and `floor_lamp.tscn` already include solid footprints; `floor_mat.tscn` is decorative and walkable.
2. Select **WallTiles**, open its TileMap painting tools, and choose the named source: **0 drywall**, **1 window**, or **2 doorway**. Paint cells to replace the default layout. A nonempty manually painted layer is preserved when the room starts.
3. Instance `interior_room_shell.tscn` for visible borders and matching physical edges. Adjust its **Floor Bounds** to your room, then match the floor/wall painting, prop placement, and arrival point. Resizing the shell does not automatically redesign the room.
4. Add the existing room-interaction scene separately when an object needs computer, sleep, or travel behavior. Wall textures and decorative props do not automatically create those actions.

## Try the checkpoint

1. Close Godot, fetch, select **`feat/business-ui-interiors`**, and pull. Reopen in Godot 4.7.2 and press F5.
2. Continue an existing save or start a fresh run. Check the room borders, furniture scale, and clear routes to the computer, bed, and door.
3. Open the computer. Change quantity and inspect cost/delivery before ordering. Compare cash, available rings, and pending rings in the HUD. Try an unaffordable batch using both mouse and B.
4. Sleep through the midnight report. Verify delivery moves pending rings into available inventory exactly once.
5. Travel to the plaza, sell using keyboard and mouse, and check customer/offer visibility during the real countdown. Compare the 6pm report with the later midnight report.
6. Save with F6, reopen, and Continue. Business values and market progress should retain their previous behavior.

## Verification

The reviewer independently ran the new business-UI suite on Godot **4.7.2**: **23 passed, zero failures, exit 0**. It covers selected-quantity mouse/B purchases, insufficient funds, default quantity reset, immediate payment versus pending stock, delivery HUD refresh, distinct evening/midnight report text, and actual resolved container geometry at 960 × 540. The geometry checks cover active selling with its start feedback, clear HUD/clock space, and normal, prison, and 6pm reports. The coding agent also passed the unchanged affected **43 market**, **119 save/continue**, and **33 stock/boundary** checks. Existing actual stall input and countdown evidence is reused from the market suite.

The reviewer independently ran **47 interior checks**, zero failures, exit 0. Real player movement checks cover four room borders, the sink/table/lamp footprints, full rug crossing, and approach routes to computer, bed, and door. The suite also checks textured solid wall pieces, paintable wall variants, preservation of manually painted layers, and disabling/restoring shell collisions across travel. The coding agent passed **41 affected apartment checks** after updating the fixture for the reusable shell. A route fixture initially crossed the existing table; the corrected path passes through the actual free corridor, without changing existing furniture positions.

The reviewer inspected final actual **960 × 540 Compatibility renders** of the room, quantity-5 computer order, active stall, 6pm report, midnight report, and prison report. The UI and furniture read clearly at gameplay size. Wall continuity requires its own rendered inspection in addition to collision checks. The active panel leaves the cash/inventory HUD and countdown visible; all three reports and their buttons fit inside the viewport. Rendered inspection initially found heading/HUD overlap and a clipped midnight panel. The headings were moved clear, the stall was compacted below the HUD, and the financial panel repositioned; the final captures and new geometry assertions verify those corrections.

These controlled captures position the founder, pause calendar progression/customer arrival, and request report presentation directly. They establish appearance and text fit rather than a new full sale-to-midnight simulation. Movement, delivery, transactions, and timing evidence comes from the focused and affected suites. No Windows playtest is claimed. Windows visual review and merge approval remain outstanding.

## Pre-merge wall correction

Illustrated caps with angled, transparent edges do not join cleanly when repeated. Continuous wall material profiles replace them, with straight runs, aligned drywall/window sections, and corner joins inspected at normal **960 × 540** gameplay size. This changes wall presentation while preserving existing solid room boundaries, furniture positions, manual painting, and gameplay. The shell and standalone wall templates share `interior_wall_profile.gd`, with fixed-scale material patches clipped at segment ends instead of stretched textures or transparent end caps. Translated pieces at their default scale and orientation share world-aligned texture phase, so adjacent runs align the material grain. Rotating or scaling pieces retains their local profiles but does not promise that same world texture alignment. The rear face uses a continuous opaque plaster underlay and separate cropped window frames below one continuous header and above one continuous baseboard. Rear trim draws behind furniture, so its horizontal rail does not cover the computer monitor or sink faucet; front and side borders retain their foreground depth. Exported profile settings redraw in the editor. The revised focused interior suite independently passed **49 checks**, zero failures, including rear-trim layering and opaque material coverage; unrelated UI/save suites were not repeated. Existing UI and save evidence is reused; only affected interior checks are repeated.

The reviewer inspected the final apartment and a joined standalone-wall fixture, both rendered at **960 × 540**. Left/right runs and the front face have straight continuous outlines; their corner contacts contain no background gaps or stepped transparent caps. Rear drywall/window frames share a continuous header, plaster face, and baseboard. The apartment monitor, faucet, and bed posts remain visible in front of rear trim. The fixture verifies reusable segment joins separately from the room shell. These are visual presentation checks; the 49 focused assertions supply collision and area-activation evidence. The project manager still decides whether the revised appearance meets the desired art quality before merging.
