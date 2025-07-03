/* // ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
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
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemCount: data.isEmpty ? 2 : lists.length,
      itemBuilder: (context, idx) {
        if (idx == recentIndex) {
          return Recents(context);
        }
        if (idx == playlistIndex &&
            playlistNames.isNotEmpty &&
            playlistDetails.isNotEmpty) {
          return Playlists(context, boxSize);
        }
        return null;
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
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      child: Column(
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
              widget.onItemTapped(3); // Navigate to now playing page
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
      ),
      builder: (BuildContext context, Box box, Widget? child) {
        return (recentList.isEmpty ||
                !(box.get('showRecent', defaultValue: true) as bool))
            ? const SizedBox()
            : child!;
      },
    );
  }
}
 */
