class RadioStation {
  const RadioStation({
    required this.id,
    required this.name,
    required this.url,
  });

  final int id;
  final String name;
  final String url;

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] as int,
      name: (json['name'] as String).trim(),
      url: json['url'] as String,
    );
  }
}

class PlaybackItem {
  const PlaybackItem({
    required this.reciterId,
    required this.reciterName,
    required this.surahId,
    required this.surahName,
    required this.source,
    this.isLocal = false,
  });

  final int reciterId;
  final String reciterName;
  final int surahId;
  final String surahName;
  final String source;
  final bool isLocal;
}
