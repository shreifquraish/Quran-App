import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../utils/quran_format.dart';

class MushafReaderScreen extends StatefulWidget {
  const MushafReaderScreen({
    super.key,
    this.initialPage,
    this.highlightAyah,
    this.highlightSurah,
    this.initialSurahId,
  });

  final int? initialPage;
  final int? highlightAyah;
  final int? highlightSurah;
  final int? initialSurahId;

  @override
  State<MushafReaderScreen> createState() => MushafReaderScreenState();
}

class MushafReaderScreenState extends State<MushafReaderScreen> {
  PageController? _pageController;
  int _currentPage = 1;
  int? _markedPage;
  bool _ready = false;
  List<HighlightVerse> _activeHighlights = [];
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final app = context.read<AppProvider>();
    final marked = await app.quranService.getMarkedPage();
    final last = await app.quranService.getLastReadPage();
    final start = widget.initialPage ??
        (widget.initialSurahId != null
            ? getPageNumber(widget.initialSurahId!, 1)
            : null) ??
        last ??
        1;

    if (!mounted) return;
    setState(() {
      _markedPage = marked;
      _currentPage = start.clamp(1, totalPagesCount);
      _pageController = PageController(initialPage: _currentPage - 1);
      _ready = true;
    });

    if (widget.highlightSurah != null && widget.highlightAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerTemporaryHighlight(
          widget.highlightSurah!,
          widget.highlightAyah!,
          _currentPage,
        );
      });
    }
  }

  void _triggerTemporaryHighlight(int surah, int ayah, int page) {
    final color = context.read<AppProvider>().isDarkMode
        ? AppColors.accent
        : AppColors.primary;

    setState(() {
      _activeHighlights.add(
        HighlightVerse(
          surah: surah,
          verseNumber: ayah,
          page: page,
          color: color,
        ),
      );
    });

    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _activeHighlights.removeWhere(
          (h) => h.surah == surah && h.verseNumber == ayah,
        );
      });
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _highlightTimer?.cancel();
    super.dispose();
  }

  String _surahLabelForPage(int page) {
    final segments = getPageData(page);
    if (segments.isEmpty) return '';
    final surahId = segments.first['surah'] as int;
    return getSurahNameArabic(surahId);
  }

  void _onPageChanged(int pageNumber) {
    setState(() => _currentPage = pageNumber);
    context.read<AppProvider>().quranService.setLastReadPage(pageNumber);
  }

  Future<void> _togglePageBookmark() async {
    final app = context.read<AppProvider>();
    if (_markedPage == _currentPage) {
      await app.quranService.clearMarkedPage();
      setState(() => _markedPage = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إزالة العلامة المرجعية')),
        );
      }
    } else {
      await app.quranService.setMarkedPage(_currentPage);
      setState(() => _markedPage = _currentPage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم وضع علامة على صفحة ${toArabicDigits(_currentPage)}',
            ),
          ),
        );
      }
    }
  }

  void goToPage(int page) {
    final p = page.clamp(1, totalPagesCount);
    _pageController?.animateToPage(
      p - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _showSurahIndex() {
    final app = context.read<AppProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final dark = app.isDarkMode;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            decoration: BoxDecoration(
              color: dark ? AppColors.surface : AppColors.cardLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'فهرس السور',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: app.surahs.length,
                    itemBuilder: (context, index) {
                      final surah = app.surahs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primaryLight.withOpacity(0.2),
                          child: Text('${surah.id}'),
                        ),
                        title: Text(surah.name),
                        subtitle: Text(
                          '${surah.ayahs} آية • ${surah.isMakkah ? 'مكية' : 'مدنية'}',
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          goToPage(getPageNumber(surah.id, 1));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _pageController == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;
    final isMarked = _markedPage == _currentPage;
    final showResume =
        _markedPage != null && _currentPage < _markedPage!;
    final textColor = dark ? AppColors.textPrimary : AppColors.textDark;

    return Column(
      children: [
        _Toolbar(
          currentPage: _currentPage,
          surahName: _surahLabelForPage(_currentPage),
          isMarked: isMarked,
          onBookmark: _togglePageBookmark,
          onIndex: _showSurahIndex,
          onPrev: _currentPage > 1 ? () => goToPage(_currentPage - 1) : null,
          onNext: _currentPage < totalPagesCount
              ? () => goToPage(_currentPage + 1)
              : null,
        ),
        if (showResume)
          _ResumeBanner(
            page: _markedPage!,
            onTap: () => goToPage(_markedPage!),
          ),
        Expanded(
          child: QuranPageView(
            pageController: _pageController!,
            highlights: _activeHighlights,
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            ayahStyle: QuranTextStyles.hafsStyle(
              fontSize: 22,
              color: textColor,
            ),
            pagePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            highlightPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            customHighlightDecoration: (color) => BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            topBarBuilder: (context, pageIndex) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الجزء ${toArabicDigits(getCurrentJuzNumberForPage(pageIndex))}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      getCurrentHizbTextForPage(pageIndex, isArabic: true),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              );
            },
            bottomBarBuilder: (context, pageIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  toArabicDigits(pageIndex),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            },
            pageBackgroundBuilder: (context, pageContent) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: dark
                      ? AppColors.card.withOpacity(0.35)
                      : const Color(0xFFFBF6EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2),
                  ),
                ),
                child: pageContent,
              );
            },
            onPageChanged: _onPageChanged,
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.currentPage,
    required this.surahName,
    required this.isMarked,
    required this.onBookmark,
    required this.onIndex,
    this.onPrev,
    this.onNext,
  });

  final int currentPage;
  final String surahName;
  final bool isMarked;
  final VoidCallback onBookmark;
  final VoidCallback onIndex;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'الصفحة السابقة',
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (surahName.isNotEmpty)
                  Text(
                    'سورة $surahName',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryLight,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  'صفحة ${toArabicDigits(currentPage)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'الصفحة التالية',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: isMarked ? 'إزالة العلامة' : 'وضع علامة على الصفحة',
            onPressed: onBookmark,
            icon: Icon(
              isMarked ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              color: isMarked ? AppColors.accent : null,
            ),
          ),
          IconButton(
            tooltip: 'فهرس السور',
            onPressed: onIndex,
            icon: const Icon(Icons.list_alt_rounded),
          ),
        ],
      ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.page, required this.onTap});

  final int page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.bookmark_rounded, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'العودة للعلامة المرجعية — صفحة ${toArabicDigits(page)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
