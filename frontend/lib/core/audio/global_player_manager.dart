import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/media/domain/entities/media_item.dart';

class GlobalPlayerManager extends ChangeNotifier {
  static final GlobalPlayerManager instance = GlobalPlayerManager._internal();

  final AudioPlayer _player = AudioPlayer();
  MediaItem? _currentMedia;
  bool _isPlaying = false;
  bool _isLoading = false;

  GlobalPlayerManager._internal() {
    _initStreams();
  }

  AudioPlayer get player => _player;
  MediaItem? get currentMedia => _currentMedia;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  void _initStreams() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading =
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      notifyListeners();
    });
  }

  Future<void> playMedia(MediaItem media, {required bool isAudioOnly}) async {
    _currentMedia = media;
    notifyListeners();

    try {
      final url = isAudioOnly ? media.audioUrl : media.videoUrl;
      if (url.isEmpty) throw Exception("Stream URL is empty");

      if (url.startsWith('http')) {
        await _player.setUrl(url);
      } else {
        await _player.setFilePath(url); // Local playback
      }

      _player.play();
    } catch (e) {
      debugPrint("Player Error: \$e");
    }
  }

  void pause() => _player.pause();
  void play() => _player.play();
  void toggle() => _isPlaying ? pause() : play();
}
