import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:scroll_animator/scroll_animator.dart';
import 'package:Codah/screens/library/downloads/downloading/widgets/downloading_section_tile.dart';

import '../../../../../generated/l10n.dart';
import 'cubit/downloading_cubit.dart';
import 'widgets/downloading_song_tile.dart';


class DownloadingPage extends StatefulWidget {
  const DownloadingPage({super.key});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage> {
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
    return BlocProvider(
      create: (_) => DownloadingCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).Downloading),
          centerTitle: true,
        ),
        body: BlocBuilder<DownloadingCubit, DownloadingState>(
          builder: (context, state) {
            return switch (state) {
              DownloadingLoading() =>
                const Center(child: LoadingIndicatorM3E()),
              DownloadingError(:final message) => Center(child: Text(message)),
              DownloadingLoaded(
                :final downloading,
                :final queued,
              ) =>
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if (downloading.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: DownloadingSectionTile(
                          title: S.of(context).In_Progress,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => DownloadingSongTile(
                            song: downloading[index],
                          ),
                          childCount: downloading.length,
                        ),
                      ),
                    ],
                    if (queued.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: DownloadingSectionTile(
                          title: S.of(context).QueuedCount(queued.length),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => DownloadingSongTile(
                            song: queued[index],
                          ),
                          childCount: queued.length,
                        ),
                      ),
                    ],
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}
