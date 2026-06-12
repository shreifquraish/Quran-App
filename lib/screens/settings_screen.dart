import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';
import 'developer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        _SettingsTile(
          icon: Icons.search_rounded,
          title: 'البحث في القرآن',
          subtitle: 'ابحث في نص المصحف بدون إنترنت',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
        _SettingsTile(
          icon: Icons.bookmark_rounded,
          title: 'العلامات المرجعية',
          subtitle: 'علامة الصفحة وآخر موضع قراءة',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookmarksScreen()),
          ),
        ),
        _SettingsTile(
          icon: Icons.menu_book_rounded,
          title: 'حالة المصحف',
          subtitle: app.quranReady
              ? 'جاهز للقراءة بدون إنترنت'
              : 'غير محمّل',
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
              trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_back_ios_new_rounded, size: 16) : null),
            ),
          ),
        ),
      ),
    );
  }
}
