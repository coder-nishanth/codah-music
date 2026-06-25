import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../generated/l10n.dart';
import '../../services/media_player.dart';
import '../../utils/bottom_modals.dart';
import '../../ytmusic/ytmusic.dart';

typedef SearchResultsCallback = void Function(List<Map<String, dynamic>> results, bool loading);

class CommonHeader extends StatefulWidget {
  final SearchResultsCallback? onResultsChanged;
  const CommonHeader({super.key, this.onResultsChanged});
  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.trim();
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _isSearching = false);
      widget.onResultsChanged?.call([], false);
      return;
    }
    setState(() => _isSearching = true);
    widget.onResultsChanged?.call([], true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    if (Hive.box('SETTINGS').get('SEARCH_HISTORY', defaultValue: true)) {
      await Hive.box('SEARCH_HISTORY').delete(query.toLowerCase());
      await Hive.box('SEARCH_HISTORY').put(query.toLowerCase(), query);
    }

    try {
      final feed = await GetIt.I<YTMusic>().search(query);
      final sections = feed['sections'] as List? ?? [];
      final List<Map<String, dynamic>> items = [];
      for (final section in sections) {
        if (section['contents'] != null) {
          for (final item in section['contents']) {
            items.add(Map<String, dynamic>.from(item));
          }
        }
      }
      if (mounted && _controller.text.trim() == query) {
        widget.onResultsChanged?.call(items, false);
      }
    } catch (e) {
      if (mounted) {
        widget.onResultsChanged?.call([], false);
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _isSearching = false);
    widget.onResultsChanged?.call([], false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).Search_River,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (_isSearching)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  CupertinoIcons.clear,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const SearchResultTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool hasThumb = item['thumbnails'] != null &&
        (item['thumbnails'] as List).isNotEmpty;
    final bool isSong = item['videoId'] != null;

    return InkWell(
      onTap: () async {
        if (isSong) {
          await GetIt.I<MediaPlayer>().playSong(Map.from(item));
        } else if (item['endpoint'] != null) {
          context.push('/browse', extra: {'endpoint': item['endpoint']});
        }
      },
      onLongPress: () {
        if (isSong) {
          Modals.showSongBottomModal(context, item);
        } else if (item['endpoint'] != null) {
          Modals.showPlaylistBottomModal(context, item);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            if (hasThumb)
              ClipRRect(
                borderRadius: BorderRadius.circular(isSong ? 4 : 6),
                child: Image.network(
                  item['thumbnails'].first['url'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  if (item['subtitle'] != null)
                    Text(
                      item['subtitle'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
