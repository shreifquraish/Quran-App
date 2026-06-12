import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final result = <String, dynamic>{};
  for (int i = 1; i <= 114; i++) {
    print('Downloading surah $i...');
    final url = 'https://raw.githubusercontent.com/spa5k/tafsir_api/main/tafsir/ar-tafsir-al-muyassar/$i.json';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        result[i.toString()] = jsonDecode(res.body);
      } else {
        print('Failed $i - ${res.statusCode}');
      }
    } catch (e) {
      print('Error $i: $e');
    }
  }
  
  final file = File('assets/data/tafsir_muyassar.json');
  file.writeAsStringSync(jsonEncode(result));
  print('Done! Size: ${file.lengthSync()} bytes');
}
