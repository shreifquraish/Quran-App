import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../utils/quran_format.dart';
import 'read_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  int? _markedPage;
  int? _lastReadPage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final app = context.read<AppProvider>();
    final marked = await app.quranService.getMarkedPage();
    final last = await app.quranService.getLastReadPage();
    if (mounted) {
      setState(() {
        _markedPage = marked;
        _lastReadPage = last;
        _loading = false;
      });
    }
  }

  Future<void> _clearMarked() async {
    await context.read<AppProvider>().quranService.clearMarkedPage();
    await _load();
  }

  void _openPage(int page) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => MushafReaderRoute(initialPage: page),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: AppTheme.gradientBackground(dark: dark),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'العلامات المرجعية',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            if (_markedPage != null)
                              _BookmarkCard(
                                icon: Icons.bookmark_rounded,
                                title: 'علامة المصحف',
                                subtitle:
                                    'صفحة ${toArabicDigits(_markedPage!)}',
                                description:
                                    'الصفحة التي وضعت عليها العلامة للعودة إليها',
                                onTap: () => _openPage(_markedPage!),
                                onDelete: _clearMarked,
                                dark: dark,
                              )
                            else
                              _EmptyMarkedCard(dark: dark),
                            const SizedBox(height: 12),
                            if (_lastReadPage != null)
                              _BookmarkCard(
                                icon: Icons.menu_book_rounded,
                                title: 'آخر موضع قراءة',
                                subtitle:
                                    'صفحة ${toArabicDigits(_lastReadPage!)}',
                                description: 'آخر صفحة توقفت عندها',
                                onTap: () => _openPage(_lastReadPage!),
                                dark: dark,
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
    required this.dark,
    this.onDelete,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: AppTheme.cardDecoration(dark: dark).copyWith(
            border: Border.all(color: AppColors.accent.withOpacity(0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.accent,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMarkedCard extends StatelessWidget {
  const _EmptyMarkedCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(dark: dark),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 56,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد علامة على صفحة',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'أثناء قراءة المصحف، اضغط على أيقونة العلامة\nلوضعها على الصفحة الحالية',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
