import 'package:flutter/material.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/usecases/media_usecases.dart';

class MediaProvider extends ChangeNotifier {
  final ExtractMediaUseCase extractUseCase;
  final GetHistoryUseCase getHistoryUseCase;
  final SaveHistoryUseCase saveHistoryUseCase;
  final RemoveHistoryUseCase removeHistoryUseCase;

  List<MediaItem> _history = [];
  bool _isLoading = false;
  String? _error;

  MediaProvider({
    required this.extractUseCase,
    required this.getHistoryUseCase,
    required this.saveHistoryUseCase,
    required this.removeHistoryUseCase,
  });

  List<MediaItem> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await getHistoryUseCase.execute();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<MediaItem?> extractMedia(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final media = await extractUseCase.execute(url);
      _isLoading = false;
      notifyListeners();
      return media;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> saveToHistory(MediaItem item) async {
    await saveHistoryUseCase.execute(item);
    await fetchHistory(); // Refresh the list
  }

  Future<void> removeFromHistory(String id) async {
    await removeHistoryUseCase.execute(id);
    await fetchHistory();
  }
}
