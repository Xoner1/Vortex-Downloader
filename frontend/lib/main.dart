import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:file_selector/file_selector.dart';

void main() {
  runApp(const VortexApp());
}

class VortexApp extends StatelessWidget {
  const VortexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vortex Downloader',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF28a745),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF28a745),
          secondary: Color(0xFF28a745),
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF28a745),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
      home: const VortexHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VortexHomePage extends StatefulWidget {
  const VortexHomePage({super.key});

  @override
  State<VortexHomePage> createState() => _VortexHomePageState();
}

class _VortexHomePageState extends State<VortexHomePage> {
  final TextEditingController _urlController = TextEditingController();
  String _mode = 'video';
  String _quality = '1080';
  String _savePath = '.';
  String _status = 'Ready';

  // Progress state
  String _percent = '0%';
  String _speed = '0 MB/s';
  String _size = '0 MB';

  WebSocketChannel? _channel;

  Future<void> _chooseFolder() async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _savePath = directoryPath;
      });
    }
  }

  Future<void> _startDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _status = 'Please enter a URL!';
      });
      return;
    }

    setState(() {
      _status = 'Initializing...';
      _percent = '0%';
      _speed = '0 B/s';
      _size = '0 MB';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': url,
          'path': _savePath,
          'mode': _mode,
          'quality': _quality,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final taskId = data['task_id'];

        if (taskId != null) {
          _connectWebSocket(taskId);
        } else {
           setState(() {
            _status = data['error'] ?? 'Failed to start download';
          });
        }
      } else {
        setState(() {
          _status = 'Failed to connect to backend.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  void _connectWebSocket(String taskId) {
    if (_channel != null) {
      _channel!.sink.close();
    }

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/progress/$taskId'),
    );

    _channel!.stream.listen((message) {
      final data = jsonDecode(message);

      setState(() {
        if (data.containsKey('status_msg')) {
          _status = data['status_msg'];
        } else {
          _percent = '${data['percent']}%';
          _speed = data['speed'];
          _size = data['total'];
          _status = 'Downloading...';
        }
      });
    }, onError: (error) {
      setState(() {
        _status = 'WebSocket Error';
      });
    }, onDone: () {
      // Don't change status to disconnected if yt-dlp finishes normally.
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                const Text(
                  'VORTEX',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),

                // URL Input
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Paste Link Here...',
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Mode Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton('VIDEO', 'video'),
                    const SizedBox(width: 20),
                    _buildModeButton('AUDIO (MP3)', 'audio'),
                  ],
                ),
                const SizedBox(height: 20),

                // Quality Dropdown
                if (_mode == 'video')
                  Container(
                    width: 160,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _quality,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2A2A2A),
                        items: ['1080', '720', '480', '360']
                            .map((q) => DropdownMenuItem(
                                  value: q,
                                  child: Text('${q}p'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _quality = val);
                          }
                        },
                      ),
                    ),
                  ),
                if (_mode == 'video') const SizedBox(height: 20),

                // Folder Selector
                TextButton.icon(
                  onPressed: _chooseFolder,
                  icon: const Icon(Icons.folder_open, color: Colors.white70),
                  label: Text(
                    _savePath == '.' ? 'Choose Folder' : '📂 ${_savePath.split(RegExp(r'[/\\]')).last}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Label
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 14,
                    color: _status.contains('Error') || _status.contains('Failed') || _status.contains('Please')
                        ? Colors.redAccent
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Start Button
                SizedBox(
                  width: 300,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _startDownload,
                    child: const Text(
                      'START DOWNLOAD',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Info Panel
                Container(
                  width: 400,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _speed,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _percent,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF28a745),
                        ),
                      ),
                      Text(
                        _size,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, String mode) {
    final isSelected = _mode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _mode = mode;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 140,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF28a745) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: Colors.white24, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
