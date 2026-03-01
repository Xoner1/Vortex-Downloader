import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui';
import 'player_screen.dart';
import '../../domain/entities/media_item.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/VortexDownloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create();
    }
    setState(() {
      _files = downloadDir.listSync().where((f) => f is File).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
    _loadDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Downloads', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _files.isEmpty
              ? const Center(child: Text('No downloaded files.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index] as File;
                    final filename = file.path.split(Platform.pathSeparator).last;
                    final size = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
                    final isAudio = filename.endsWith('.mp3');

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isAudio ? CupertinoColors.activeBlue : CupertinoColors.systemGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(isAudio ? CupertinoIcons.music_note : CupertinoIcons.video_camera, color: Colors.white),
                          ),
                          title: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('$size MB', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                          trailing: IconButton(
                            icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
                            onPressed: () => _deleteFile(file),
                          ),
                          onTap: () {
                            // Offline playback support using GlobalPlayerManager
                             Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => PlayerScreen(
                                  media: MediaItem(
                                    id: filename,
                                    title: filename,
                                    artist: 'Offline Mode',
                                    thumbnail: '',
                                    videoUrl: file.path,
                                    audioUrl: file.path,
                                    duration: 0,
                                  ),
                                  isAudioOnly: isAudio,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
