import 'package:equatable/equatable.dart';

class MediaItem extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String thumbnail;
  final String audioUrl;
  final String videoUrl;
  final int duration;

  const MediaItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.audioUrl,
    required this.videoUrl,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, title, artist, thumbnail, audioUrl, videoUrl, duration];
}
