import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'notification_service.dart';
import '../core/constants.dart';

// Helper to compare semantic version strings (major.minor.patch)
bool _isNewerVersion(String remote, String current) {
  List<int> parts(String value) {
    final version = value.trim().split('+').first;
    final numbers = version.split('.').map(int.tryParse).toList();
    if (numbers.any((part) => part == null)) return const [0, 0, 0];
    return [
      numbers.isNotEmpty ? numbers[0]! : 0,
      numbers.length > 1 ? numbers[1]! : 0,
      numbers.length > 2 ? numbers[2]! : 0,
    ];
  }

  final remoteParts = parts(remote);
  final currentParts = parts(current);
  for (var i = 0; i < 3; i++) {
    final r = i < remoteParts.length ? remoteParts[i] : 0;
    final c = i < currentParts.length ? currentParts[i] : 0;
    if (r != c) return r > c;
  }
  return false;
}
/// Background callback invoked by WorkManager. Checks the remote Gist for a new
/// version. If a newer version is found, shows a notification using
/// NotificationService.
void updateCheckCallback() async {
  const url =
      'https://gist.githubusercontent.com/shreifquraish/4580454c14f68df1a109f4eef024ee/raw/version.json';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final remoteVersion = json['version'] as String? ?? '';
    // Use app version defined in constants
    final localVersion = AppConstants.appVersion;
    // Use singleton NotificationService (factory returns same instance)
    final notificationService = NotificationService();
    if (remoteVersion.isNotEmpty && _isNewerVersion(remoteVersion, localVersion)) {
      await notificationService.showUpdateNotification(
        remoteVersion,
        json['url'] as String?,
      );
    }
  } catch (_) {
    // Silently ignore errors in background tasks.
  }
}

/// Register the periodic background task. Call once from `main()` before the
/// Flutter engine is initialized.
Future<void> registerUpdateCheckWorker() async {
  await Workmanager().initialize(
    (task) => updateCheckCallback(),
    isInDebugMode: false,
  );
  await Workmanager().registerPeriodicTask(
    'update-check-task',
    'update-check',
    frequency: const Duration(hours: 12),
    initialDelay: const Duration(minutes: 5),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
}
