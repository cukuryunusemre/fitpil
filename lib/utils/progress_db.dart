import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

DateTime onlyDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}


class ProgressDB {
  static final ProgressDB instance = ProgressDB._init();
  static Database? _database;

  ProgressDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('progress.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const dateType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE measurements (
      id $idType,
      metric $textType,
      value $doubleType,
      date $dateType
    )
    ''');
  }

  Future<void> addOrUpdateMeasurement(String metric, double value, DateTime date) async {
    final db = await instance.database;

    final normalizedDate = onlyDate(date);

    // Hem date hem de metric ile birlikte kontrol yapıyoruz
    final existing = await db.query(
      'measurements',
      where: 'date = ? AND metric = ?',
      whereArgs: [normalizedDate.toIso8601String(), metric],
    );

    if (existing.isNotEmpty) {
      // Eğer mevcutsa, veriyi güncelle
      await db.update(
        'measurements',
        {
          'metric': metric,
          'value': value,
          'date': normalizedDate.toIso8601String(),
        },
        where: 'date = ? AND metric = ?',
        whereArgs: [normalizedDate.toIso8601String(), metric],
      );
    } else {
      // Eğer mevcut değilse, yeni bir veri ekle
      await db.insert(
        'measurements',
        {
          'metric': metric,
          'value': value,
          'date': normalizedDate.toIso8601String(),
        },
      );
    }
  }



  Future<List<Map<String, dynamic>>> fetchAllMeasurements() async {
    final db = await instance.database;

    final result = await db.query('measurements', orderBy: 'date ASC');

    return result.map((e) {
      return {
        'id': e['id'],
        'metric': e['metric'],
        'value': e['value'],
        'date': DateTime(
        DateTime.parse(e['date'] as String).year,
        DateTime.parse(e['date'] as String).month,
        DateTime.parse(e['date'] as String).day,
        ),
      };
    }).toList();
  }

  Future<void> deleteMeasurementsByMetric(String metric) async {
    final db = await instance.database;

    await db.delete(
      'measurements',
      where: 'metric = ?',
      whereArgs: [metric],
    );
  }

  Future<void> deleteAllMeasurements() async {
    final db = await instance.database;

    await db.delete('measurements');

    await db.execute('VACUUM');
  }

  Future<void> resetTable() async {
    final db = await instance.database;

    // Tablonun içeriğini tamamen sil ve yeniden oluştur
    await db.execute('DROP TABLE IF EXISTS measurements');
    await db.execute('''
    CREATE TABLE measurements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      metric TEXT NOT NULL,
      value REAL NOT NULL,
      date TEXT NOT NULL
    )
  ''');
  }


  Future close() async {
    final db = await _database;

    if (db != null) {
      await db.close();
    }
  }
}
