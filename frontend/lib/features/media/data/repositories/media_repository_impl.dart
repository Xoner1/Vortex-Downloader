import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/media_local_data_source.dart';
import '../datasources/media_remote_data_source.dart';
import '../models/media_model.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource remoteDataSource;
  final MediaLocalDataSource localDataSource;

  MediaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<MediaItem> extractMediaFromUrl(String url) async {
    return await remoteDataSource.extractMedia(url);
  }

  @override
  Future<List<MediaItem>> getLocalHistory() async {
    return await localDataSource.getHistory();
  }

  @override
  Future<void> saveToHistory(MediaItem item) async {
    final model = MediaModel(
      id: item.id,
      title: item.title,
      artist: item.artist,
      thumbnail: item.thumbnail,
      audioUrl: item.audioUrl,
      videoUrl: item.videoUrl,
      duration: item.duration,
    );
    await localDataSource.saveToHistory(model);
  }

  @override
  Future<void> removeFromHistory(String id) async {
    await localDataSource.removeFromHistory(id);
  }
}
