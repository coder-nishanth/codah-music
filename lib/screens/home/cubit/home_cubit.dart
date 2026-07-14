import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:Codah/ytmusic/ytmusic.dart';
import 'package:Codah/services/charts_service.dart';
import 'package:Codah/services/chart_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final YTMusic _ytMusic;
  HomeCubit(this._ytMusic) : super(HomeLoading());

  Future<void> fetch() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _ytMusic.browse(),
        ChartsService().getChartsWithPreviews(),
        _fetchRecommendationsFromHistory(),
        _fetchTrendingSongs(),
        _ytMusic.getMoodAndGenres(),
      ]);

      final feed = results[0] as Map<String, dynamic>;
      final charts = results[1] as List<ChartURL>;
      final recommendations = results[2] as List<Map<String, dynamic>>;
      final trending = results[3] as List<Map<String, dynamic>>;
      final moodAndGenresFull = results[4] as List<Map<String, dynamic>>;

      final ytSections = List<Map<String, dynamic>>.from(feed['sections'] ?? []);
      final chips = feed['chips'] ?? [];

      List<Map<String, dynamic>> sections = [];

      final speedDial = _createSpeedDialSection();
      if (speedDial != null) sections.add(speedDial);

      final quickPicksIdx = ytSections.indexWhere(
        (s) => s is Map && s['title'] is String && (s['title'] as String).toLowerCase().contains('quick'),
      );
      if (quickPicksIdx >= 0) {
        sections.add(ytSections.removeAt(quickPicksIdx));
      }

      final dailyDiscover = _createDailyDiscoverSection(recommendations);
      if (dailyDiscover != null) sections.add(dailyDiscover);

      final moodAndGenres = _createMoodAndGenresSection(moodAndGenresFull.isNotEmpty ? moodAndGenresFull : chips);
      if (moodAndGenres != null) sections.add(moodAndGenres);

      if (trending.isNotEmpty) {
        sections.add(_createTrendingSection(trending));
      }
      sections.add(_createChartsSection(charts));
      sections.addAll(ytSections);

      emit(HomeSuccess(
        chips: chips,
        sections: sections,
        continuation: feed['continuation'],
        loadingMore: false,
      ));
    } catch (e, st) {
      emit(HomeError(e.toString(), st.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecommendationsFromHistory() async {
    try {
      final box = Hive.box('SONG_HISTORY');
      final allSongs = box.values
          .where((s) => s is Map && (s as Map)['videoId'] != null)
          .map((s) => Map<String, dynamic>.from(s as Map))
          .toList();

      if (allSongs.isEmpty) return [];

      allSongs.sort((a, b) =>
          ((b['plays'] as int? ?? 0)).compareTo((a['plays'] as int? ?? 0)));
      final topSongs = allSongs.take(3).toList();

      final relatedResults = await Future.wait(
        topSongs.map((song) => _ytMusic.getNextSongList(videoId: song['videoId'], limit: 6)),
      );

      final seen = <String>{};
      final recommendations = <Map<String, dynamic>>[];
      for (final result in relatedResults) {
        for (final song in result) {
          final id = song['videoId'] as String?;
          final title = (song['title'] as String? ?? '').toLowerCase().trim();
          final artist = ((song['artists'] as List?)?.firstOrNull is Map
              ? (song['artists'] as List).first['name'] as String?
              : null)?.toLowerCase().trim() ?? '';
          final titleKey = '$title|$artist';
          if (id != null && seen.add(id) && seen.add(titleKey)) {
            recommendations.add(Map<String, dynamic>.from(song));
          }
          if (recommendations.length >= 20) break;
        }
        if (recommendations.length >= 20) break;
      }

      return recommendations;
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTrendingSongs() async {
    try {
      final result = await _ytMusic.browse(body: {'browseId': 'FEmusic_charts'});
      final sections = result['sections'] as List?;
      final allSongs = <String, Map<String, dynamic>>{};
      if (sections != null && sections.isNotEmpty) {
        for (final section in sections) {
          final contents = section['contents'] as List?;
          if (contents != null && contents.isNotEmpty) {
            for (final s in contents) {
              final song = Map<String, dynamic>.from(s);
              final id = song['videoId'] as String?;
              if (id != null && !allSongs.containsKey(id)) {
                song['aspectRatio'] = 1.0;
                allSongs[id] = song;
              }
            }
          }
        }
      }
      if (allSongs.length < 20) {
        try {
          final searchResult = await _ytMusic.search(
            'trending songs india',
            filter: 'songs',
          );
          final searchSections = searchResult['sections'] as List?;
          if (searchSections != null && searchSections.isNotEmpty) {
            final searchContents = searchSections.first['contents'] as List?;
            if (searchContents != null) {
              for (final s in searchContents) {
                final song = Map<String, dynamic>.from(s);
                final id = song['videoId'] as String?;
                if (id != null && !allSongs.containsKey(id)) {
                  song['aspectRatio'] = 1.0;
                  allSongs[id] = song;
                }
              }
            }
          }
        } catch (_) {}
      }
      return allSongs.values.toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic>? _createSpeedDialSection() {
    try {
      final box = Hive.box('SONG_HISTORY');
      final allSongs = box.values
          .where((s) => s is Map && (s as Map)['videoId'] != null)
          .map((s) => Map<String, dynamic>.from(s as Map))
          .toList();
      if (allSongs.isEmpty) return null;
      allSongs.sort((a, b) =>
          ((b['plays'] as int? ?? 0)).compareTo((a['plays'] as int? ?? 0)));
      final items = allSongs.take(24).toList();
      return {
        'customType': 'speed_dial',
        'title': 'Speed Dial',
        'contents': items,
      };
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _createDailyDiscoverSection(List<Map<String, dynamic>> recommendations) {
    if (recommendations.isEmpty) return null;
    return {
      'customType': 'daily_discover',
      'title': 'Daily Discover',
      'contents': recommendations.take(10).toList(),
    };
  }

  Map<String, dynamic>? _createMoodAndGenresSection(List items) {
    if (items.isEmpty) return null;
    final moodItems = items.where((item) {
      final title = (item['title'] as String?)?.toLowerCase() ?? '';
      return title.isNotEmpty && title != 'all';
    }).toList();
    if (moodItems.isEmpty) return null;
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < moodItems.length; i++) {
      result.add({
        'title': moodItems[i]['title'],
        'endpoint': moodItems[i]['endpoint'],
      });
    }
    return {
      'customType': 'mood_and_genres',
      'title': 'Mood & Genres',
      'contents': result,
    };
  }

  Map<String, dynamic> _createTrendingSection(List songs) {
    return {
      'title': 'Trending in India',
      'contents': songs,
    };
  }

  Map<String, dynamic> _createChartsSection(List<ChartURL> charts) {
      return {
          'title': 'Browse Charts',
          'contents': charts.map((chart) => {
              'title': chart.title,
              'subtitle': 'Billboard Chart',
              'thumbnails': [{'url': chart.coverArt ?? 'https://www.billboard.com/wp-content/themes/vip/pmc-billboard-2021/assets/app/icons/icon-512x512.png', 'width': 500, 'height': 500}],
              'chartUrl': chart,
              'aspectRatio': 1.0,
          }).toList(),
      };
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _ytMusic.browse(),
        ChartsService().getChartsWithPreviews(),
        _fetchRecommendationsFromHistory(),
        _fetchTrendingSongs(),
        _ytMusic.getMoodAndGenres(),
      ]);

      final feed = results[0] as Map<String, dynamic>;
      final charts = results[1] as List<ChartURL>;
      final recommendations = results[2] as List<Map<String, dynamic>>;
      final trending = results[3] as List<Map<String, dynamic>>;
      final moodAndGenresFull = results[4] as List<Map<String, dynamic>>;

      final ytSections = List<Map<String, dynamic>>.from(feed['sections'] ?? []);
      final chips = feed['chips'] ?? [];

      List<Map<String, dynamic>> sections = [];

      final speedDial = _createSpeedDialSection();
      if (speedDial != null) sections.add(speedDial);

      final quickPicksIdx = ytSections.indexWhere(
        (s) => s is Map && s['title'] is String && (s['title'] as String).toLowerCase().contains('quick'),
      );
      if (quickPicksIdx >= 0) {
        sections.add(ytSections.removeAt(quickPicksIdx));
      }

      final dailyDiscover = _createDailyDiscoverSection(recommendations);
      if (dailyDiscover != null) sections.add(dailyDiscover);

      final moodAndGenres = _createMoodAndGenresSection(moodAndGenresFull.isNotEmpty ? moodAndGenresFull : chips);
      if (moodAndGenres != null) sections.add(moodAndGenres);

      if (trending.isNotEmpty) {
        sections.add(_createTrendingSection(trending));
      }
      sections.add(_createChartsSection(charts));
      sections.addAll(ytSections);

      emit(HomeSuccess(
        chips: chips,
        sections: sections,
        continuation: feed['continuation'],
        loadingMore: false,
      ));
    } catch (e, st) {
      emit(HomeError(e.toString(), st.toString()));
    }
  }

  Future<void> fetchNext() async {
    final current = state;
    if (current is! HomeSuccess) return;
    if (current.loadingMore || current.continuation == null) return;
    emit(current.copyWith(loadingMore: true));
    try {
      final feed = await _ytMusic.browseContinuation(
          additionalParams: current.continuation!);
      emit(
        HomeSuccess(
          chips: current.chips,
          sections: [...current.sections, ...feed['sections']],
          continuation: feed['continuation'],
          loadingMore: false,
        ),
      );
    } catch (e, st) {
      emit(HomeError(e.toString(), st.toString()));
    }
  }
}
