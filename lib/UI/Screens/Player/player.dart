import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:oryn/index.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'halfDark')
      .toString();
  final bool getLyricsOnline =
      Hive.box('settings').get('getLyricsOnline', defaultValue: true) as bool;

  final MyTheme currentTheme = GetIt.I<MyTheme>();
  final ValueNotifier<List<Color?>?> gradientColor =
      ValueNotifier<List<Color?>?>(GetIt.I<MyTheme>().playGradientColor);
  final PanelController _panelController = PanelController();
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late Duration _time;

  bool isSharePopupShown = false;

  void sleepTimer(int time) {
    audioHandler.customAction('sleepTimer', {'time': time});
  }

  void sleepCounter(int count) {
    audioHandler.customAction('sleepCounter', {'count': count});
  }

  Future<dynamic> setTimer(
    BuildContext context,
    BuildContext? scaffoldContext,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Center(
            child: Text(
              CustomLocalizations.of(context).selectDur,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    primaryColor: Theme.of(context).colorScheme.secondary,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      _time = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sleepTimer(0);
                    Navigator.pop(context);
                  },
                  child: Text(CustomLocalizations.of(context).cancel),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor:
                        Theme.of(context).colorScheme.secondary == Colors.white
                            ? Colors.black
                            : Colors.white,
                  ),
                  onPressed: () {
                    sleepTimer(_time.inMinutes);
                    Navigator.pop(context);
                    ShowSnackBar().showSnackBar(
                      context,
                      '${CustomLocalizations.of(context).sleepTimerSetFor} ${_time.inMinutes} ${CustomLocalizations.of(context).minutes}',
                    );
                  },
                  child: Text(CustomLocalizations.of(context).ok),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> setCounter() async {
    showTextInputDialog(
      context: context,
      title: CustomLocalizations.of(context).enterSongsCount,
      initialText: '',
      keyboardType: TextInputType.number,
      onSubmitted: (String value, BuildContext context) {
        sleepCounter(
          int.parse(value),
        );
        Navigator.pop(context);
        ShowSnackBar().showSnackBar(
          context,
          '${CustomLocalizations.of(context).sleepTimerSetFor} $value ${CustomLocalizations.of(context).songs}',
        );
      },
    );
  }

  void updateBackgroundColors(List<Color?> value) {
    gradientColor.value = value;
    return;
  }

  String format(String msg) {
    return '${msg[0].toUpperCase()}${msg.substring(1)}'.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? scaffoldContext;

    return Dismissible(
      direction: DismissDirection.down,
      background: const ColoredBox(color: Colors.transparent),
      key: const Key('playScreen'),
      onDismissed: (direction) {
        Navigator.pop(context);
      },
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final MediaItem? mediaItem = snapshot.data;
          if (mediaItem == null) return const SizedBox();
          final offline =
              !mediaItem.extras!['url'].toString().startsWith('http');
          if (mediaItem.artUri != null && mediaItem.artUri.toString() != '') {
            mediaItem.artUri.toString().startsWith('file')
                ? getColors(
                    imageProvider: FileImage(
                      File(
                        mediaItem.artUri!.toFilePath(),
                      ),
                    ),
                    // useDominantAndDarkerColors: gradientType == 'halfLight' ||
                    //     gradientType == 'fullLight' ||
                    //     gradientType == 'fullMix',
                  ).then((value) => updateBackgroundColors(value))
                : getColors(
                    imageProvider: CachedNetworkImageProvider(
                      mediaItem.artUri.toString(),
                    ),
                    // useDominantAndDarkerColors: gradientType == 'halfLight' ||
                    //     gradientType == 'fullLight' ||
                    //     gradientType == 'fullMix',
                  ).then((value) => updateBackgroundColors(value));
          }
          return ValueListenableBuilder(
            valueListenable: gradientColor,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.expand_more_rounded),
                    tooltip: CustomLocalizations.of(context).back,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.lyrics_rounded),
                      //     Image.asset(
                      //   'assets/lyrics.png',
                      // ),
                      tooltip: CustomLocalizations.of(context).lyrics,
                      onPressed: () => cardKey.currentState!.toggleCard(),
                    ),
                    if (!offline)
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        tooltip: CustomLocalizations.of(context).share,
                        onPressed: () async {
                          if (!isSharePopupShown) {
                            isSharePopupShown = true;

                            await Share.share(
                              mediaItem.extras!['perma_url'].toString(),
                            ).whenComplete(() {
                              Timer(const Duration(milliseconds: 600), () {
                                isSharePopupShown = false;
                              });
                            });
                          }
                        },
                      ),
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      onSelected: (int? value) {
                        if (value == 10) {
                          showSongInfo(mediaItem, context);
                        }
                        if (value == 5) {
                          showBottomSheet(
                            context: context,
                            builder: (context) => SongsListPage(
                              listItem: {
                                'type': 'album',
                                'id': mediaItem.extras?['album_id'],
                                'title': mediaItem.album,
                                'image': mediaItem.artUri,
                              },
                            ),
                          );
                        }
                        if (value == 4) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Equalizer();
                            },
                          );
                        }
                        if (value == 3) {
                          launchUrl(
                            Uri.parse(
                              mediaItem.genre == 'YouTube'
                                  ? 'https://youtube.com/watch?v=${mediaItem.id}'
                                  : 'https://www.youtube.com/results?search_query=${mediaItem.title} by ${mediaItem.artist}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                        if (value == 1) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                title: Text(
                                  CustomLocalizations.of(context).sleepTimer,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(10.0),
                                children: [
                                  ListTile(
                                    title: Text(
                                      CustomLocalizations.of(context).sleepDur,
                                    ),
                                    subtitle: Text(
                                      CustomLocalizations.of(context)
                                          .sleepDurSub,
                                    ),
                                    dense: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setTimer(
                                        context,
                                        scaffoldContext,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    title: Text(
                                      CustomLocalizations.of(context)
                                          .sleepAfter,
                                    ),
                                    subtitle: Text(
                                      CustomLocalizations.of(context)
                                          .sleepAfterSub,
                                    ),
                                    dense: true,
                                    isThreeLine: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      setCounter();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        if (value == 0) {
                          AddToPlaylist().addToPlaylist(context, mediaItem);
                        }
                      },
                      itemBuilder: (context) => offline
                          ? [
                              if (mediaItem.extras?['album_id'] != null)
                                PopupMenuItem(
                                  value: 5,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.album_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        CustomLocalizations.of(context)
                                            .viewAlbum,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.timer,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      CustomLocalizations.of(context)
                                          .sleepTimer,
                                    ),
                                  ],
                                ),
                              ),
                              if (Hive.box('settings').get(
                                'supportEq',
                                defaultValue: false,
                              ) as bool)
                                PopupMenuItem(
                                  value: 4,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.equalizer_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        CustomLocalizations.of(context)
                                            .equalizer,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 10,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      CustomLocalizations.of(context).songInfo,
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          : [
                              if (mediaItem.extras?['album_id'] != null)
                                PopupMenuItem(
                                  value: 5,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.album_rounded,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        CustomLocalizations.of(context)
                                            .viewAlbum,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.playlist_add_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      CustomLocalizations.of(context)
                                          .addToPlaylist,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.timer,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      CustomLocalizations.of(context)
                                          .sleepTimer,
                                    ),
                                  ],
                                ),
                              ),
                              if (Hive.box('settings').get(
                                'supportEq',
                                defaultValue: false,
                              ) as bool)
                                PopupMenuItem(
                                  value: 4,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.equalizer_rounded,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        CustomLocalizations.of(context)
                                            .equalizer,
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    Icon(
                                      MdiIcons.youtube,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      mediaItem.genre == 'YouTube'
                                          ? CustomLocalizations.of(
                                              context,
                                            ).watchVideo
                                          : CustomLocalizations.of(
                                              context,
                                            ).searchVideo,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 10,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_rounded,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      CustomLocalizations.of(context).songInfo,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                    ),
                  ],
                ),
                body: LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                  ) {
                    if (constraints.maxWidth > constraints.maxHeight) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Artwork
                          ArtWorkWidget(
                            cardKey: cardKey,
                            mediaItem: mediaItem,
                            width: min(
                              constraints.maxHeight / 0.9,
                              constraints.maxWidth / 1.8,
                            ),
                            audioHandler: audioHandler,
                            offline: offline,
                            getLyricsOnline: getLyricsOnline,
                          ),

                          // title and controls
                          NameNControls(
                            mediaItem: mediaItem,
                            offline: offline,
                            width: constraints.maxWidth / 2,
                            height: constraints.maxHeight,
                            panelController: _panelController,
                            audioHandler: audioHandler,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        // Artwork
                        ArtWorkWidget(
                          cardKey: cardKey,
                          mediaItem: mediaItem,
                          width: constraints.maxWidth,
                          audioHandler: audioHandler,
                          offline: offline,
                          getLyricsOnline: getLyricsOnline,
                        ),

                        // title and controls
                        NameNControls(
                          mediaItem: mediaItem,
                          offline: offline,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight -
                              (constraints.maxWidth * 0.85),
                          panelController: _panelController,
                          audioHandler: audioHandler,
                        ),
                      ],
                    );
                  },
                ),
                // }
              ),
            ),
            builder:
                (BuildContext context, List<Color?>? value, Widget? child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: gradientType == 'simple'
                        ? Alignment.topLeft
                        : Alignment.topCenter,
                    end: gradientType == 'simple'
                        ? Alignment.bottomRight
                        : (gradientType == 'halfLight' ||
                                gradientType == 'halfDark')
                            ? Alignment.center
                            : Alignment.bottomCenter,
                    colors: gradientType == 'simple'
                        ? Theme.of(context).brightness == Brightness.dark
                            ? currentTheme.getBackGradient()
                            : [
                                const Color(0xfff5f9ff),
                                Colors.white,
                              ]
                        : Theme.of(context).brightness == Brightness.dark
                            ? [
                                if (gradientType == 'halfDark' ||
                                    gradientType == 'fullDark')
                                  value?[1] ?? Colors.grey[900]!
                                else
                                  value?[0] ?? Colors.grey[900]!,
                                if (gradientType == 'fullMix')
                                  value?[1] ?? Colors.black
                                else
                                  Colors.black,
                              ]
                            : [
                                value?[0] ?? const Color(0xfff5f9ff),
                                Colors.white,
                              ],
                  ),
                ),
                child: child,
              );
            },
          );
          // );
        },
      ),
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class QueueState {
  static const QueueState empty =
      QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
    this.queue,
    this.queueIndex,
    this.shuffleIndices,
    this.repeatMode,
  );

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
}
