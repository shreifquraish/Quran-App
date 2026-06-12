import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
 

import '../core/constants.dart';
import '../models/radio_station.dart';
import 'quran_service.dart';

class AudioDownloadService {
  AudioDownloadService(this._db);

  final DatabaseHelper _db;
  final Dio _dio = Dio();

  Future<void> downloadSurah({
    required ReciterConfig reciter,
    required int surahId,
    required void Function(double progress) onProgress,
  }) async {
    if (await _db.isSurahDownloaded(reciter.id, surahId)) return;

    final dir = await _getReciterDir(reciter.id);
    final filePath =
        '${dir.path}/${surahId.toString().padLeft(3, '0')}.mp3';
    final url = reciter.surahUrl(surahId);

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );

    await _db.saveDownload(reciter.id, surahId, filePath);
  }

  Future<void> downloadAllSurahs({
    required ReciterConfig reciter,
    required void Function(double progress, int current) onProgress,
    required bool Function() isCancelled,
  }) async {
    for (var i = 1; i <= AppConstants.totalSurahs; i++) {
      if (isCancelled()) break;
      if (await _db.isSurahDownloaded(reciter.id, i)) {
        onProgress(i / AppConstants.totalSurahs, i);
        continue;
      }
      await downloadSurah(
        reciter: reciter,
        surahId: i,
        onProgress: (_) {},
      );
      onProgress(i / AppConstants.totalSurahs, i);
    }
  }

  Future<String?> localPath(ReciterConfig reciter, int surahId) {
    return _db.getDownloadPath(reciter.id, surahId);
  }

  Future<int> downloadedCount(int reciterId) {
    return _db.downloadedCount(reciterId);
  }

  Future<void> deleteAll(ReciterConfig reciter) {
    return _db.deleteReciterDownloads(reciter.id);
  }

  Future<Directory> _getReciterDir(int reciterId) async {
    final docs = await getApplicationDocumentsDirectory();
    final appDir = Directory('${docs.path}/audio/$reciterId');
    if (!appDir.existsSync()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }
}

class RadioService {
  Future<List<RadioStation>> fetchFeaturedRadios() async {
    const supportedRadioIds = [
      32,
      58,
      74,
      63,
      79,
      3,
      33,
      69,
      80,
      17,
    ];

    final response = await Dio().get('https://mp3quran.net/api/v3/radios');
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch radio stations');
    }

    final radiosJson = response.data['radios'] as List<dynamic>?;
    if (radiosJson == null) {
      throw Exception('Invalid radio data');
    }

    final stations = radiosJson
        .map((json) => RadioStation.fromJson(json as Map<String, dynamic>))
        .where((station) => supportedRadioIds.contains(station.id))
        .toList();

    stations.sort((a, b) =>
        supportedRadioIds.indexOf(a.id).compareTo(supportedRadioIds.indexOf(b.id)));

    return stations;
  }
}
