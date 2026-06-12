import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/surah.dart';
import '../models/tafsir.dart';
import '../providers/app_provider.dart';

class SurahTafsirScreen extends StatefulWidget {
  const SurahTafsirScreen({super.key, required this.surah});

  final Surah surah;

  @override
  State<SurahTafsirScreen> createState() => _SurahTafsirScreenState();
}

class _SurahTafsirScreenState extends State<SurahTafsirScreen> {
  SurahTafsir? _tafsir;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final app = context.read<AppProvider>();
    final edition =
        app.tafsirService.editionBySlug(app.tafsirEditionSlug);

    final result = await app.tafsirService.getSurahTafsir(
      surahId: widget.surah.id,
      surahName: widget.surah.name,
      edition: edition,
    );

    if (!mounted) return;
    setState(() {
      _tafsir = result;
      _loading = false;
      _error = result == null ? 'تعذّر تحميل تفسير هذه السورة' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: dark ? AppColors.surfaceDark : AppColors.cardLight,
        appBar: AppBar(
          title: Column(
            children: [
              Text('سورة ${widget.surah.name}'),
              if (_tafsir != null)
                Text(
                  _tafsir!.edition.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                ),
            ],
          ),
        ),
        body: _buildBody(dark),
      ),
    );
  }

  Widget _buildBody(bool dark) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final tafsir = _tafsir!;
    final textStyle = GoogleFonts.amiri(
      fontSize: 20,
      height: 2.0,
      color: dark ? AppColors.textPrimary : AppColors.textDark,
    );
    final titleStyle = GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.accent,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.35),
                  AppColors.primaryLight.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'تفسير سورة ${widget.surah.name}',
                  style: titleStyle.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  tafsir.edition.author,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (tafsir.infoSections.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...tafsir.infoSections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: titleStyle),
                    const SizedBox(height: 8),
                    SelectableText(section.content, style: textStyle),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            Text('التفسير', style: titleStyle),
            const SizedBox(height: 12),
          ],
          SelectableText(tafsir.fullText, style: textStyle),
        ],
      ),
    );
  }
}
