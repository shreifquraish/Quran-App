import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';
import 'developer_screen.dart';
import 'daily_reading_screen.dart';
import 'duas_screen.dart';
import 'tajweed_screen.dart';
import 'hijri_calendar_screen.dart';
// Tasmee feature removed

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        Container(
          decoration: AppTheme.cardDecoration(dark: dark),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.mosque_rounded,
                size: 48,
                color: AppColors.accent,
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'قراءة واستماع القرآن الكريم',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tasmee tile removed

        // Small Prayer-on-Prophet status card (moved here from Duas)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: AppTheme.cardDecoration(dark: dark),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mosque_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'الصلاة على النبي',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مفعّل دائماً',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.accent),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: AppTheme.cardDecoration(dark: dark),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.volume_up_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'الأذان',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مفعّل دائماً',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.accent),
              ],
            ),
          ),
        ),

        // Removed 'البحث في القرآن' tile per user request
        _SettingsTile(
          icon: Icons.bookmark_rounded,
          title: 'العلامات المرجعية',
          subtitle: 'علامة الصفحة وآخر موضع قراءة',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookmarksScreen()),
          ),
        ),
        // Removed 'الورد اليومي' tile per user request
        _SettingsTile(
          icon: Icons.favorite_rounded,
          title: 'الأدعية والأذكار',
          subtitle: 'أذكار الصباح والمساء وأدعية الأنبياء',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DuasScreen()),
          ),
        ),
        _SettingsTile(
          icon: Icons.school_rounded,
          title: 'قواعد التجويد',
          subtitle: 'تعلم أحكام تلاوة القرآن',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TajweedScreen()),
          ),
        ),
        _SettingsTile(
          icon: Icons.calendar_today_rounded,
          title: 'التقويم الهجري',
          subtitle: 'التاريخ الهجري والأحداث المهمة',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
          ),
        ),
        _SettingsTile(
          icon: Icons.dark_mode_rounded,
          title: 'الوضع الداكن',
          subtitle: app.isDarkMode ? 'مفعّل' : 'معطّل',
          trailing: Switch(
            value: app.isDarkMode,
            onChanged: (_) => app.toggleTheme(),
            activeColor: AppColors.accent,
          ),
        ),
        _SettingsTile(
          icon: Icons.menu_book_rounded,
          title: 'حالة المصحف',
          subtitle: app.quranReady ? 'جاهز للقراءة بدون إنترنت' : 'غير محمّل',
          trailing: Icon(
            app.quranReady ? Icons.check_circle : Icons.cloud_download,
            color: app.quranReady ? AppColors.primaryLight : AppColors.accent,
          ),
        ),
        _SettingsTile(
          icon: Icons.person_rounded,
          title: 'المطور',
          subtitle: 'ENG: Shreif Quraish',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DeveloperScreen()),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'المطور: Shreif Quraish\nالهاتف: 01556313513',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: AppTheme.cardDecoration(dark: dark),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: ListTile(
              leading: Icon(icon, color: AppColors.accent),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: trailing ??
                  (onTap != null
                      ? const Icon(Icons.arrow_back_ios_new_rounded, size: 16)
                      : null),
            ),
          ),
        ),
      ),
    );
  }
}
