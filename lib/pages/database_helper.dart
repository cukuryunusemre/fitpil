import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> resetTable(Database db, String tableName) async {
  await db.execute('DROP TABLE IF EXISTS $tableName;');
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB('workouts_data.db');
    return _database!;
  }

  Future<void> resetTable(String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    print('$tableName tablosu silindi.');

    // Örnek: workouts tablosu yeniden oluşturulabilir
    if (tableName == 'workouts') {
      await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pageId INTEGER,
        title TEXT,
        set_count INTEGER,
        reps TEXT,
        weight TEXT,
        date TEXT,
        rName TEXT,
        historyId INTEGER
      )
    ''');
      print('$tableName tablosu yeniden oluşturuldu.');
    }
  }

  //
  // Future<Database> get databaseep async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'apps.db');
  //
  //   return openDatabase(
  //     path,
  //     version: 2,
  //     onCreate: (db, version) async {
  //       // Tabloyu burada oluşturduğunuzdan emin olun
  //       await db.execute('''
  //     CREATE TABLE dynamicPages (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       title TEXT NOT NULL,
  //       createdAt TEXT NOT NULL
  //     )
  //   ''');
  //     },
  //   );
  // }
  // Future<void> resetAndReinitializeDatabase() async {
  //   await resetDatabase(); // Veritabanını sıfırla
  //   await DatabaseHelper.instance.database; // Veritabanını yeniden oluştur
  //   print('Veritabanı yeniden başlatıldı.');
  // }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 15,
      onCreate: _createDB, // Veritabanı oluşturma işlemi buraya yönlendirilir
      // onOpen: (db) async {
      //   await db.execute(
      //       'PRAGMA foreign_keys = ON'); // Foreign Key desteğini etkinleştir
      // },
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.execute(
            'PRAGMA foreign_keys = ON;'); // Foreign key kontrolünü etkinleştir
      },
    );
  }

  // Future<Database> _initDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'app.db');
  //
  //   return openDatabase(
  //     path,
  //     version: 1, // Veritabanı sürümü
  //     onCreate: (db, version) async {
  //       await db.execute('''
  //       CREATE TABLE dynamicPages (
  //         id INTEGER PRIMARY KEY AUTOINCREMENT,
  //         title TEXT NOT NULL,
  //         createdAt TEXT NOT NULL
  //       )
  //     ''');
  //     },
  //   );
  // }

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
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pageId INTEGER,
        title TEXT,
        set_count INTEGER,
        reps TEXT,
        weight TEXT,
        date TEXT,
        rName TEXT,
        historyId INTEGER,
        FOREIGN KEY (historyId) REFERENCES historyWorkoutPages (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
  CREATE TABLE historyWorkoutPages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pageId INTEGER NOT NULL,
  title TEXT NOT NULL,
  createdAt TEXT NOT NULL
  )
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // `historyWorkoutPages` tablosunu oluştur
      await db.execute('''
        CREATE TABLE IF NOT EXISTS historyWorkoutPages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pageId INTEGER NOT NULL,
          content TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      // `workouts` tablosunu oluştur
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workouts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pageId INTEGER NOT NULL,
          title TEXT NOT NULL,
          "set" INTEGER NOT NULL,
          reps TEXT NOT NULL,
          weight TEXT NOT NULL,
          date TEXT NOT NULL,
          rName TEXT NOT NULL,
          historyWorkout INTEGER NOT NULL,
          FOREIGN KEY (pageId) REFERENCES historyWorkoutPages (id) ON DELETE CASCADE,
          FOREIGN KEY (historyId) REFERENCES historyWorkoutPages (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<int> insertDynamicPage(String title, int pageId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(
      // Burada `return` ekliyoruz
      'historyWorkoutPages',
      {
        'title': title,
        'pageId': pageId,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHistoryWorkoutPage(int historyId) async {
    final db = await database;
    await db.delete(
      'historyWorkoutPages',
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchDynamicWorkouts(int pageId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'workouts',
      where: 'pageId = ?', // Sadece bu pageId'ye ait kayıtları getir
      whereArgs: [pageId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutsByPageId(int pageId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'workouts',
      where: 'pageId = ?',
      whereArgs: [pageId],
    ); // Belirli pageId'ye ait kayıtları alır
  }

  Future<Map<String, dynamic>?> getHistoryWorkoutPageById(int historyId) async {
    final db = await database;
    final result = await db.query(
      'historyWorkoutPages',
      where: 'id = ?', // Yalnızca verilen `id`'yi filtreliyoruz
      whereArgs: [historyId],
    );

    if (result.isNotEmpty) {
      return result.first; // İlk ve tek satırı döndürür
    }

    return null; // Eğer sonuç yoksa null döner
  }

  Future<int?> getPageIdByHistoryId(int historyId) async {
    final historyWorkoutPage = await getHistoryWorkoutPageById(historyId);
    if (historyWorkoutPage != null) {
      return historyWorkoutPage['pageId'] as int?; // `pageId`'yi döndürüyoruz
    }
    return null; // Eğer satır bulunamazsa null döndürüyoruz
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByHistoryId(
      int historyId) async {
    final db = await database;
    return await db.query(
      'workouts',
      where: 'historyId = ?', // historyId sütunu üzerinden filtreleme
      whereArgs: [historyId],
    );
  }

  Future<void> deleteHistoryWorkoutWithWorkouts(int historyId) async {
    final db = await database;

    // Önce workouts tablosundaki ilişkili verileri sil
    await db.delete(
      'workouts',
      where: 'historyId = ?',
      whereArgs: [historyId],
    );

    // Ardından historyWorkoutPages tablosundaki veriyi sil
    await db.delete(
      'historyWorkoutPages',
      where: 'id = ?',
      whereArgs: [historyId],
    );

    print('History id: $historyId ve ilişkili workouts silindi.');
  }

  Future<int> insertPage(Map<String, dynamic> page) async {
    final db = await instance.database;
    return await db.insert('pages', page);
  }

  Future<List<Map<String, dynamic>>> fetchDynamicPages() async {
    final db = await DatabaseHelper.instance.database;
    return await db
        .query('historyWorkoutPages'); // dynamicPages tablosunu sorgula
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

  Future<int> insertWorkout(int pageId, String title, int setCount, String reps,
      String weight, String date, String rName, int historyId) async {
    final db = await database;
    return await db.insert('workouts', {
      'pageId': pageId,
      'title': title,
      'set_count': setCount,
      'reps': reps,
      'weight': weight,
      'date': date,
      'rName': rName,
      'historyId': historyId,
    });
  }
}
