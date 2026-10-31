import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/word_log_model.dart';

class LocalDbHelper {
  static final LocalDbHelper instance = LocalDbHelper._internal();
  static Database? _database;

  LocalDbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lang_master.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE word_mistakes (
            word TEXT PRIMARY KEY,
            meaning TEXT,
            wrongTypingCount INTEGER,
            wrongPronounceCount INTEGER,
            correctStreak INTEGER,
            lastWrongTime TEXT
          )
        ''');
      },
    );
  }

  Future<void> upsertWordLog(WordLogModel log) async {
    final db = await database;
    await db.insert(
      'word_mistakes',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertOrUpdateWordLog(WordLogModel log) => upsertWordLog(log);

  Future<List<WordLogModel>> getAllWordLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('word_mistakes');
    return maps.map((m) => WordLogModel.fromMap(m)).toList();
  }

  Future<void> clearAllLogs() async {
    final db = await database;
    await db.delete('word_mistakes');
  }
}


