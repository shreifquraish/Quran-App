import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/bookmark.dart';
import '../models/surah.dart';
import '../providers/app_provider.dart';

class TafsirSheet extends StatefulWidget {
  const TafsirSheet({
    super.key,
    required this.surah,
    required this.ayahNumber,
    required this.ayahText,
  });

  final Surah surah;
  final int ayahNumber;
  final String ayahText;

  static Future<void> show(
    BuildContext context, {
    required Surah surah,
    required int ayahNumber,
    required String ayahText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafsirSheet(
        surah: surah,
        ayahNumber: ayahNumber,
        ayahText: ayahText,
      ),
    );
  }

  @override
  State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  List<TafsirBook> _books = [];
  int? _selectedBookId;
  TafsirContent? _content;
  bool _loadingBooks = true;
  bool _loadingContent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final app = context.read<AppProvider>();
    try {
      final books =
          await app.tafsirService.getBooksForSurah(widget.surah.id);
      if (mounted) {
        setState(() {
          _books = books;
          _selectedBookId = books.first.id;
          _loadingBooks = false;
        });
        _loadTafsir(books.first.id);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingBooks = false;
          _error = 'تعذر تحميل كتب التفسير';
        });
      }
    }
  }

  Future<void> _loadTafsir(int bookId) async {
    setState(() {
      _loadingContent = true;
      _error = null;
      _selectedBookId = bookId;
    });

    final app = context.read<AppProvider>();
    final content = await app.tafsirService.getTafsir(
      surahId: widget.surah.id,
      ayahNumber: widget.ayahNumber,
      bookId: bookId,
    );

    if (mounted) {
      setState(() {
        _content = content;
        _loadingContent = false;
        _error = content == null ? 'لا يتوفر تفسير لهذه الآية' : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isDarkMode;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: dark ? AppColors.surface : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفسير الآية',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${widget.surah.name} : ${widget.ayahNumber}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  widget.ayahText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.9,
                        fontSize: 18,
                      ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            if (_books.length > 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _books.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    final selected = book.id == _selectedBookId;
                    return FilterChip(
                      label: Text(book.name),
                      selected: selected,
                      onSelected: (_) => _loadTafsir(book.id),
                      selectedColor: AppColors.accent.withOpacity(0.25),
                      checkmarkColor: AppColors.accent,
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
            Flexible(
              child: _buildContent(context, dark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool dark) {
    if (_loadingBooks || _loadingContent) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _loadTafsir(_selectedBookId ?? 1),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textDark,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_content != null) ...[
            Text(
              _content!.bookName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                  ),
            ),
            if (_content!.author.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _content!.author,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _content!.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.9,
                    fontSize: 16,
                  ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ],
      ),
    );
  }
}
