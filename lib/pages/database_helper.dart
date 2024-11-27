import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workout.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON'); // Foreign Key'i aç
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        icon TEXT NOT NULL,
        iconColor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pageId INTEGER NOT NULL,
        title TEXT NOT NULL,
        sets INTEGER,
        reps INTEGER,
        `order` INTEGER NOT NULL,
        FOREIGN KEY (pageId) REFERENCES pages (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertPage(Map<String, dynamic> page) async {
    final db = await instance.database;
    return await db.insert('pages', page);
  }

  Future<int> updatePage(Map<String, dynamic> page, int id) async {
    final db = await instance.database;
    return await db.update(
      'pages',
      page,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePage(int id) async {
    final db = await instance.database;
    return await db.delete(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> fetchPages() async {
    final db = await instance.database;
    return await db.query('pages');
  }

  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await instance.database;
    return await db.insert('exercises', exercise);
  }

  Future<int> updateExercise(Map<String, dynamic> exercise, int id) async {
    final db = await instance.database;
    return await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await instance.database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> fetchExercises(int pageId) async {
    final db = await instance.database;

    return await db.query(
      'exercises',
      where: 'pageId = ?',
      whereArgs: [pageId],
      orderBy: '`order` ASC',
    );
  }

  Future<int> updateExerciseOrder(int id, int order) async {
    final db = await database;
    return await db.update(
      'exercises',
      {'order': order},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPageCount() async {
    final db = await database; // Veritabanı referansı alınır
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM pages'); // Sayfaları say
    return Sqflite.firstIntValue(result) ?? 0; // İlk sonuç değerini döndür
  }
}
