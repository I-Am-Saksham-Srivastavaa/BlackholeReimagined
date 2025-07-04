import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:hive/hive.dart';

class RecentlyPlayed extends StatefulWidget {
  const RecentlyPlayed({super.key});

  @override
  _RecentlyPlayedState createState() => _RecentlyPlayedState();
}

class _RecentlyPlayedState extends State<RecentlyPlayed> {
  List _songs = [];
  bool added = false;

  Future<void> getSongs() async {
    _songs = Hive.box('cache').get('recentSongs', defaultValue: []) as List;
    added = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!added) {
      getSongs();
    }

    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(CustomLocalizations.of(context).lastSession),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Hive.box('cache').put('recentSongs', []);
                setState(() {
                  _songs = [];
                });
              },
              tooltip: CustomLocalizations.of(context).clearAll,
              icon: const Icon(Icons.clear_all_rounded),
            ),
          ],
        ),
        body: _songs.isEmpty
            ? emptyScreen(
                context,
                3,
                CustomLocalizations.of(context).nothingTo,
                15,
                CustomLocalizations.of(context).showHere,
                50.0,
                CustomLocalizations.of(context).playSomething,
                23.0,
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                shrinkWrap: true,
                itemCount: _songs.length,
                itemExtent: 70.0,
                itemBuilder: (context, index) {
                  return _songs.isEmpty
                      ? const SizedBox()
                      : Dismissible(
                          key: Key(_songs[index]['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: const ColoredBox(
                            color: Colors.redAccent,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete_outline_rounded),
                                ],
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            _songs.removeAt(index);
                            setState(() {});
                            Hive.box('cache').put('recentSongs', _songs);
                          },
                          child: ListTile(
                            leading: imageCard(
                              imageUrl: _songs[index]['image'].toString(),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // DownloadButton(
                                //   data: _songs[index] as Map,
                                //   icon: 'download',
                                // ),
                                LikeButton(
                                  mediaItem: null,
                                  data: _songs[index] as Map,
                                ),
                              ],
                            ),
                            title: Text(
                              '${_songs[index]["title"]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_songs[index]["artist"]}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              PlayerInvoke.init(
                                songsList: _songs,
                                index: index,
                                isOffline: false,
                              );
                            },
                          ),
                        );
                },
              ),
      ),
    );
  }
}
