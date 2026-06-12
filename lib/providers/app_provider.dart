import 'dart:convert';

import 'package:al_quran_kareem/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';
import '../models/surah.dart';
import '../models/tafsir.dart';
import '../services/audio_player_service.dart';
import '../services/audio_service.dart';
import '../services/tafsir_service.dart';
import '../services/quran_service.dart' show DatabaseHelper, QuranService;

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _bootstrap();
  }

  final DatabaseHelper db = DatabaseHelper.instance;
  late final QuranService quranService = QuranService(db);
  late final TafsirService tafsirService = TafsirService(db);
  late final AudioDownloadService downloadService = AudioDownloadService(db);
  late final AudioPlayerService playerService = AudioPlayerService();
  late final RadioService radioService = RadioService();

  bool isDarkMode = false;
  bool isLoading = true;
  bool isFirstLaunch = false;
  bool showProgress = true;
  bool quranReady = false;
  bool quranFontLoaded = true;
  double setupProgress = 0;
  String setupMessage = 'جاري التحميل...';
  String? setupError;

  List<Surah> surahs = [];
  List<TafsirEdition> availableTafsirEditions = [
    TafsirEdition(name: 'الميسر', author: 'نخبة من العلماء', slug: 'ar-tafsir-al-muyassar'),
    TafsirEdition(name: 'الجلالين', author: 'المحلي والسيوطي', slug: 'ar-tafsir-al-jalalayn'),
    TafsirEdition(name: 'السعدي', author: 'عبد الرحمن السعدي', slug: 'ar-tafseer-al-saddi'),
    TafsirEdition(name: 'ابن كثير', author: 'ابن كثير', slug: 'ar-tafsir-ibn-kathir'),
    TafsirEdition(name: 'الطبري', author: 'الطبري', slug: 'ar-tafseer-al-qurtubi'),
  ];
  String tafsirEditionSlug = 'ar-tafsir-al-muyassar';
  List<RadioStation> radios = [];
  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode = prefs.getBool('dark_mode') ?? false;
      tafsirEditionSlug = prefs.getString('tafsir_edition') ?? availableTafsirEditions.first.slug;
      isFirstLaunch = !(prefs.getBool('first_run_complete') ?? false);
      showProgress = isFirstLaunch;
      isLoading = true;
      notifyListeners();

      _continueBootstrap(isFirstLaunch: isFirstLaunch);
    } catch (e, stack) {
      debugPrint('Bootstrap error: $e\n$stack');
      setupError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _continueBootstrap({required bool isFirstLaunch}) async {
    try {
      final raw = await rootBundle.loadString('assets/data/surahs.json');
      surahs = (jsonDecode(raw) as List<dynamic>).map((x) => Surah.fromJson(x)).toList();
      notifyListeners();

      if (!isFirstLaunch) {
        await Future.delayed(const Duration(milliseconds: 800));
        showProgress = false;
      }

      quranReady = true;
      quranFontLoaded = true;

      if (isFirstLaunch) {
        await _performInitialSetup();
      }

      try {
        radios = await radioService.fetchFeaturedRadios();
      } catch (_) {
        radios = [];
      }

      if (isFirstLaunch) {
        if (setupError == null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('first_run_complete', true);
          this.isFirstLaunch = false;
          showProgress = false;
          isLoading = false;
        }
      } else {
        isLoading = false;
      }
      notifyListeners();
    } catch (e, stack) {
      debugPrint('Continue bootstrap error: $e\n$stack');
    }
  }

  Future<void> _performInitialSetup() async {
    setupError = null;
    setupProgress = 0;
    setupMessage = 'جاري تجهيز التفسير...';
    notifyListeners();

    try {
      await tafsirService.ensureOfflineData();
      setupProgress = 1;
    } catch (e) {
      setupError = e.toString();
    }
  }

  Future<void> retryQuranDownload() async {
    setupError = null;
    isLoading = true;
    showProgress = true;
    notifyListeners();

    await _performInitialSetup();

    if (setupError == null && isFirstLaunch) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_run_complete', true);
      isFirstLaunch = false;
      showProgress = false;
      isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refreshRadios() async {
    try {
      radios = await radioService.fetchFeaturedRadios();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
    notifyListeners();
  }

  Future<void> setTafsirEdition(String slug) async {
    tafsirEditionSlug = slug;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tafsir_edition', slug);
    notifyListeners();
  }

  @override
  void dispose() {
    playerService.dispose();
    super.dispose();
  }
}

// AudioProvider remains unchanged; placed here for convenience.
class AudioProvider extends ChangeNotifier {
  AudioProvider(this.app) {
    app.playerService.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  final AppProvider app;
  final Map<int, int> _downloadCounts = {};
  final Map<String, double> _activeDownloads = {};
  bool bulkDownloading = false;
  ReciterConfig? bulkReciter;
  double setupProgressLocal = 0;
  String setupMessageLocal = '';

  int downloadCountFor(int reciterId) => _downloadCounts[reciterId] ?? 0;

  double? activeDownloadProgress(int reciterId, int surahId) =>
      _activeDownloads['$reciterId-$surahId'];

  Future<void> refreshDownloadCount(ReciterConfig reciter) async {
    _downloadCounts[reciter.id] = await app.downloadService.downloadedCount(reciter.id);
    notifyListeners();
  }

  Future<void> downloadSurah({
    required ReciterConfig reciter,
    required Surah surah,
  }) async {
    final key = '${reciter.id}-${surah.id}';
    _activeDownloads[key] = 0;
    notifyListeners();
    try {
      await app.downloadService.downloadSurah(
        reciter: reciter,
        surahId: surah.id,
        onProgress: (p) {
          _activeDownloads[key] = p;
          notifyListeners();
        },
      );
      await refreshDownloadCount(reciter);
    } finally {
      _activeDownloads.remove(key);
      notifyListeners();
    }
  }

  Future<void> downloadAll(ReciterConfig reciter) async {
    bulkReciter = reciter;
    bulkDownloading = true;
    notifyListeners();
    try {
      await app.downloadService.downloadAllSurahs(
        reciter: reciter,
        isCancelled: () => !bulkDownloading,
        onProgress: (progress, current) {
          setupProgressLocal = progress;
          setupMessageLocal = 'تم تحميل $current من 114';
          notifyListeners();
        },
      );
      await refreshDownloadCount(reciter);
    } finally {
      bulkDownloading = false;
      bulkReciter = null;
      notifyListeners();
    }
  }

  void cancelBulkDownload() {
    bulkDownloading = false;
    notifyListeners();
  }

  Future<void> playSurah({
    required ReciterConfig reciter,
    required Surah surah,
  }) async {
    final local = await app.downloadService.localPath(reciter, surah.id);
    final source = local ?? reciter.surahUrl(surah.id);
    await app.playerService.playSurah(
      item: PlaybackItem(
        reciterId: reciter.id,
        reciterName: reciter.name,
        surahId: surah.id,
        surahName: surah.name,
        source: local != null ? 'file://$local' : source,
        isLocal: local != null,
      ),
    );
    notifyListeners();
  }

  Future<void> playRadio(RadioStation station) async {
    await app.playerService.playRadio(station);
    notifyListeners();
  }

  Future<void> playNext() async {
    final current = app.playerService.current;
    if (current == null || app.playerService.isRadio) return;

    final nextSurahId = current.surahId + 1;
    if (nextSurahId > 114) return;

    final reciter = featuredReciters.firstWhere((r) => r.id == current.reciterId);
    final surah = app.surahs.firstWhere((s) => s.id == nextSurahId);

    await playSurah(reciter: reciter, surah: surah);
  }

  Future<void> playPrevious() async {
    final current = app.playerService.current;
    if (current == null || app.playerService.isRadio) return;

    final prevSurahId = current.surahId - 1;
    if (prevSurahId < 1) return;

    final reciter = featuredReciters.firstWhere((r) => r.id == current.reciterId);
    final surah = app.surahs.firstWhere((s) => s.id == prevSurahId);

    await playSurah(reciter: reciter, surah: surah);
  }

  Future<void> deleteDownloads(ReciterConfig reciter) async {
    await app.downloadService.deleteAll(reciter);
    _downloadCounts[reciter.id] = 0;
    notifyListeners();
  }
}
