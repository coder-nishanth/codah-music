import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class _CachedStream {
  final Uri url;
  final int totalBytes;
  final String mimeType;
  final bool isThrottled;
  _CachedStream({required this.url, required this.totalBytes, required this.mimeType, required this.isThrottled});
}

class YouTubeAudioSource extends StreamAudioSource {
  final String videoId;
  final String quality;
  _CachedStream? _cachedStream;

  YouTubeAudioSource({
    required this.videoId,
    required this.quality,
    super.tag,
  });

  Future<void> preload() async {
    await _getStreamInfo();
  }

  bool get hasPreloaded => _cachedStream != null;

  Future<_CachedStream> _getStreamInfo() async {
    if (_cachedStream != null) return _cachedStream!;

    int attempts = 0;
    const int maxAttempts = 2;
    while (attempts < maxAttempts) {
      attempts++;
      try {
        final manifest = await ytExplode.videos.streams.getManifest(videoId,
            requireWatchPage: true, ytClients: [YoutubeApiClient.androidVr]);

        Iterable<AudioOnlyStreamInfo> audioStreams = manifest.audioOnly;
        audioStreams = audioStreams.sortByBitrate();
        final bestAudio = quality == 'high'
            ? audioStreams.lastOrNull
            : audioStreams.firstOrNull;

        if (bestAudio != null) {
          _cachedStream = _CachedStream(
            url: bestAudio.url,
            totalBytes: bestAudio.size.totalBytes,
            mimeType: bestAudio.codec.mimeType,
            isThrottled: bestAudio.isThrottled,
          );
          return _cachedStream!;
        }

        final muxedStreams = manifest.muxed..sort((a, b) => b.bitrate.compareTo(a.bitrate));
        final bestMuxed = muxedStreams.isNotEmpty ? muxedStreams.first : null;

        if (bestMuxed != null) {
          _cachedStream = _CachedStream(
            url: bestMuxed.url,
            totalBytes: bestMuxed.size.totalBytes,
            mimeType: bestMuxed.codec.mimeType,
            isThrottled: bestMuxed.isThrottled,
          );
          return _cachedStream!;
        }

        throw Exception('No audio stream available for this video.');
      } catch (e) {
        if (attempts >= maxAttempts) rethrow;
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    throw Exception('Failed to get stream info after $maxAttempts attempts.');
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    try {
      final streamInfo = await _getStreamInfo();

      start ??= 0;
      end ??= (streamInfo.isThrottled
          ? (end ?? (start + 10379935))
          : streamInfo.totalBytes);
      if (end > streamInfo.totalBytes) {
        end = streamInfo.totalBytes;
      }

      final stream = await _downloadStream(streamInfo.url, start, end - 1);
      return StreamAudioResponse(
        sourceLength: streamInfo.totalBytes,
        contentLength: end - start,
        offset: start,
        stream: stream,
        contentType: streamInfo.mimeType,
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

  try {
    AudioOnlyStreamInfo? audioStreamInfo;

    if (_manifestCache.containsKey(videoId)) {
      final cached = _manifestCache[videoId]!;
      if (DateTime.now().isBefore(cached.expiry)) {
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
      debugPrint('Stream chunk read error: $streamError');
    }

    await response.close();
  } catch (e) {
    try {
      response.statusCode = HttpStatus.internalServerError;
      response.write('Error: $e');
      await response.close();
    } catch (_) {
      debugPrint('Failed to write error response: $_');
    }
  }
}

final Map<String, ({String url, DateTime expiry})> _urlCache = {};

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
    final manifest = await ytExplode.videos.streamsClient.getManifest(videoId,
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
