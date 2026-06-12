import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/tafsir.dart';
import '../providers/app_provider.dart';
import 'surah_tafsir_screen.dart';

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  String _query = '';

  void _showEditionPicker(AppProvider app) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dark = app.isDarkMode;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: dark ? AppColors.surface : AppColors.cardLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    'اختر كتاب التفسير',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
                ...availableTafsirEditions.map((edition) {
                  final selected = edition.slug == app.tafsirEditionSlug;
                  return ListTile(
                    leading: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.menu_book_outlined,
                      color: selected ? AppColors.accent : null,
                    ),
                    title: Text(edition.name),
                    subtitle: Text(edition.author),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await app.setTafsirEdition(edition.slug);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final edition = app.tafsirService.editionBySlug(app.tafsirEditionSlug);
    final normalizedQuery = _query.trim();
    final surahs = app.surahs.where((s) {
      if (normalizedQuery.isEmpty) return true;
      return s.name.contains(normalizedQuery) ||
          s.id.toString() == normalizedQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              InkWell(
                onTap: () => _showEditionPicker(app),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: app.isDarkMode
                        ? AppColors.card
                        : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              edition.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              edition.author,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: app.isDarkMode
                      ? AppColors.card.withOpacity(0.6)
                      : Colors.white.withOpacity(0.85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    child: Text('${surah.id}'),
                  ),
                  title: Text('سورة ${surah.name}'),
                  subtitle: Text(
                    '${surah.ayahs} آية • ${surah.isMakkah ? 'مكية' : 'مدنية'}',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SurahTafsirScreen(surah: surah),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
