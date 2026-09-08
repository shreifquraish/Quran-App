import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(settings);
  }

  Future<bool> requestAllPermissions(BuildContext context) async {
    await _requestMicrophonePermission();
    final locationGranted = await _requestLocationPermission();
    final notificationGranted = await _requestNotificationPermission();
    final alarmGranted = await _requestAlarmPermission();

    if (!locationGranted || !notificationGranted) {
      _showPermissionDialog(context, locationGranted, notificationGranted, alarmGranted);
      return false;
    }

    return true;
  }

  Future<bool> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<bool> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> _requestAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true;
  }

  void _showPermissionDialog(
    BuildContext context,
    bool locationGranted,
    bool notificationGranted,
    bool alarmGranted,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('الأذونات المطلوبة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionItem('الموقع', locationGranted, Icons.location_on),
              _buildPermissionItem('الإشعارات', notificationGranted, Icons.notifications),
              if (Platform.isAndroid)
                _buildPermissionItem('المنبه الدقيق', alarmGranted, Icons.alarm),
              const SizedBox(height: 16),
              const Text(
                'هذه الأذونات ضرورية لعمل التطبيق بشكل صحيح مثل القبلة وأوقات الصلاة والتنبيهات.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _openAppSettings();
              },
              child: const Text('فتح الإعدادات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String name, bool granted, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: granted ? Colors.green : Colors.red,
            ),
          ),
          const Spacer(),
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 16,
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  Future<bool> checkLocationPermission() async {
    return await _requestLocationPermission();
  }

  Future<bool> checkNotificationPermission() async {
    return await _requestNotificationPermission();
  }
}
