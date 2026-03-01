import 'package:frontend/core/database/local_db.dart';
import '../models/media_model.dart';

abstract class MediaLocalDataSource {
  Future<void> saveToHistory(MediaModel media);
  Future<List<MediaModel>> getHistory();
  Future<void> removeFromHistory(String id);
}

class MediaLocalDataSourceImpl implements MediaLocalDataSource {
  final LocalDatabase dbInstance;

  MediaLocalDataSourceImpl(this.dbInstance);

  @override
  Future<void> saveToHistory(MediaModel media) async {
    final db = await dbInstance.database;
    // Basic deduplication
    await db.delete('history', where: 'mediaId = ?', whereArgs: [media.id]);
    await db.insert('history', media.toLocalDb());
  }

  @override
  Future<List<MediaModel>> getHistory() async {
    final db = await dbInstance.database;
    final result = await db.query('history', orderBy: 'timestamp DESC');
    return result.map((json) => MediaModel.fromLocalDb(json)).toList();
  }

  @override
  Future<void> removeFromHistory(String id) async {
    final db = await dbInstance.database;
    await db.delete('history', where: 'mediaId = ?', whereArgs: [id]);
  }
}
