import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:scroll_animator/scroll_animator.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../utils/bottom_modals.dart';

import 'cubit/download_playlist_cubit.dart';
import 'widgets/download_playlist_header.dart';
import 'widgets/download_song_tile.dart';

class DownloadPlaylistPage extends StatelessWidget {
  const DownloadPlaylistPage({
    super.key,
    required this.playlistId,
  });

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DownloadPlaylistCubit(playlistId)..load(),
      child: BlocBuilder<DownloadPlaylistCubit, DownloadPlaylistState>(
        builder: (context, state) {
          return switch (state) {
            DownloadPlaylistLoading() => const Scaffold(
                body: Center(child: LoadingIndicatorM3E()),
              ),
            DownloadPlaylistError() => Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Text(S.of(context).Playlist_Not_Available),
                ),
              ),
            DownloadPlaylistLoaded(
              :final playlist,
              :final songs,
            ) =>
              _PlaylistView(
                playlist: playlist,
                songs: songs,
                playlistId: playlistId,
              ),
          };
        },
      ),
    );
  }
}

class _PlaylistView extends StatefulWidget {
  const _PlaylistView({
    required this.playlist,
    required this.songs,
    required this.playlistId,
  });

  final Map playlist;
  final List songs;
  final String playlistId;

  @override
  State<_PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<_PlaylistView> {
  late final AnimatedScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimatedScrollController(
      animationFactory: const ChromiumEaseInOut(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.playlist['type'] == 'SONGS'
            ? Text(S.of(context).Songs)
            : Text(widget.playlist['title']),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    DownloadPlaylistHeader(
                      playlist: widget.playlist,
                      imageType: widget.playlist['type'],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = widget.songs[index];

                    return SwipeActionCell(
                      key: ObjectKey(song['videoId']),
                      backgroundColor: Colors.transparent,
                      trailingActions: [
                        SwipeAction(
                          title: S.of(context).Remove,
                          color: Colors.red,
                          onTap: (handler) async {
                            await Modals.showConfirmBottomModal(
                              context,
                              message: S.of(context).Remove_Message,
                              isDanger: true,
                            );


                          },
                        ),
                      ],
                      child: DownloadedSongTile(song: song),
                    );
                  },
                  childCount: widget.songs.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
