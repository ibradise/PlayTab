# Tasks

Current tasks for the PS Zone Game Tracker (Flutter).

**How this file works:** write the current task(s) below, implement one at a time, and once a task is implemented and verified, **delete its content from this file**. Keep this header.

Spec: [`PRD.md`](./PRD.md) · Agent guide: [`agent.md`](./agent.md)

**Architecture:** layered `data → domain → presentation`, `flutter_bloc`, `sqflite`, `get_it`.
**Conventions:** int birr, epoch-int timestamps, plain models (no codegen), `Navigator` only, usecases only for real logic. Every task ends with `flutter analyze` + `flutter test`.

---

## Task 9 — Edge cases, polish & acceptance pass

- [ ] Single-station rule: move-with-confirmation when placing on a second station.
- [ ] Price snapshot only affects future games.
- [ ] Empty/half-empty station states; `0 birr` / no-owed handling.
- [ ] Run through PRD §11 acceptance criteria end to end.
- [ ] Final `flutter analyze` + `flutter test`, and a manual `flutter run` walkthrough.

**Done when:** all PRD §11 criteria pass offline.
