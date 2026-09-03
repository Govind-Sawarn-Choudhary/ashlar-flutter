import 'dart:io';

import 'package:flutter/foundation.dart';

/// API base URL for Ashlar Lawyer Hub backend.
///
/// Production / physical device:
/// `flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com`
/// or `--dart-define-from-file=env.json`
abstract final class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL is required for release builds. '
        'Pass --dart-define=API_BASE_URL=https://your-api.com',
      );
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }
}
