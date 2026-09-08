import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_times_service.dart';

class SalawatService {
  SalawatService._();
  static final SalawatService instance = SalawatService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _voicePlayer = AudioPlayer();

  static const MethodChannel _nativeChannel =
      MethodChannel('com.alqurankareem/salawat');
  
  // High-importance channel with custom sound "salawat.mp3"
  static const String _channelId = 'salawat_alarm_v5';
  static const String _channelName = 'الصلاة على النبي ﷺ (صوت)';
    static const String _channelDesc =
      'تذكير دوري صوتي دقيق: عند الدقيقة 00 تُقال عبارة الصلاة على محمد ﷺ، وعند الدقيقة 30 تُقال عبارة خاتم المرسلين';

  static const int _baseNotificationId = 3000;
  static const int _totalSlots = 48; // 24 hours * 2 (00 and 30)

  static const String salawatText = 'صَلِّ عَلَى مُحَمَّد ﷺ';
  static const String salawatAudioPath = 'assets/audio/صلي علي محمد.mp3';
  // Additional phrase for :30
  static const String salawatTextHalf = 'وَصَلِّ عَلَى خَاتَمِ الْمُرْسَلِينَ';
  // You can add a separate audio file for the half-hour phrase if available
  static const String salawatAudioPathHalf = 'assets/audio/لا اله الا الله.mp3';

  Timer? _clockTimer;
  Timer? _recurringForegroundTimer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Create Android notification channel with max priority and alarm attributes
    if (Platform.isAndroid) {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestExactAlarmsPermission();

        // Delete previous channels to ensure fresh sound assignment
        try {
          await androidImplementation.deleteNotificationChannel('salawat_channel');
          await androidImplementation.deleteNotificationChannel('salawat_voice_channel');
          await androidImplementation.deleteNotificationChannel('salawat_exact_alarm_v3');
          await androidImplementation.deleteNotificationChannel('salawat_alarm_v5');
        } catch (_) {}

        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('salawat'),
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
        );
      }
    }

    _isInitialized = true;

    // Permanently enabled - always schedule
    await scheduleAll();
    if (!Platform.isAndroid) {
      _startClockAlignedForegroundTimer();
    }
  }

  /// Always returns true - user requested Salawat & Athkar to remain permanently enabled
  Future<bool> isEnabled() async {
    return true;
  }

  Future<void> setEnabled(bool enabled) async {
    // Kept for interface compatibility; always stays enabled
    await scheduleAll();
    if (!Platform.isAndroid) {
      _startClockAlignedForegroundTimer();
    }
  }

  /// Calculates milliseconds until the next exact :00 or :30 minute on the clock
  void _startClockAlignedForegroundTimer() {
    _stopForegroundTimers();

    final now = DateTime.now();
    int nextMinute;
    DateTime nextTime;

    if (now.minute < 30) {
      nextMinute = 30;
      nextTime = DateTime(now.year, now.month, now.day, now.hour, nextMinute, 0);
    } else {
      nextMinute = 0;
      nextTime = DateTime(now.year, now.month, now.day, now.hour + 1, nextMinute, 0);
    }

    final initialDelay = nextTime.difference(now);

    _clockTimer = Timer(initialDelay, () async {
      await _playNextSequentialThikr();

      // Then trigger every 30 minutes repeatedly
      _recurringForegroundTimer =
          Timer.periodic(const Duration(minutes: 30), (_) async {
        await _playNextSequentialThikr();
      });
    });
  }

  void _stopForegroundTimers() {
    _clockTimer?.cancel();
    _clockTimer = null;
    _recurringForegroundTimer?.cancel();
    _recurringForegroundTimer = null;
  }

  Future<void> _playNextSequentialThikr() async {
    final now = DateTime.now();
    final prayerTimes = await PrayerTimesService().getPrayerTimes();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    if (prayerTimes?.rawTimes.values.any(
          (time) => time == currentTime,
        ) ==
        true) {
      return;
    }

    final minute = now.minute;
    if (minute % 60 == 0) {
      // minute == 00 -> play 'صلي على محمد'
      await playVoice(assetPath: salawatAudioPath);
    } else if (minute == 30) {
      // minute == 30 -> play 'خاتم المر سلين'
      await playVoice(assetPath: salawatAudioPathHalf);
    } else {
      // fallback: play primary
      await playVoice(assetPath: salawatAudioPath);
    }
  }

  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('salawat'),
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'salawat.mp3',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Plays the voice sound directly through phone speaker at maximum volume
  Future<void> playVoice({String? assetPath}) async {
    try {
      if (Platform.isAndroid) {
        await _nativeChannel.invokeMethod('setMaxVolume');
      }
      final path = assetPath ?? salawatAudioPath;
      await _voicePlayer.setAsset(path);
      await _voicePlayer.setVolume(1.0);
      await _voicePlayer.play();
    } catch (e) {
      debugPrint('Error playing voice salawat: $e');
    }
  }

  Future<void> showTestNotification() async {
    await playVoice(assetPath: salawatAudioPath);
    await playVoice(assetPath: salawatAudioPathHalf);
  }

  Future<void> showTestNotificationInternal({bool half = false}) async {
    if (!_isInitialized) await initialize();

    if (Platform.isAndroid && !half) {
      try {
        await _nativeChannel.invokeMethod('testSalawat');
        return;
      } catch (e) {
        debugPrint('Native testSalawat error: $e');
      }
    }

    // Fallback: play appropriate phrase locally
    if (half) {
      await playVoice(assetPath: salawatAudioPathHalf);
    } else {
      await _playNextSequentialThikr();
    }
  }

  /// Schedules exact alarms at :00 and :30 of every hour
  Future<void> scheduleAll() async {
    if (!_isInitialized) await initialize();

    await cancelAll();

    // Trigger Native Android AlarmManager with WakeLock for guaranteed audio when screen is locked
    if (Platform.isAndroid) {
      try {
        await _nativeChannel.invokeMethod('scheduleSalawat');
      } catch (e) {
        debugPrint('Native scheduleSalawat error: $e');
      }

      // Android uses the native alarm receiver so it can skip prayer minutes
      // even when the Flutter engine is not running.
      _startClockAlignedForegroundTimer();
      return;
    }

    final now = DateTime.now();
    int slotIndex = 0;

    for (int hour = 0; hour < 24; hour++) {
      for (int minute in [0, 30]) {
        final id = _baseNotificationId + slotIndex;
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
          0,
        );

        // If this slot already passed today, schedule for tomorrow
        if (now.isAfter(scheduledDate)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
        // minute == 0 -> play salawatText (صلي على محمد)
        final body = (minute == 0) ? salawatText : salawatTextHalf;

        try {
          await _notifications.zonedSchedule(
            id,
            'الصلاة على النبي ﷺ',
            body,
            tzDateTime,
            _getNotificationDetails(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (e) {
          debugPrint('Error scheduling exact salawat slot $slotIndex ($hour:$minute): $e');
        }

        slotIndex++;
      }
    }
  }

  Future<void> cancelAll() async {
    if (Platform.isAndroid) {
      try {
        await _nativeChannel.invokeMethod('cancelSalawat');
      } catch (e) {
        debugPrint('Native cancelSalawat error: $e');
      }
    }

    for (int i = 0; i < _totalSlots; i++) {
      await _notifications.cancel(_baseNotificationId + i);
    }
  }
}
