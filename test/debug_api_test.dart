import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('LRCLIB direct GET', () async {
    final uri = Uri.https('lrclib.net', 'api/get', {
      'track_name': 'Blinding Lights',
      'artist_name': 'The Weeknd',
      'album_name': 'After Hours',
      'duration': '200',
    });
    print('URL: $uri');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    print('Status: ${response.statusCode}');
    expect(response.statusCode, 200);
    final data = json.decode(response.body);
    print('plainLyrics len: ${(data['plainLyrics'] ?? '').length}');
    print('syncedLyrics len: ${(data['syncedLyrics'] ?? '').length}');
    print('artistName: ${data['artistName']}');
    print('trackName: ${data['trackName']}');
  });

  test('LRCLIB search', () async {
    final uri = Uri.https('lrclib.net', 'api/search', {
      'q': 'Blinding Lights The Weeknd',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    print('Status: ${response.statusCode}');
    expect(response.statusCode, 200);
    final List data = json.decode(response.body);
    print('Results: ${data.length}');
    if (data.isNotEmpty) {
      print('First: ${data[0]['trackName']} - ${data[0]['artistName']}');
    }
  });

  test('SimpMusic API', () async {
    final uri = Uri.parse('https://api-lyrics.simpmusic.org/v1/dQw4w9WgXcQ');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List && data['data'].isNotEmpty) {
        final item = data['data'][0];
        print('songTitle: ${item['songTitle']}');
        print('artistName: ${item['artistName']}');
        print('plainLyric len: ${(item['plainLyric'] ?? '').length}');
        print('syncedLyrics len: ${(item['syncedLyrics'] ?? '').length}');
      } else {
        print('No data item. Response: ${response.body.substring(0, 200)}');
      }
    } else {
      print('Body: ${response.body.substring(0, 200)}');
    }
  });

  test('Better Lyrics API', () async {
    final uri = Uri.parse('https://lyrics-api.boidu.dev/getLyrics?s=Blinding Lights&a=The Weeknd');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    print('Status: ${response.statusCode}');
    print('Body len: ${response.body.length}');
    if (response.body.isNotEmpty) {
      print('Body: ${response.body.substring(0, 500)}');
    }
  });
}
