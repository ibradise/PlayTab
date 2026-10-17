# Tasks

Current tasks for the PS Zone Game Tracker (Flutter).

**How this file works:** write the current task(s) below, implement one at a time, and once a task is implemented and verified, **delete its content from this file**. Keep this header.

Spec: [`PRD.md`](./PRD.md) · Agent guide: [`agent.md`](./agent.md)

**Architecture:** layered `data → domain → presentation`, `flutter_bloc`, `sqflite`, `get_it`.
**Conventions:** int birr, epoch-int timestamps, plain models (no codegen), `Navigator` only, usecases only for real logic. Every task ends with `flutter analyze` + `flutter test`.

---

**All tasks complete.** Verify against PRD §11 acceptance criteria: every criterion is covered by an automated test except the manual `flutter run` walkthrough (do this on a device once).

