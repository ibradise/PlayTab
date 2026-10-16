# Tasks

Current tasks for the PS Zone Game Tracker (Flutter).

**How this file works:** write the current task(s) below, implement one at a time, and once a task is implemented and verified, **delete its content from this file**. Keep this header.

Spec: [`PRD.md`](./PRD.md) · Agent guide: [`agent.md`](./agent.md)

**Architecture:** layered `data → domain → presentation`, `flutter_bloc`, `sqflite`, `get_it`.
**Conventions:** int birr, epoch-int timestamps, plain models (no codegen), `Navigator` only, usecases only for real logic. Every task ends with `flutter analyze` + `flutter test`.

---

## Task 5 — Mark paid & close tab

- [ ] Usecase `MarkPaid`: record `Payment` (full owed), then close or keep open; remove from station if closed.
- [ ] Usecase `CloseTab` (0 owed).
- [ ] `presentation/pages/tab_detail_page.dart`: owed, **Mark paid** with summary dialog (`N losses × price = total`) + close/keep-open choice, edit label.
- [ ] Tests: payment records, owed → 0, tab leaves open list.

**Done when:** full pay flow works per PRD §8; analyze/test pass.

---

## Task 6 — Tab detail: stats & head-to-head

- [ ] Usecases: `GetTabStats` (played/won/lost), `GetHeadToHead`.
- [ ] `presentation/bloc/tab_detail/`: `TabDetailBloc` (load tab + stats + h2h).
- [ ] `TabDetailPage`: stats section and head-to-head list.

**Done when:** correct played/won/lost and h2h shown; analyze/test pass.

---

## Task 7 — Game history & per-game undo

- [ ] Usecases: `GetGameHistory`, `UndoGame` (delete game, recompute owed, restore slot when it's the station's latest; block on conflict).
- [ ] `presentation/pages/game_history_page.dart` + `bloc/game_history/`.
- [ ] Entry per game (time, station, winner, loser, price) with Undo.

**Done when:** any history game can be undone with correct recompute/restore; analyze/test pass.

---

## Task 8 — Settings

- [ ] Usecases: `UpdatePricePerGame`, `AddStation`, `RenameStation`, `RemoveStation`.
- [ ] `presentation/pages/settings_page.dart` + `bloc/settings/`.
- [ ] Price field; station add/rename/remove. New station appears on main screen.

**Done when:** price and stations manageable; adding a station needs no code change; analyze/test pass.

---

## Task 9 — Edge cases, polish & acceptance pass

- [ ] Single-station rule: move-with-confirmation when placing on a second station.
- [ ] Price snapshot only affects future games.
- [ ] Empty/half-empty station states; `0 birr` / no-owed handling.
- [ ] Run through PRD §11 acceptance criteria end to end.
- [ ] Final `flutter analyze` + `flutter test`, and a manual `flutter run` walkthrough.

**Done when:** all PRD §11 criteria pass offline.
