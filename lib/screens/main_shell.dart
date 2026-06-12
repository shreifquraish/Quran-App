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

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    ReadScreen(),
    TafsirScreen(),
    ListenScreen(),
    RadiosScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    if (app.isLoading) {
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
        return 'استماع التلاوات';
      case 3:
        return 'إذاعة القرآن';
      default:
        return 'الإعدادات';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mosque_rounded, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 0.5,
                      ),
                ),
                Text(
                  _title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          if (index == 0) ...[
            IconButton(
              tooltip: 'بحث',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              icon: const Icon(Icons.search_rounded, color: AppColors.accent),
            ),
            IconButton(
              tooltip: 'العلامات المرجعية',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookmarksScreen()),
              ),
              icon: const Icon(Icons.bookmark_rounded, color: AppColors.accent),
            ),
          ],
        ],
      ),
    );
  }
}
