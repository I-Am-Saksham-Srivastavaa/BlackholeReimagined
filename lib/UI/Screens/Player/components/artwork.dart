import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:oryn/index.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

class ArtWorkWidget extends StatefulWidget {
  final GlobalKey<FlipCardState> cardKey;
  final MediaItem mediaItem;
  final bool offline;
  final bool getLyricsOnline;
  final double width;
  final AudioPlayerHandler audioHandler;

  const ArtWorkWidget({
    super.key,
    required this.cardKey,
    required this.mediaItem,
    required this.width,
    this.offline = false,
    required this.getLyricsOnline,
    required this.audioHandler,
  });

  @override
  _ArtWorkWidgetState createState() => _ArtWorkWidgetState();
}

class _ArtWorkWidgetState extends State<ArtWorkWidget> {
  final ValueNotifier<bool> dragging = ValueNotifier<bool>(false);
  final ValueNotifier<bool> tapped = ValueNotifier<bool>(false);
  final ValueNotifier<int> doubletapped = ValueNotifier<int>(0);
  final ValueNotifier<bool> done = ValueNotifier<bool>(false);
  final ValueNotifier<String> lyricsSource = ValueNotifier<String>('');
  Map lyrics = {
    'id': '',
    'lyrics': '',
    'source': '',
    'type': '',
  };
  final lyricUI = UINetease();
  LyricsReaderModel? lyricsReaderModel;
  bool flipped = false;

  void fetchLyrics() {
    Logger.root.info('Fetching lyrics for ${widget.mediaItem.title}');
    done.value = false;
    lyricsSource.value = '';
    if (widget.offline) {
      Lyrics.getOffLyrics(
        widget.mediaItem.extras!['url'].toString(),
      ).then((value) {
        if (value == '' && widget.getLyricsOnline) {
          Lyrics.getLyrics(
            id: widget.mediaItem.id,
            title: widget.mediaItem.title,
            artist: widget.mediaItem.artist.toString(),
          ).then((Map value) {
            lyrics['lyrics'] = value['lyrics'];
            lyrics['type'] = value['type'];
            lyrics['source'] = value['source'];
            lyrics['id'] = widget.mediaItem.id;
            done.value = true;
            lyricsSource.value = lyrics['source'].toString();
            lyricsReaderModel = LyricsModelBuilder.create()
                .bindLyricToMain(lyrics['lyrics'].toString())
                .getModel();
          });
        } else {
          Logger.root.info('Lyrics found offline');
          lyrics['lyrics'] = value;
          lyrics['type'] = value.startsWith('[00') ? 'lrc' : 'text';
          lyrics['source'] = 'Local';
          lyrics['id'] = widget.mediaItem.id;
          done.value = true;
          lyricsSource.value = lyrics['source'].toString();
          lyricsReaderModel = LyricsModelBuilder.create()
              .bindLyricToMain(lyrics['lyrics'].toString())
              .getModel();
        }
      });
    } else {
      Lyrics.getLyrics(
        id: widget.mediaItem.id,
        title: widget.mediaItem.title,
        artist: widget.mediaItem.artist.toString(),
      ).then((Map value) {
        if (widget.mediaItem.id != value['id']) {
          done.value = true;
          return;
        }
        lyrics['lyrics'] = value['lyrics'];
        lyrics['type'] = value['type'];
        lyrics['source'] = value['source'];
        lyrics['id'] = widget.mediaItem.id;
        done.value = true;
        lyricsSource.value = lyrics['source'].toString();
        lyricsReaderModel = LyricsModelBuilder.create()
            .bindLyricToMain(lyrics['lyrics'].toString())
            .getModel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (flipped && lyrics['id'] != widget.mediaItem.id) {
      fetchLyrics();
    }
    return SizedBox(
      height: widget.width * 0.85,
      width: widget.width * 0.85,
      child: Hero(
        tag: 'currentArtwork',
        child: FlipCard(
          key: widget.cardKey,
          flipOnTouch: false,
          onFlipDone: (value) {
            flipped = value;
            if (flipped && lyrics['id'] != widget.mediaItem.id) {
              fetchLyrics();
            }
          },
          back: GestureDetector(
            onTap: () => widget.cardKey.currentState!.toggleCard(),
            onDoubleTap: () => widget.cardKey.currentState!.toggleCard(),
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 20,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: done,
                        child: const CircularProgressIndicator(),
                        builder: (
                          BuildContext context,
                          bool value,
                          Widget? child,
                        ) {
                          return value
                              ? lyrics['lyrics'] == ''
                                  ? emptyScreen(
                                      context,
                                      0,
                                      ':( ',
                                      100.0,
                                      CustomLocalizations.of(context).lyrics,
                                      60.0,
                                      CustomLocalizations.of(context)
                                          .notAvailable,
                                      20.0,
                                      useWhite: true,
                                    )
                                  : lyrics['type'] == 'text'
                                      ? SelectableText(
                                          lyrics['lyrics'].toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        )
                                      : StreamBuilder<Duration>(
                                          stream: AudioService.position,
                                          builder: (context, snapshot) {
                                            final position =
                                                snapshot.data ?? Duration.zero;
                                            return LyricsReader(
                                              model: lyricsReaderModel,
                                              position: position.inMilliseconds,
                                              lyricUi:
                                                  UINetease(highlight: false),
                                              playing: true,
                                              size: Size(
                                                widget.width * 0.85,
                                                widget.width * 0.85,
                                              ),
                                              emptyBuilder: () => Center(
                                                child: Text(
                                                  'Lyrics Not Found',
                                                  style: lyricUI
                                                      .getOtherMainTextStyle(),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                              : child!;
                        },
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: lyricsSource,
                  child: const CircularProgressIndicator(),
                  builder: (
                    BuildContext context,
                    String value,
                    Widget? child,
                  ) {
                    if (value == '') {
                      return const SizedBox();
                    }
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Powered by $value',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 10.0, color: Colors.white70),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Card(
                    elevation: 10.0,
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Theme.of(context).cardColor.withValues(alpha: 0.6),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      tooltip: CustomLocalizations.of(context).copy,
                      onPressed: () {
                        Feedback.forLongPress(context);
                        copyToClipboard(
                          context: context,
                          text: lyrics['lyrics'].toString(),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      color: Theme.of(context)
                          .iconTheme
                          .color!
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          front: StreamBuilder<QueueState>(
            stream: widget.audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;

              final bool enabled = Hive.box('settings')
                  .get('enableGesture', defaultValue: true) as bool;
              final volumeGestureEnabled = Hive.box('settings')
                  .get('volumeGestureEnabled', defaultValue: false) as bool;

              return ValueListenableBuilder(
                valueListenable: dragging,
                child: StreamBuilder<double>(
                  stream: widget.audioHandler.volume,
                  builder: (context, snapshot) {
                    final double volumeValue = snapshot.data ?? 1.0;
                    return Center(
                      child: SizedBox(
                        width: 60.0,
                        height: widget.width * 0.7,
                        child: Card(
                          color: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: RotatedBox(
                                    quarterTurns: -1,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        thumbShape: HiddenThumbComponentShape(),
                                        activeTrackColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        inactiveTrackColor: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.4),
                                        trackShape:
                                            const RoundedRectSliderTrackShape(),
                                        disabledActiveTrackColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        disabledInactiveTrackColor:
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.4),
                                      ),
                                      child: ExcludeSemantics(
                                        child: Slider(
                                          value:
                                              widget.audioHandler.volume.value,
                                          onChanged: null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 20.0,
                                ),
                                child: Icon(
                                  volumeValue == 0
                                      ? Icons.volume_off_rounded
                                      : volumeValue > 0.6
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_down_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                builder: (context, bool value, Widget? child) {
                  return GestureDetector(
                    onTap: () {
                      if (dragging.value) {
                        dragging.value = false;
                      } else if (enabled) {
                        tapped.value = true;
                        Future.delayed(const Duration(seconds: 3), () async {
                          tapped.value = false;
                        });
                        Feedback.forTap(context);
                      }
                    },
                    onDoubleTapDown: (details) {
                      if (details.globalPosition.dx <= widget.width * 2 / 5) {
                        widget.audioHandler.customAction('rewind');
                        doubletapped.value = -1;
                        Future.delayed(const Duration(milliseconds: 500),
                            () async {
                          doubletapped.value = 0;
                        });
                      }

                      if (details.globalPosition.dx > widget.width * 2 / 5 &&
                          details.globalPosition.dx < widget.width * 3 / 5) {
                        widget.cardKey.currentState!.toggleCard();
                      }

                      if (details.globalPosition.dx >= widget.width * 3 / 5) {
                        widget.audioHandler.customAction('fastForward');
                        doubletapped.value = 1;
                        Future.delayed(const Duration(milliseconds: 500),
                            () async {
                          doubletapped.value = 0;
                        });
                      }

                      Feedback.forLongPress(context);
                    },
                    onHorizontalDragEnd: !enabled
                        ? null
                        : (DragEndDetails details) {
                            if ((details.primaryVelocity ?? 0) > 100) {
                              if (queueState.hasPrevious) {
                                widget.audioHandler.skipToPrevious();
                                Feedback.forTap(context);
                              }
                            } else if ((details.primaryVelocity ?? 0) < -100) {
                              if (queueState.hasNext) {
                                widget.audioHandler.skipToNext();
                                Feedback.forTap(context);
                              }
                            }
                          },
                    onLongPress: !enabled
                        ? null
                        : () {
                            if (!widget.offline) {
                              Feedback.forLongPress(context);
                              AddToPlaylist()
                                  .addToPlaylist(context, widget.mediaItem);
                            }
                          },
                    onVerticalDragStart: enabled && volumeGestureEnabled
                        ? (_) {
                            dragging.value = true;
                          }
                        : null,
                    onVerticalDragEnd: !enabled
                        ? null
                        : (_) {
                            dragging.value = false;
                          },
                    onVerticalDragUpdate: !enabled || !dragging.value
                        ? null
                        : (DragUpdateDetails details) {
                            if (details.delta.dy != 0.0) {
                              double volume = widget.audioHandler.volume.value;
                              volume -= details.delta.dy / 150;
                              if (volume < 0) {
                                volume = 0;
                              }
                              if (volume > 1.0) {
                                volume = 1.0;
                              }
                              widget.audioHandler.setVolume(volume);
                            }
                          },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.mediaItem.artUri
                                  .toString()
                                  .startsWith('file')
                              ? Image(
                                  fit: BoxFit.contain,
                                  width: widget.width * 0.85,
                                  gaplessPlayback: true,
                                  errorBuilder: (
                                    BuildContext context,
                                    Object exception,
                                    StackTrace? stackTrace,
                                  ) {
                                    return const Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage('assets/cover.jpg'),
                                    );
                                  },
                                  image: FileImage(
                                    File(
                                      widget.mediaItem.artUri!.toFilePath(),
                                    ),
                                  ),
                                )
                              : CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  errorWidget: (BuildContext context, _, __) =>
                                      const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                  placeholder: (BuildContext context, _) =>
                                      const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                  imageUrl: widget.mediaItem.artUri.toString(),
                                  width: widget.width * 0.85,
                                ),
                        ),
                        Visibility(
                          visible: value,
                          child: child!,
                        ),
                        ValueListenableBuilder(
                          valueListenable: tapped,
                          child: GestureDetector(
                            onTap: () {
                              tapped.value = false;
                            },
                            child: Card(
                              color: Colors.black26,
                              elevation: 0.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: IconButton(
                                          tooltip:
                                              CustomLocalizations.of(context)
                                                  .songInfo,
                                          onPressed: () {
                                            showSongInfo(
                                              widget.mediaItem,
                                              context,
                                            );
                                          },
                                          icon: const Icon(Icons.info_rounded),
                                          color:
                                              Theme.of(context).iconTheme.color,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: IconButton(
                                              onPressed: () {
                                                tapped.value = false;
                                                dragging.value = true;
                                              },
                                              icon: const Icon(
                                                Icons.volume_up_rounded,
                                              ),
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: IconButton(
                                              tooltip: CustomLocalizations.of(
                                                      context)
                                                  .addToPlaylist,
                                              onPressed: () {
                                                AddToPlaylist().addToPlaylist(
                                                  context,
                                                  widget.mediaItem,
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.playlist_add_rounded,
                                              ),
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          builder: (context, bool value, Widget? child) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Visibility(visible: value, child: child!),
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: doubletapped,
                          child: const Icon(
                            Icons.forward_10_rounded,
                            size: 60.0,
                          ),
                          builder: (
                            BuildContext context,
                            int value,
                            Widget? child,
                          ) {
                            return Visibility(
                              visible: value != 0,
                              child: Card(
                                color: Colors.transparent,
                                elevation: 0.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox.expand(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: value == 1
                                            ? [
                                                Colors.transparent,
                                                Colors.black
                                                    .withValues(alpha: 0.4),
                                                Colors.black
                                                    .withValues(alpha: 0.7),
                                              ]
                                            : [
                                                Colors.black
                                                    .withValues(alpha: 0.7),
                                                Colors.black
                                                    .withValues(alpha: 0.4),
                                                Colors.transparent,
                                              ],
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Visibility(
                                          visible: value == -1,
                                          child: const Icon(
                                            Icons.replay_10_rounded,
                                            size: 60.0,
                                          ),
                                        ),
                                        const SizedBox(),
                                        Visibility(
                                          visible: value == 1,
                                          child: child!,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
