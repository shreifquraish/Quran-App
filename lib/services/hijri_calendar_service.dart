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

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthName,
  });

  String get formatted => '$day $monthName $year هـ';

  factory HijriDate.now() => HijriDate.fromGregorian(DateTime.now());

  factory HijriDate.fromGregorian(DateTime date) {
    // Julian Day Number
    int y = date.year, m = date.month, d = date.day;
    if (m <= 2) { y -= 1; m += 12; }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
               (30.6001 * (m + 1)).floor() +
               d + b - 1524;

    // Julian → Hijri
    var l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
              (l / 5670).floor() * ((43 * l) / 15238).floor();
    l = l - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    final hMonth = ((24 * l) / 709).floor();
    final hDay = l - ((709 * hMonth) / 24).floor();
    final hYear = 30 * n + j - 30;

    return HijriDate(
      year: hYear,
      month: hMonth,
      day: hDay,
      monthName: _getHijriMonthName(hMonth),
    );
  }

  DateTime toGregorian() {
    // Hijri → Julian Day Number
    final jd = ((11 * year + 3) / 30).floor() +
               354 * year +
               30 * month -
               ((month - 1) / 2).floor() +
               day +
               1948440 -
               385;

    // Julian → Gregorian
    var l = jd + 68569;
    final n = ((4 * l) / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    final i = ((4000 * (l + 1)) / 1461001).floor();
    l = l - ((1461 * i) / 4).floor() + 31;
    final j = ((80 * l) / 2447).floor();
    final gDay = l - ((2447 * j) / 80).floor();
    l = (j / 11).floor();
    final gMonth = j + 2 - 12 * l;
    final gYear = 100 * (n - 49) + i + l;

    return DateTime(gYear, gMonth, gDay);
  }

  static String _getHijriMonthName(int month) {
    const months = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    return months[(month - 1).clamp(0, 11)];
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

  bool isToday(HijriDate today) => today.month == month && today.day == day;

  bool isUpcoming(HijriDate today, int daysBefore) {
    var targetYear = today.year;
    if (month < today.month || (month == today.month && day < today.day)) {
      targetYear += 1;
    }
    final eventGregorian = HijriDate(year: targetYear, month: month, day: day, monthName: '').toGregorian();
    final now = DateTime.now();
    final todayGregorian = DateTime(now.year, now.month, now.day);
    final diff = eventGregorian.difference(todayGregorian).inDays;
    return diff >= 0 && diff <= daysBefore;
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
      if (daysUntil == 1) {
        final alreadyNotified = await wasEventNotified('\${event.id}_before');
        if (!alreadyNotified) {
          await _scheduleNotification(
            event,
            'غداً: \${event.name}',
            event.description,
            DateTime.now().add(const Duration(hours: 24)),
          );
          await markEventAsNotified('\${event.id}_before');
        }
      }
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
    upcoming.sort((a, b) => _daysUntilEvent(a, today).compareTo(_daysUntilEvent(b, today)));
    return upcoming;
  }

    int _daysUntilEvent(HijriEvent event, HijriDate today) {
      var targetYear = today.year;
      if (event.month < today.month || (event.month == today.month && event.day < today.day)) {
        targetYear += 1;
      }
      final gregorianTarget = HijriDate(year: targetYear, month: event.month, day: event.day, monthName: '').toGregorian();
      final now = DateTime.now();
final todayGregorian = DateTime(now.year, now.month, now.day);
      return gregorianTarget.difference(todayGregorian).inDays;
    }

  HijriEvent? getTodayEvent() {
    final today = currentDate;
    for (final event in importantEvents) {
      if (event.isToday(today)) return event;
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
