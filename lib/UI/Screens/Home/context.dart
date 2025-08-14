// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oryn/index.dart';
import 'package:hive_flutter/hive_flutter.dart';

bool fetched = false;
List preferredLangs = Hive.box('settings')
    .get('preferredLanguage', defaultValue: ['Hindi']) as List;
List likedRadio =
    Hive.box('settings').get('likedRadio', defaultValue: []) as List;
Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
List lists = ['recent', 'playlist', ...?data['collections'] as List?];

class HomeContext extends StatefulWidget {
  const HomeContext({
    super.key,
    required this.onItemTapped,
  });
  final void Function(int) onItemTapped;
  @override
  _HomeContextState createState() => _HomeContextState();
}

class _HomeContextState extends State<HomeContext>
    with AutomaticKeepAliveClientMixin<HomeContext> {
  final ScrollController scrollController = ScrollController();
  List recentList =
      Hive.box('cache').get('recentSongs', defaultValue: []) as List;
  Map likedArtists =
      Hive.box('settings').get('likedArtists', defaultValue: {}) as Map;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  int recentIndex = 0;
  int playlistIndex = 1;

  String getSubTitle(Map item) {
    final type = item['type'];
    switch (type) {
      case 'charts':
        return '';
      case 'radio_station':
        return 'Radio • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'JioSaavn' : item['subtitle']?.toString().unescape()}';
      case 'playlist':
        return 'Playlist • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'JioSaavn' : item['subtitle'].toString().unescape()}';
      case 'song':
        return 'Single • ${item['artist']?.toString().unescape()}';
      case 'mix':
        return 'Mix • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'JioSaavn' : item['subtitle'].toString().unescape()}';
      case 'show':
        return 'Podcast • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'JioSaavn' : item['subtitle'].toString().unescape()}';
      case 'album':
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        if (artists != null) {
          return 'Album • ${artists?.join(', ')?.toString().unescape()}';
        } else if (item['subtitle'] != null && item['subtitle'] != '') {
          return 'Album • ${item['subtitle']?.toString().unescape()}';
        }
        return 'Album';
      default:
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        return artists?.join(', ')?.toString().unescape() ?? '';
    }
  }

  int likedCount() {
    return Hive.box('Favorite Songs').length;
  }

  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double boxSize =
        MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).height / 2.5;
    if (boxSize > 250) boxSize = 250;
    if (playlistNames.length >= 3) {
      recentIndex = 0;
      playlistIndex = 1;
    } else {
      recentIndex = 1;
      playlistIndex = 0;
    }

    // Calculate total item count including queue sections
    int totalItems = data.isEmpty ? 2 : lists.length;
    totalItems += 2; // Add NextFive and UpNextQueue sections

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemCount: totalItems,
      itemBuilder: (context, idx) {
        if (idx == recentIndex) {
          return Recents(context);
        }
        if (idx == playlistIndex &&
            playlistNames.isNotEmpty &&
            playlistDetails.isNotEmpty) {
          return Playlists(context, boxSize);
        }
        // Handle queue sections when audioHandler is available
        // This assumes audioHandler is always available
        int queueStartIndex = data.isEmpty ? 2 : lists.length;
        if (idx == queueStartIndex) {
          return NextFive(audioHandler);
        }
        // // Uncomment this if you want to show UpNextQueue
        /* 
        if (idx == queueStartIndex + 1) {
          return UpNextQueue(audioHandler);
        } */

        // Handle other data sections
        if (data.isNotEmpty && idx < lists.length) {
          // Handle other collections from data
          // This would need to be implemented based on your data structure
        }

        return const SizedBox.shrink();
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> Playlists(
      BuildContext context, double boxSize) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      child: Column(
        children: [
          GestureDetector(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: Text(
                    CustomLocalizations.of(context).yourPlaylists,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {},
          ),
          SizedBox(
            height: boxSize + 15,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: playlistNames.length,
              itemBuilder: (context, index) {
                final String name = playlistNames[index].toString();
                final String showName = playlistDetails.containsKey(name)
                    ? playlistDetails[name]['name']?.toString() ?? name
                    : name;
                final String? subtitle = playlistDetails[name] == null ||
                        playlistDetails[name]['count'] == null ||
                        playlistDetails[name]['count'] == 0
                    ? null
                    : '${playlistDetails[name]['count']} ${CustomLocalizations.of(context).songs}';
                if (playlistDetails[name] == null ||
                    playlistDetails[name]['count'] == null ||
                    playlistDetails[name]['count'] == 0) {
                  return const SizedBox();
                }
                return GestureDetector(
                  child: SizedBox(
                    width: boxSize - 20,
                    child: HoverBox(
                      child: Collage(
                        borderRadius: 10.0,
                        imageList: playlistDetails[name]['imagesList'] as List,
                        showGrid: true,
                        placeholderImage: 'assets/cover.jpg',
                      ),
                      builder: ({
                        required BuildContext context,
                        required bool isHover,
                        Widget? child,
                      }) {
                        return Card(
                          color: isHover ? null : Colors.transparent,
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              SizedBox.square(
                                dimension:
                                    isHover ? boxSize - 25 : boxSize - 30,
                                child: child,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      showName,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (subtitle != null && subtitle.isNotEmpty)
                                      Text(
                                        subtitle,
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .color,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  onTap: () async {
                    await Hive.openBox(name);
                    widget.onItemTapped(1); // Navigate to playlists page
                    showBottomSheet(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: FavouritePage(
                              playlistName: name,
                              showName: playlistDetails.containsKey(name)
                                  ? playlistDetails[name]['name']?.toString() ??
                                      name
                                  : name,
                            ),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
      builder: (BuildContext context, Box box, Widget? child) {
        return (playlistNames.isEmpty ||
                !(box.get('showPlaylist', defaultValue: true) as bool) ||
                (playlistNames.length == 1 &&
                    playlistNames.first == 'Favorite Songs' &&
                    likedCount() == 0))
            ? const SizedBox()
            : child!;
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> Recents(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: Hive.box('settings').listenable(),
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem, // ✅ Listen to mediaItem changes
        builder: (context, snapshot) {
          final currentMediaItem = snapshot.data;

          if (currentMediaItem != null &&
              !recentList.any((item) => item['id'] == currentMediaItem.id)) {
            recentList.insert(
                0, MediaItemConverter.mediaItemToMap(currentMediaItem));

            if (recentList.length > 30) {
              recentList = recentList.sublist(0, 30);
            }
          }

          return Column(
            children: [
              GestureDetector(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                      child: Text(
                        CustomLocalizations.of(context).lastSession,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  widget.onItemTapped(3); // Navigate to now playing
                },
              ),
              HorizontalAlbumsListSeparated(
                songsList: recentList,
                onTap: (int idx) {
                  PlayerInvoke.init(
                    songsList: [recentList[idx]],
                    index: 0,
                    isOffline: false,
                  );
                },
              ),
            ],
          );
        },
      ),
      builder: (BuildContext context, Box box, Widget? child) {
        final showRecent = box.get('showRecent', defaultValue: true) as bool;
        return (recentList.isEmpty || !showRecent)
            ? const SizedBox.shrink()
            : child!;
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> NextFive(dynamic audioHandler) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      child: StreamBuilder<QueueState>(
        stream: audioHandler.queueState,
        builder: (context, snapshot) {
          final queueState = snapshot.data ?? QueueState.empty;
          final queue = queueState.queue;
          final int queueStateIndex = queueState.queueIndex ?? 0;
          final upcoming = queue
              .skip(queueStateIndex + 1)
              .take(5)
              .toList(); // Exclude current track
          late bool head = false;
          return Column(children: [
            GestureDetector(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Text(
                      CustomLocalizations.of(context).playNext,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                widget.onItemTapped(3); // Navigate to now playing
              },
            ),
            ReorderableListView.builder(
              header: SizedBox(
                height: head ? 50 : 0,
              ),
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex--;
                }
                audioHandler.moveQueueItem(
                  queueStateIndex + 1 + oldIndex,
                  queueStateIndex + 1 + newIndex,
                );
              },
              scrollController: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 10),
              shrinkWrap: true,
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                return Dismissible(
                    key: ValueKey(
                      '${upcoming[index].id}#${queueStateIndex + 1 + index}',
                    ),
                    direction:
                        (queueStateIndex + 1 + index) == queueState.queueIndex
                            ? DismissDirection.none
                            : DismissDirection.horizontal,
                    onDismissed: (dir) {
                      audioHandler
                          .removeQueueItemAt(queueStateIndex + 1 + index);
                    },
                    child: ListTileTheme(
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 16.0, right: 10.0),
                        selected: queueStateIndex + 1 + index ==
                            queueState.queueIndex,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: (queueStateIndex + 1 + index ==
                                  queueState.queueIndex)
                              ? [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.bar_chart_rounded,
                                    ),
                                    tooltip:
                                        CustomLocalizations.of(context).playing,
                                    onPressed: () {},
                                  ),
                                ]
                              : [
                                  if (upcoming[index]
                                      .extras!['url']
                                      .toString()
                                      .startsWith('http')) ...[
                                    LikeButton(
                                      mediaItem: upcoming[index],
                                    ),
                                    DownloadButton(
                                      icon: 'download',
                                      size: 25.0,
                                      data: {
                                        'id': upcoming[index].id,
                                        'artist':
                                            upcoming[index].artist.toString(),
                                        'album':
                                            upcoming[index].album.toString(),
                                        'image':
                                            upcoming[index].artUri.toString(),
                                        'duration': upcoming[index]
                                            .duration!
                                            .inSeconds
                                            .toString(),
                                        'title': upcoming[index].title,
                                        'url': upcoming[index]
                                            .extras?['url']
                                            .toString(),
                                        'year': upcoming[index]
                                            .extras?['year']
                                            .toString(),
                                        'language': upcoming[index]
                                            .extras?['language']
                                            .toString(),
                                        'genre':
                                            upcoming[index].genre?.toString(),
                                        '320kbps':
                                            upcoming[index].extras?['320kbps'],
                                        'has_lyrics': upcoming[index]
                                            .extras?['has_lyrics'],
                                        'release_date': upcoming[index]
                                            .extras?['release_date'],
                                        'album_id':
                                            upcoming[index].extras?['album_id'],
                                        'subtitle':
                                            upcoming[index].extras?['subtitle'],
                                        'perma_url': upcoming[index]
                                            .extras?['perma_url'],
                                      },
                                    ),
                                  ],
                                  ReorderableDragStartListener(
                                    key: Key(
                                      '${upcoming[index].id}#${queueStateIndex + 1 + index}',
                                    ),
                                    index: index,
                                    enabled: (queueStateIndex + 1 + index) !=
                                        queueState.queueIndex,
                                    child:
                                        const Icon(Icons.drag_handle_rounded),
                                  ),
                                ],
                        ),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (upcoming[index].extras?['addedByAutoplay']
                                    as bool? ??
                                false)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          CustomLocalizations.of(context)
                                              .addedBy,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 5.0,
                                          ),
                                        ),
                                      ),
                                      RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          CustomLocalizations.of(context)
                                              .autoplay,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 8.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                ],
                              ),
                            Card(
                              elevation: 5,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (upcoming[index].artUri == null)
                                  ? const SizedBox.square(
                                      dimension: 50,
                                      child: Image(
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                    )
                                  : SizedBox.square(
                                      dimension: 50,
                                      child: upcoming[index]
                                              .artUri
                                              .toString()
                                              .startsWith('file:')
                                          ? Image(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                File(
                                                  upcoming[index]
                                                      .artUri!
                                                      .toFilePath(),
                                                ),
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (BuildContext context, _,
                                                          __) =>
                                                      const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'assets/cover.jpg',
                                                ),
                                              ),
                                              placeholder:
                                                  (BuildContext context, _) =>
                                                      const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'assets/cover.jpg',
                                                ),
                                              ),
                                              imageUrl: upcoming[index]
                                                  .artUri
                                                  .toString(),
                                            ),
                                    ),
                            ),
                          ],
                        ),
                        title: Text(
                          upcoming[index].title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: queueStateIndex + 1 + index ==
                                    queueState.queueIndex
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          upcoming[index].artist!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          audioHandler
                              .skipToQueueItem(queueStateIndex + 1 + index);
                        },
                      ),
                    ));
              },
            )
          ]);
        },
      ),
      builder: (BuildContext context, Box box, Widget? child) {
        return (box.get('showNextFive', defaultValue: true) as bool)
            ? child!
            : const SizedBox();
      },
    );
  }

  ValueListenableBuilder<Box<dynamic>> UpNextQueue(dynamic audioHandler) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      child: StreamBuilder<QueueState>(
        stream: audioHandler.queueState,
        builder: (context, snapshot) {
          final queueState = snapshot.data ?? QueueState.empty;
          final queue = queueState.queue;
          final int queueStateIndex = queueState.queueIndex ?? 0;
          final upcomingQueue =
              queue.skip(queueStateIndex + 1).toList(); // Exclude current track
          return Column(children: [
            GestureDetector(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Text(
                      CustomLocalizations.of(context).upNext,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                widget.onItemTapped(3); // Navigate to now playing
              },
            ),
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 10),
              shrinkWrap: true,
              itemCount: upcomingQueue.length,
              itemBuilder: (context, index) {
                return Dismissible(
                    key: ValueKey(
                      '${queue[queueStateIndex + index].id}#${queueStateIndex + index}',
                    ),
                    direction:
                        (queueStateIndex + index) == queueState.queueIndex
                            ? DismissDirection.none
                            : DismissDirection.horizontal,
                    onDismissed: (dir) {
                      audioHandler.removeQueueItemAt(queueStateIndex + index);
                    },
                    child: ListTileTheme(
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 16.0, right: 10.0),
                        selected:
                            queueStateIndex + index == queueState.queueIndex,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: (queueStateIndex + index ==
                                  queueState.queueIndex)
                              ? [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.bar_chart_rounded,
                                    ),
                                    tooltip:
                                        CustomLocalizations.of(context).playing,
                                    onPressed: () {},
                                  ),
                                ]
                              : [
                                  if (queue[queueStateIndex + index]
                                      .extras!['url']
                                      .toString()
                                      .startsWith('http')) ...[
                                    LikeButton(
                                      mediaItem: queue[queueStateIndex + index],
                                    ),
                                    DownloadButton(
                                      icon: 'download',
                                      size: 25.0,
                                      data: {
                                        'id': queue[queueStateIndex + index].id,
                                        'artist': queue[queueStateIndex + index]
                                            .artist
                                            .toString(),
                                        'album': queue[queueStateIndex + index]
                                            .album
                                            .toString(),
                                        'image': queue[queueStateIndex + index]
                                            .artUri
                                            .toString(),
                                        'duration':
                                            queue[queueStateIndex + index]
                                                .duration!
                                                .inSeconds
                                                .toString(),
                                        'title': queue[queueStateIndex + index]
                                            .title,
                                        'url': queue[queueStateIndex + index]
                                            .extras?['url']
                                            .toString(),
                                        'year': queue[queueStateIndex + index]
                                            .extras?['year']
                                            .toString(),
                                        'language':
                                            queue[queueStateIndex + index]
                                                .extras?['language']
                                                .toString(),
                                        'genre': queue[queueStateIndex + index]
                                            .genre
                                            ?.toString(),
                                        '320kbps':
                                            queue[queueStateIndex + index]
                                                .extras?['320kbps'],
                                        'has_lyrics':
                                            queue[queueStateIndex + index]
                                                .extras?['has_lyrics'],
                                        'release_date':
                                            queue[queueStateIndex + index]
                                                .extras?['release_date'],
                                        'album_id':
                                            queue[queueStateIndex + index]
                                                .extras?['album_id'],
                                        'subtitle':
                                            queue[queueStateIndex + index]
                                                .extras?['subtitle'],
                                        'perma_url':
                                            queue[queueStateIndex + index]
                                                .extras?['perma_url'],
                                      },
                                    ),
                                  ],
                                  ReorderableDragStartListener(
                                    key: Key(
                                      '${queue[queueStateIndex + index].id}#${queueStateIndex + index}',
                                    ),
                                    index: index,
                                    enabled: (queueStateIndex + index) !=
                                        queueState.queueIndex,
                                    child:
                                        const Icon(Icons.drag_handle_rounded),
                                  ),
                                ],
                        ),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (queue[queueStateIndex + index]
                                    .extras?['addedByAutoplay'] as bool? ??
                                false)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          CustomLocalizations.of(context)
                                              .addedBy,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 5.0,
                                          ),
                                        ),
                                      ),
                                      RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          CustomLocalizations.of(context)
                                              .autoplay,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 8.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                ],
                              ),
                            Card(
                              elevation: 5,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (queue[queueStateIndex + index].artUri ==
                                      null)
                                  ? const SizedBox.square(
                                      dimension: 50,
                                      child: Image(
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                    )
                                  : SizedBox.square(
                                      dimension: 50,
                                      child: queue[queueStateIndex + index]
                                              .artUri
                                              .toString()
                                              .startsWith('file:')
                                          ? Image(
                                              fit: BoxFit.cover,
                                              image: FileImage(
                                                File(
                                                  queue[queueStateIndex + index]
                                                      .artUri!
                                                      .toFilePath(),
                                                ),
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (BuildContext context, _,
                                                          __) =>
                                                      const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'assets/cover.jpg',
                                                ),
                                              ),
                                              placeholder:
                                                  (BuildContext context, _) =>
                                                      const Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                  'assets/cover.jpg',
                                                ),
                                              ),
                                              imageUrl:
                                                  queue[queueStateIndex + index]
                                                      .artUri
                                                      .toString(),
                                            ),
                                    ),
                            ),
                          ],
                        ),
                        title: Text(
                          queue[queueStateIndex + index].title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                queueStateIndex + index == queueState.queueIndex
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          queue[queueStateIndex + index].artist!,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          audioHandler.skipToQueueItem(queueStateIndex + index);
                        },
                      ),
                    ));
              },
            )
          ]);
        },
      ),
      builder: (BuildContext context, Box box, Widget? child) {
        return (box.get('showUpNextQueue', defaultValue: true) as bool)
            ? child!
            : const SizedBox();
      },
    );
  }
}
