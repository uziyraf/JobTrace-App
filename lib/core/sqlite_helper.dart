import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jobtrace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabel 1: Lamaran
    await db.execute('''
      CREATE TABLE applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL,
        role TEXT NOT NULL,
        status TEXT NOT NULL,
        platform TEXT NOT NULL,
        dateApplied TEXT NOT NULL,
        evaluation TEXT,
        notes TEXT
      )
    ''');

    // Tabel 2: Jadwal
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jobId INTEGER NOT NULL,
        company TEXT NOT NULL,
        role TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        platform TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }
}
