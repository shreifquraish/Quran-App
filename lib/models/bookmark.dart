class Bookmark {
  const Bookmark({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
  });

  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final int createdAt;

  String get reference => '$surahName - آية $ayahNumber';

  Map<String, dynamic> toMap() => {
        'surah_id': surahId,
        'surah_name': surahName,
        'ayah_number': ayahNumber,
        'ayah_text': ayahText,
        'created_at': createdAt,
      };

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      surahId: map['surah_id'] as int,
      surahName: map['surah_name'] as String,
      ayahNumber: map['ayah_number'] as int,
      ayahText: map['ayah_text'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}

class AyahSearchResult {
  const AyahSearchResult({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.text,
    this.pageNumber,
  });

  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String text;
  final int? pageNumber;

  String get reference => '$surahName : $ayahNumber';
}

class PageBookmark {
  const PageBookmark({
    required this.page,
    required this.markedAt,
  });

  final int page;
  final int markedAt;
}

class TafsirBook {
  const TafsirBook({
    required this.id,
    required this.name,
    this.author,
  });

  final int id;
  final String name;
  final String? author;

  factory TafsirBook.fromJson(Map<String, dynamic> json) {
    return TafsirBook(
      id: json['id'] as int,
      name: json['name'] as String,
      author: json['author'] as String?,
    );
  }
}

class TafsirContent {
  const TafsirContent({
    required this.bookName,
    required this.author,
    required this.text,
  });

  final String bookName;
  final String author;
  final String text;
}
