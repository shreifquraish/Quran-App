class AppConstants {
  static const appName = 'القرآن الكريم';
  static const quranpediaBase = 'https://api.quranpedia.net/v1';
  static const mp3QuranBase = 'https://mp3quran.net/api/v3';
  static const mushafId = 2;
  static const defaultTafsirBookId = 1;
  static const tafsirCdnBase =
      'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir';
  static const quranFontUrl =
      'https://quranpedia.net/assets/fonts/arabic/UthmanicHafs_V22.ttf';
    static const mushafPdfUrl =
      'https://drive.google.com/uc?export=download&id=1piEeiya3laflAV8EUnN0jjCxAqaM_3Zd';
    static const mushafRemoteBase = 'https://www.mp3quran.net/mushaf2';
  static const totalSurahs = 114;
  static const totalPages = 604;
  static const bismillah =
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
}

class ReciterConfig {
  const ReciterConfig({
    required this.id,
    required this.name,
    required this.serverUrl,
    this.radioId,
  });

  final int id;
  final String name;
  final String serverUrl;
  final int? radioId;

  String surahUrl(int surahId) =>
      '$serverUrl${surahId.toString().padLeft(3, '0')}.mp3';
}

const featuredReciters = [
  ReciterConfig(
    id: 51,
    name: 'عبد الباسط عبد الصمد',
    serverUrl: 'https://server7.mp3quran.net/basit/',
    radioId: 32,
  ),
  ReciterConfig(
    id: 92,
    name: 'ياسر الدوسري',
    serverUrl: 'https://server11.mp3quran.net/yasser/',
    radioId: 58,
  ),
  ReciterConfig(
    id: 118,
    name: 'محمود خليل الحصري',
    serverUrl: 'https://server13.mp3quran.net/husr/',
    radioId: 74,
  ),
  ReciterConfig(
    id: 102,
    name: 'ماهر المعيقلي',
    serverUrl: 'https://server12.mp3quran.net/maher/',
    radioId: 63,
  ),
  ReciterConfig(
    id: 123,
    name: 'مشاري بن راشد العفاسي',
    serverUrl: 'https://server8.mp3quran.net/afs/',
    radioId: 79,
  ),
  ReciterConfig(
    id: 5,
    name: 'أحمد بن علي العجمي',
    serverUrl: 'https://server10.mp3quran.net/ajm/',
    radioId: 3,
  ),
  ReciterConfig(
    id: 54,
    name: 'عبد الرحمن السديس',
    serverUrl: 'https://server11.mp3quran.net/sds/',
    radioId: 33,
  ),
  ReciterConfig(
    id: 112,
    name: 'محمد صديق المنشاوي',
    serverUrl: 'https://server10.mp3quran.net/minsh/',
    radioId: 69,
  ),
  ReciterConfig(
    id: 125,
    name: 'مصطفى إسماعيل',
    serverUrl: 'https://server8.mp3quran.net/mustafa/',
    radioId: 80,
  ),
  ReciterConfig(
    id: 30,
    name: 'سعد الغامدي',
    serverUrl: 'https://server7.mp3quran.net/s_gmd/',
    radioId: 17,
  ),
];
