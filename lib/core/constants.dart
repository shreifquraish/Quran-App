class AppConstants {
  static const appName = 'القرآن الكريم';
  static const appVersion = '1.1.2';
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
    id: 1,
    name: 'إبراهيم الأخضر',
    serverUrl: 'https://server6.mp3quran.net/akdr/',
  ),
  ReciterConfig(
    id: 10,
    name: 'أكرم العلقمي',
    serverUrl: 'https://server9.mp3quran.net/akrm/',
  ),
  ReciterConfig(
    id: 100,
    name: 'ماجد العنزي',
    serverUrl: 'https://server8.mp3quran.net/majd_onazi/',
  ),
  ReciterConfig(
    id: 102,
    name: 'ماهر المعيقلي',
    serverUrl: 'https://server12.mp3quran.net/maher/',
  ),
  ReciterConfig(
    id: 104,
    name: 'محمد الأيراويني',
    serverUrl: 'https://server6.mp3quran.net/earawi/',
  ),
  ReciterConfig(
    id: 105,
    name: 'محمد البراك',
    serverUrl: 'https://server13.mp3quran.net/braak/',
  ),
  ReciterConfig(
    id: 106,
    name: 'محمد الطبلاوي',
    serverUrl: 'https://server12.mp3quran.net/tblawi/',
  ),
  ReciterConfig(
    id: 107,
    name: 'محمد اللحيذان',
    serverUrl: 'https://server8.mp3quran.net/lhdan/',
  ),
  ReciterConfig(
    id: 108,
    name: 'محمد المحيسني',
    serverUrl: 'https://server11.mp3quran.net/mhsny/',
  ),
  ReciterConfig(
    id: 109,
    name: 'محمد أيوب',
    serverUrl: 'https://server8.mp3quran.net/ayyub/',
  ),
  ReciterConfig(
    id: 110,
    name: 'محمد صالح عالم شاه',
    serverUrl: 'https://server12.mp3quran.net/shah/',
  ),
  ReciterConfig(
    id: 111,
    name: 'محمد جبريل',
    serverUrl: 'https://server8.mp3quran.net/jbrl/',
  ),
  ReciterConfig(
    id: 112,
    name: 'محمد صديق المنشاوي',
    serverUrl: 'https://server10.mp3quran.net/minsh/',
  ),
  ReciterConfig(
    id: 115,
    name: 'محمد عبد الكريم',
    serverUrl: 'https://server12.mp3quran.net/m_krm/',
  ),
  ReciterConfig(
    id: 116,
    name: 'محمد عبد الحكيم سعيد عبد الله',
    serverUrl: 'https://server9.mp3quran.net/abdullah/',
  ),
  ReciterConfig(
    id: 118,
    name: 'محمود خليل الحصري',
    serverUrl: 'https://server13.mp3quran.net/husr/',
  ),
  ReciterConfig(
    id: 12,
    name: 'إدريس أبيكر',
    serverUrl: 'https://server6.mp3quran.net/abkr/',
  ),
  ReciterConfig(
    id: 121,
    name: 'محمد علي البنا',
    serverUrl: 'https://server8.mp3quran.net/bna/',
  ),
  ReciterConfig(
    id: 123,
    name: 'مشاري العفاسي',
    serverUrl: 'https://server8.mp3quran.net/afs/',
  ),
  ReciterConfig(
    id: 125,
    name: 'مصطفى إسماعيل',
    serverUrl: 'https://server8.mp3quran.net/mustafa/',
  ),
  ReciterConfig(
    id: 126,
    name: 'مصطفى اللاهوني',
    serverUrl: 'https://server6.mp3quran.net/lahoni/',
  ),
  ReciterConfig(
    id: 127,
    name: 'مصطفى رعد العزاوي',
    serverUrl: 'https://server8.mp3quran.net/ra3ad/',
  ),
  ReciterConfig(
    id: 128,
    name: 'معمر الأندونيسي',
    serverUrl: 'https://server6.mp3quran.net/muamr/',
  ),
  ReciterConfig(
    id: 129,
    name: 'مفتاح السلطاني',
    serverUrl: 'https://server14.mp3quran.net/muftah_sultany/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 13,
    name: 'الزين محمد أحمد',
    serverUrl: 'https://server9.mp3quran.net/alzain/',
  ),
  ReciterConfig(
    id: 135,
    name: 'عبد الرحمن السويد',
    serverUrl: 'https://server16.mp3quran.net/a_swaiyd/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 136,
    name: 'عبد الله بن عون',
    serverUrl: 'https://server16.mp3quran.net/a_binaoun/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 137,
    name: 'أحمد طالب بن حميد',
    serverUrl: 'https://server16.mp3quran.net/a_binhameed/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 139,
    name: 'ماجد الزامل',
    serverUrl: 'https://server9.mp3quran.net/zaml/',
  ),
  ReciterConfig(
    id: 15,
    name: 'العشري عمران',
    serverUrl: 'https://server9.mp3quran.net/omran/',
  ),
  ReciterConfig(
    id: 150,
    name: 'محمد المنشد',
    serverUrl: 'https://server10.mp3quran.net/monshed/',
  ),
  ReciterConfig(
    id: 151,
    name: 'محمد الشيمي',
    serverUrl: 'https://server10.mp3quran.net/sheimy/',
  ),
  ReciterConfig(
    id: 152,
    name: 'ياسر سلامة',
    serverUrl: 'https://server12.mp3quran.net/salamah/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 159,
    name: 'خالد المهنى',
    serverUrl: 'https://server11.mp3quran.net/mohna/',
  ),
  ReciterConfig(
    id: 160,
    name: 'عادل الكلاباني',
    serverUrl: 'https://server8.mp3quran.net/a_klb/',
  ),
  ReciterConfig(
    id: 161,
    name: 'موسى بلال',
    serverUrl: 'https://server11.mp3quran.net/bilal/',
  ),
  ReciterConfig(
    id: 162,
    name: 'حسين آل الشيخ',
    serverUrl: 'https://server11.mp3quran.net/alshaik/',
  ),
  ReciterConfig(
    id: 163,
    name: 'حاتم فريد الواعر',
    serverUrl: 'https://server11.mp3quran.net/hatem/',
  ),
  ReciterConfig(
    id: 164,
    name: 'إبراهيم الجرمي',
    serverUrl: 'https://server11.mp3quran.net/jormy/',
  ),
  ReciterConfig(
    id: 165,
    name: 'محمد الرفاعي',
    serverUrl: 'https://server11.mp3quran.net/mrifai/',
  ),
  ReciterConfig(
    id: 166,
    name: 'ناصر العبيدي',
    serverUrl: 'https://server11.mp3quran.net/obaid/',
  ),
  ReciterConfig(
    id: 167,
    name: 'واصل المذين',
    serverUrl: 'https://server11.mp3quran.net/wasel/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 17,
    name: 'توفيق الصايغ',
    serverUrl: 'https://server6.mp3quran.net/twfeeq/',
  ),
  ReciterConfig(
    id: 178,
    name: 'إبراهيم الدوسري',
    serverUrl: 'https://server10.mp3quran.net/ibrahim_dosri/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 18,
    name: 'جمال شاكر عبد الله',
    serverUrl: 'https://server6.mp3quran.net/jamal/',
  ),
  ReciterConfig(
    id: 283,
    name: 'مختار الحاج',
    serverUrl: 'https://server16.mp3quran.net/mukhtar_haj/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 48,
    name: 'عادل ريان',
    serverUrl: 'https://server8.mp3quran.net/ryan/',
  ),
  ReciterConfig(
    id: 49,
    name: 'عبد البارئ الثبيتي',
    serverUrl: 'https://server6.mp3quran.net/thubti/',
  ),
  ReciterConfig(
    id: 5,
    name: 'أحمد بن علي العجمي',
    serverUrl: 'https://server10.mp3quran.net/ajm/',
  ),
  ReciterConfig(
    id: 50,
    name: 'عبد البارئ محمد',
    serverUrl: 'https://server12.mp3quran.net/bari/',
  ),
  ReciterConfig(
    id: 51,
    name: 'عبد الباسط عبد الصمد',
    serverUrl: 'https://server7.mp3quran.net/basit/',
  ),
  ReciterConfig(
    id: 54,
    name: 'عبد الرحمن السديس',
    serverUrl: 'https://server11.mp3quran.net/sds/',
  ),
  ReciterConfig(
    id: 55,
    name: 'عبد العزيز الأحمد',
    serverUrl: 'https://server11.mp3quran.net/a_ahmed/',
  ),
  ReciterConfig(
    id: 56,
    name: 'عبد العزيز الزهراني',
    serverUrl: 'https://server9.mp3quran.net/zahrani/',
  ),
  ReciterConfig(
    id: 57,
    name: 'عبد الله البريمي',
    serverUrl: 'https://server8.mp3quran.net/brmi/',
  ),
  ReciterConfig(
    id: 58,
    name: 'عبد الله البعيجان',
    serverUrl: 'https://server8.mp3quran.net/buajan/',
  ),
  ReciterConfig(
    id: 59,
    name: 'عبد الله المطرو',
    serverUrl: 'https://server8.mp3quran.net/mtrod/',
  ),
  ReciterConfig(
    id: 6,
    name: 'أحمد الحواشي',
    serverUrl: 'https://server11.mp3quran.net/hawashi/',
  ),
  ReciterConfig(
    id: 60,
    name: 'عبد الله بصفر',
    serverUrl: 'https://server6.mp3quran.net/bsfr/',
  ),
  ReciterConfig(
    id: 61,
    name: 'عبد الله خياط',
    serverUrl: 'https://server12.mp3quran.net/kyat/',
  ),
  ReciterConfig(
    id: 62,
    name: 'عبد الله عوض الجهني',
    serverUrl: 'https://server13.mp3quran.net/jhn/',
  ),
  ReciterConfig(
    id: 63,
    name: 'عبد الله غيلان',
    serverUrl: 'https://server8.mp3quran.net/gulan/',
  ),
  ReciterConfig(
    id: 258,
    name: 'عبد الرشيد صوفي',
    serverUrl: 'https://server16.mp3quran.net/soufi/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 66,
    name: 'عبد المحسن الحارثي',
    serverUrl: 'https://server6.mp3quran.net/mohsin_harthi/',
  ),
  ReciterConfig(
    id: 67,
    name: 'عبد المحسن القاسم',
    serverUrl: 'https://server8.mp3quran.net/qasm/',
  ),
  ReciterConfig(
    id: 68,
    name: 'عبد المحسن العسكر',
    serverUrl: 'https://server6.mp3quran.net/askr/',
  ),
  ReciterConfig(
    id: 69,
    name: 'عبد المحسن العبكان',
    serverUrl: 'https://server12.mp3quran.net/obk/',
  ),
  ReciterConfig(
    id: 7,
    name: 'أحمد سعود',
    serverUrl: 'https://server11.mp3quran.net/saud/',
  ),
  ReciterConfig(
    id: 70,
    name: 'عبد الهادي أحمد كنكري',
    serverUrl: 'https://server6.mp3quran.net/kanakeri/',
  ),
  ReciterConfig(
    id: 71,
    name: 'عبد الودود حنيف',
    serverUrl: 'https://server8.mp3quran.net/wdod/',
  ),
  ReciterConfig(
    id: 72,
    name: 'عبد الولي الأركاني',
    serverUrl: 'https://server6.mp3quran.net/arkani/',
  ),
  ReciterConfig(
    id: 73,
    name: 'علي أبو هاشم',
    serverUrl: 'https://server9.mp3quran.net/abo_hashim/',
  ),
  ReciterConfig(
    id: 74,
    name: 'علي بن عبد الرحمن الحذيفي',
    serverUrl: 'https://server9.mp3quran.net/hthfi/',
  ),
  ReciterConfig(
    id: 76,
    name: 'علي جابر',
    serverUrl: 'https://server11.mp3quran.net/a_jbr/',
  ),
  ReciterConfig(
    id: 77,
    name: 'علي حجاج السوسي',
    serverUrl: 'https://server9.mp3quran.net/hajjaj/',
  ),
  ReciterConfig(
    id: 78,
    name: 'عماد زهير حافظ',
    serverUrl: 'https://server6.mp3quran.net/hafz/',
  ),
  ReciterConfig(
    id: 79,
    name: 'عبد العزيز التركي',
    serverUrl: 'https://server16.mp3quran.net/a_turki/Rewayat-Hafs-A-n-Assem/',
  ),
  ReciterConfig(
    id: 8,
    name: 'أحمد صابر',
    serverUrl: 'https://server8.mp3quran.net/saber/',
  ),
  ReciterConfig(
    id: 81,
    name: 'فارس عباد',
    serverUrl: 'https://server8.mp3quran.net/frs_a/',
  ),
  ReciterConfig(
    id: 82,
    name: 'فهد العتيبي',
    serverUrl: 'https://server8.mp3quran.net/fahad_otibi/',
  ),
  ReciterConfig(
    id: 83,
    name: 'فهد الكندري',
    serverUrl: 'https://server11.mp3quran.net/kndri/',
  ),
  ReciterConfig(
    id: 84,
    name: 'فواز الكعبي',
    serverUrl: 'https://server8.mp3quran.net/fawaz/',
  ),
  ReciterConfig(
    id: 85,
    name: 'لافي العوني',
    serverUrl: 'https://server6.mp3quran.net/lafi/',
  ),
  ReciterConfig(
    id: 86,
    name: 'ناصر القطامي',
    serverUrl: 'https://server6.mp3quran.net/qtm/',
  ),
  ReciterConfig(
    id: 87,
    name: 'نبيل الرفاعي',
    serverUrl: 'https://server9.mp3quran.net/nabil/',
  ),
  ReciterConfig(
    id: 88,
    name: 'نعمة الحسن',
    serverUrl: 'https://server8.mp3quran.net/namh/',
  ),
  ReciterConfig(
    id: 89,
    name: 'هاني الرفاعي',
    serverUrl: 'https://server8.mp3quran.net/hani/',
  ),
  ReciterConfig(
    id: 9,
    name: 'أحمد نعيم',
    serverUrl: 'https://server11.mp3quran.net/ahmad_nu/',
  ),
  ReciterConfig(
    id: 90,
    name: 'وليد الدليمي',
    serverUrl: 'https://server8.mp3quran.net/dlami/',
  ),
  ReciterConfig(
    id: 92,
    name: 'ياسر الدوسري',
    serverUrl: 'https://server11.mp3quran.net/yasser/',
  ),
  ReciterConfig(
    id: 93,
    name: 'ياسر القرشي',
    serverUrl: 'https://server9.mp3quran.net/qurashi/',
  ),
  ReciterConfig(
    id: 94,
    name: 'ياسر الفيلكاوي',
    serverUrl: 'https://server6.mp3quran.net/fyl/',
  ),
  ReciterConfig(
    id: 96,
    name: 'يحيى حواس',
    serverUrl: 'https://server12.mp3quran.net/yahya/',
  ),
  ReciterConfig(
    id: 97,
    name: 'يوسف الشعيبي',
    serverUrl: 'https://server9.mp3quran.net/yousef/',
  ),
  ReciterConfig(
    id: 284,
    name: 'عبد الله عبدل',
    serverUrl: 'https://server16.mp3quran.net/a_abdl/Rewayat-Hafs-A-n-Assem/',
  ),
];
