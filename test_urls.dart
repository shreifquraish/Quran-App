import 'dart:io';

Future<void> main() async {
  final urls = [
    'https://download.quranicaudio.com/quran/abdul_basit_murattal/001.mp3',
    'https://download.quranicaudio.com/quran/yasser_ad-dussary/001.mp3',
    'https://download.quranicaudio.com/quran/husary/001.mp3',
    'https://download.quranicaudio.com/quran/maher_almuaiqly/001.mp3',
    'https://download.quranicaudio.com/quran/mishari_al-afasi/001.mp3',
    'https://download.quranicaudio.com/quran/ahmed_ibn_ali_al-ajamy/001.mp3',
    'https://download.quranicaudio.com/quran/abdurrahmaan_as-sudais/001.mp3',
    'https://download.quranicaudio.com/quran/minshawi_murattal/001.mp3',
    'https://download.quranicaudio.com/quran/mustafa_ismail/001.mp3',
    'https://download.quranicaudio.com/quran/saad_al_ghamidi/001.mp3',
  ];

  final client = HttpClient();
  for (var url in urls) {
    try {
      final request = await client.headUrl(Uri.parse(url));
      final response = await request.close();
      print('$url: ${response.statusCode}');
    } catch (e) {
      print('$url: Error $e');
    }
  }
}
