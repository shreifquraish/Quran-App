import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';
import 'read_screen.dart';

class _SearchHit {
  const _SearchHit({
    required this.surahId,
    required this.ayahNumber,
    required this.text,
    required this.reference,
    required this.pageNumber,
  });

  final int surahId;
  final int ayahNumber;
  final String text;
  final String reference;
  final int pageNumber;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<_SearchHit> _results = [];
  bool _searching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results = [];
        _lastQuery = trimmed;
      });
      return;
    }

    setState(() {
      _searching = true;
      _lastQuery = trimmed;
    });

    final cleaned = normalise(trimmed);
    final data = searchWords(cleaned, limit: 50);
    final raw = List<Map>.from(data['result'] as List<dynamic>? ?? []);

    final results = raw.map((item) {
      final surahId = item['sora'] as int;
      final ayahNumber = item['aya_no'] as int;
      final surahName = getSurahNameArabic(surahId);
      final page = getPageNumber(surahId, ayahNumber);
      return _SearchHit(
        surahId: surahId,
        ayahNumber: ayahNumber,
        text: getVerse(surahId, ayahNumber, verseEndSymbol: true),
        reference: 'سورة $surahName — آية $ayahNumber',
        pageNumber: page,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _results = results;
        _searching = false;
      });
    }
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
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'ابحث في القرآن...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _controller.clear();
                                      _search('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (v) {
                            setState(() {});
                            _search(v);
                          },
                          onSubmitted: _search,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_searching)
                  const LinearProgressIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                  ),
                Expanded(
                  child: _buildBody(context, dark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool dark) {
    if (_lastQuery.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'اكتب كلمة أو عبارة للبحث',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'البحث يعمل بدون إنترنت',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty && !_searching) {
      return Center(
        child: Text(
          'لا توجد نتائج لـ "$_lastQuery"',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MushafReaderRoute(
                      initialPage: result.pageNumber,
                      highlightAyah: result.ayahNumber,
                      highlightSurah: result.surahId,
                    ),
                  ),
                );
              },
              child: Ink(
                decoration: AppTheme.cardDecoration(dark: dark),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              result.reference,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result.text,
                        style: QuranTextStyles.hafsStyle(
                          fontSize: 20,
                          color: dark
                              ? AppColors.textPrimary
                              : AppColors.textDark,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
