import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../utils/quran_format.dart';
import 'mushaf_reader_screen.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  int? _lastReadPage;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final last =
        await context.read<AppProvider>().quranService.getLastReadPage();
    if (mounted) setState(() => _lastReadPage = last);
  }

  void _openMushaf({required int page, int? surahId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => MushafReaderRoute(
              initialPage: page,
              initialSurahId: surahId,
            ),
          ),
        )
        .then((_) => _loadLastRead());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;
    final showContinue = _lastReadPage != null;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: app.surahs.length + (showContinue ? 1 : 0),
      itemBuilder: (context, index) {
        if (showContinue && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: AppTheme.cardDecoration(dark: dark),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: AppColors.accent.withOpacity(0.2),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.accent,
                  ),
                ),
                title: const Text('متابعة القراءة'),
                subtitle: Text(
                  'من صفحة ${toArabicDigits(_lastReadPage!)}',
                ),
                trailing:
                    const Icon(Icons.menu_book_rounded, color: AppColors.accent),
                onTap: () => _openMushaf(page: _lastReadPage!),
              ),
            ),
          );
        }

        final surah = app.surahs[showContinue ? index - 1 : index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: AppTheme.cardDecoration(dark: dark),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.25),
                child: Text(
                  '${surah.id}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('سورة ${surah.name}'),
              subtitle: Text(
                '${surah.ayahs} آية • ${surah.isMakkah ? 'مكية' : 'مدنية'}',
              ),
              trailing:
                  const Icon(Icons.menu_book_rounded, color: AppColors.accent),
              onTap: () => _openMushaf(
                page: getPageNumber(surah.id, 1),
                surahId: surah.id,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// للتنقل من البحث أو العلامات المرجعية.
class MushafReaderRoute extends StatelessWidget {
  const MushafReaderRoute({
    super.key,
    required this.initialPage,
    this.highlightAyah,
    this.highlightSurah,
    this.initialSurahId,
  });

  final int initialPage;
  final int? highlightAyah;
  final int? highlightSurah;
  final int? initialSurahId;

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
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
                Expanded(
                  child: MushafReaderScreen(
                    initialPage: initialPage,
                    highlightAyah: highlightAyah,
                    highlightSurah: highlightSurah,
                    initialSurahId: initialSurahId,
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
