import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../services/media_player.dart';
import '../../utils/adaptive_widgets/adaptive_widgets.dart';
import '../../utils/enhanced_image.dart';
import '../../utils/bottom_modals.dart';

class SpeedDialGrid extends StatelessWidget {
  final List items;
  const SpeedDialGrid({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    final itemWidth = 120.0;
    final itemHeight = 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.flash_on, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Text('Quick Access',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              AdaptiveOutlinedButton(
                onPressed: () {
                  if (items.isNotEmpty) {
                    final random = items[Random().nextInt(items.length)];
                    GetIt.I<MediaPlayer>().playSong(Map.from(random));
                  }
                },
                child: const Icon(Icons.shuffle, size: 18),
              ),
            ],
          ),
        ),
        SizedBox(
          height: itemHeight + 16,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final thumbnails = item['thumbnails'] as List? ?? [];
              final thumbUrl = thumbnails.isNotEmpty
                  ? getEnhancedImage(thumbnails.first['url'], dp: MediaQuery.of(context).devicePixelRatio, width: itemWidth)
                  : '';
              return SizedBox(
                width: itemWidth,
                child: AdaptiveInkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    if (item['endpoint'] != null && item['videoId'] == null) {
                      context.push('/browse', extra: {'endpoint': item['endpoint']});
                    } else {
                      await GetIt.I<MediaPlayer>().playSong(Map.from(item));
                    }
                  },
                  onLongPress: () {
                    if (item['videoId'] != null) {
                      Modals.showSongBottomModal(context, item);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: itemWidth,
                        height: itemWidth,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          image: thumbUrl.isNotEmpty
                              ? DecorationImage(image: CachedNetworkImageProvider(thumbUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: thumbUrl.isEmpty
                            ? const Center(child: Icon(Icons.music_note, size: 32, color: Colors.white38))
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title'] ?? '',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, height: 1.2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DailyDiscoverCarousel extends StatelessWidget {
  final List items;
  const DailyDiscoverCarousel({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    const cardWidth = 260.0;
    const cardHeight = 320.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Discover',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Based on your history',
                    style: TextStyle(color: Colors.grey.withAlpha(200), fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight + 16,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final thumbnails = item['thumbnails'] as List? ?? [];
              final thumbUrl = thumbnails.isNotEmpty
                  ? getEnhancedImage(thumbnails.first['url'], dp: MediaQuery.of(context).devicePixelRatio, width: cardWidth)
                  : '';
              final artists = item['artists'] as List? ?? [];
              final artistName = artists.isNotEmpty ? artists[0]['name'] ?? '' : '';
              return SizedBox(
                width: cardWidth,
                child: AdaptiveInkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    if (item['videoId'] != null) {
                      await GetIt.I<MediaPlayer>().playSong(Map.from(item));
                    } else if (item['endpoint'] != null) {
                      context.push('/browse', extra: {'endpoint': item['endpoint']});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.withOpacity(0.15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumbUrl.isNotEmpty)
                                CachedNetworkImage(imageUrl: thumbUrl, fit: BoxFit.cover)
                              else
                                Container(color: Colors.grey.withOpacity(0.2), child: const Center(child: Icon(Icons.music_note, size: 48, color: Colors.white38))),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text(artistName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MoodAndGenresGrid extends StatelessWidget {
  final List items;
  const MoodAndGenresGrid({required this.items, super.key});

  Color _parseColor(dynamic val) {
    if (val is int) return Color(val);
    return const Color(0xFF9C27B0);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    final itemHeight = 52.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.explore, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Text('Mood & Genres',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        SizedBox(
          height: itemHeight * 2 + 12,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.5,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final color = _parseColor(item['color']);
              return AdaptiveInkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (item['endpoint'] != null) {
                    context.go('/chip', extra: item['endpoint']);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MultiRowHorizontalGrid extends StatelessWidget {
  final List items;
  final int rowCount;
  const MultiRowHorizontalGrid({required this.items, this.rowCount = 4, super.key});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    const itemHeight = 48.0;
    const itemWidth = 200.0;

    return SizedBox(
      height: itemHeight * rowCount + 8 * (rowCount - 1),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: (items.length / rowCount).ceil(),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, pageIndex) {
          final start = pageIndex * rowCount;
          final end = (start + rowCount).clamp(0, items.length);
          final pageItems = items.sublist(start, end);
          return SizedBox(
            width: itemWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(pageItems.length, (i) {
                final item = pageItems[i];
                final thumbnails = item['thumbnails'] as List? ?? [];
                final thumbUrl = thumbnails.isNotEmpty
                    ? getEnhancedImage(thumbnails.first['url'], dp: MediaQuery.of(context).devicePixelRatio, width: 44)
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AdaptiveInkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () async {
                      if (item['videoId'] != null) {
                        await GetIt.I<MediaPlayer>().playSong(Map.from(item));
                      } else if (item['endpoint'] != null) {
                        context.push('/browse', extra: {'endpoint': item['endpoint']});
                      }
                    },
                    onLongPress: () {
                      if (item['videoId'] != null) Modals.showSongBottomModal(context, item);
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: thumbUrl.isNotEmpty
                                ? CachedNetworkImage(imageUrl: thumbUrl, fit: BoxFit.cover)
                                : Container(color: Colors.grey.withOpacity(0.2), child: const Icon(Icons.music_note, size: 20, color: Colors.white38)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              Text((item['artists'] as List?)?.first?['name'] ?? item['subtitle'] ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: Colors.grey.withOpacity(0.8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
