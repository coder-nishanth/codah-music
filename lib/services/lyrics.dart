import '../models/lyrics_model.dart';
import 'lrcnet_api.dart';

class LyricsService {
  Future<Lyrics> getLyrics({
    required String title,
    String? artist,
    String? album,
    String? duration,
  }) async {
    return await getLRCNetAPILyrics(
      title,
      artist: artist,
      album: album,
      duration: duration,
    );
  }
}
