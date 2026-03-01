import '../../domain/entities/media_item.dart';

class MediaModel extends MediaItem {
  const MediaModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.thumbnail,
    required super.audioUrl,
    required super.videoUrl,
    required super.duration,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] ?? json['video_url'] ?? 'unknown', // Generate ID based on URL if none provided
      title: json['title'] ?? 'Unknown Media',
      artist: json['artist'] ?? 'Unknown Artist',
      thumbnail: json['thumbnail'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }

  factory MediaModel.fromLocalDb(Map<String, dynamic> json) {
    return MediaModel(
      id: json['mediaId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      thumbnail: json['thumbnail'] as String,
      audioUrl: json['audioUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toLocalDb() {
    return {
      'mediaId': id,
      'title': title,
      'artist': artist,
      'thumbnail': thumbnail,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
