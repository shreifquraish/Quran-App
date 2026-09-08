import 'dart:convert';
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final Map<String, String> rawTimes;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.rawTimes,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    return PrayerTimes(
      fajr: _convertTo12Hour(timings['Fajr'] as String),
      dhuhr: _convertTo12Hour(timings['Dhuhr'] as String),
      asr: _convertTo12Hour(timings['Asr'] as String),
      maghrib: _convertTo12Hour(timings['Maghrib'] as String),
      isha: _convertTo12Hour(timings['Isha'] as String),
      rawTimes: {
        'الفجر': _cleanTime(timings['Fajr'] as String),
        'الظهر': _cleanTime(timings['Dhuhr'] as String),
        'العصر': _cleanTime(timings['Asr'] as String),
        'المغرب': _cleanTime(timings['Maghrib'] as String),
        'العشاء': _cleanTime(timings['Isha'] as String),
      },
    );
  }

  static String _cleanTime(String time) => time.split(' ').first;

  static String _convertTo12Hour(String time24) {
    try {
      final parts = time24.split(' ');
      if (parts.length > 1) return time24; // Already has AM/PM
      
      final timeParts = time24.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      
      final period = hour >= 12 ? 'م' : 'ص';
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
      
      return '$hour:$minute $period';
    } catch (e) {
      return time24;
    }
  }
}

class PrayerSettings {
  final String city;
  final String country;
  final bool fajrEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;

  PrayerSettings({
    required this.city,
    required this.country,
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'fajr_enabled': fajrEnabled,
      'dhuhr_enabled': dhuhrEnabled,
      'asr_enabled': asrEnabled,
      'maghrib_enabled': maghribEnabled,
      'isha_enabled': ishaEnabled,
    };
  }

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    return PrayerSettings(
      city: json['city'] as String,
      country: json['country'] as String,
      fajrEnabled: json['fajr_enabled'] as bool? ?? true,
      dhuhrEnabled: json['dhuhr_enabled'] as bool? ?? true,
      asrEnabled: json['asr_enabled'] as bool? ?? true,
      maghribEnabled: json['maghrib_enabled'] as bool? ?? true,
      ishaEnabled: json['isha_enabled'] as bool? ?? true,
    );
  }
}

class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  PrayerSettings? _settings;

  static const Map<String, List<double>> _egyptianCityCoordinates = {
    'Cairo': [30.0444, 31.2357],
    'Alexandria': [31.2001, 29.9187],
    'Giza': [30.0131, 31.2089],
    'Shubra El Kheima': [30.1286, 31.2422],
    'Port Said': [31.2653, 32.3019],
    'Suez': [29.9668, 32.5498],
    'Luxor': [25.6872, 32.6396],
    'Mansoura': [31.0409, 31.3785],
    'El-Mahalla El-Kubra': [30.9706, 31.1669],
    'Tanta': [30.7865, 31.0004],
    'Asyut': [27.1809, 31.1837],
    'Ismailia': [30.5965, 32.2715],
    'Fayyum': [29.3084, 30.8428],
    'Faiyum': [29.3084, 30.8428],
    'Zagazig': [30.5877, 31.5020],
    'Aswan': [24.0889, 32.8998],
    'Damietta': [31.4165, 31.8133],
    'Minya': [28.1099, 30.7503],
    'Damanhur': [31.0341, 30.4682],
    'Beni Suef': [29.0661, 31.0994],
    'Qena': [26.1551, 32.7160],
    'Sohag': [26.5591, 31.6957],
    'Shibin El Kom': [30.5526, 31.0090],
    'Banha': [30.4667, 31.1833],
    'Kafr El Sheikh': [31.1107, 30.9388],
    'Arish': [31.1316, 33.7984],
    'Mallawi': [27.7314, 30.8417],
    'Marsa Matruh': [31.3543, 27.2373],
    'Matrouh': [31.3543, 27.2373],
    'North Sinai': [31.1316, 33.7984],
    'South Sinai': [28.5559, 33.9180],
    'Red Sea': [27.2579, 33.8116],
    'New Valley': [25.4400, 30.5500],
    'Dakahlia': [31.0409, 31.3785],
    'Gharbia': [30.7865, 31.0004],
    'Monufia': [30.5526, 31.0090],
    'Qalyubia': [30.4667, 31.1833],
    'Sharqia': [30.5877, 31.5020],
    'Beheira': [31.0341, 30.4682],
  };

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    await _loadSettings();
    await _scheduleUpcomingPrayers();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('prayer_settings');
    if (settingsJson != null) {
      _settings = PrayerSettings.fromJson(jsonDecode(settingsJson));
    } else {
      // Default to Cairo, Egypt
      _settings = PrayerSettings(city: 'Cairo', country: 'Egypt');
      await _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prayer_settings', jsonEncode(_settings!.toJson()));
  }

  PrayerSettings? get settings => _settings;

  Future<void> updateSettings({
    String? city,
    String? country,
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
  }) async {
    _settings = PrayerSettings(
      city: city ?? _settings?.city ?? 'Cairo',
      country: country ?? _settings?.country ?? 'Egypt',
      fajrEnabled: fajrEnabled ?? _settings?.fajrEnabled ?? true,
      dhuhrEnabled: dhuhrEnabled ?? _settings?.dhuhrEnabled ?? true,
      asrEnabled: asrEnabled ?? _settings?.asrEnabled ?? true,
      maghribEnabled: maghribEnabled ?? _settings?.maghribEnabled ?? true,
      ishaEnabled: ishaEnabled ?? _settings?.ishaEnabled ?? true,
    );
    await _saveSettings();
    await _scheduleUpcomingPrayers();
  }

  Future<PrayerTimes?> getPrayerTimes() async {
    if (_settings == null) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      return await _getPrayerTimesForDate(DateTime.now(), prefs);
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
    }
    return null;
  }

  String _cacheKey(DateTime date) {
    final dateString = DateFormat('dd-MM-yyyy').format(date);
    return 'prayer_times_${_settings!.city}_${_settings!.country}_$dateString';
  }

  Future<PrayerTimes?> _getPrayerTimesForDate(
    DateTime date,
    SharedPreferences prefs,
  ) async {
    final key = _cacheKey(date);

    try {
      final coordinates = _egyptianCityCoordinates[_settings!.city] ??
          _egyptianCityCoordinates['Cairo']!;
      final calculated = adhan.PrayerTimes(
        coordinates: adhan.Coordinates(coordinates[0], coordinates[1]),
        date: date,
        calculationParameters: adhan.CalculationMethodParameters.egyptian(),
      );
      final timings = _formatCalculatedTimes(calculated);
      await prefs.setString(key, jsonEncode(timings));
      return PrayerTimes.fromJson({'timings': timings});
    } catch (e) {
      debugPrint('Using cached prayer times for $date: $e');
    }

    final cached = prefs.getString(key);
    if (cached == null) return null;
    return PrayerTimes.fromJson({'timings': jsonDecode(cached)});
  }

  Map<String, String> _formatCalculatedTimes(adhan.PrayerTimes times) {
    String format(DateTime value) {
      final cairoTime = tz.TZDateTime.from(value, tz.local);
        return '${cairoTime.hour.toString().padLeft(2, '0')}:'
          '${cairoTime.minute.toString().padLeft(2, '0')}';
    }

    return {
      'Fajr': format(times.fajr),
      'Dhuhr': format(times.dhuhr),
      'Asr': format(times.asr),
      'Maghrib': format(times.maghrib),
      'Isha': format(times.isha),
    };
  }

  Future<void> _scheduleUpcomingPrayers() async {
    if (_settings == null) return;

    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.cancelScheduledAdhanNotifications();

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = now.add(Duration(days: dayOffset));
        final timings = await _getPrayerTimesForDate(date, prefs);
        if (timings == null) continue;
        await notificationService.scheduleAdhanNotifications(
          date: date,
          times: timings.rawTimes,
          enabled: {
            'الفجر': _settings!.fajrEnabled,
            'الظهر': _settings!.dhuhrEnabled,
            'العصر': _settings!.asrEnabled,
            'المغرب': _settings!.maghribEnabled,
            'العشاء': _settings!.ishaEnabled,
          },
        );
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  List<String> getEgyptianCities() {
    return [
      'Cairo',
      'Alexandria',
      'Giza',
      'Shubra El Kheima',
      'Port Said',
      'Suez',
      'Luxor',
      'Mansoura',
      'El-Mahalla El-Kubra',
      'Tanta',
      'Asyut',
      'Ismailia',
      'Fayyum',
      'Zagazig',
      'Aswan',
      'Damietta',
      'Minya',
      'Damanhur',
      'Beni Suef',
      'Qena',
      'Sohag',
      'Shibin El Kom',
      'Banha',
      'Kafr El Sheikh',
      'Arish',
      'Mallawi',
      'Bilbeis',
      'Marsa Matruh',
      'Mit Ghamr',
      'Edfu',
      'Dakahlia',
      'Gharbia',
      'Monufia',
      'Qalyubia',
      'Sharqia',
      'Beheira',
      'Kafr El Sheikh',
      'Dakahlia',
      'Damietta',
      'Port Said',
      'Ismailia',
      'Suez',
      'North Sinai',
      'South Sinai',
      'Faiyum',
      'Beni Suef',
      'Minya',
      'Asyut',
      'Sohag',
      'Qena',
      'Luxor',
      'Aswan',
      'Red Sea',
      'New Valley',
      'Matrouh',
    ];
  }
}
