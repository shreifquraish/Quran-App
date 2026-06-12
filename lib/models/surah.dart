class Surah {
  const Surah({
    required this.id,
    required this.name,
    required this.ayahs,
    required this.type,
  });

  final int id;
  final String name;
  final int ayahs;
  final String type;

  bool get isMakkah => type == 'makkah';

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      name: json['name'] as String,
      ayahs: json['ayahs'] as int,
      type: json['type'] as String,
    );
  }
}

class Ayah {
  const Ayah({
    required this.surah,
    required this.number,
    required this.text,
    this.pageNumber,
  });

  final int surah;
  final int number;
  final String text;
  final int? pageNumber;

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surah: int.parse(json['surah'].toString()),
      number: json['number'] as int,
      text: json['text'] as String,
      pageNumber: json['page_number'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'surah': surah,
        'number': number,
        'text': text,
        'page_number': pageNumber,
      };

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      surah: map['surah'] as int,
      number: map['number'] as int,
      text: map['text'] as String,
      pageNumber: map['page_number'] as int?,
    );
  }
}
