import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vortex_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT';

    await db.execute('''
CREATE TABLE history (
  id $idType,
  title $textType,
  artist $textNullType,
  thumbnail $textNullType,
  video_url $textNullType,
  audio_url $textNullType
)
''');
  }

  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('history', row);
  }

  Future<List<Map<String, dynamic>>> readAllHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'id DESC');
  }

  Future<int> deleteHistory(int id) async {
    final db = await instance.database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
