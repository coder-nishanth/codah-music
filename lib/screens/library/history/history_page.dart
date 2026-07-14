import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

import '../../../../generated/l10n.dart';
import '../../../../utils/bottom_modals.dart';
import '../../../../utils/adaptive_widgets/adaptive_widgets.dart';
import 'cubit/history_cubit.dart';
import '../../../../core/widgets/section_item.dart';


class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).History),
          centerTitle: true,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            return switch (state) {
              HistoryLoading() => const Center(child: LoadingIndicatorM3E()),
              HistoryError(:final message) => Center(child: Text(message)),
              HistoryLoaded(:final songs) => _HistoryBody(songs: songs),
            };
          },
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.songs});

  final List songs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            onChanged: (query) {
              context.read<HistoryCubit>().search(query);
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search history...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: songs.isEmpty
              ? const Center(
                  child: Text("No History Found"),
                )
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];

                        return SwipeActionCell(
                          backgroundColor: Colors.transparent,
                          key: ObjectKey(song['videoId']),
                          trailingActions: [
                            SwipeAction(
                              title: S.of(context).Remove,
                              color: Colors.red,
                              onTap: (handler) async {
                                final confirm = await Modals.showConfirmBottomModal(
                                  context,
                                  message: S.of(context).Remove_Message,
                                  isDanger: true,
                                );

                                if (confirm && context.mounted) {
                                  context.read<HistoryCubit>().remove(song['videoId']);
                                }
                              },
                            ),
                          ],
                          child: SongTile(song: song),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
