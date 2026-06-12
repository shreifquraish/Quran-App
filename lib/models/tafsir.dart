class TafsirEdition {
  const TafsirEdition({
    required this.slug,
    required this.name,
    required this.author,
  });

  final String slug;
  final String name;
  final String author;
}

const availableTafsirEditions = [
  TafsirEdition(
    slug: 'ar-tafsir-muyassar',
    name: 'التفسير الميسر',
    author: 'نخبة من العلماء',
  ),
  TafsirEdition(
    slug: 'ar-tafsir-as-saadi',
    name: 'تفسير السعدي',
    author: 'الشيخ عبد الرحمن السعدي',
  ),
  TafsirEdition(
    slug: 'ar-tafsir-al-jalalayn',
    name: 'تفسير الجلالين',
    author: 'جلال الدين المحلي والسيوطي',
  ),
  TafsirEdition(
    slug: 'ar-tafseer-al-qurtubi',
    name: 'تفسير القرطبي',
    author: 'الإمام القرطبي',
  ),
];

class SurahInfoSection {
  const SurahInfoSection({required this.title, required this.content});

  final String title;
  final String content;
}

class SurahTafsir {
  const SurahTafsir({
    required this.surahId,
    required this.surahName,
    required this.edition,
    required this.fullText,
    this.infoSections = const [],
  });

  final int surahId;
  final String surahName;
  final TafsirEdition edition;
  final String fullText;
  final List<SurahInfoSection> infoSections;
}
