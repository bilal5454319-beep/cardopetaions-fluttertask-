import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    return _database ??= await initDB();
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "students.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            age TEXT,
            class TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertData(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert("students", row);
  }

  Future<List<Map<String, dynamic>>> readData() async {
    final db = await instance.database;
    return await db.query("students");
  }

  Future<int> updateData(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      "students",
      row,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteData(int id) async {
    final db = await instance.database;
    return await db.delete(
      "students",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
