import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:hive/hive.dart';

class SongsList extends StatefulWidget {
  final List data;
  final bool offline;
  final String? title;
  const SongsList({
    super.key,
    required this.data,
    required this.offline,
    this.title,
  });
  @override
  _SongsListState createState() => _SongsListState();
}

class _SongsListState extends State<SongsList> {
  List _songs = [];
  List original = [];
  bool offline = false;
  bool added = false;
  bool processStatus = false;
  int sortValue = Hive.box('settings').get('sortValue', defaultValue: 1) as int;
  int orderValue =
      Hive.box('settings').get('orderValue', defaultValue: 1) as int;

  Future<void> getSongs() async {
    added = true;
    _songs = widget.data;
    offline = widget.offline;
    if (!offline) original = List.from(_songs);

    sortSongs(sortVal: sortValue, order: orderValue);

    processStatus = true;
    setState(() {});
  }

  void sortSongs({required int sortVal, required int order}) {
    switch (sortVal) {
      case 0:
        _songs.sort(
          (a, b) => a['title']
              .toString()
              .toUpperCase()
              .compareTo(b['title'].toString().toUpperCase()),
        );
      case 1:
        _songs.sort(
          (a, b) => a['dateAdded']
              .toString()
              .toUpperCase()
              .compareTo(b['dateAdded'].toString().toUpperCase()),
        );
      case 2:
        _songs.sort(
          (a, b) => a['album']
              .toString()
              .toUpperCase()
              .compareTo(b['album'].toString().toUpperCase()),
        );
      case 3:
        _songs.sort(
          (a, b) => a['artist']
              .toString()
              .toUpperCase()
              .compareTo(b['artist'].toString().toUpperCase()),
        );
      case 4:
        _songs.sort(
          (a, b) => a['duration']
              .toString()
              .toUpperCase()
              .compareTo(b['duration'].toString().toUpperCase()),
        );
      default:
        _songs.sort(
          (b, a) => a['dateAdded']
              .toString()
              .toUpperCase()
              .compareTo(b['dateAdded'].toString().toUpperCase()),
        );
        break;
    }

    if (order == 1) {
      _songs = _songs.reversed.toList();
    }
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
          title: Text(widget.title ?? CustomLocalizations.of(context).songs),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.sort_rounded),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              onSelected: (int value) {
                if (value < 5) {
                  sortValue = value;
                  Hive.box('settings').put('sortValue', value);
                } else {
                  orderValue = value - 5;
                  Hive.box('settings').put('orderValue', orderValue);
                }
                sortSongs(sortVal: sortValue, order: orderValue);
                setState(() {});
              },
              itemBuilder: (context) {
                final List<String> sortTypes = [
                  CustomLocalizations.of(context).displayName,
                  CustomLocalizations.of(context).dateAdded,
                  CustomLocalizations.of(context).album,
                  CustomLocalizations.of(context).artist,
                  CustomLocalizations.of(context).duration,
                ];
                final List<String> orderTypes = [
                  CustomLocalizations.of(context).inc,
                  CustomLocalizations.of(context).dec,
                ];
                final menuList = <PopupMenuEntry<int>>[];
                menuList.addAll(
                  sortTypes
                      .map(
                        (e) => PopupMenuItem(
                          value: sortTypes.indexOf(e),
                          child: Row(
                            children: [
                              if (sortValue == sortTypes.indexOf(e))
                                Icon(
                                  Icons.check_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.grey[700],
                                )
                              else
                                const SizedBox(),
                              const SizedBox(width: 10),
                              Text(
                                e,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
                menuList.add(
                  const PopupMenuDivider(
                    height: 10,
                  ),
                );
                menuList.addAll(
                  orderTypes
                      .map(
                        (e) => PopupMenuItem(
                          value: sortTypes.length + orderTypes.indexOf(e),
                          child: Row(
                            children: [
                              if (orderValue == orderTypes.indexOf(e))
                                Icon(
                                  Icons.check_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.grey[700],
                                )
                              else
                                const SizedBox(),
                              const SizedBox(width: 10),
                              Text(
                                e,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
                return menuList;
              },
            ),
          ],
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
        ),
        body: !processStatus
            ? const Center(
                child: CircularProgressIndicator(),
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
                      : ListTile(
                          leading: imageCard(
                            localImage: offline,
                            imageUrl: offline
                                ? _songs[index]['image'].toString()
                                : _songs[index]['image'].toString(),
                          ),
                          title: Text(
                            '${_songs[index]['title']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_songs[index]['artist']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            PlayerInvoke.init(
                              songsList: _songs,
                              index: index,
                              isOffline: offline,
                              fromDownloads: offline,
                              recommend: !offline,
                            );
                          },
                        );
                },
              ),
      ),
    );
  }
}
