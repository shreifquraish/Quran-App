import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';

class UpdateService {
  // Replace this URL with the raw URL of your version.json file hosted on GitHub Gist or similar.
  // The JSON file should look exactly like this:
  // {
  //   "version": "1.0.1",
  //   "url": "https://www.mediafire.com/file/pvjih40arlls1ro/%25D8%25A7%25D9%2584%25D9%2582%25D8%25B1%25D8%25A3%25D9%2586_%25D8%25A7%25D9%2584%25D9%2583%25D8%25B1%25D9%258A%25D9%2585.apk/file"
  // }
  static const String _versionUrl = 'https://gist.githubusercontent.com/shreifquraish/458045c14f68fd1af109f4cfeef024ee/raw/version.json';
  
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(_versionUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final remoteVersion = data['version'] as String;
        final downloadUrl = data['url'] as String;
        
        // Check if current version is less than 1.1.0 - show special message to reinstall
        if (_isOlderThan(AppConstants.appVersion, '1.1.0')) {
          _showReinstallDialog(context, remoteVersion, downloadUrl);
          return;
        }
        
        // Simple version check (assuming format x.y.z)
        // If your app version in pubspec is 1.0.0, you can compare it.
        // For simplicity, we compare it against a hardcoded constant in AppConstants.
        if (_isNewer(remoteVersion, AppConstants.appVersion)) {
          _showUpdateDialog(context, remoteVersion, downloadUrl);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  static bool _isNewer(String remote, String local) {
    final rParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final lParts = local.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final r = i < rParts.length ? rParts[i] : 0;
      final l = i < lParts.length ? lParts[i] : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }

  static bool _isOlderThan(String version, String threshold) {
    final vParts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final tParts = threshold.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final v = i < vParts.length ? vParts[i] : 0;
      final t = i < tParts.length ? tParts[i] : 0;
      if (v < t) return true;
      if (v > t) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تحديث جديد متوفر'),
        content: Text('تم إصدار النسخة $version من التطبيق. هل ترغب في تحميلها الآن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('تحميل الآن'),
          ),
        ],
      ),
    );
  }

  static void _showReinstallDialog(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تحديث هام'),
        content: const Text('تم إصدار نسخة جديدة من التطبيق. لتحديث التطبيق، يرجى حذف النسخة الحالية وتحميل النسخة الجديدة من موقعنا الرسمي.'),
        actions: [
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('تحميل من الموقع'),
          ),
        ],
      ),
    );
  }
}
