import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oryn/index.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final bool shuffle;
  final bool miniplayer;
  final List buttons;
  final Color? dominantColor;

  const ControlButtons(
    this.audioHandler, {
    super.key,
    this.shuffle = false,
    this.miniplayer = false,
    this.buttons = const ['Previous', 'Play/Pause', 'Next'],
    this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    final MediaItem mediaItem = audioHandler.mediaItem.value!;
    final bool online = mediaItem.extras!['url'].toString().startsWith('http');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((e) {
        switch (e) {
          case 'Like':
            return !online
                ? const SizedBox()
                : miniplayer
                    ? ValueListenableBuilder(
                        valueListenable:
                            Hive.box('Favorite Songs').listenable(),
                        builder:
                            (BuildContext context, Box box, Widget? widget) {
                          return LikeButton(
                            mediaItem: mediaItem,
                            size: 22.0,
                          );
                        },
                      )
                    : LikeButton(
                        mediaItem: mediaItem,
                        size: 22.0,
                      );
          case 'Previous':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                final resetOnSkip = Hive.box('settings')
                    .get('resetOnSkip', defaultValue: false) as bool;
                return IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: miniplayer ? 24.0 : 45.0,
                  tooltip: CustomLocalizations.of(context).skipPrevious,
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: ((queueState?.hasPrevious ?? true) || resetOnSkip)
                      ? audioHandler.skipToPrevious
                      : null,
                );
              },
            );
          case 'Play/Pause':
            return SizedBox(
              height: miniplayer ? 40.0 : 65.0,
              width: miniplayer ? 40.0 : 65.0,
              child: StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  final playing = playbackState?.playing ?? true;
                  return Stack(
                    children: [
                      if (processingState == AudioProcessingState.loading ||
                          processingState == AudioProcessingState.buffering)
                        Center(
                          child: SizedBox(
                            height: miniplayer ? 40.0 : 65.0,
                            width: miniplayer ? 40.0 : 65.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).iconTheme.color!,
                              ),
                            ),
                          ),
                        ),
                      if (miniplayer)
                        Center(
                          child: playing
                              ? IconButton(
                                  tooltip:
                                      CustomLocalizations.of(context).pause,
                                  onPressed: audioHandler.pause,
                                  icon: const Icon(
                                    Icons.pause_rounded,
                                  ),
                                  color: Theme.of(context).iconTheme.color,
                                )
                              : IconButton(
                                  tooltip: CustomLocalizations.of(context).play,
                                  onPressed: audioHandler.play,
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                  ),
                                  color: Theme.of(context).iconTheme.color,
                                ),
                        )
                      else
                        Center(
                          child: SizedBox(
                            height: 59,
                            width: 59,
                            child: Center(
                              child: playing
                                  ? FloatingActionButton(
                                      elevation: 10,
                                      tooltip:
                                          CustomLocalizations.of(context).pause,
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.pause,
                                      child: const Icon(
                                        Icons.pause_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    )
                                  : FloatingActionButton(
                                      elevation: 10,
                                      tooltip:
                                          CustomLocalizations.of(context).play,
                                      backgroundColor: Colors.white,
                                      onPressed: audioHandler.play,
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 40.0,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          case 'Next':
            return StreamBuilder<QueueState>(
              stream: audioHandler.queueState,
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                return IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: miniplayer ? 24.0 : 45.0,
                  tooltip: CustomLocalizations.of(context).skipNext,
                  color: dominantColor ?? Theme.of(context).iconTheme.color,
                  onPressed: queueState?.hasNext ?? true
                      ? audioHandler.skipToNext
                      : null,
                );
              },
            );
          case 'Download':
            return !online
                ? const SizedBox()
                : DownloadButton(
                    size: 20.0,
                    icon: 'download',
                    data: MediaItemConverter.mediaItemToMap(mediaItem),
                  );
          default:
            break;
        }
        return const SizedBox();
      }).toList(),
    );
  }
}
