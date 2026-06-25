import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeAudioSource extends StreamAudioSource {
  final String videoId;
  final String quality;
  final YoutubeExplode ytExplode;
  AudioOnlyStreamInfo? _cachedStreamInfo;

  YouTubeAudioSource({
    required this.videoId,
    required this.quality,
    super.tag,
  }) : ytExplode = YoutubeExplode();

  Future<AudioOnlyStreamInfo> _getStreamInfo() async {
    if (_cachedStreamInfo != null) return _cachedStreamInfo!;

    final manifest = await ytExplode.videos.streams.getManifest(videoId,
        requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);
    Iterable<AudioOnlyStreamInfo> supportedStreams = manifest.audioOnly;
    supportedStreams = supportedStreams.sortByBitrate();

    final audioStream = quality == 'high'
        ? supportedStreams.lastOrNull
        : supportedStreams.firstOrNull;

    if (audioStream == null) {
      throw Exception('No audio stream available for this video.');
    }

    _cachedStreamInfo = audioStream;
    return audioStream;
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    try {
      final audioStream = await _getStreamInfo();

      start ??= 0;
      end ??= (audioStream.isThrottled
          ? (end ?? (start + 10379935))
          : audioStream.size.totalBytes);
      if (end > audioStream.size.totalBytes) {
        end = audioStream.size.totalBytes;
      }

      final stream = await _downloadStream(audioStream.url, start, end - 1);
      return StreamAudioResponse(
        sourceLength: audioStream.size.totalBytes,
        contentLength: end - start,
        offset: start,
        stream: stream,
        contentType: audioStream.codec.mimeType,
      );
    } catch (e) {
      throw Exception('Failed to load audio: $e');
    }
  }
}

final YoutubeExplode ytExplode = YoutubeExplode();

Future<String> createAudioStreamServer() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

  server.listen((HttpRequest request) {
    handleAudioRequest(request);
  });

  final host = server.address.host;
  final port = server.port;
  final url = 'http://$host:$port/audio';

  print(
      'Generic streaming server started on $url. Use ?id=...&quality=... to stream.');

  return url;
}


final Map<String, ({AudioOnlyStreamInfo info, DateTime expiry})>
    _manifestCache = {};

Future<void> handleAudioRequest(HttpRequest request) async {
  final response = request.response;

  if (request.uri.path != '/audio') {
    response.statusCode = HttpStatus.notFound;
    response.write('404 Not Found');
    await response.close();
    return;
  }

  final queryParams = request.uri.queryParameters;
  final videoId = queryParams['id'];
  final quality = queryParams['quality'] ?? 'high';

  if (videoId == null || videoId.isEmpty) {
    response.statusCode = HttpStatus.badRequest;
    response.write('Missing required query parameter: id');
    await response.close();
    return;
  }

  print('Processing request for video ID: $videoId (Quality: $quality)');

  try {
    AudioOnlyStreamInfo? audioStreamInfo;

    if (_manifestCache.containsKey(videoId)) {
      final cached = _manifestCache[videoId]!;
      if (DateTime.now().isBefore(cached.expiry)) {
        print('Using cached manifest for $videoId');
        audioStreamInfo = cached.info;
      } else {
        _manifestCache.remove(videoId);
      }
    }

    if (audioStreamInfo == null) {
      final manifest = await ytExplode.videos.streamsClient.getManifest(videoId,
          requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);

      Iterable<AudioOnlyStreamInfo> supportedStreams = manifest.audioOnly;
      supportedStreams = supportedStreams.sortByBitrate();

      audioStreamInfo = quality == 'high'
          ? supportedStreams.lastOrNull
          : supportedStreams.firstOrNull;

      if (audioStreamInfo != null) {
        _manifestCache[videoId] = (
          info: audioStreamInfo,
          expiry: DateTime.now().add(const Duration(hours: 1))
        );
      }
    }

    if (audioStreamInfo == null) {
      response.statusCode = HttpStatus.internalServerError;
      response.write('No audio stream available for video $videoId.');
      await response.close();
      return;
    }

    final totalLength = audioStreamInfo.size.totalBytes;


    (int start, int end)? parseRange(String rangeHeader, int totalLength) {
      if (!rangeHeader.startsWith('bytes=')) return null;

      final parts = rangeHeader.substring(6).split('-');
      if (parts.length != 2) return null;

      final startStr = parts[0];
      final endStr = parts[1];

      final start = int.tryParse(startStr) ?? 0;

      final end = endStr.isEmpty ? totalLength - 1 : int.tryParse(endStr);

      if (end == null ||
          end >= totalLength ||
          start >= totalLength ||
          start > end) {
        return null;
      }

      return (start, end);
    }

    int start = 0;
    int end = totalLength - 1;
    bool isPartial = false;

    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    if (rangeHeader != null) {
      final range = parseRange(rangeHeader, totalLength);
      if (range != null) {
        start = range.$1;
        end = range.$2;
        isPartial = true;
      }
    }

    final stream = await _downloadStream(audioStreamInfo.url, start, end);

    final mimeType = audioStreamInfo.codec.mimeType;

    response.statusCode = isPartial ? HttpStatus.partialContent : HttpStatus.ok;
    response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    response.headers.contentType = ContentType.parse(mimeType);
    if (isPartial) {
      response.headers.set(
          HttpHeaders.contentRangeHeader, 'bytes $start-$end/$totalLength');
    }
    response.bufferOutput = false;

    try {
      await for (final chunk in stream) {
        response.add(chunk);
      }
    } catch (streamError) {
      print('Stream error for $videoId: $streamError');
    }

    await response.close();
    print(
        '[$videoId] Served ${isPartial ? 'partial' : 'full'} stream: bytes $start-$end');
  } catch (e) {
    print('Error serving audio for ID $videoId: $e');
    try {
      response.statusCode = HttpStatus.internalServerError;
      response.write('Error: $e');
      await response.close();
    } catch (_) {}
  }
}

final Map<String, ({String url, DateTime expiry})> _urlCache = {};

final YoutubeExplode _ytClient = YoutubeExplode();

Future<AudioSource> getDirectUrlAudioSource(
    String videoId, String quality, dynamic tag) async {
  if (_urlCache.containsKey(videoId)) {
    final cached = _urlCache[videoId]!;
    if (DateTime.now().isBefore(cached.expiry)) {
      return AudioSource.uri(Uri.parse(cached.url), tag: tag);
    } else {
      _urlCache.remove(videoId);
    }
  }

  try {
    final manifest = await _ytClient.videos.streamsClient.getManifest(videoId,
        requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);
    Iterable<AudioOnlyStreamInfo> supportedStreams = manifest.audioOnly;
    supportedStreams = supportedStreams.sortByBitrate();

    final audioStream = quality == 'high'
        ? supportedStreams.lastOrNull
        : supportedStreams.firstOrNull;

    if (audioStream == null) {
      throw Exception('No audio stream available for this video.');
    }

    _urlCache[videoId] = (
      url: audioStream.url.toString(),
      expiry: DateTime.now().add(const Duration(hours: 1))
    );

    return AudioSource.uri(audioStream.url, tag: tag);
  } catch (e) {
    print('Error fetching URL for $videoId: $e');
    rethrow;
  }
}

Future<Stream<List<int>>> _downloadStream(Uri url, int start, int end) async {
  final client = HttpClient();
  final request = await client.getUrl(url);
  request.headers.add(HttpHeaders.rangeHeader, "bytes=$start-$end");
  final response = await request.close();
  return response;
}
