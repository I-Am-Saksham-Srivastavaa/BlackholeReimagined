import 'package:audio_service/audio_service.dart';

import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:get_it/get_it.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key});

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: StreamBuilder<PlaybackState>(
        stream: audioHandler.playbackState,
        builder: (context, snapshot) {
          final playbackState = snapshot.data;
          final processingState = playbackState?.processingState;
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: processingState != AudioProcessingState.idle
                ? null
                : AppBar(
                    title: Text(CustomLocalizations.of(context).nowPlaying),
                    centerTitle: true,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                  ),
            body: processingState == AudioProcessingState.idle
                ? emptyScreen(
                    context,
                    3,
                    CustomLocalizations.of(context).nothingIs,
                    18.0,
                    CustomLocalizations.of(context).playingCap,
                    60,
                    CustomLocalizations.of(context).playSomething,
                    23.0,
                  )
                : StreamBuilder<MediaItem?>(
                    stream: audioHandler.mediaItem,
                    builder: (context, snapshot) {
                      final mediaItem = snapshot.data;
                      return mediaItem == null
                          ? const SizedBox()
                          : BouncyImageSliverScrollView(
                              scrollController: _scrollController,
                              title: CustomLocalizations.of(context).nowPlaying,
                              localImage: mediaItem.artUri!
                                  .toString()
                                  .startsWith('file:'),
                              imageUrl: mediaItem.artUri!
                                      .toString()
                                      .startsWith('file:')
                                  ? mediaItem.artUri!.toFilePath()
                                  : mediaItem.artUri!.toString(),
                              sliverList: SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    NowPlayingStream(
                                      audioHandler: audioHandler,
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                  ),
          );
        },
      ),
    );
  }
}
