import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:River/services/yt_audio_stream.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/add_history.dart';
import '../ytmusic/ytmusic.dart';
import 'settings_manager.dart';

class MediaPlayer extends ChangeNotifier {
  late final AudioPlayer _player;

  List<IndexedAudioSource> _songList = [];
  List<Map<String, dynamic>> _originalPlaylist = [];
  final ValueNotifier<MediaItem?> _currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _currentIndex = ValueNotifier(null);
  final ValueNotifier<ButtonState> _buttonState =
      ValueNotifier(ButtonState.loading);
  Timer? _timer;
  final ValueNotifier<Duration?> _timerDuration = ValueNotifier(null);

  final ValueNotifier<LoopMode> _loopMode = ValueNotifier(LoopMode.off);

  final ValueNotifier<ProgressBarState> _progressBarState =
      ValueNotifier(ProgressBarState());

  bool _shuffleModeEnabled = false;

  bool autoFetching = false;

  MediaPlayer() {
    _player = AudioPlayer();
    _init();
  }

  AudioPlayer get player => _player;
  List<IndexedAudioSource> get songList => List.unmodifiable(_songList);
  ValueNotifier<MediaItem?> get currentSongNotifier => _currentSongNotifier;
  ValueNotifier<int?> get currentIndex => _currentIndex;
  ValueNotifier<ButtonState> get buttonState => _buttonState;
  ValueNotifier<ProgressBarState> get progressBarState => _progressBarState;
  bool get shuffleModeEnabled => _shuffleModeEnabled;
  ValueNotifier<LoopMode> get loopMode => _loopMode;
  ValueNotifier<Duration?> get timerDuration => _timerDuration;

  Stream<
      ({
        List<IndexedAudioSource>? sequence,
        int? currentIndex,
        MediaItem? currentItem
      })> get currentTrackStream => Rx.combineLatest2<
          List<IndexedAudioSource>?,
          int?,
          ({
            List<IndexedAudioSource>? sequence,
            int? currentIndex,
            MediaItem? currentItem
          })>(
        _player.sequenceStream,
        _player.currentIndexStream,
        (sequence, currentIndex) {
          MediaItem? currentItem;
          if (sequence != null &&
              currentIndex != null &&
              currentIndex >= 0 &&
              currentIndex < sequence.length) {
            final tag = sequence[currentIndex].tag;
            if (tag is MediaItem) currentItem = tag;
          }
          return (
            sequence: sequence,
            currentIndex: currentIndex,
            currentItem: currentItem,
          );
        },
      );

  Future<void> _init() async {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    _listenToShuffle();
    _listenToAutofetch();
    _listenToPlayerErrors();

    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (currentSongNotifier.value != null && _player.playing) {
        GetIt.I<YTMusic>()
            .addPlayingStats(currentSongNotifier.value!.id, _player.position);
      }
    });
  }


  void _listenToChangesInPlaylist() {
    _player.sequenceStream.listen((playlist) {
      final List<IndexedAudioSource> newList =
          (playlist).cast<IndexedAudioSource>();

      if (listEquals(newList, _songList)) return;

      final bool shouldAdd = (_songList.isEmpty && newList.isNotEmpty);

      if (newList.isEmpty) {
        _currentSongNotifier.value = null;
        _currentIndex.value = null;
        _songList = [];
      } else {
        _songList = newList;

        _currentIndex.value ??= 0;
        _currentSongNotifier.value =
            (_songList.length > (_currentIndex.value ?? 0))
                ? _songList[_currentIndex.value ?? 0].tag
                : null;
      }

      if (shouldAdd == true && _currentSongNotifier.value != null) {
        addHistory(_currentSongNotifier.value!.extras!);
      }

      notifyListeners();
    });
  }

  void _listenToPlaybackState() {
    _player.playerStateStream.listen((event) {
      final isPlaying = event.playing;
      final processingState = event.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        _buttonState.value = ButtonState.loading;
      } else if (processingState == ProcessingState.ready) {
        _buttonState.value =
            isPlaying ? ButtonState.playing : ButtonState.paused;
      } else if (processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        _buttonState.value = ButtonState.paused;
      } else {
        _buttonState.value = ButtonState.paused;
      }
    });
  }

  void _listenToPlayerErrors() {
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        _buttonState.value = ButtonState.paused;
        notifyListeners();
      },
    );
  }

  void _listenToCurrentPosition() {
    _player.positionStream.listen((position) {
      final oldState = _progressBarState.value;
      if (oldState.current != position) {
        _progressBarState.value = ProgressBarState(
          current: position,
          buffered: oldState.buffered,
          total: oldState.total,
        );
      }
    });
  }

  void _listenToBufferedPosition() {
    _player.bufferedPositionStream.listen((position) {
      final oldState = _progressBarState.value;
      if (oldState.buffered != position) {
        _progressBarState.value = ProgressBarState(
          current: oldState.current,
          buffered: position,
          total: oldState.total,
        );
      }
    });
  }

  void _listenToTotalDuration() {
    _player.durationStream.listen((position) {
      final oldState = _progressBarState.value;
      if (oldState.total != position) {
        _progressBarState.value = ProgressBarState(
          current: oldState.current,
          buffered: oldState.buffered,
          total: position ?? Duration.zero,
        );
      }
    });
  }

  void _listenToShuffle() {
  }

  void _listenToChangesInSong() {
    _player.currentIndexStream.listen((index) {
      if (_songList.isNotEmpty && _currentIndex.value != index) {
        _currentIndex.value = index;
        _currentSongNotifier.value =
            index != null && _songList.isNotEmpty && index < _songList.length
                ? _songList[index].tag
                : null;
        if (_songList.isNotEmpty && _currentIndex.value != null) {
          final MediaItem item = _songList[_currentIndex.value!].tag;
          addHistory(item.extras!);
        }
        notifyListeners();
      }
    });
  }

  void changeLoopMode() {
    switch (_loopMode.value) {
      case LoopMode.off:
        _loopMode.value = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode.value = LoopMode.one;
        break;
      default:
        _loopMode.value = LoopMode.off;
        break;
    }
    _player.setLoopMode(_loopMode.value);
  }

  Future<void> skipSilence(bool value) async {
    await _player.setSkipSilenceEnabled(value);
    GetIt.I<SettingsManager>().skipSilence = value;
  }

  Future<void> setShuffleModeEnabled(bool value) async {
    _shuffleModeEnabled = value;
    notifyListeners();
    try {
      if (value) {
        await _shuffleRemainingQueue();
      } else {
        await _restoreOriginalQueueOrder();
      }
    } catch (e) {
      print("Error setting shuffle mode: $e");
    }
  }

  Future<AudioSource> _getAudioSource(Map<String, dynamic> song) async {
    MediaItem tag = MediaItem(
      id: song['videoId'],
      title: song['title'] ?? 'Title',
      album: song['album']?['name'],
      artUri: Uri.parse(
          song['thumbnails']?.first['url'].replaceAll('w60-h60', 'w225-h225')),
      artist: song['artists']?.map((artist) => artist['name']).join(','),
      extras: song,
    );

    final bool isDownloaded = song['status'] == 'DOWNLOADED' &&
        song['path'] != null &&
        (await File(song['path']).exists());

    if (isDownloaded) {
      return AudioSource.file(song['path'], tag: tag);
    } else {
      return YouTubeAudioSource(
        videoId: song['videoId'],
        quality: GetIt.I<SettingsManager>().streamingQuality.name.toLowerCase(),
        tag: tag,
      );
    }
  }

  int _lastPlayRequestId = 0;

  Future<void> playSong(Map<String, dynamic> song) async {
    if (song['videoId'] == null) return;

    final int requestId = DateTime.now().millisecondsSinceEpoch;
    _lastPlayRequestId = requestId;

    _originalPlaylist = [song];

    MediaItem tempTag = MediaItem(
      id: song['videoId'],
      title: song['title'] ?? 'Title',
      album: song['album']?['name'],
      artUri: Uri.parse(
          song['thumbnails']?.first['url'].replaceAll('w60-h60', 'w225-h225')),
      artist: song['artists']?.map((artist) => artist['name']).join(','),
      extras: song,
    );
    _currentSongNotifier.value = tempTag;
    _buttonState.value = ButtonState.loading;
    notifyListeners();

    try {
      await _player.pause();
      await _player.stop();
      if (_lastPlayRequestId != requestId) return;
      await _player.clearAudioSources();
      if (_lastPlayRequestId != requestId) return;
    } catch (e) {
    }

    try {
      final source = await _getAudioSource(song);
      if (_lastPlayRequestId != requestId)
        return;

      await _player.setAudioSource(source);
      if (_lastPlayRequestId != requestId) return;

      await _player.play();
    } catch (e) {
      if (_lastPlayRequestId == requestId) {
        print("Error playing song: $e");
        _buttonState.value = ButtonState.paused;
        notifyListeners();
      }
    }
  }

  Future<void> playNext(Map<String, dynamic> mediaItem) async {
    final currentSong = _currentSongNotifier.value;
    int insertIndexOrig = _originalPlaylist.length;
    if (currentSong != null) {
      final origIdx = _originalPlaylist.indexWhere((song) => song['videoId'] == currentSong.id);
      if (origIdx != -1) {
        insertIndexOrig = origIdx + 1;
      }
    }

    if (mediaItem['videoId'] != null) {
      _originalPlaylist.insert(insertIndexOrig, mediaItem);
      final audioSource = await _getAudioSource(mediaItem);

      final currentIndex = _player.currentIndex ?? -1;
      final sequenceLength = _player.sequence.length;
      final insertIndex = (currentIndex + 1).clamp(0, sequenceLength);

      if (sequenceLength > 0) {
        await _player.insertAudioSource(insertIndex, audioSource);
      } else {
        await _player.setAudioSource(audioSource);
      }

    } else if (mediaItem['songs'] != null) {
      List songs = mediaItem['songs'];
      final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
      _originalPlaylist.insertAll(insertIndexOrig, songMaps);
      await _addSongListToQueue(songs, isNext: true);

    } else if (mediaItem['playlistId'] != null) {
      List songs = mediaItem['type'] == 'ARTIST'
          ? await GetIt.I<YTMusic>()
              .getNextSongList(playlistId: mediaItem['playlistId'])
          : await GetIt.I<YTMusic>().getPlaylistSongs(mediaItem['playlistId']);
      final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
      _originalPlaylist.insertAll(insertIndexOrig, songMaps);
      await _addSongListToQueue(songs, isNext: true);
    }
  }

  Future<void> playAll(List songs, {int index = 0}) async {
    if (songs.isEmpty) return;

    autoFetching = true;
    _originalPlaylist = songs.map((s) => Map<String, dynamic>.from(s)).toList();

    _buttonState.value = ButtonState.loading;
    notifyListeners();

    try {
      await _player.stop();

      final selectedSong = Map<String, dynamic>.from(songs[index]);
      final firstSource = await _getAudioSource(selectedSong);

      await _player.setAudioSource(firstSource);
      _player.play();

      if (songs.length > 1) {
        Future(() async {
        await _addRemainingToPlaylist(songs, index);
        autoFetching = false;
        });
      }
      else {
        autoFetching = false;
      }
    } catch (e) {
      autoFetching = false;
      print('Error in playAll: $e');
      _buttonState.value = ButtonState.paused;
      notifyListeners();
    }
  }

  Future<void> _addRemainingToPlaylist(List songs, int playedIndex) async {
    try {
      int added = 0;
      final remaining = <Map<String, dynamic>>[];
      for (int i = playedIndex + 1; i < songs.length; i++) {
        remaining.add(Map<String, dynamic>.from(songs[i]));
      }

      if (_shuffleModeEnabled) {
        remaining.shuffle();
      }

      for (var song in remaining) {
        try {
          final source = await _getAudioSource(song);
          await _player.addAudioSource(source);
          added++;
        } catch (e) {
        }
      }
    } catch (e) {
      print('Error adding remaining songs: $e');
    }
  }

  Future<void> addToQueue(Map<String, dynamic> mediaItem) async {
    if (mediaItem['videoId'] != null) {
      _originalPlaylist.add(mediaItem);
      await _player.addAudioSource(await _getAudioSource(mediaItem));

    } else if (mediaItem['songs'] != null) {
      List songs = mediaItem['songs'];
      final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
      _originalPlaylist.addAll(songMaps);
      await _addSongListToQueue(songs, isNext: false);

    } else if (mediaItem['playlistId'] != null) {
      List songs = mediaItem['type'] == 'ARTIST'
          ? await GetIt.I<YTMusic>()
              .getNextSongList(playlistId: mediaItem['playlistId'])
          : await GetIt.I<YTMusic>().getPlaylistSongs(mediaItem['playlistId']);
      final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
      _originalPlaylist.addAll(songMaps);
      await _addSongListToQueue(songs, isNext: false);
    }
  }

  Future<void> startRelated(Map<String, dynamic> song,
      {bool radio = false, bool shuffle = false, bool isArtist = false}) async {
    _originalPlaylist = [];
    await _player.clearAudioSources();
    if (!isArtist) {
      await addToQueue(song);
    }
    List songs = await GetIt.I<YTMusic>().getNextSongList(
        videoId: song['videoId'],
        playlistId: song['playlistRadioId'],
        radio: radio,
        shuffle: shuffle);
    if (songs.isNotEmpty) songs.removeAt(0);
    final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
    _originalPlaylist.addAll(songMaps);
    await _addSongListToQueue(songs, isNext: false);
    await _player.play();
  }

  Future<void> startPlaylistSongs(Map endpoint) async {
    _originalPlaylist = [];
    await _player.clearAudioSources();
    List songs = await GetIt.I<YTMusic>().getNextSongList(
        playlistId: endpoint['playlistId'], params: endpoint['params']);

    if (songs.isNotEmpty && songs.first['videoId'] == null) {
    }

    final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
    _originalPlaylist.addAll(songMaps);
    await _addSongListToQueue(songs);
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.clearAudioSources();
    await _player.seek(Duration.zero, index: 0);
    _currentIndex.value = null;
    _currentSongNotifier.value = null;
    notifyListeners();
  }

  Future<void> _addSongListToQueue(List songs, {bool isNext = false}) async {
    if (songs.isEmpty) return;

    final songMaps = songs.map((s) => Map<String, dynamic>.from(s)).toList();
    if (_shuffleModeEnabled) {
      songMaps.shuffle();
    }

    final newSources = await Future.wait(songMaps.map((song) async {
      return await _getAudioSource(song);
    }));

    final queueLength = _player.sequence.length;

    if (isNext) {
      final currentIndex = _player.currentIndex ?? -1;
      int insertIndex = (currentIndex + 1).clamp(0, queueLength);
      await _player.insertAudioSources(insertIndex, newSources);
    } else {
      await _player.addAudioSources(newSources);
    }
  }

  void _listenToAutofetch() {
    player.currentIndexStream.listen((index) async {
      if (index == null) return;
      if (player.sequence.length - index < 5 &&
          GetIt.I<SettingsManager>().autofetchSongs &&
          autoFetching == false) {
        autoFetching = true;
        List nextSongs = await GetIt.I<YTMusic>()
            .getNextSongList(videoId: player.sequence[index].tag.id);
        if (nextSongs.isNotEmpty) nextSongs.removeAt(0);
        final songMaps = nextSongs.map((s) => Map<String, dynamic>.from(s)).toList();
        _originalPlaylist.addAll(songMaps);
        await _addSongListToQueue(nextSongs);
        autoFetching = false;
      }
    });
  }

  void setTimer(Duration duration) {
    int seconds = duration.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      _timerDuration.value = Duration(seconds: seconds);
      if (seconds == 0) {
        cancelTimer();
        _player.pause();
      }
      notifyListeners();
    });
  }

  void cancelTimer() {
    _timerDuration.value = null;
    _timer?.cancel();
    notifyListeners();
  }

  Future<AudioSource> _cloneSource(AudioSource source, Map<String, dynamic> song) async {
    if (source is UriAudioSource) {
      return AudioSource.uri(source.uri, tag: source.tag);
    }
    return await _getAudioSource(song);
  }

  Future<void> _shuffleRemainingQueue() async {
    try {
      final currentSong = _currentSongNotifier.value;
      if (currentSong == null) return;
      final currentIndex = _player.currentIndex;
      if (currentIndex == null) return;
      final currentPosition = _player.position;

      final allSources = List<IndexedAudioSource>.from(_player.sequence ?? []);
      if (allSources.isEmpty || currentIndex + 1 >= allSources.length) return;

      final beforeSources = allSources.sublist(0, currentIndex);
      final remainingSources = allSources.sublist(currentIndex + 1);

      final List<AudioSource> newBeforeSources = [];
      for (int i = 0; i < beforeSources.length; i++) {
        final src = beforeSources[i];
        final song = _originalPlaylist.firstWhere(
          (s) => s['videoId'] == (src.tag as MediaItem).id,
          orElse: () => <String, dynamic>{},
        );
        newBeforeSources.add(await _cloneSource(src, song));
      }

      final List<AudioSource> newRemainingSources = [];
      for (int i = 0; i < remainingSources.length; i++) {
        final src = remainingSources[i];
        final song = _originalPlaylist.firstWhere(
          (s) => s['videoId'] == (src.tag as MediaItem).id,
          orElse: () => <String, dynamic>{},
        );
        newRemainingSources.add(await _cloneSource(src, song));
      }

      newRemainingSources.shuffle();

      final currentSrc = allSources[currentIndex];
      final currentSongMap = _originalPlaylist.firstWhere(
        (s) => s['videoId'] == (currentSrc.tag as MediaItem).id,
        orElse: () => <String, dynamic>{},
      );
      final newCurrentSource = await _cloneSource(currentSrc, currentSongMap);

      final newSources = [...newBeforeSources, newCurrentSource, ...newRemainingSources];

      await _player.setAudioSource(
        ConcatenatingAudioSource(children: newSources),
        initialIndex: currentIndex,
        initialPosition: currentPosition,
      );
    } catch (e) {
      print("Error shuffling remaining queue: $e");
    }
  }

  Future<void> _restoreOriginalQueueOrder() async {
    try {
      final currentSong = _currentSongNotifier.value;
      if (currentSong == null) return;
      final currentPosition = _player.position;

      final allSources = List<IndexedAudioSource>.from(_player.sequence ?? []);

      final sourceMap = <String, IndexedAudioSource>{};
      for (var source in allSources) {
        final tag = source.tag;
        if (tag is MediaItem) {
          sourceMap[tag.id] = source;
        }
      }

      final usedSources = <IndexedAudioSource>{};
      final List<AudioSource> originalSources = [];
      for (var song in _originalPlaylist) {
        final videoId = song['videoId'];
        final source = sourceMap[videoId];
        if (source != null && !usedSources.contains(source)) {
          originalSources.add(await _cloneSource(source, song));
          usedSources.add(source);
        } else {
          final newSource = await _getAudioSource(song);
          originalSources.add(newSource);
        }
      }

      final origIndex = originalSources.indexWhere((source) {
        if (source is IndexedAudioSource) {
          final tag = source.tag;
          return tag is MediaItem && tag.id == currentSong.id;
        }
        return false;
      });
      if (origIndex == -1) return;

      await _player.setAudioSource(
        ConcatenatingAudioSource(children: originalSources),
        initialIndex: origIndex,
        initialPosition: currentPosition,
      );
    } catch (e) {
      print("Error restoring original queue order: $e");
    }
  }
}

enum ButtonState { loading, paused, playing }

enum LoopState { off, all, one }

class ProgressBarState {
  Duration current;
  Duration buffered;
  Duration total;
  ProgressBarState(
      {this.current = Duration.zero,
      this.buffered = Duration.zero,
      this.total = Duration.zero});
}
