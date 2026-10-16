# Agent Guide — PS Zone Game Tracker

Guidance for AI agents (and humans) working in this repository.

## Project

Offline mobile app for a PlayStation zone owner to track who loses each game and how much each person owes. Single user (the owner). No backend, no login, no sync in v1.

Full spec: [`PRD.md`](./PRD.md). Read it before making product decisions.

## Tech stack

- **Flutter** (Dart) — mobile app.
- **State management** — `flutter_bloc` (BLoC). Each screen/flow gets a Bloc + events/states.
- **Local database** — SQLite via `sqflite` (simple, no code generation). Derived values (owed, stats) are computed in Dart, so raw SQL is enough.
- **Architecture** — layered: `data` → `domain` → `presentation`.
- No network layer in v1.

## Product vocabulary

- **Tab** — a person's running bill / identity. Auto number `#N` + optional label. Open until paid and closed.
- **Station** — one TV/PS. Holds up to 2 tabs (slots A/B).
- **Game** — one finished match: station, winner tab, loser tab, time, and a `price` snapshot.
- **Payment** — money paid by a tab.
- **Setting** — app config; currently `price_per_game` (default 15). Currency label: **birr**.
- **Owed** — derived value: sum of lost-game prices minus payments. Never stored.

## Core rules (do not violate)

- Owed amounts and stats are always **derived from Game/Payment records** — never stored as columns.
- Each Game stores its own `price` snapshot; changing the price only affects future games.
- A game can be recorded only when both station slots are filled; a tab can be on only one station.
- Closed (paid) tabs disappear from the Open tabs list but keep their records forever.
- Recording a game is the hot path: 1–2 taps. Don't add friction or typing there.
- Auto-fill: if exactly one tab is waiting, placing it after a loss happens automatically (with Undo available).

## Project structure (target)

Layered architecture. `presentation` depends on `domain`; `data` implements `domain`; `domain` depends on nothing.

```
lib/
  main.dart
  data/                     # data layer
    database/               # sqflite database + migrations
    models/                 # row/DTO models + toMap/fromMap
    repositories/           # implementations of domain repositories
  domain/                   # domain layer (pure Dart, no Flutter/sqflite imports)
    entities/               # Tab, Station, Game, Payment, Setting
    repositories/           # abstract repository interfaces
    usecases/               # RecordGameResult, MarkPaid, GetOpenTabs, GetStats...
  presentation/             # presentation layer
    bloc/                   # one Bloc + events + states per screen/flow
      stations_bloc/        # stations, open_tabs, tab_detail, game_history, settings
    pages/                  # home, open_tabs, tab_detail, game_history, settings
    widgets/                # station_card, tab_tile, ...
  core/                     # formatting, currency (birr), DI/app wiringta
test/
```

Layer rules:
- `presentation` never imports `data` directly — Blocs call **domain usecases**, which use repository interfaces.
- `domain` has no Flutter/sqflite imports; entities, repository contracts, and usecases only.
- `data` maps DTOs ↔ domain entities and contains all SQL.
- Keep one Bloc per screen/flow; inject usecases via `BlocProvider` (or a simple DI/service locator).

## Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk   # release build for the owner's phone
```

Always run `flutter analyze` and `flutter test` after changes. Fix any warnings you introduce.

## Workflow

1. Tasks live in [`task.md`](./task.md).
2. Pick the top unchecked task, mark it in progress, implement it.
3. Verify: `flutter analyze` + `flutter test`, plus a manual run when UI changes.
4. When a task is implemented and verified, **delete that task's content from `task.md`** (keep the file's header/instructions).
5. Keep changes focused. Do not commit unless asked.

## Conventions

- Format with `dart format .`.
- No code comments unless they explain non-obvious intent.
- Follow the PRD screen list (section 7) and acceptance criteria (section 11) as the definition of done.
- Money is stored as `int` birr; timestamps as epoch ints; IDs as `INTEGER PRIMARY KEY AUTOINCREMENT`.
- Use `Navigator` only (no routing package); plain models with `toMap/fromMap` (no codegen).
- Domain entities double as persistence models (`toMap`/`fromMap`) since rows map 1:1 — no separate DTO layer.
- `usecases/` only for real logic (`RecordGameResult`, `MarkPaid`, `GetTabStats`, ...); trivial reads go Bloc → repository.
- Wire dependencies with `get_it` in `core/di.dart`; one Bloc per screen.
