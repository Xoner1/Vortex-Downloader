import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui';

import '../../domain/entities/media_item.dart';
import '../providers/media_provider.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  Future<void> _processUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    FocusScope.of(context).unfocus(); // Dismiss keyboard

    final provider = Provider.of<MediaProvider>(context, listen: false);
    final media = await provider.extractMedia(url);

    if (media != null && mounted) {
      _showOptionsSheet(media);
    } else if (provider.error != null && mounted) {
      _showError(provider.error!);
    }
  }

  void _showOptionsSheet(MediaItem media) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Options'),
        message: Text(media.title),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Stream Now', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () async {
              Navigator.pop(context);

              // Save to local history using provider
              await Provider.of<MediaProvider>(context, listen: false).saveToHistory(media);

              if (mounted) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => PlayerScreen(
                      media: media,
                      isAudioOnly: false,
                    ),
                  ),
                );
              }
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Download Video (4K/1080p)'),
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(media.videoUrl, 'mp4', media.title);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Download Audio (MP3)'),
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(media.audioUrl, 'mp3', media.title);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String downloadUrl, String ext, String title) async {
    if (downloadUrl.isEmpty) {
      _showError('URL not found for this format');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/VortexDownloads');
      if (!await downloadDir.exists()) await downloadDir.create();

      // Clean title for filename
      final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
      final filename = "${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.$ext";
      final savePath = '${downloadDir.path}/$filename';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading started in background...'), backgroundColor: Color(0xFF1C1C1E)),
      );

      // Using Dio for download
      Dio().download(downloadUrl, savePath).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Download Complete! Saved to: $filename'), backgroundColor: const Color(0xFF30D158)),
        );
      }).catchError((e) {
        _showError('Download Failed: $e');
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MediaProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Discover', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Paste Video URL...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(CupertinoIcons.link, color: Colors.white54),
                  suffixIcon: isLoading
                    ? const Padding(padding: EdgeInsets.all(12), child: CupertinoActivityIndicator())
                    : IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.white54),
                        onPressed: () => _urlController.clear(),
                      ),
                ),
                textDirection: TextDirection.ltr,
                onSubmitted: (_) => _processUrl(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _processUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Search & Extract', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
