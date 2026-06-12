import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../core/constants.dart';
import '../models/bookmark.dart';
import '../models/surah.dart';
import '../utils/arabic_utils.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;
  static const _dbVersion = 3;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'quran_kareem.db');
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createV1Tables(db);
        await _createV2Tables(db);
        await _createV3Tables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createV2Tables(db);
          await _backfillSearchableText(db);
        }
        if (oldVersion < 3) {
          await _createV3Tables(db);
        }
      },
    );
  }

  Future<void> _createV1Tables(Database db) async {
    await db.execute('''
      CREATE TABLE ayahs (
        surah INTEGER NOT NULL,
        number INTEGER NOT NULL,
        text TEXT NOT NULL,
        page_number INTEGER,
        searchable_text TEXT,
        PRIMARY KEY (surah, number)
      )
    ''');
    await db.execute('''
      CREATE TABLE downloads (
        reciter_id INTEGER NOT NULL,
        surah_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        PRIMARY KEY (reciter_id, surah_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks (
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        ayah_text TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (surah_id, ayah_number)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tafsir_cache (
        surah_id INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        author TEXT,
        text TEXT NOT NULL,
        PRIMARY KEY (surah_id, ayah_number, book_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tafsir_books_cache (
        surah_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        author TEXT,
        PRIMARY KEY (surah_id, book_id)
      )
    ''');
  }

  Future<void> _createV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS surah_tafsir_cache (
        surah_id INTEGER NOT NULL,
        edition_slug TEXT NOT NULL,
        book_name TEXT NOT NULL,
        author TEXT,
        full_text TEXT NOT NULL,
        info_json TEXT,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (surah_id, edition_slug)
      )
    ''');
  }

  Future<void> _backfillSearchableText(Database db) async {
    try {
      await db.execute('ALTER TABLE ayahs ADD COLUMN searchable_text TEXT');
    } catch (_) {}

    final rows = await db.query('ayahs');
    final batch = db.batch();
    for (final row in rows) {
      final text = row['text'] as String;
      batch.update(
        'ayahs',
        {'searchable_text': normalizeArabic(text)},
        where: 'surah = ? AND number = ?',
        whereArgs: [row['surah'], row['number']],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<bool> isQuranDownloaded() async {
    final db = await database;
    final result = await db.query(
      'app_meta',
      where: 'key = ?',
      whereArgs: ['quran_ready'],
    );
    return result.isNotEmpty && result.first['value'] == 'true';
  }

  Future<void> markQuranDownloaded() async {
    final db = await database;
    await db.insert(
      'app_meta',
      {'key': 'quran_ready', 'value': 'true'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAyahs(List<Ayah> ayahs) async {
    final db = await database;
    final batch = db.batch();
    for (final ayah in ayahs) {
      batch.insert(
        'ayahs',
        {
          ...ayah.toMap(),
          'searchable_text': normalizeArabic(ayah.text),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Ayah>> getAyahsByPage(int page) async {
    final db = await database;
    final rows = await db.query(
      'ayahs',
      where: 'page_number = ?',
      whereArgs: [page],
      orderBy: 'surah ASC, number ASC',
    );
    return rows.map(Ayah.fromMap).toList();
  }

  Future<int?> getAyahPage(int surahId, int ayahNumber) async {
    final db = await database;
    final rows = await db.query(
      'ayahs',
      columns: ['page_number'],
      where: 'surah = ? AND number = ?',
      whereArgs: [surahId, ayahNumber],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['page_number'] as int?;
  }

  Future<int> getSurahStartPage(int surahId) async {
    final ayahs = await getAyahsBySurah(surahId);
    if (ayahs.isEmpty) return 1;
    return ayahs.first.pageNumber ?? 1;
  }

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMeta(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_meta',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<List<Ayah>> getAyahsBySurah(int surahId) async {
    final db = await database;
    final rows = await db.query(
      'ayahs',
      where: 'surah = ?',
      whereArgs: [surahId],
      orderBy: 'number ASC',
    );
    return rows.map(Ayah.fromMap).toList();
  }

  Future<List<AyahSearchResult>> searchAyahs(
    String query,
    Map<int, String> surahNames,
  ) async {
    final normalized = normalizeArabic(query);
    if (normalized.length < 2) return [];

    final db = await database;
    final rows = await db.query('ayahs');
    final results = <AyahSearchResult>[];

    for (final row in rows) {
      final searchable = row['searchable_text'] as String? ??
          normalizeArabic(row['text'] as String);
      if (searchable.contains(normalized)) {
        final surahId = row['surah'] as int;
        results.add(
          AyahSearchResult(
            surahId: surahId,
            surahName: surahNames[surahId] ?? 'سورة $surahId',
            ayahNumber: row['number'] as int,
            pageNumber: row['page_number'] as int?,
            text: row['text'] as String,
          ),
        );
      }
    }

    return results;
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(int surahId, int ayahNumber) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );
  }

  Future<bool> isBookmarked(int surahId, int ayahNumber) async {
    final db = await database;
    final rows = await db.query(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );
    return rows.isNotEmpty;
  }

  Future<List<Bookmark>> getBookmarks() async {
    final db = await database;
    final rows = await db.query(
      'bookmarks',
      orderBy: 'created_at DESC',
    );
    return rows.map(Bookmark.fromMap).toList();
  }

  Future<void> saveDownload(int reciterId, int surahId, String filePath) async {
    final db = await database;
    await db.insert(
      'downloads',
      {
        'reciter_id': reciterId,
        'surah_id': surahId,
        'file_path': filePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getDownloadPath(int reciterId, int surahId) async {
    final db = await database;
    final rows = await db.query(
      'downloads',
      where: 'reciter_id = ? AND surah_id = ?',
      whereArgs: [reciterId, surahId],
    );
    if (rows.isEmpty) return null;
    final path = rows.first['file_path'] as String;
    if (File(path).existsSync()) return path;
    return null;
  }

  Future<int> downloadedCount(int reciterId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) as c FROM downloads WHERE reciter_id = ?',
      [reciterId],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<bool> isSurahDownloaded(int reciterId, int surahId) async {
    final path = await getDownloadPath(reciterId, surahId);
    return path != null;
  }

  Future<void> deleteReciterDownloads(int reciterId) async {
    final db = await database;
    final rows = await db.query(
      'downloads',
      where: 'reciter_id = ?',
      whereArgs: [reciterId],
    );
    for (final row in rows) {
      final file = File(row['file_path'] as String);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    await db.delete('downloads', where: 'reciter_id = ?', whereArgs: [reciterId]);
  }
}

class QuranService {
  QuranService(this._db);

  final DatabaseHelper _db;

  Future<void> downloadQuran({
    required void Function(double progress, String message) onProgress,
  }) async {
    if (await _db.isQuranDownloaded()) return;

    await _downloadFont(onProgress);

    for (var surah = 1; surah <= AppConstants.totalSurahs; surah++) {
      onProgress(
        surah / AppConstants.totalSurahs,
        'جاري تحميل سورة رقم $surah...',
      );
      final url =
          '${AppConstants.quranpediaBase}/mushafs/${AppConstants.mushafId}/$surah';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('فشل تحميل السورة $surah');
      }
      final list = jsonDecode(response.body) as List<dynamic>;
      final ayahs =
          list.map((e) => Ayah.fromJson(e as Map<String, dynamic>)).toList();
      await _db.insertAyahs(ayahs);
    }

    await _db.markQuranDownloaded();
    onProgress(1, 'اكتمل تحميل القرآن الكريم');
  }

  Future<void> _downloadFont(
    void Function(double progress, String message) onProgress,
  ) async {
    onProgress(0, 'جاري تحميل خط المصحف...');
    final dir = await getApplicationDocumentsDirectory();
    final fontFile = File(p.join(dir.path, 'UthmanicHafs_V22.ttf'));
    if (fontFile.existsSync()) return;

    final response = await http.get(Uri.parse(AppConstants.quranFontUrl));
    if (response.statusCode == 200) {
      await fontFile.writeAsBytes(response.bodyBytes);
    }
  }

  Future<String?> getFontPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final fontFile = File(p.join(dir.path, 'UthmanicHafs_V22.ttf'));
    if (fontFile.existsSync()) return fontFile.path;
    return null;
  }

  Future<List<Ayah>> getSurahAyahs(int surahId) {
    return _db.getAyahsBySurah(surahId);
  }

  Future<List<Ayah>> getPageAyahs(int page) {
    return _db.getAyahsByPage(page);
  }

  Future<int> getSurahStartPage(int surahId) {
    return _db.getSurahStartPage(surahId);
  }

  Future<int?> getAyahPage(int surahId, int ayahNumber) {
    return _db.getAyahPage(surahId, ayahNumber);
  }

  Future<int?> getMarkedPage() async {
    final v = await _db.getMeta('marked_page');
    return v != null ? int.tryParse(v) : null;
  }

  Future<void> setMarkedPage(int page) async {
    await _db.setMeta('marked_page', page.toString());
    await _db.setMeta(
      'marked_page_at',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> clearMarkedPage() async {
    final db = await _db.database;
    await db.delete('app_meta', where: 'key = ?', whereArgs: ['marked_page']);
    await db.delete('app_meta', where: 'key = ?', whereArgs: ['marked_page_at']);
  }

  Future<int?> getLastReadPage() async {
    final v = await _db.getMeta('last_read_page');
    return v != null ? int.tryParse(v) : null;
  }

  Future<void> setLastReadPage(int page) {
    return _db.setMeta('last_read_page', page.toString());
  }

  Future<List<AyahSearchResult>> searchAyahs(
    String query,
    Map<int, String> surahNames,
  ) {
    return _db.searchAyahs(query, surahNames);
  }

  Future<void> toggleBookmark({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
  }) async {
    final exists = await _db.isBookmarked(surahId, ayahNumber);
    if (exists) {
      await _db.removeBookmark(surahId, ayahNumber);
    } else {
      await _db.addBookmark(
        Bookmark(
          surahId: surahId,
          surahName: surahName,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<bool> isBookmarked(int surahId, int ayahNumber) {
    return _db.isBookmarked(surahId, ayahNumber);
  }

  Future<List<Bookmark>> getBookmarks() => _db.getBookmarks();

  Future<void> removeBookmark(int surahId, int ayahNumber) {
    return _db.removeBookmark(surahId, ayahNumber);
  }
}
