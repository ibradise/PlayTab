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
        : p.join(await getDatabasesPath(), _name);
    _db = await _factory.openDatabase(
      location,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
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
        closed_at INTEGER
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
        price_per_game INTEGER NOT NULL
      )
    ''');

    await db.insert('stations', {'name': 'TV 1'});
    await db.insert('stations', {'name': 'TV 2'});
    await db.insert('settings', {'id': 1, 'price_per_game': 15});
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
