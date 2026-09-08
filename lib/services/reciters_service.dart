import 'package:dio/dio.dart';

class ReciterApiResponse {
  final int id;
  final String name;
  final String serverUrl;
  final int? radioId;

  ReciterApiResponse({
    required this.id,
    required this.name,
    required this.serverUrl,
    this.radioId,
  });

  factory ReciterApiResponse.fromJson(Map<String, dynamic> json) {
    return ReciterApiResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      serverUrl: json['server'] as String,
      radioId: json['radio_id'] as int?,
    );
  }
}

class RecitersService {
  static final RecitersService _instance = RecitersService._internal();
  factory RecitersService() => _instance;
  RecitersService._internal();

  final Dio _dio = Dio();
  static const String _baseUrl = 'https://mp3quran.net/api/v3';

  Future<List<ReciterApiResponse>> fetchAllReciters() async {
    try {
      final response = await _dio.get('$_baseUrl/reciters');
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final recitersJson = response.data['reciters'] as List<dynamic>;
        return recitersJson
            .map((json) => ReciterApiResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error fetching reciters: $e');
    }
    return [];
  }
}
