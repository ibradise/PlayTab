# PS Zone Game Tracker: PRD

_Offline mobile app for a PlayStation zone owner to track who loses each game and how much each person owes._

## 1. Problem

A PlayStation zone has several TVs (currently 2 TVs, 2 PS4s). Two people play per TV, mostly EA Sports football. The loser of each game pays 15 birr. The loser is replaced by a waiting player, and pays their total only when they leave. With many games and rotating players, the owner loses count of who lost what, so he charges incorrectly. This gets worse as TVs are added.

## 2. Goal

Let the owner record each game result with one tap, and always know exactly what each person owes. Also show win/loss stats per person and head-to-head.

## 3. User

One user: the zone owner, using the app on his phone at the counter. Players never use the app.

## 4. Constraints

- Fully offline. All data stored on the phone (local database). No backend, no login, no sync in v1.
- Fixed price: 15 birr per lost game. Store as a setting (`price_per_game`), never hardcode.
- Fast input. Recording a game must take 1 to 2 taps. Typing only when creating a new tab.
- Scales to more TVs. Stations are a list; adding one must not change any logic.
- Currency label: birr.

## 5. Core concepts

- **Tab**: one person's running bill. Has an auto number (#1, #2, ...) and a free-text label (a name like "Abebe" or a description like "red shirt", "blue shoes"). Stays open until the person pays and leaves. A tab is the person's identity in the app. Real names are NOT required.
- **Station**: one TV/PS. Holds up to 2 tabs currently playing.
- **Game**: one finished match. Records station, winner tab, loser tab, time.
- No waiting queue in v1. The owner remembers who is waiting and picks them from the open tabs list when it's their turn — except that when exactly one tab is waiting, it is auto-placed after a loss (see Main flows).

## 6. Data model

### Tab

- `id`
- `number` (auto-increment, shown as `#N`)
- `label` (text, optional but encouraged)
- `status`: `open | closed`
- `created_at`, `closed_at`

### Station

- `id`
- `name` (e.g. "TV 1")
- `slot_a_tab_id` (nullable)
- `slot_b_tab_id` (nullable)

### Game

- `id`
- `station_id`
- `winner_tab_id`
- `loser_tab_id`
- `played_at`
- `price` (snapshot of `price_per_game` at that time)

### Payment

- `id`
- `tab_id`
- `amount`
- `paid_at`

### Setting

- `price_per_game` (default 15)

### Derived values (never stored, always calculated from records)

- Amount owed by a tab = sum of price of games it lost, minus sum of its payments
- Games played / won / lost per tab
- Head-to-head between two tabs = count of games where each beat the other

## 7. Screens

### 7.1 Main screen (stations)

One card per station:

```
┌─────────────────────────┐
│ TV 1                    │
│ #3 red shirt            │
│        vs               │
│ #5 Abebe                │
│                         │
│ [#3 lost]   [#5 lost]   │
└─────────────────────────┘
```

Bottom buttons: Open tabs, New player.

- Tapping a player's name on the card opens Change player (pick another open tab).
- An empty or half-empty station shows Start game / empty slot, where the owner picks tabs.
- Right after a game is recorded, a temporary Undo action appears on the main screen (see 7.6).

### 7.2 Pick player (list of open tabs)

List of open tabs not currently on a TV, each shown as `#N label`, with a New player option at the top. Used when filling a slot.

### 7.3 New player

One text field (label, optional) and a Create button. The number is assigned automatically. Returns the new tab ready to be placed on a station.

### 7.4 Open tabs

```
┌─────────────────────────┐
│ Open tabs               │
│ #3 red shirt     45 birr│
│ #4 blue shoes    15 birr│
│ #5 Abebe         30 birr│
│ #7 Dawit          0 birr│
│ Total owed:      90 birr│
└─────────────────────────┘
```

Tapping a tab opens the tab detail.

### 7.5 Tab detail

- Label, number, amount owed
- Stats: played, won, lost
- Head-to-head vs other tabs (e.g. vs #5 Abebe: 3 - 1)
- **Mark paid**: shows a confirmation summary (e.g. "5 losses × 15 birr = 75 birr"), then records a Payment for the full owed amount. After paying, the owner chooses: Close tab (person leaves) or Keep open (person continues playing).
- Edit label

### 7.6 Game history

- Reverse-chronological list of all games: time, station, winner, loser, price.
- Every entry has an Undo button that deletes that Game. Owed amounts recalculate automatically.
- If the undone game is the most recent on its station, the previous slot state is restored; otherwise station slots are left as-is.
- If undo would conflict with later games (e.g. the tab was already placed on a station), block with a short message.
- Records are kept forever — undo is not limited to just the last game.

### 7.7 Settings

- Price per game
- Add / rename / remove stations

## 8. Main flows

### Record a game result

- Owner taps `[#5 lost]` on a station card.
- App creates a Game: loser = #5, winner = the other tab on that station, station, time, current price.
- #5 is removed from the station slot.
- If exactly one open tab is waiting (not on any station), the app auto-places it in the emptied slot (Undo available right after). Otherwise the app shows Pick player to fill the empty slot (existing open tab or New player). The winner stays on the station.
- Card updates. Owed amount for #5 increased by the price.

### Start a game on an empty station

Owner picks two tabs for the two slots.

### Player changes TV

Owner uses Change player on both cards. Tabs and totals are untouched, because money belongs to the tab, not the station.

### Player leaves and pays

Open tabs > tap tab > Mark paid. App shows a payment summary (losses × price = total owed), records the payment, then asks: Close tab (person leaves) or Keep open (person continues playing). If closed and the tab is on a station, it is removed from the slot. Closed tabs disappear from the Open tabs list.

## 9. Rules and edge cases

- A tab can be on only one station at a time. If the owner puts a tab on a second station, either block with a message or move it and empty the old slot (choose one; prefer move with confirmation).
- A game can be recorded only when both slots on the station are filled.
- Undo any recent game. The owner will mis-tap. Any game in the history can be undone (see 7.6): deleting the Game recalculates owed amounts automatically and restores the station slot when it is that station's most recent game. A temporary Undo action also appears on the main screen right after recording.
- Mark paid never forces closure: after recording the payment the owner chooses close or keep open. A tab with an unpaid balance cannot be closed without a payment; a tab with 0 owed can be closed directly.
- Partial payments: v1 may support only full payment. Data model already allows partials via `Payment.amount`.
- Closed (paid) tabs are removed from the Open tabs list entirely — the list only ever shows people currently in the zone, so nothing accumulates across days. Their Game and Payment records are kept forever; stats remain available in Tab detail and Game history (all time).
- Changing `price_per_game` affects only future games, because each Game stores its own price.
- Two tabs may share the same label. The auto number keeps them distinct.
- Deleting data is not required in v1.

## 10. Not in v1

- Waiting queue
- Accounts, login, cloud sync, multiple devices
- Per-hour / time-based billing
- Player-facing app
- Inventory, snacks, reports beyond the stats above
- Photos or wristband/QR identification

## 11. Acceptance criteria

- With no internet, the owner can create tabs, place players on stations, record results, and mark tabs as paid.
- Tapping one lost button creates exactly one Game and adds the current price to the loser's owed amount. If exactly one tab is waiting, it is auto-placed in the emptied slot (with Undo available); otherwise the pick-player list opens.
- Owed amount for any tab always equals (games lost × prices at that time) minus payments, even after players move between TVs.
- Tab detail shows correct played / won / lost counts and head-to-head scores.
- Adding a third station in Settings requires no code change and the new card appears on the main screen.
- Closing the app and reopening it keeps all data.
- Undo from Game history removes the selected game, recalculates owed amounts, and restores the station slot when it is that station's most recent game.
- Mark paid shows a summary (losses × price = total) before recording the payment, and the owner can keep the tab open after paying.
- Paid-and-closed tabs no longer appear in the Open tabs list.

## 12. Suggested build order

1. Local database and the data model above.
2. Create tabs, and the list of open tabs with owed amounts.
3. Station cards and placing tabs on stations.
4. Record a game result (the core loop) and the pick-next-player step.
5. Mark paid (payment summary, close-or-keep-open choice) and close tab.
6. Tab detail with stats and head-to-head.
7. Game history with per-game undo, settings (price, stations), and edge-case rules.

## 13. Open decisions

- Tech stack (pick any mobile stack with a local database; e.g. React Native/Expo + SQLite, or Flutter + SQLite).
- Whether stats are shown per day or all time by default.
- Block vs auto-move when a tab is placed on a second station.
- Whether to support partial payments in v1.
