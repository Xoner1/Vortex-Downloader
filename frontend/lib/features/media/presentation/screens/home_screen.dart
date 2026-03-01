import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

    try {
      // Haptic Feedback for Apple Polish
      HapticFeedback.lightImpact();

      final media = await provider.extractMedia(url);

      if (!mounted) return;

      if (media != null) {
        // Save to local history automatically
        await provider.saveToHistory(media);

        // Immediate Navigation to PlayerScreen on success
        if (mounted) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => PlayerScreen(
                media: media,
                isAudioOnly:
                    false, // Defaulting to video stream, can be toggleable later
              ),
            ),
          );
        }
      } else {
        _showError(provider.error ?? 'Failed to extract media data.');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _downloadFile(
    String downloadUrl,
    String ext,
    String title,
  ) async {
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
      final filename =
          "${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.$ext";
      final savePath = '${downloadDir.path}/$filename';

      if (mounted) {
        _showGlassmorphismSnackBar('Downloading started in background...');
      }

      // Using Dio for download
      Dio()
          .download(downloadUrl, savePath)
          .then((_) {
            if (mounted) {
              _showGlassmorphismSnackBar(
                'Download Complete! Saved to: $filename',
              );
            }
          })
          .catchError((e) {
            if (mounted) {
              _showError('Download Failed: $e');
            }
          });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    _showGlassmorphismSnackBar(message, isError: true);
  }

  void _showGlassmorphismSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.redAccent.withValues(alpha: 0.3)
                    : const Color(0xFF1C1C1E).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12, width: 0.5),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MediaProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.8),
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
                  prefixIcon: const Icon(
                    CupertinoIcons.link,
                    color: Colors.white54,
                  ),
                  suffixIcon: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CupertinoActivityIndicator(),
                        )
                      : IconButton(
                          icon: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: Colors.white54,
                          ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Search & Extract',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
