import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:ui';

class PlayerScreen extends StatefulWidget {
  final Map<String, dynamic> metadata;
  final bool isAudioOnly;

  const PlayerScreen({
    super.key,
    required this.metadata,
    required this.isAudioOnly,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final AudioPlayer _player;
  bool _isLoading = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudioSession();
    _playMedia();

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading || state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _playMedia() async {
    try {
      final url = widget.isAudioOnly ? widget.metadata['audio_url'] : widget.metadata['video_url'];
      if (url != null) {
        if (url.startsWith('http')) {
           await _player.setUrl(url);
        } else {
           await _player.setFilePath(url); // Offline local playback
        }

        if (mounted) {
          setState(() => _isLoading = false);
        }
        _player.play();
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playback error. Stream might be expired or unsupported.')));
         setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Now Playing', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background blur
          if (widget.metadata['thumbnail'] != null)
             Positioned.fill(
              child: Image.network(
                widget.metadata['thumbnail'],
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
              child: Container(color: Colors.black.withOpacity(0.5)),
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
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 20),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: widget.metadata['thumbnail'] != null
                          ? Image.network(widget.metadata['thumbnail'], fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF1C1C1E),
                              child: const Icon(CupertinoIcons.music_note, size: 100, color: Colors.white54),
                            ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      widget.metadata['title'] ?? 'Unknown Media',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.metadata['artist'] ?? 'Unknown Artist',
                    style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 50),
                  _isLoading
                      ? const CupertinoActivityIndicator(radius: 20)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 40,
                              icon: const Icon(CupertinoIcons.backward_fill, color: Colors.white),
                              onPressed: () {
                                _player.seek(Duration(seconds: _player.position.inSeconds - 10));
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
                                icon: Icon(_isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill, color: Colors.black),
                                onPressed: () {
                                  if (_isPlaying) {
                                    _player.pause();
                                  } else {
                                    _player.play();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 30),
                            IconButton(
                              iconSize: 40,
                              icon: const Icon(CupertinoIcons.forward_fill, color: Colors.white),
                              onPressed: () {
                                _player.seek(Duration(seconds: _player.position.inSeconds + 10));
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
