import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('https://api.quran.com/api/v4/resources/recitations'));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    print(stringData);
  } catch (e) {
    print('Error $e');
  }
}
