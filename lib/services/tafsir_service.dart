import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/bookmark.dart';
import '../models/tafsir.dart';
import 'quran_service.dart';

class TafsirService {
  TafsirService(this._db);

  // _db is reserved for future DB-backed tafsir caching
  // ignore: unused_field
  final DatabaseHelper _db;
  Map<String, dynamic>? _offlineData;

  Future<void> ensureOfflineData() async {
    await _loadOfflineData();
  }

  Future<void> _loadOfflineData() async {
    if (_offlineData != null) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/tafsir.json');
      _offlineData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      _offlineData = null;
      rethrow;
    }
  }

  TafsirEdition editionBySlug(String slug) {
    return availableTafsirEditions.firstWhere(
      (e) => e.slug == slug,
      orElse: () => availableTafsirEditions.first,
    );
  }

  Future<Set<int>> cachedSurahIds(String editionSlug) async {
    return List.generate(114, (i) => i + 1).toSet();
  }

  Future<SurahTafsir?> getSurahTafsir({
    required int surahId,
    required String surahName,
    required TafsirEdition edition,
    bool includeInfo = true,
  }) async {
    await _loadOfflineData();
    if (_offlineData == null) return null;

    try {
      final surahs = _offlineData!['data']['surahs'] as List<dynamic>;
      final surah = surahs.firstWhere(
        (s) => s['number'] == surahId,
        orElse: () => null,
      );
      if (surah == null) return null;

      final ayahs = surah['ayahs'] as List<dynamic>;
      final parts = <String>[];
      for (final ayah in ayahs) {
        final map = ayah as Map<String, dynamic>;
        final text = (map['text'] as String? ?? '').trim();
        if (text.isNotEmpty) {
          parts.add('﴿${map['numberInSurah']}﴾ $text');
        }
      }

      if (parts.isEmpty) return null;
      final fullText = parts.join('\n\n');

      return SurahTafsir(
        surahId: surahId,
        surahName: surahName,
        edition: availableTafsirEditions.firstWhere(
            (e) => e.slug == 'ar-tafsir-al-jalalayn',
            orElse: () => edition),
        fullText: fullText,
        infoSections: const [],
      );
    } catch (_) {
      return null;
    }
  }

  // --- Ayah-level API ---

  Future<List<TafsirBook>> getBooksForSurah(int surahId) async {
    return const [
      TafsirBook(
        id: 1,
        name: 'تفسير الجلالين',
        author: 'جلال الدين المحلي والسيوطي',
      ),
    ];
  }

  Future<TafsirContent?> getTafsir({
    required int surahId,
    required int ayahNumber,
    int bookId = 1,
  }) async {
    await _loadOfflineData();
    if (_offlineData == null) return null;

    try {
      final surahs = _offlineData!['data']['surahs'] as List<dynamic>;
      final surah = surahs.firstWhere(
        (s) => s['number'] == surahId,
        orElse: () => null,
      );
      if (surah == null) return null;

      final ayahs = surah['ayahs'] as List<dynamic>;
      final ayah = ayahs.firstWhere(
        (a) => a['numberInSurah'] == ayahNumber,
        orElse: () => null,
      );
      if (ayah == null) return null;

      final text = (ayah['text'] as String? ?? '').trim();
      if (text.isEmpty) return null;

      return TafsirContent(
        bookName: 'تفسير الجلالين',
        author: 'جلال الدين المحلي والسيوطي',
        text: text,
      );
    } catch (_) {
      return null;
    }
  }
}
