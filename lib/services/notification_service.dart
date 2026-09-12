import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../core/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const MethodChannel _adhanChannel =
      MethodChannel('com.alqurankareem/adhan');

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _notifications.cancel(5001);

    await requestPermissions();

    _initialized = true;
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    if (response.id == 5002 && response.payload != null) {
      await launchUrl(
        Uri.parse(response.payload!),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final bool? granted = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  Future<void> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(AppConstants.updateManifestUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final manifest = jsonDecode(response.body) as Map<String, dynamic>;
      final remoteVersion = manifest['version'] as String?;
      final downloadUrl = manifest['url'] as String?;
      if (remoteVersion == null || downloadUrl == null ||
          !_isNewerVersion(remoteVersion, AppConstants.appVersion)) {
        return;
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'app_updates',
          'تحديثات التطبيق',
          channelDescription: 'إشعارات إصدارات التطبيق الجديدة',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      );
      await _notifications.show(
        5002,
        'يتوفر تحديث جديد',
        'الإصدار $remoteVersion متاح الآن، اضغط للتحميل',
        details,
        payload: downloadUrl,
      );
    } catch (_) {
      // Update checks are optional and must never affect offline startup.
    }
  }

  /// Shows a notification about a new version (called from background worker).
  /// `version` is the remote version string, `downloadUrl` is an optional URL to open when the user taps the notification.
  Future<void> showUpdateNotification(String version, String? downloadUrl) async {
    const androidDetails = AndroidNotificationDetails(
      'app_updates',
      'تحديثات التطبيق',
      channelDescription: 'إشعارات إصدارات التطبيق الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      5002,
      'يتوفر تحديث جديد',
      'الإصدار $version متاح الآن، اضغط للتحميل',
      details,
      payload: downloadUrl,
    );
  }

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
    for (var index = 0; index < 3; index++) {
      final remotePart = index < remoteParts.length ? remoteParts[index] : 0;
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      if (remotePart != currentPart) return remotePart > currentPart;
    }
    return false;
  }

  Future<void> showUpdateNotificationIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    const lastVersionKey = 'last_notified_app_version';
    final lastVersion = prefs.getString(lastVersionKey);

    if (lastVersion == null) {
      await prefs.setString(lastVersionKey, AppConstants.appVersion);
      return;
    }
    if (lastVersion == AppConstants.appVersion) return;

    const androidDetails = AndroidNotificationDetails(
      'app_updates',
      'تحديثات التطبيق',
      channelDescription: 'إشعارات إصدارات التطبيق الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      5001,
      'تم تحديث التطبيق',
      'تم تثبيت الإصدار ${AppConstants.appVersion} بنجاح',
      details,
    );
    await prefs.setString(lastVersionKey, AppConstants.appVersion);
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'تجربة',
      channelDescription: 'قناة تجربة الإشعارات',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      0,
      'تجربة',
      'هذا إشعار تجريبي',
      platformChannelSpecifics,
    );
  }

  Future<void> playTestAdhan() async {
    if (Platform.isAndroid) {
      await _adhanChannel.invokeMethod('testAdhan');
    }
  }

  Future<void> scheduleAdhanNotification(String prayerName, String time) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'adhan_channel_v2',
      'الأذان',
      channelDescription: 'إشعارات الأذان',
      importance: Importance.max,
      priority: Priority.max,
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'adhan.mp3',
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'حان وقت $prayerName',
      'الآن الساعة $time',
      platformChannelSpecifics,
    );
  }

  Future<void> cancelScheduledAdhanNotifications() async {
    if (Platform.isAndroid) {
      await _adhanChannel.invokeMethod('cancelAdhan');
      return;
    }
    for (var id = 1000; id < 2000; id++) {
      await _notifications.cancel(id);
    }
  }

  Future<void> scheduleAdhanNotifications({
    required DateTime date,
    required Map<String, String> times,
    required Map<String, bool> enabled,
  }) async {
    for (final entry in times.entries) {
      if (enabled[entry.key] != true) continue;

      final parts = entry.value.split(':');
      if (parts.length < 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      final scheduledDate = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
      if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) continue;

      final id = 1000 +
          (date.difference(DateTime(date.year, 1, 1)).inDays * 10) +
          times.keys.toList().indexOf(entry.key);
      if (Platform.isAndroid) {
        await _adhanChannel.invokeMethod('scheduleAdhan', {
          'id': id,
          'timestamp': scheduledDate.millisecondsSinceEpoch,
        });
        continue;
      }
      await _notifications.zonedSchedule(
        id,
        'حان وقت ${entry.key}',
        'حان الآن وقت صلاة ${entry.key}',
        scheduledDate,
        _adhanNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  NotificationDetails get _adhanNotificationDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'adhan_channel_v2',
        'الأذان',
        channelDescription: 'إشعارات الأذان',
        importance: Importance.max,
        priority: Priority.max,
        sound: const RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'adhan.wav',
        presentSound: true,
      ),
    );
  }
}
