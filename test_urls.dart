import 'dart:io';

void main() async {
  final urls = [
    'https://android.quran.com/data/images_v11/page1.png',
    'https://android.quran.com/data/width_1024/page001.png',
    'https://cdn.islamic.network/quran/images/1.png',
    'https://quran.ksu.edu.sa/png_big/1.png',
    'https://quran.ksu.edu.sa/ayats/png_1024/1.png',
    'https://raw.githubusercontent.com/quran/quran.com-images/master/images/page001.png',
    'https://cdn.jsdelivr.net/gh/quran/quran.com-images@master/images/page001.png',
    'https://cdn.jsdelivr.net/gh/quran/quran.com-images@master/width_1024/page001.png',
    'https://www.quranmubeen.com/images/pages/1.jpg'
  ];

  for (var url in urls) {
    try {
      final request = await HttpClient().headUrl(Uri.parse(url));
      final response = await request.close();
      print('URL: $url => ${response.statusCode}');
    } catch (e) {
      print('URL: $url => Error');
    }
  }
}
