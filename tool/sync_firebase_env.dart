// Reads android/app/google-services.json (Firebase project ashlarlawyer)
// and merges FCM dart-defines into env.production.json.
//
// Usage: dart run tool/sync_firebase_env.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final gsPath = 'android/app/google-services.json';
  final envPath = 'env.production.json';
  final gsFile = File(gsPath);

  if (!gsFile.existsSync()) {
    stderr.writeln('Missing $gsPath');
    stderr.writeln('Firebase Console → project ashlarlawyer → Android app');
    stderr.writeln('Package: com.ashlarlawyerhub.ashlar_lawyer_hub');
    stderr.writeln('Download google-services.json → flutter/android/app/');
    exit(1);
  }

  final gs = jsonDecode(gsFile.readAsStringSync()) as Map<String, dynamic>;
  final projectInfo = gs['project_info'] as Map<String, dynamic>?;
  final clients = gs['client'] as List<dynamic>? ?? [];

  if (projectInfo == null || clients.isEmpty) {
    stderr.writeln('Invalid google-services.json');
    exit(1);
  }

  const packageName = 'com.ashlarlawyerhub.ashlar_lawyer_hub';
  Map<String, dynamic>? match;
  for (final raw in clients) {
    final client = raw as Map<String, dynamic>;
    final info = client['client_info'] as Map<String, dynamic>?;
    final android = info?['android_client_info'] as Map<String, dynamic>?;
    if (android?['package_name'] == packageName) {
      match = client;
      break;
    }
  }

  match ??= clients.first as Map<String, dynamic>;
  final clientInfo = match['client_info'] as Map<String, dynamic>;
  final apiKeys = match['api_key'] as List<dynamic>? ?? [];
  final apiKey = apiKeys.isNotEmpty
      ? (apiKeys.first as Map<String, dynamic>)['current_key'] as String?
      : null;

  final merged = <String, dynamic>{
    'API_BASE_URL': 'http://160.191.14.97:8080',
    'FIREBASE_PROJECT_ID': projectInfo['project_id'],
    'FIREBASE_MESSAGING_SENDER_ID': projectInfo['project_number'],
    'FIREBASE_ANDROID_API_KEY': apiKey ?? '',
    'FIREBASE_ANDROID_APP_ID': clientInfo['mobilesdk_app_id'],
  };

  final existing = File(envPath);
  if (existing.existsSync()) {
    final old = jsonDecode(existing.readAsStringSync()) as Map<String, dynamic>;
    if (old['API_BASE_URL'] != null) {
      merged['API_BASE_URL'] = old['API_BASE_URL'];
    }
  }

  existing.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(merged)}\n');
  stdout.writeln('Updated $envPath for Firebase project ${merged['FIREBASE_PROJECT_ID']}');
}