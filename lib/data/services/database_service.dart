import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/analysis_record.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'eurorent_lens.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE analyses(
            id TEXT PRIMARY KEY,
            text TEXT NOT NULL,
            analysis TEXT NOT NULL,
            image_path TEXT,
            city TEXT,
            price REAL,
            score INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertAnalysis(AnalysisRecord record) async {
    final db = await database;
    await db.insert('analyses', record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AnalysisRecord>> getAllAnalyses() async {
    final db = await database;
    final maps = await db.query('analyses', orderBy: 'created_at DESC');
    return maps.map((map) => AnalysisRecord.fromMap(map)).toList();
  }

  Future<AnalysisRecord?> getAnalysis(String id) async {
    final db = await database;
    final maps = await db.query('analyses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return AnalysisRecord.fromMap(maps.first);
  }

  Future<void> deleteAnalysis(String id) async {
    final db = await database;
    await db.delete('analyses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('analyses');
  }
}
