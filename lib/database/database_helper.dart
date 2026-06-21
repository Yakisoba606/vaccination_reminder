import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "vaccination.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE vaccinations(
id INTEGER PRIMARY KEY AUTOINCREMENT,
personName TEXT,
vaccineName TEXT,
vaccinationDate TEXT,
nextDate TEXT
)
''');
      },
    );
  }

  static Future<int> insertVaccination(Map<String, dynamic> data) async {
    final db = await database;

    return await db.insert(
      "vaccinations",
      data,
    );
  }

  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final db = await database;

    return await db.query(
      "vaccinations",
      orderBy: "nextDate ASC",
    );
  }

  static Future<int> deleteVaccination(int id) async {
    final db = await database;

    return await db.delete(
      "vaccinations",
      where: "id=?",
      whereArgs: [id],
    );
  }
}
