import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DailyReadingProgress {
  final String date;
  final int pagesRead;
  final int juzRead;
  final int targetPages;
  final int targetJuz;

  DailyReadingProgress({
    required this.date,
    required this.pagesRead,
    required this.juzRead,
    required this.targetPages,
    required this.targetJuz,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'pages_read': pagesRead,
      'juz_read': juzRead,
      'target_pages': targetPages,
      'target_juz': targetJuz,
    };
  }

  factory DailyReadingProgress.fromJson(Map<String, dynamic> json) {
    return DailyReadingProgress(
      date: json['date'] as String,
      pagesRead: json['pages_read'] as int? ?? 0,
      juzRead: json['juz_read'] as int? ?? 0,
      targetPages: json['target_pages'] as int? ?? 10,
      targetJuz: json['target_juz'] as int? ?? 1,
    );
  }

  double get pagesProgress => targetPages > 0 ? pagesRead / targetPages : 0;
  double get juzProgress => targetJuz > 0 ? juzRead / targetJuz : 0;
}

class DailyReadingService {
  static final DailyReadingService _instance = DailyReadingService._internal();
  factory DailyReadingService() => _instance;
  DailyReadingService._internal();

  static const String _progressKey = 'daily_reading_progress';
  static const String _historyKey = 'daily_reading_history';
  static const String _settingsKey = 'daily_reading_settings';
  static const String _notificationKey = 'daily_reading_notification';

  DailyReadingProgress? _currentProgress;
  List<DailyReadingProgress> _history = [];
  int _targetPages = 10;
  int _targetJuz = 1;
  bool _notificationsEnabled = true;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _loadSettings();
    await _loadCurrentProgress();
    await _loadHistory();
    await _initializeNotifications();
    await _scheduleDailyNotification();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(settings);
  }

  Future<void> _scheduleDailyNotification() async {
    if (!_notificationsEnabled) return;

    // Cancel existing notification
    await _notifications.cancel(999);

    // Schedule notification for 12 PM
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 12, 0);
    
    if (now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      999,
      'تذكير بالورد اليومي',
      'لم تقرأ وردك اليوم بعد',
      scheduledTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reading',
          'الورد اليومي',
          channelDescription: 'إشعارات الورد اليومي',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> checkAndSendNotification() async {
    if (!_notificationsEnabled) return;

    final now = DateTime.now();
    if (now.hour == 12 && now.minute >= 0 && now.minute < 5) {
      final prefs = await SharedPreferences.getInstance();
      final lastNotification = prefs.getString(_notificationKey);
      final today = _getTodayDateString();

      if (lastNotification != today) {
        await _sendMissedReadingNotification();
        await prefs.setString(_notificationKey, today);
      }
    }
  }

  Future<void> _sendMissedReadingNotification() async {
    final missedDays = <DailyReadingProgress>[];
    
    // Check today
    if (_currentProgress != null && 
        _currentProgress!.pagesRead < _currentProgress!.targetPages &&
        _currentProgress!.juzRead < _currentProgress!.targetJuz) {
      missedDays.add(_currentProgress!);
    }

    // Check yesterday if not completed
    if (_history.isNotEmpty) {
      final yesterday = _history[_history.length - 1];
      if (yesterday.pagesRead < yesterday.targetPages &&
          yesterday.juzRead < yesterday.targetJuz) {
        missedDays.add(yesterday);
      }
    }

    if (missedDays.isEmpty) {
      await _notifications.show(
        999,
        'أحسنت!',
        'لقد أكملت وردك اليوم',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reading',
            'الورد اليومي',
            channelDescription: 'إشعارات الورد اليومي',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } else {
      String message = 'لم تقرأ وردك في الأيام التالية:\n';
      for (final day in missedDays) {
        message += '${day.date}: ${day.pagesRead}/${day.targetPages} صفحة\n';
      }
      
      await _notifications.show(
        999,
        'تذكير بالورد اليومي',
        message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reading',
            'الورد اليومي',
            channelDescription: 'إشعارات الورد اليومي',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(message),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      _targetPages = settings['target_pages'] as int? ?? 10;
      _targetJuz = settings['target_juz'] as int? ?? 1;
      _notificationsEnabled = settings['notifications_enabled'] as bool? ?? true;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode({
      'target_pages': _targetPages,
      'target_juz': _targetJuz,
      'notifications_enabled': _notificationsEnabled,
    }));
  }

  Future<void> _loadCurrentProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    if (progressJson != null) {
      _currentProgress = DailyReadingProgress.fromJson(jsonDecode(progressJson));
      
      // Reset if it's a new day
      final today = _getTodayDateString();
      if (_currentProgress!.date != today) {
        await _saveToHistory(_currentProgress!);
        _currentProgress = DailyReadingProgress(
          date: today,
          pagesRead: 0,
          juzRead: 0,
          targetPages: _targetPages,
          targetJuz: _targetJuz,
        );
        await _saveCurrentProgress();
      }
    } else {
      _currentProgress = DailyReadingProgress(
        date: _getTodayDateString(),
        pagesRead: 0,
        juzRead: 0,
        targetPages: _targetPages,
        targetJuz: _targetJuz,
      );
      await _saveCurrentProgress();
    }
  }

  Future<void> _saveCurrentProgress() async {
    if (_currentProgress == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(_currentProgress!.toJson()));
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> historyList = jsonDecode(historyJson);
      _history = historyList
          .map((json) => DailyReadingProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveToHistory(DailyReadingProgress progress) async {
    _history.add(progress);
    // Keep only last 30 days
    if (_history.length > 30) {
      _history.removeAt(0);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(_history.map((p) => p.toJson()).toList()));
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DailyReadingProgress? get currentProgress => _currentProgress;
  List<DailyReadingProgress> get history => _history;
  int get targetPages => _targetPages;
  int get targetJuz => _targetJuz;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> updateProgress({int? pagesRead, int? juzRead}) async {
    if (_currentProgress == null) return;
    
    _currentProgress = DailyReadingProgress(
      date: _currentProgress!.date,
      pagesRead: pagesRead ?? _currentProgress!.pagesRead,
      juzRead: juzRead ?? _currentProgress!.juzRead,
      targetPages: _currentProgress!.targetPages,
      targetJuz: _currentProgress!.targetJuz,
    );
    
    await _saveCurrentProgress();
  }

  Future<void> updateSettings({
    int? targetPages,
    int? targetJuz,
    bool? notificationsEnabled,
  }) async {
    if (targetPages != null) _targetPages = targetPages;
    if (targetJuz != null) _targetJuz = targetJuz;
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    
    await _saveSettings();
    
    // Update current progress with new targets
    if (_currentProgress != null) {
      _currentProgress = DailyReadingProgress(
        date: _currentProgress!.date,
        pagesRead: _currentProgress!.pagesRead,
        juzRead: _currentProgress!.juzRead,
        targetPages: _targetPages,
        targetJuz: _targetJuz,
      );
      await _saveCurrentProgress();
    }
  }

  double getOverallCompletionRate() {
    if (_history.isEmpty) return 0.0;
    
    int completedDays = 0;
    for (final progress in _history) {
      if (progress.pagesRead >= progress.targetPages || 
          progress.juzRead >= progress.targetJuz) {
        completedDays++;
      }
    }
    
    return completedDays / _history.length;
  }

  double getAveragePagesPerDay() {
    if (_history.isEmpty) return 0.0;
    
    int totalPages = 0;
    for (final progress in _history) {
      totalPages += progress.pagesRead;
    }
    
    return totalPages / _history.length;
  }

  int getCurrentStreak() {
    if (_history.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < _history.length; i++) {
      final progress = _history[_history.length - 1 - i];
      final progressDate = DateTime.parse(progress.date);
      final difference = today.difference(progressDate).inDays;
      
      if (difference == i + 1) {
        if (progress.pagesRead >= progress.targetPages || 
            progress.juzRead >= progress.targetJuz) {
          streak++;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    
    return streak;
  }
}
