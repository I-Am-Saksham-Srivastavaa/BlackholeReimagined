import 'dart:io';
import 'package:oryn/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NowPlayingStream extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final ScrollController? scrollController;
  final PanelController? panelController;
  final bool head;
  final double headHeight;

  const NowPlayingStream({
    super.key,
    required this.audioHandler,
    this.scrollController,
    this.panelController,
    this.head = false,
    this.headHeight = 50,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
      stream: audioHandler.queueState,
      builder: (context, snapshot) {
        final queueState = snapshot.data ?? QueueState.empty;
        final queue = queueState.queue;
        final int queueStateIndex = queueState.queueIndex ?? 0;

        return ReorderableListView.builder(
          header: SizedBox(
            height: head ? headHeight : 0,
          ),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex--;
            }
            audioHandler.moveQueueItem(
              queueStateIndex + oldIndex,
              queueStateIndex + newIndex,
            );
          },
          scrollController: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 10),
          shrinkWrap: true,
          itemCount: queue.length - queueStateIndex,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(
                '${queue[queueStateIndex + index].id}#${queueStateIndex + index}',
              ),
              direction: (queueStateIndex + index) == queueState.queueIndex
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
                  selected: queueStateIndex + index == queueState.queueIndex,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: (queueStateIndex + index == queueState.queueIndex)
                        ? [
                            IconButton(
                              icon: const Icon(
                                Icons.bar_chart_rounded,
                              ),
                              tooltip: CustomLocalizations.of(context).playing,
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
                                  'duration': queue[queueStateIndex + index]
                                      .duration!
                                      .inSeconds
                                      .toString(),
                                  'title': queue[queueStateIndex + index].title,
                                  'url': queue[queueStateIndex + index]
                                      .extras?['url']
                                      .toString(),
                                  'year': queue[queueStateIndex + index]
                                      .extras?['year']
                                      .toString(),
                                  'language': queue[queueStateIndex + index]
                                      .extras?['language']
                                      .toString(),
                                  'genre': queue[queueStateIndex + index]
                                      .genre
                                      ?.toString(),
                                  '320kbps': queue[queueStateIndex + index]
                                      .extras?['320kbps'],
                                  'has_lyrics': queue[queueStateIndex + index]
                                      .extras?['has_lyrics'],
                                  'release_date': queue[queueStateIndex + index]
                                      .extras?['release_date'],
                                  'album_id': queue[queueStateIndex + index]
                                      .extras?['album_id'],
                                  'subtitle': queue[queueStateIndex + index]
                                      .extras?['subtitle'],
                                  'perma_url': queue[queueStateIndex + index]
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
                              child: const Icon(Icons.drag_handle_rounded),
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
                                    CustomLocalizations.of(context).addedBy,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 5.0,
                                    ),
                                  ),
                                ),
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    CustomLocalizations.of(context).autoplay,
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
                        child: (queue[queueStateIndex + index].artUri == null)
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
                                            (BuildContext context, _, __) =>
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
                                        imageUrl: queue[queueStateIndex + index]
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
              ),
            );
          },
        );
      },
    );
  }
}
