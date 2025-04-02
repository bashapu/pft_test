import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'session_manager.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      amount REAL,
      type TEXT,
      category TEXT,
      date TEXT,
      userId TEXT
    )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT,
      email TEXT,
      password TEXT
    )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      targetAmount REAL,
      savedAmount REAL,
      userId TEXT
      )
    ''');
  }

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transactions', row);
  }

  Future<List<Map<String, dynamic>>> fetchTransactions(userId) async {
    final db = await instance.database;
    return await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }
}
