import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory, String? name})
      : _factory = factory ?? databaseFactory,
        _name = name ?? 'playtab.db';

  static final AppDatabase instance = AppDatabase();

  final DatabaseFactory _factory;
  final String _name;
  Database? _db;

  bool get _inMemory => _name == inMemoryDatabasePath;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final location = _inMemory
        ? inMemoryDatabasePath
        : p.join(await _factory.getDatabasesPath(), _name);
  _db = await _factory.openDatabase(
    location,
    options: OpenDatabaseOptions(
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    ),
  );
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tabs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        closed_at INTEGER,
        display_number INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        slot_a_tab_id INTEGER,
        slot_b_tab_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        station_id INTEGER NOT NULL,
        winner_tab_id INTEGER NOT NULL,
        loser_tab_id INTEGER NOT NULL,
        played_at INTEGER NOT NULL,
        price INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tab_id INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        paid_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        price_per_game INTEGER NOT NULL,
        dark_mode INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.insert('stations', {'name': 'TV 1'});
    await db.insert('stations', {'name': 'TV 2'});
    await db.insert('settings', {'id': 1, 'price_per_game': 15});
    await _backfillDisplayNumbers(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE tabs ADD COLUMN display_number INTEGER',
      );
      await _backfillDisplayNumbers(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE settings ADD COLUMN dark_mode INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  static Future<void> _backfillDisplayNumbers(Database db) async {
    await db.execute(
      'UPDATE tabs SET display_number = id WHERE display_number IS NULL',
    );
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_tabs_display_number_open
      ON tabs (display_number) WHERE status = 'open'
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
