import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/mini_player.dart';
import 'listen_screen.dart';
import 'radios_screen.dart';
import 'read_screen.dart';
import 'tafsir_screen.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'prayer_times_screen.dart';
// Tasmee feature removed
import '../services/update_service.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UpdateService.checkForUpdates(context);
      // Removed microphone permission prompt as requested
    });
  }

  final _pages = const [
    ReadScreen(),
    TafsirScreen(),
    ListenScreen(),
    PrayerTimesScreen(),
    RadiosScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    // Only show splash screen if quran is not ready
    if (!app.quranReady) {
      return SplashScreen(
        progress: app.setupProgress,
        message: app.setupMessage,
        error: app.setupError,
        onRetry: app.retryQuranDownload,
        showProgress: app.showProgress,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: false,
        body: Container(
          decoration: AppTheme.gradientBackground(dark: app.isDarkMode),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(index: _index),
                Expanded(child: _pages[_index]),
                const MiniPlayer(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'القراءة',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'التفسير',
            ),
            NavigationDestination(
              icon: Icon(Icons.headphones_outlined),
              selectedIcon: Icon(Icons.headphones_rounded),
              label: 'الاستماع',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time_rounded),
              label: 'الصلاة',
            ),
            NavigationDestination(
              icon: Icon(Icons.radio_outlined),
              selectedIcon: Icon(Icons.radio_rounded),
              label: 'الإذاعة',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.index});

  final int index;

  String get _title {
    switch (index) {
      case 0:
        return 'قراءة المصحف';
      case 1:
        return 'تفسير السور';
      case 2:
        return 'إذاعة القرآن';
      case 3:
        return 'أوقات الصلاة';
      case 4:
        return 'استماع التلاوات';
      default:
        return 'الإعدادات';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
                if (index == 0) ...[
            Container(
              decoration: BoxDecoration(
                color: dark ? AppColors.card.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'بحث',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                icon: const Icon(Icons.search_rounded, color: AppColors.accent),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: dark ? AppColors.card.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'العلامات المرجعية',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                ),
                icon: const Icon(Icons.bookmark_rounded, color: AppColors.accent),
              ),
            ),
            // Removed duplicate search icon per user request
          ],
        ],
      ),
    );
  }
}
