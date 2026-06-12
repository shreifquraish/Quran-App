import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';

class AudioPlayerService {
  AudioPlayerService() {
    _init();
  }

  final AudioPlayer player = AudioPlayer();
  PlaybackItem? _current;
  bool _isRadio = false;

  PlaybackItem? get current => _current;
  bool get isRadio => _isRadio;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> playSurah({
    required PlaybackItem item,
  }) async {
    _isRadio = false;
    _current = item;
    if (item.isLocal) {
      final path = item.source.replaceFirst('file://', '');
      await player.setFilePath(path);
    } else {
      await player.setUrl(item.source);
    }
    await player.play();
  }

  Future<void> playRadio(RadioStation station) async {
    _isRadio = true;
    _current = PlaybackItem(
      reciterId: station.id,
      reciterName: station.name,
      surahId: 0,
      surahName: 'بث مباشر',
      source: station.url,
    );
    await player.setUrl(station.url);
    await player.play();
  }

  Future<void> pause() => player.pause();
  Future<void> resume() => player.play();
  Future<void> stop() async {
    await player.stop();
    _current = null;
    _isRadio = false;
  }

  Future<void> seek(Duration position) => player.seek(position);

  void dispose() {
    player.dispose();
  }
}
