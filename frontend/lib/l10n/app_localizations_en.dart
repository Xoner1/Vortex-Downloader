// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vortex Downloader';

  @override
  String get enterPasscode => 'Enter Passcode';

  @override
  String get unlock => 'UNLOCK';

  @override
  String get incorrectPasscode => 'Incorrect Passcode!';

  @override
  String get pasteLinkOrSearch => 'Paste Link or Search...';

  @override
  String get ready => 'Ready';

  @override
  String get initializing => 'Initializing...';

  @override
  String get pleaseEnterUrl => 'Please enter a URL!';

  @override
  String get downloading => 'Downloading...';

  @override
  String get failedToStart => 'Failed to start download';

  @override
  String get failedToConnect => 'Failed to connect to backend.';

  @override
  String get webSocketError => 'WebSocket Error';

  @override
  String get chooseFolder => 'Choose Folder';

  @override
  String get startDownload => 'START DOWNLOAD';

  @override
  String get speed => 'SPEED';

  @override
  String get size => 'SIZE';

  @override
  String get video => 'VIDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get settings => 'Settings';
}
