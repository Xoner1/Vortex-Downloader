import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class ExtractMediaUseCase {
  final MediaRepository repository;

  ExtractMediaUseCase(this.repository);

  Future<MediaItem> execute(String url) async {
    return await repository.extractMediaFromUrl(url);
  }
}

class GetHistoryUseCase {
  final MediaRepository repository;

  GetHistoryUseCase(this.repository);

  Future<List<MediaItem>> execute() async {
    return await repository.getLocalHistory();
  }
}

class SaveHistoryUseCase {
  final MediaRepository repository;

  SaveHistoryUseCase(this.repository);

  Future<void> execute(MediaItem item) async {
    await repository.saveToHistory(item);
  }
}

class RemoveHistoryUseCase {
  final MediaRepository repository;

  RemoveHistoryUseCase(this.repository);

  Future<void> execute(String id) async {
    await repository.removeFromHistory(id);
  }
}
