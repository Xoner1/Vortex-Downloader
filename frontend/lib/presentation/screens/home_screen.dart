import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:frontend/presentation/screens/player_screen.dart';
import 'package:frontend/data/local_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  Future<void> _processUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://vortex-downloader-nh6sa471q-xoner1s-projects.vercel.app/api/extract'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          _showError(data['error']);
          return;
        }

        // Show iOS Action Sheet
        _showOptionsSheet(data);
      } else {
        _showError('Server Error');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOptionsSheet(Map<String, dynamic> data) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Options'),
        message: Text(data['title'] ?? 'Unknown Media'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Stream Now', style: TextStyle(color: CupertinoColors.activeBlue)),
            onPressed: () async {
              Navigator.pop(context);

              // Save to history
              await LocalDatabase.instance.insertHistory({
                'title': data['title'],
                'artist': data['artist'],
                'thumbnail': data['thumbnail'],
                'video_url': data['video_url'],
                'audio_url': data['audio_url'],
              });

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => PlayerScreen(
                    metadata: data,
                    isAudioOnly: false,
                  ),
                ),
              );
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Download Video (4K/1080p)'),
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(data['video_url'], 'mp4');
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Download Audio (MP3)'),
            onPressed: () {
              Navigator.pop(context);
              _downloadFile(data['audio_url'], 'mp3');
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

  Future<void> _downloadFile(String? downloadUrl, String ext) async {
    if (downloadUrl == null) {
      _showError('URL not found for this format');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/VortexDownloads');
      if (!await downloadDir.exists()) await downloadDir.create();

      final filename = "download_${DateTime.now().millisecondsSinceEpoch}.$ext";
      final savePath = '${downloadDir.path}/$filename';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading started in background...'), backgroundColor: Color(0xFF1C1C1E)),
      );

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
                  suffixIcon: _isLoading
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
                  onPressed: _isLoading ? null : _processUrl,
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
