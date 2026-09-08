import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HijriDate {
  final int year;
  final int month;
  final int day;
  final String monthName;

  HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthName,
  });

  String get formatted => '$day $monthName $year هـ';

  factory HijriDate.now() {
    // Reference date: July 20, 2026 = 6 Safar 1448
    final referenceGregorian = DateTime(2026, 7, 20);
    const referenceHijriDay = 6;
    const referenceHijriMonth = 2; // Safar
    const referenceHijriYear = 1448;
    
    final now = DateTime.now();
    final daysDifference = now.difference(referenceGregorian).inDays;
    
    // Calculate the Hijri date based on the reference
    // Average Hijri month length: 29.5 days
    final totalDaysFromReference = daysDifference;
    final monthDifference = (totalDaysFromReference / 29.5).floor();
    final dayDifference = totalDaysFromReference % 29.5;
    
    var newDay = referenceHijriDay + dayDifference.floor();
    var newMonth = referenceHijriMonth + monthDifference;
    var newYear = referenceHijriYear;
    
    // Adjust for month overflow
    while (newDay > 30) {
      newDay -= 30;
      newMonth++;
    }
    while (newDay < 1) {
      newDay += 29;
      newMonth--;
    }
    
    // Adjust for year overflow
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    
    return HijriDate(
      year: newYear,
      month: newMonth.clamp(1, 12),
      day: newDay.clamp(1, 30),
      monthName: _getHijriMonthName(newMonth.clamp(1, 12)),
    );
  }

  static double _gregorianToJulian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
           (30.6001 * (month + 1)).floor() +
           day +
           b - 1524.5;
  }

  static String _getHijriMonthName(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    return months[(month - 1) % 12];
  }
}

class HijriEvent {
  const HijriEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.month,
    required this.day,
    required this.notificationDaysBefore,
  });

  final String id;
  final String name;
  final String description;
  final int month;
  final int day;
  final int notificationDaysBefore;

  bool isToday(HijriDate today) {
    return today.month == month && today.day == day;
  }

  bool isUpcoming(HijriDate today, int daysBefore) {
    final eventDate = DateTime(today.year, month, day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final difference = eventDate.difference(todayDate).inDays;
    return difference >= 0 && difference <= daysBefore;
  }
}

class HijriCalendarService {
  static final HijriCalendarService _instance = HijriCalendarService._internal();
  factory HijriCalendarService() => _instance;
  HijriCalendarService._internal();

  static const String _eventsKey = 'hijri_events_history';
  static const String _settingsKey = 'hijri_calendar_settings';

  bool _notificationsEnabled = true;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const List<HijriEvent> importantEvents = [
    HijriEvent(
      id: 'ramadan_start',
      name: 'بداية شهر رمضان',
      description: 'شهر الصيام والقيام',
      month: 9,
      day: 1,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'laylat_al_qadr',
      name: 'ليلة القدر',
      description: 'ليلة خير من ألف شهر',
      month: 9,
      day: 27,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'eid_al_fitr',
      name: 'عيد الفطر',
      description: 'عيد الفطر المبارك',
      month: 10,
      day: 1,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'arafat',
      name: 'يوم عرفة',
      description: 'يوم الحج الأكبر',
      month: 12,
      day: 9,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'eid_al_adha',
      name: 'عيد الأضحى',
      description: 'عيد النحر',
      month: 12,
      day: 10,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'hijri_new_year',
      name: 'رأس السنة الهجرية',
      description: 'بداية السنة الهجرية الجديدة',
      month: 1,
      day: 1,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'ashura',
      name: 'يوم عاشوراء',
      description: 'يوم عاشوراء',
      month: 1,
      day: 10,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'mawlid',
      name: 'المولد النبوي',
      description: 'مولد النبي محمد ﷺ',
      month: 3,
      day: 12,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'isra_miraj',
      name: 'الإسراء والمعراج',
      description: 'رحلة الإسراء والمعراج',
      month: 7,
      day: 27,
      notificationDaysBefore: 1,
    ),
    HijriEvent(
      id: 'mid_shaaban',
      name: 'ليلة النصف من شعبان',
      description: 'ليلة النصف من شعبان',
      month: 8,
      day: 15,
      notificationDaysBefore: 1,
    ),
  ];

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _loadSettings();
    await _initializeNotifications();
    await _scheduleEventNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(settings);
  }

  Future<void> _scheduleEventNotifications() async {
    if (!_notificationsEnabled) return;

    final today = currentDate;
    
    for (final event in importantEvents) {
      final daysUntil = _daysUntilEvent(event, today);
      
      // Schedule notification 1 day before the event
      if (daysUntil == 1) {
        final alreadyNotified = await wasEventNotified('${event.id}_before');
        if (!alreadyNotified) {
          await _scheduleNotification(
            event,
            'غداً: ${event.name}',
            event.description,
            DateTime.now().add(const Duration(hours: 24)),
          );
          await markEventAsNotified('${event.id}_before');
        }
      }
      
      // Schedule notification on the event day
      if (daysUntil == 0) {
        final alreadyNotified = await wasEventNotified(event.id);
        if (!alreadyNotified) {
          await _scheduleNotification(
            event,
            event.name,
            event.description,
            DateTime.now().add(const Duration(hours: 1)),
          );
          await markEventAsNotified(event.id);
        }
      }
    }
  }

  Future<void> _scheduleNotification(
    HijriEvent event,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    try {
      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      await _notifications.zonedSchedule(
        event.id.hashCode,
        title,
        body,
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hijri_events',
            'أحداث هجرية',
            channelDescription: 'إشعارات الأحداث الهجرية المهمة',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
      _notificationsEnabled = settings['notifications_enabled'] as bool? ?? true;
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode({
      'notifications_enabled': _notificationsEnabled,
    }));
  }

  HijriDate get currentDate => HijriDate.now();

  List<HijriEvent> get events => importantEvents;

  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSettings();
  }

  List<HijriEvent> getUpcomingEvents({int daysAhead = 30}) {
    final today = currentDate;
    final upcoming = <HijriEvent>[];

    for (final event in importantEvents) {
      if (event.isUpcoming(today, daysAhead)) {
        upcoming.add(event);
      }
    }

    upcoming.sort((a, b) {
      final aDays = _daysUntilEvent(a, today);
      final bDays = _daysUntilEvent(b, today);
      return aDays.compareTo(bDays);
    });

    return upcoming;
  }

  int _daysUntilEvent(HijriEvent event, HijriDate today) {
    final eventDate = DateTime(today.year, event.month, event.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return eventDate.difference(todayDate).inDays;
  }

  HijriEvent? getTodayEvent() {
    final today = currentDate;
    for (final event in importantEvents) {
      if (event.isToday(today)) {
        return event;
      }
    }
    return null;
  }

  Future<void> markEventAsNotified(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_eventsKey) ?? '[]';
    final history = jsonDecode(historyJson) as List<dynamic>;
    
    final today = currentDate.formatted;
    if (!history.any((e) => e['event_id'] == eventId && e['date'] == today)) {
      history.add({
        'event_id': eventId,
        'date': today,
        'notified_at': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_eventsKey, jsonEncode(history));
    }
  }

  Future<bool> wasEventNotified(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_eventsKey) ?? '[]';
    final history = jsonDecode(historyJson) as List<dynamic>;
    
    final today = currentDate.formatted;
    return history.any((e) => e['event_id'] == eventId && e['date'] == today);
  }
}
