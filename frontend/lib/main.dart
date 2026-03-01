import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audio_session/audio_session.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/presentation/screens/passcode_screen.dart';
import 'package:frontend/core/audio/global_player_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Audio Session Setup: TikTok/Call Interruption Logic
  await _initAudioSession();

  // Local Storage Initialization (sqflite handled by Repositories later)

  runApp(const VortexProApp());
}

/// Strict AudioSession implementation enforcing background playback
/// and auto-ducking/pausing for phone calls, TikTok, WhatsApp, etc.
Future<void> _initAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback, // Essential for iOS background
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    androidWillPauseWhenDucked: true, // Crucial for auto-pause when TikTok opens
  ));

  // Listen to focus changes actively
  session.interruptionEventStream.listen((event) {
    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          // Temporary interruption (e.g., notification) -> Volume drops
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          // Phone call or TikTok starts -> Player must pause
          GlobalPlayerManager.instance.pause();
          break;
      }
    } else {
      switch (event.type) {
        case AudioInterruptionType.duck:
          // Volume normalizes
          break;
        case AudioInterruptionType.pause:
          // Call ended, or user closed TikTok -> Auto-Resume
          GlobalPlayerManager.instance.play();
          break;
        case AudioInterruptionType.unknown:
          break;
      }
    }
  });
}

class VortexProApp extends StatelessWidget {
  const VortexProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vortex Stream Pro',
      theme: AppTheme.darkTheme,
      home: const PasscodeScreen(), // Entry point -> Features/Auth
      debugShowCheckedModeBanner: false,

      // Global Localizations (Arabic RTL & English LTR)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
    );
  }
}
