import 'package:Codah/ytmusic/client.dart';

import '../helpers.dart';
import 'utils.dart';

mixin LibraryMixin on YTClient {
  Future<Map> getLibrarySongs({String? continuationParams}) async {
    Map<String, dynamic> body = {'browseId': 'FEmusic_liked_videos'};

    final response = await sendRequest('browse', body,
        additionalParams: continuationParams ?? '');

    Map outerContents = {};
    if (continuationParams != null) {
      outerContents =
          nav(response, ['continuationContents', 'musicShelfContinuation']);
    } else {
      Map contents = nav(response, [
        'contents',
        'singleColumnBrowseResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'sectionListRenderer',
        'contents',
        0,
      ]);
      outerContents = nav(contents, ['musicShelfRenderer']) ??
          nav(contents, ['itemSectionRenderer']);
    }

    String? continuation = nav(outerContents,
        ['continuations', 0, 'nextContinuationData', 'continuation']);
    if (continuation != null) {
      continuation = getContinuationString(continuation);
    }
    List contents = nav(outerContents, ['contents']);

    return {
      'contents': handleContents(contents),
      'continuation': continuation,
    };
  }

  Future<Map> getLibraryAlbums({String? continuationParams}) async {
    Map<String, dynamic> body = {'browseId': 'FEmusic_liked_albums'};
    final response = await sendRequest('browse', body);
    Map outerContents = {};
    if (continuationParams != null) {
      outerContents =
          nav(response, ['continuationContents', 'gridContinuation']);
    } else {
      Map contents = nav(response, [
        'contents',
        'singleColumnBrowseResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'sectionListRenderer',
        'contents',
        0,
      ]);
      outerContents = nav(contents, [
            'gridRenderer',
          ]) ??
          nav(contents, [
            'itemSectionRenderer',
          ]);
    }
    String? continuation = nav(outerContents,
        ['continuations', 0, 'nextContinuationData', 'continuation']);
    if (continuation != null) {
      continuation = getContinuationString(continuation);
    }
    List contents =
        nav(outerContents, ['items']) ?? nav(outerContents, ['contents']);

    return {
      'contents': handleContents(contents),
      'continuation': continuation,
    };
  }

  Future<Map> getLibraryArtists({String? continuationParams}) async {
    Map<String, dynamic> body = {
      'browseId': 'FEmusic_library_corpus_track_artists'
    };

    final response = await sendRequest('browse', body,
        additionalParams: continuationParams ?? '');
    Map outerContents = {};
    if (continuationParams != null) {
      outerContents =
          nav(response, ['continuationContents', 'musicShelfContinuation']);
    } else {
      Map contents = nav(response, [
        'contents',
        'singleColumnBrowseResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'sectionListRenderer',
        'contents',
        0,
      ]);
      outerContents = nav(contents, [
            'musicShelfRenderer',
          ]) ??
          nav(contents, [
            'itemSectionRenderer',
          ]);
    }
    String? continuation = nav(outerContents,
        ['continuations', 0, 'nextContinuationData', 'continuation']);
    if (continuation != null) {
      continuation = getContinuationString(continuation);
    }
    List contents = nav(outerContents, ['contents']);
    return {
      'contents': handleContents(contents),
      'continuation': continuation,
    };
  }

  Future<Map> getLibraryPlaylists(
      {int limit = 25, String? continuationParams}) async {
    Map<String, dynamic> body = {'browseId': 'FEmusic_liked_playlists'};
    var response = await sendRequest('browse', body,
        additionalParams: continuationParams ?? '');
    Map outerContents = {};
    if (continuationParams != null) {
      outerContents =
          nav(response, ['continuationContents', 'gridContinuation']);
    } else {
      Map contents = nav(response, [
        'contents',
        'singleColumnBrowseResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'sectionListRenderer',
        'contents',
        0,
      ]);
      outerContents = nav(contents, ['gridRenderer']) ??
          nav(contents, [
            'itemSectionRenderer',
          ]);
    }
    String? continuation = nav(outerContents,
        ['continuations', 0, 'nextContinuationData', 'continuation']);
    if (continuation != null) {
      continuation = getContinuationString(continuation);
    }
    List contents = nav(outerContents, ['items']);
    if (continuationParams == null) {
      contents = contents.sublist(1);
    }

    return {
      'contents': handleContents(contents),
      'continuation': continuation,
    };
  }

  Future<Map> getLibrarySubscriptions({String? continuationParams}) async {
    Map<String, dynamic> body = {'browseId': 'FEmusic_library_corpus_artists'};
    final response = await sendRequest('browse', body,
        additionalParams: continuationParams ?? '');
    Map outerContents = {};
    if (continuationParams != null) {
      outerContents = outerContents =
          nav(response, ['continuationContents', 'musicShelfContinuation']);
    } else {
      Map contents = nav(response, [
        'contents',
        'singleColumnBrowseResultsRenderer',
        'tabs',
        0,
        'tabRenderer',
        'content',
        'sectionListRenderer',
        'contents',
        0,
      ]);
      outerContents = nav(contents, [
            'musicShelfRenderer',
          ]) ??
          nav(contents, [
            'itemSectionRenderer',
          ]);
    }
    String? continuation = nav(outerContents,
        ['continuations', 0, 'nextContinuationData', 'continuation']);
    if (continuation != null) {
      continuation = getContinuationString(continuation);
    }
    List contents = nav(outerContents, ['contents']);

    return {
      'contents': handleContents(contents),
      'continuation': continuation,
    };
  }

  Future<Map<String, dynamic>> importPlaylist(String browseId) async {
    Map<String, dynamic> body = {'browseId': browseId};
    var response = await sendRequest('browse', body);
    Map<String, dynamic> header = nav(response, [
      'contents',
      'twoColumnBrowseResultsRenderer',
      'tabs',
      0,
      'tabRenderer',
      'content',
      'sectionListRenderer',
      'contents',
      0,
      'musicResponsiveHeaderRenderer'
    ]);
    Map<String, dynamic> result = handlePageHeader(header);
    if (result['endpoint'] == null) {
      result['endpoint'] = {"browseId": browseId};
    }
    return result;
  }

  Future<List> getHistory() async {
    Map<String, dynamic> body = {'browseId': 'FEmusic_history'};
    var response = await sendRequest('browse', body);

    List allContents = nav(response, [
      'contents',
      'singleColumnBrowseResultsRenderer',
      'tabs',
      0,
      'tabRenderer',
      'content',
      'sectionListRenderer',
      'contents',
    ]);
    List result = [];
    for (var content in allContents) {
      List contents = nav(content, ['musicShelfRenderer', 'contents']);
      Map header = nav(content, ['musicShelfRenderer']);
      Map section = {
        'title': nav(header, ['title', 'runs', 0, 'text']),
        'contents': handleContents(contents),
      };
      result.add(section);
    }
    return result;
  }














































}
