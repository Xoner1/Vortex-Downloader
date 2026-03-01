import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../../../core/audio/global_player_manager.dart';
import '../../domain/entities/media_item.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem media;
  final bool isAudioOnly;

  const PlayerScreen({
    super.key,
    required this.media,
    required this.isAudioOnly,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Begin playback via Global Player Manager
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalPlayerManager.instance.playMedia(
        widget.media,
        isAudioOnly: widget.isAudioOnly,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Now Playing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<GlobalPlayerManager>(
        builder: (context, playerManager, child) {
          final isPlaying = playerManager.isPlaying;
          final isLoading = playerManager.isLoading;
          final player = playerManager.player;

          return Stack(
            children: [
              // Background blur
              if (widget.media.thumbnail.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    widget.media.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
                ),
              ),

              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.media.thumbnail.isNotEmpty
                              ? Image.network(
                                  widget.media.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          widget.media.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.media.artist,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 50),
                      isLoading
                          ? const CupertinoActivityIndicator(radius: 20)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  iconSize: 40,
                                  icon: const Icon(
                                    CupertinoIcons.backward_fill,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    player.seek(
                                      Duration(
                                        seconds: player.position.inSeconds - 10,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 30),
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: IconButton(
                                    iconSize: 50,
                                    icon: Icon(
                                      isPlaying
                                          ? CupertinoIcons.pause_fill
                                          : CupertinoIcons.play_fill,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      playerManager.toggle();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 30),
                                IconButton(
                                  iconSize: 40,
                                  icon: const Icon(
                                    CupertinoIcons.forward_fill,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    player.seek(
                                      Duration(
                                        seconds: player.position.inSeconds + 10,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1C1C1E),
      child: const Icon(
        CupertinoIcons.music_note,
        size: 100,
        color: Colors.white54,
      ),
    );
  }
}
