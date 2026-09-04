import 'dart:io';

import 'package:flutter/foundation.dart';

/// API base URL for Ashlar Lawyer Hub backend.
///
/// Override for local backend:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000`
/// or `--dart-define-from-file=env.production.json`
abstract final class ApiConfig {
  /// Live VPS — default for debug runs on physical devices and release APKs.
  static const String liveApiUrl = 'http://72.62.228.106:8080';

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kReleaseMode) {
      return liveApiUrl;
    }

    if (kIsWeb) {
      return liveApiUrl;
    }

    // Debug without dart-define: use live API so physical phones work out of the box.
    // For Android emulator + local backend, pass:
    // --dart-define=API_BASE_URL=http://10.0.2.2:3000
    if (Platform.isAndroid || Platform.isIOS) {
      return liveApiUrl;
    }

    return liveApiUrl;
  }
}
