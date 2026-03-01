import '../entities/media_item.dart';

abstract class MediaRepository {
  Future<MediaItem> extractMediaFromUrl(String url);
  Future<List<MediaItem>> getLocalHistory();
  Future<void> saveToHistory(MediaItem item);
  Future<void> removeFromHistory(String id);
}
