# Save and continue

This checkpoint is on **`feat/save-continue`**, based on the approved apartment checkpoint `9053091`. It is a review branch, not merged into `main`.

## How to play

The game now opens a **Continue / New game** screen. Continue is enabled when a valid saved run is available. New game starts with 100 credits in the apartment. If a save already exists, a confirmation lets you cancel before replacing it. The prison restart button uses the same confirmation.

Use **Save (F6)** or **Save & Quit** in the lower-right corner. During the roughly 1.4-second market closing transition, the mouse buttons are explicitly disabled; **F6 still saves immediately**. The buttons re-enable when the closing report appears. Closing the game window normally also saves. On reopening, choose Continue. A successful save displays “Business saved.” If writing fails, the game reports the failure and stays open; keep playing or retry saving after resolving the storage problem. Starting a new run also requires a successful initial save before replacing the old game.

The save contains cash, stock, revenue, reputation, unpaid refund exposure, last settled day and report, calendar time, pending paid orders, area, player position/facing, current price/claim choices, and market progress. An active market keeps its frozen attendance, processed visitors, arrival delay, and remaining seconds. The clock does not advance while the application is closed. Ordinary shop, sign, and travel menus close on reload, without leaving movement locked. A plaza position outside the new visible play area is clamped to its safe rectangle on restoration, so saves from before the plaza boundary fix remain usable. Apartment positions are unaffected. Financial and market-closing reports reappear. Sleep or travel interrupted by midnight resumes its remaining time only after Continue. Prison remains terminal.

The save also stores the random generators for attendance and refunds. Continuing a saved run cannot reroll the same future draw merely by recreating those generators. Reopening a settled report displays the saved result instead of settling again. Delivered orders have already left the pending queue, so loading cannot deliver those rings twice.

## One local slot and recovery

Godot stores the slot at **`user://business-save.json`**, outside the repository. `user://` is Godot's writable application-data folder; use the editor's **Open User Data Folder** command to inspect it. Its location depends on the operating system and configured XDG folders. Tests use separate named files and never use the player's slot.

A complete new file is first written and flushed to `.tmp`. The previous valid primary is copied to `.bak` through its own temporary file, then the new primary is installed by a rename. Write failures do not delete the existing primary. A malformed primary never replaces a valid backup. Temporary files left by an interrupted write are ignored on startup.

Loading validates the version, required data types, bounded values, and related phase/date fields before applying any state. It never loads nodes or executable objects. If the primary is invalid or missing but the backup is valid, Continue uses the backup and the start screen explicitly warns that recent progress may be missing. If neither is readable, Continue stays disabled and the files remain untouched until the player explicitly confirms a new run. Keep a separate copy before replacing a save you want to investigate.

## Small implementation map

- `scenes/game.tscn` is the new entry scene. It wraps the existing `main.tscn` gameplay and the save UI, so existing isolated gameplay fixtures remain unchanged.
- `scripts/save_game.gd` owns the title screen, confirmation, Save/F6, normal quit handling, and save feedback.
- `scripts/save_snapshot.gd` captures, validates, and restores version-1 data. RNG seed/state use decimal strings because JSON floating-point numbers cannot represent every 64-bit integer exactly.
- `scripts/save_store.gd` reads the primary/backup and writes via temporary files. The controller's exported `save_path` makes tests independent of real player data.
- `day_cycle.gd` separates displaying an existing report from settling it. `market_session.gd` reconstructs closing presentation without applying the penalty again.

The save format is intentionally explicit: adding a new gameplay state field later requires deciding whether it belongs in the snapshot and adding a corresponding test. There is no generic serialization of the scene tree.

## Try it on Windows

1. Fetch and check out `feat/save-continue`; import the project in Godot 4.7.2. Press F5. Choose New game, or Continue if you already have a saved run from this branch.
2. Walk to the computer and order three rings. Save, close the game window, relaunch, and Continue. Expect cash 70, no available rings, and three paid pending rings. Your location should be restored; reopen the computer normally.
3. Sleep. While the midnight report is open, use F6 or close the game window. Relaunch and Continue: the same report must reappear. Continue it and receive three rings at day 2, 08:00. Save and reopen again; stock must remain three.
4. Before delivery, visit the plaza with zero available rings: Start day must be disabled even if orders are pending. S must leave the day unused, and Escape must let you walk to the exit and return home. After delivery, travel to the plaza, start a market, and sell a ring. Save & Quit during the minute. Continue: attendance, served count, and remaining countdown should resume. Finish the market, save during its report, and reload. Continue and make a round trip; today’s market must not restart.
5. Try New game from the title screen and Cancel. Continue must still restore the old run. Confirm New game only when you intend to replace it. The prison restart action also requires confirmation.
6. Check title, buttons, notices, confirmation, and restored reports at normal game size. Report any Windows save errors or visual issues before merge approval.

## Pre-merge regression fix

After the initial save review, the project manager found that a zero-stock market could start before morning delivery. Start now rejects that route before consuming RNG, attendance, timers, or today's eligibility. Plaza edges now use reusable physical walls, and restoration clamps only plaza positions into their safe rectangle. Save version, primary/backup write rules, business data, and refund RNG serialization are unchanged.

For this fix the coding agent passed **119 save/continue**, **43 market**, **41 apartment**, and **33 new stock/boundary checks**. The reviewer independently passed the **33 new checks**. The focused suite includes restoring older outside-plaza positions without resetting business values or market eligibility, plus preserving apartment positions and disabling inactive plaza walls. Separate-process save evidence below is reused from the initial review; those processes were not rerun for this fix. See [market-session](market-session.md#pre-merge-stock-and-plaza-boundary-fix) for the implementation and playtest steps.

## Initial save/continue verification evidence

Godot **4.7.2.stable.official.ed1daf0bf** import completed without script errors. The focused save suite passed **119 checks, zero failures**. Affected regression suites passed: **41 apartment**, **43 market-session**, **37 day/refund**, **32 sales**, and **25 purchase** checks, for **297 assertions** in total. All test processes exited 0. The three separate-process phases below also completed successfully, including the failure-to-save quit guard.

Thirteen actual **960 × 540** Compatibility renders were inspected: New game, paid orders with save feedback, saved midnight report, Continue, restored report, morning delivery, replacement confirmation, plaza, write failure, backup recovery, unreadable save, closing with disabled buttons/F6 feedback, and the closing report with re-enabled buttons. The sequence restored the midnight report, then reached day 2 08:00 with cash 70 and three rings, and travelled to the plaza at 08:30. The final save controls sit at the lower right, clear of the plaza exit prompt; recovery and error text fit. These captures use frozen calendar progression and positioned interaction fixtures for stable inspection. Automated movement/collision evidence from the unchanged apartment checkpoint is reused; no new full manual route or Windows playtest is claimed.

Independent review identified input-order differences after replacing the game scene. Real F6 events reproduced four failures on the original checkpoint: closing notice and fade after both New game and prison restart. A separate real-mouse reproduction confirmed that both enabled-looking toolbar buttons were swallowed by closing's input guard. Replacement gameplay now retains the original sibling position, keeping the save controller first for F6 input. Mouse save controls are explicitly disabled during the transition and re-enabled by the market's changed signal. Regression coverage sends real F6 and mouse events after New game, Continue, and prison restart, inspects written files, rejects echoed saves, and verifies the enabled Save button writes the final report. No economy or market-timing behavior changed.

The confirmation test sends real mouse events through the embedded dialog's window coordinates. Regression coverage includes canceling and confirming both title-screen replacement and prison restart. A separate boundary case verifies saving a report after the existing End day shortcut skips past a pending 08:00 delivery, then releasing those goods exactly once on Continue. Unchanged art and movement suites were not rerun. Windows review remains outstanding.

From the repository root, use the configured cloud executable and writable user directories:

```bash
env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_save_continue.gd
```

The focused suite exercises disk round trips, orders before/after midnight, delivery at 08:00, nonzero refund restoration, RNG preservation, active/finished markets, closing fade/report, interrupted sleep/travel, prison, schema rejection, missing/corrupt saves, backup recovery, write failures, title/confirmation controls, F6, and Continue.

The separate-process check runs three commands in order, using its own disposable slot:

```bash
for phase in write read finish; do
  env XDG_DATA_HOME=/workspace/tools/data XDG_CONFIG_HOME=/workspace/tools/config XDG_CACHE_HOME=/workspace/tools/cache /workspace/tools/godot/bin/godot --headless --path jewel-rpg --script res://tests/verify_save_process.gd -- --phase="$phase" || exit 1
done
```

This closes the first process through the window-close handler during an interrupted sleep report, restores and continues it in a second process, finishes a market and exits through an actual mouse Save & Quit click on its closing report, then verifies in a third process that delivery did not repeat and a failed quit-save keeps the application running. The last process removes its isolated test slot.

## Limits

There is one local slot per Godot user-data folder, with one previous-save backup. Run one game instance at a time. No cloud sync, multiple profiles, import/export UI, older-format migration, or protection against deliberate save editing is included. Force-killing the process, editor Stop/F8, a crash, or power loss can bypass normal quit handling; progress then returns to the most recent successful save or backup. Use F6 before editor Stop. Filesystem rename/flush checks and backup recovery reduce accidental loss but do not promise crash-proof storage. Ordinary menus and transient delivery banners are not restored; inventory and pending queues are authoritative. Cosmetic customer actors are rebuilt, while attendance and transaction state remain unchanged.
