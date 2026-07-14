import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:Codah/services/library.dart';
import 'package:Codah/services/spotify_embed_scraper.dart';
import 'package:Codah/ytmusic/ytmusic.dart';

class ImportState {
  final int total;
  final int current;
  final String message;
  final bool isDone;
  final bool isError;

  ImportState({
    required this.total,
    required this.current,
    required this.message,
    this.isDone = false,
    this.isError = false,
  });
}

class ImportService {
  static final importingTitle = ValueNotifier<String?>(null);
  static final importingKey = ValueNotifier<String?>(null);
  static final importingCurrent = ValueNotifier<int>(0);
  static final importingTotal = ValueNotifier<int>(0);
  final SpotifyEmbedScraper _scraper = SpotifyEmbedScraper();
  final YTMusic _ytMusic = GetIt.I<YTMusic>();
  final LibraryService _library = GetIt.I<LibraryService>();

  Stream<ImportState> import(String url) async* {
    ImportService.importingTitle.value = url;
    ImportService.importingCurrent.value = 0;
    ImportService.importingTotal.value = 0;

    await for (final state in _doImport(url)) {
      if (state.total > 0) {
        ImportService.importingTotal.value = state.total;
        ImportService.importingCurrent.value = state.current;
      }
      if (state.isDone || state.isError) {
        ImportService.importingTitle.value = null;
        ImportService.importingKey.value = null;
      }
      yield state;
    }
  }

  Stream<ImportState> _doImport(String url) async* {
    if (url.contains('spotify.com')) {
      yield* _importSpotify(url);
    } else if (url.contains('youtu.be') || url.contains('youtube.com')) {
      yield* _importYouTube(url);
    } else {
      yield ImportState(
        total: 0,
        current: 0,
        message: "Invalid URL",
        isError: true,
      );
    }
  }

  Stream<ImportState> _importYouTube(String url) async* {
    yield ImportState(
      total: 0,
      current: 0,
      message: "Importing YouTube Playlist...",
    );
    try {
      final result = await _library.importPlaylist(url);
      if (result.contains('Error') || result == 'Invalid Url') {
        yield ImportState(
          total: 0,
          current: 0,
          message: result,
          isError: true,
        );
      } else {
        yield ImportState(
          total: 1,
          current: 1,
          message: result,
          isDone: true,
        );
      }
    } catch (e) {
      yield ImportState(
        total: 0,
        current: 0,
        message: "Failed to import: $e",
        isError: true,
      );
    }
  }

  Stream<ImportState> _importSpotify(String url) async* {
    try {
      yield ImportState(total: 0, current: 0, message: "Fetching Spotify data...");

      final id = _scraper.extractId(url);
      if (id == null) {
        yield ImportState(total: 0, current: 0, message: "Invalid Spotify URL", isError: true);
        return;
      }

      yield ImportState(total: 0, current: 0, message: "Fetching tracks from Spotify...");
      Map<String, Object> playlistData;

      if (_scraper.isAlbumUrl(url)) {
        playlistData = await _scraper.getAlbumTracks(id);
      } else {
        playlistData = await _scraper.getPlaylistTracks(id);
      }

      final tracks = playlistData['tracks'] as List;
      final playlistName = _scraper.isAlbumUrl(url)
          ? (playlistData['albumName'] as String? ?? "Imported Album")
          : (playlistData['playlistName'] as String? ?? "Imported Playlist");

      if (tracks.isEmpty) {
        yield ImportState(total: 0, current: 0, message: "No tracks found", isError: true);
        return;
      }

      yield ImportState(total: tracks.length, current: 0, message: "Created Playlist: $playlistName");
      String playlistKey = await _library.createPlaylistKey(playlistName);
      ImportService.importingKey.value = playlistKey;

      final List<String> queries = [];
      for (var track in tracks) {
        if (track == null) continue;
        String title = '';
        if (track['name'] != null) title += '${track['name']}';
        if (track['artists'] != null) {
          var artists = track['artists'];
          if (artists is List) {
            title += ' ${artists.map((a) => a['name']).join(" ")}';
          } else if (artists is String) {
            title += ' $artists';
          }
        }
        queries.add(title);
      }

      final int concurrency = 5;
      int count = 0;
      int found = 0;

      for (int i = 0; i < queries.length; i += concurrency) {
        final batch = queries.sublist(
          i,
          i + concurrency > queries.length ? queries.length : i + concurrency,
        );

        final results = await Future.wait(
          batch.map((q) async {
            final match = await _findSongOnYouTube(q);
            return {'query': q, 'match': match};
          }),
        );

        for (final result in results) {
          count++;
          final match = result['match'] as Map?;
          final query = result['query'] as String;

          if (match != null) {
            await _library.addToPlaylist(item: match, key: playlistKey);
            found++;
            yield ImportState(
              total: queries.length,
              current: count,
              message: "Imported: ${match['title']}",
            );
          } else {
            yield ImportState(
              total: queries.length,
              current: count,
              message: "Not found: $query",
            );
          }
        }
      }

      yield ImportState(
        total: queries.length,
        current: count,
        message: "Import Complete ($found/${queries.length} found)",
        isDone: true,
      );

    } catch (e) {
      yield ImportState(total: 0, current: 0, message: "Error: $e", isError: true);
    }
  }

  Future<Map?> _findSongOnYouTube(String query) async {
    try {
      final result = await _ytMusic.search(query, filter: 'songs');
      if (result['sections'] != null && (result['sections'] as List).isNotEmpty) {
        final section = result['sections'][0];
        if (section['contents'] != null && (section['contents'] as List).isNotEmpty) {
          return section['contents'][0];
        }
      }
    } catch (e) {
    }
    return null;
  }
}
