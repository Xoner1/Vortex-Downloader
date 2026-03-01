import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vortex_stream_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Increment version if schema changes
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE history (
        id $idType,
        mediaId $textType,
        title $textType,
        artist $textNullType,
        thumbnail $textNullType,
        videoUrl $textNullType,
        audioUrl $textNullType,
        duration $integerType,
        timestamp $integerType
      )
    ''');

    // Future expansion for structured downloads vs basic history
    await db.execute('''
      CREATE TABLE downloads (
        id $idType,
        mediaId $textType,
        title $textType,
        artist $textNullType,
        thumbnail $textNullType,
        localPath $textType,
        format $textType,
        sizeInBytes $integerType,
        timestamp $integerType
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
