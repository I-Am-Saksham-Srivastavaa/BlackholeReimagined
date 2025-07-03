// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:oryn/index.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Base extends StatefulWidget {
  const Base({super.key});

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<Source> source = ValueNotifier<Source>(Source.Spotify);
  String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: true) as bool;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  DateTime? backButtonPressTime;
  final bool useDense =
      Hive.box('settings').get('useDenseMini', defaultValue: false) as bool;

  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<PlaylistModel> playlistDetails = [];

  void callback() {
    onItemTapped(0);
    setState(() {});
  }

  // ignore: use_setters_to_change_properties
  void onItemTapped(int index) {
    _selectedIndex.value = index;
  }

  Future<bool> handleWillPop(BuildContext? context) async {
    if (context == null) return false;
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        CustomLocalizations.of(context).exitConfirm,
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  void checkVersion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appVersion = packageInfo.version;

      if (checkUpdate) {
        Logger.root.info('Checking for update');
        GitHub.getLatestVersion().then((String version) async {
          if (compareVersion(
            version,
            appVersion!,
          )) {
            Logger.root.info('Update available');
            ShowSnackBar().showSnackBar(
              context,
              CustomLocalizations.of(context).updateAvailable,
              duration: const Duration(seconds: 15),
              action: SnackBarAction(
                textColor: Theme.of(context).colorScheme.secondary,
                label: CustomLocalizations.of(context).update,
                onPressed: () async {
                  String arch = '';
                  if (Platform.isAndroid) {
                    List? abis = await Hive.box('settings').get('supportedAbis')
                        as List?;

                    if (abis == null) {
                      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                      final AndroidDeviceInfo androidDeviceInfo =
                          await deviceInfo.androidInfo;
                      abis = androidDeviceInfo.supportedAbis;
                      await Hive.box('settings').put('supportedAbis', abis);
                    }
                    if (abis.contains('arm64')) {
                      arch = 'arm64';
                    } else if (abis.contains('armeabi')) {
                      arch = 'armeabi';
                    }
                  }
                  Logger.root.info('Arch: $arch');
                  Logger.root.info(
                    'Latest Version: $version',
                  );
                  Logger.root.info(
                    'Current Version: $appVersion',
                  );
                },
              ),
            );
          } else {
            Logger.root.info('No update available');
          }
        });
      }
      if (autoBackup) {
        final List<String> checked = [
          CustomLocalizations.of(
            context,
          ).settings,
          CustomLocalizations.of(
            context,
          ).downs,
          CustomLocalizations.of(
            context,
          ).playlists,
        ];
        final List playlistNames = Hive.box('settings').get(
          'playlistNames',
          defaultValue: ['Favorite Songs'],
        ) as List;
        final Map<String, List> boxNames = {
          CustomLocalizations.of(
            context,
          ).settings: ['settings'],
          CustomLocalizations.of(
            context,
          ).cache: ['cache'],
          CustomLocalizations.of(
            context,
          ).downs: ['downloads'],
          CustomLocalizations.of(
            context,
          ).playlists: playlistNames,
        };
        final String autoBackPath = Hive.box('settings').get(
          'autoBackPath',
          defaultValue: '',
        ) as String;
        if (autoBackPath == '') {
          ExtStorageProvider.getExtStorage(
            dirName: 'BlackHole/Backups',
            writeAccess: true,
          ).then((value) {
            Hive.box('settings').put('autoBackPath', value);
            createBackup(
              context,
              checked,
              boxNames,
              path: value,
              fileName: 'BlackHole_AutoBackup',
              showDialog: false,
            );
          });
        } else {
          createBackup(
            context,
            checked,
            boxNames,
            path: autoBackPath,
            fileName: 'BlackHole_AutoBackup',
            showDialog: false,
          ).then(
            (value) => {
              if (value.contains('No such file or directory'))
                {
                  ExtStorageProvider.getExtStorage(
                    dirName: 'BlackHole/Backups',
                    writeAccess: true,
                  ).then(
                    (value) {
                      Hive.box('settings').put('autoBackPath', value);
                      createBackup(
                        context,
                        checked,
                        boxNames,
                        path: value,
                        fileName: 'BlackHole_AutoBackup',
                      );
                    },
                  ),
                },
            },
          );
        }
      }
    });
    downloadChecker();
  }

  final PageController _pageController = PageController();
  //final PersistentTabController _controller = PersistentTabController();

  @override
  void initState() {
    super.initState();
    // Ensure the Hive box is opened before accessing it
    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings').then((_) {
        setState(() {}); // Rebuild the widget after the box is opened
      });
    }
    checkVersion();
  }

  @override
  void dispose() {
    //_controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool rotated = MediaQuery.sizeOf(context).height < screenWidth;
    final isNotMobile =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    //final double screenHeight = MediaQuery.sizeOf(context).height;
    //final miniplayer = MiniPlayer();
    var drawerEdgeDragWidth = rotated ? screenWidth * 0.3 : screenWidth * 0.5;
    return GradientContainer(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final shouldPop = await handleWillPop(context);
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Colors.transparent,
          body: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rotated) NavRail(),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder:
                      (BuildContext context, int indexValue, Widget? child) {
                    switch (_selectedIndex.value) {
                      case 0:
                        return HomeScreen(
                            source: source, onItemTapped: onItemTapped);
                      case 1:
                        return PlaylistScreen();
                      case 2:
                        return FavouritePage(
                          playlistName: 'Favorite Songs',
                          showName: CustomLocalizations.of(context).favSongs,
                        );
                      case 3:
                        return PageView(
                          children: [NowPlaying(), const RecentlyPlayed()],
                        );
                      case 4:
                        return isNotMobile
                            ? const DownloadedSongsDesktop()
                            : const DownloadedSongs(showPlaylists: true);
                      case 5:
                        return const Downloads();
                      case 6:
                        return SettingsPage(callback: callback);
                      case 7:
                        return const YouTube();
                      default:
                        return Center(
                          child: Text(
                            CustomLocalizations.of(context).notAvailable,
                          ),
                        );
                    }
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [MiniPlayer(), NavBar()],
            ),
          ),
          drawer: CustomDrawer(),
          drawerEdgeDragWidth:
              drawerEdgeDragWidth, // Adjusted for better usability
          endDrawer: CustomEndDrawer(),
          endDrawerEnableOpenDragGesture: false,
          //floatingActionButton: FAB(),
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: true,
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget NavRail() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return ValueListenableBuilder(
      valueListenable: _selectedIndex,
      builder: (BuildContext context, int indexValue, Widget? child) {
        return NavigationRail(
          minWidth: 70.0,
          groupAlignment: 0.0,
          backgroundColor: Theme.of(context).cardColor,
          selectedIndex: indexValue < 0 || indexValue >= 4 ? 3 : indexValue,
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                onItemTapped(0);
              case 1:
                onItemTapped(1);
              case 2:
                onItemTapped(2);
              case 3:
                onItemTapped(4);
              default:
              // Do nothing or handle invalid index if needed
            }
          },
          labelType: screenWidth > 1050
              ? NavigationRailLabelType.selected
              : NavigationRailLabelType.none,
          selectedLabelTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: Theme.of(context).iconTheme.color,
          ),
          selectedIconTheme: Theme.of(context).iconTheme.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
          unselectedIconTheme: Theme.of(context).iconTheme,
          useIndicator: screenWidth < 1050,
          indicatorColor: Theme.of(context).colorScheme.secondary.withAlpha(50),
          leading: homeDrawer(
            context: context,
            padding: const EdgeInsets.symmetric(vertical: 5.0),
          ),
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.home_rounded),
              label: Text(CustomLocalizations.of(context).home),
              selectedIcon: const Icon(Icons.home_outlined),
            ),
            NavigationRailDestination(
              icon: const Icon(MdiIcons.youtube),
              label: Text(CustomLocalizations.of(context).youTube),
              selectedIcon: const Icon(MdiIcons.youtubeTv),
            ),
            NavigationRailDestination(
              icon: const Icon(MdiIcons.spotify),
              label: Text(CustomLocalizations.of(context).spotify),
              selectedIcon: const Icon(MdiIcons.spotify),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.bookmark),
              label: Text(CustomLocalizations.of(context).library),
              selectedIcon: const Icon(Icons.bookmark_outline),
            ),
          ],
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget CustomDrawer() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: screenWidth,
      child: GradientContainer(
        child: CustomScrollView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              elevation: 0,
              stretch: true,
              expandedHeight: MediaQuery.sizeOf(context).height * 0.2,
              flexibleSpace: FlexibleSpaceBar(
                title: RichText(
                  text: TextSpan(
                    text: CustomLocalizations.of(context).appTitle,
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w600,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: appVersion == null ? 'custom' : '\nv$appVersion',
                        style: const TextStyle(
                          fontSize: 7.0,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.end,
                ),
                titlePadding: const EdgeInsets.only(bottom: 40.0),
                centerTitle: true,
                background: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ).createShader(
                      Rect.fromLTRB(0, 0, rect.width, rect.height),
                    );
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image(
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    image: AssetImage(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/header-dark.jpg'
                          : 'assets/header-dark.jpg',
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  ValueListenableBuilder(
                    valueListenable: _selectedIndex,
                    builder: (
                      BuildContext context,
                      int snapshot,
                      Widget? child,
                    ) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              CustomLocalizations.of(context).home,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 0
                                ? const Icon(
                                    Icons.home_outlined,
                                  )
                                : const Icon(Icons.home),
                            selected: _selectedIndex.value == 0,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(0);
                              Navigator.pop(context);
                            },
                            trailing: ValueListenableBuilder<Source>(
                              valueListenable: source,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        source.value = Source.Spotify;

                                        Logger.root
                                            .info('Source changed to Spotify');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.spotify,
                                          color: value == Source.Spotify
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color
                                                  ?.withValues(alpha: 0.2),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        source.value = Source.YouTube;
                                        Logger.root
                                            .info('Source changed to YouTube');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.youtube,
                                          color: value == Source.YouTube
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color
                                                  ?.withValues(alpha: 0.2),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        source.value = Source.YouTubeMusic;
                                        Logger.root.info(
                                            'Source changed to YouTube Music');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.youtubeTv,
                                          color: value == Source.YouTubeMusic
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color
                                                  ?.withValues(alpha: 0.2),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              CustomLocalizations.of(context).playlists,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 1
                                ? const Icon(
                                    Icons.web_stories_outlined,
                                  )
                                : const Icon(Icons.web_stories),
                            selected: _selectedIndex.value == 1,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(1);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(CustomLocalizations.of(context).like),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 2
                                ? const Icon(
                                    Icons.favorite_outline,
                                  )
                                : const Icon(Icons.favorite),
                            selected: _selectedIndex.value == 2,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(2);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title:
                                Text(CustomLocalizations.of(context).youTube),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 7
                                ? const Icon(
                                    MdiIcons.youtubeTv,
                                  )
                                : const Icon(MdiIcons.youtube),
                            selected: _selectedIndex.value == 7,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(7);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(
                              CustomLocalizations.of(context).nowPlaying,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 4
                                ? const Icon(
                                    Icons.vertical_distribute_outlined,
                                  )
                                : const Icon(Icons.vertical_distribute),
                            selected: _selectedIndex.value == 4,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(3);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title:
                                Text(CustomLocalizations.of(context).spotify),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: const Icon(MdiIcons.spotify),
                            selected: _selectedIndex.value == 8,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(8);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(CustomLocalizations.of(context).local),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 4
                                ? const Icon(Icons.download_outlined)
                                : const Icon(Icons.download),
                            selected: _selectedIndex.value == 4,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(4);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title:
                                Text(CustomLocalizations.of(context).library),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 5
                                ? const Icon(
                                    Icons.bookmark_outline,
                                  )
                                : const Icon(Icons.bookmark),
                            selected: _selectedIndex.value == 5,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(5);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title:
                                Text(CustomLocalizations.of(context).settings),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            leading: _selectedIndex.value == 6
                                ? const Icon(
                                    Icons.settings_outlined,
                                  )
                                : const Icon(Icons.settings_rounded),
                            selected: _selectedIndex.value == 6,
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                            onTap: () {
                              onItemTapped(6);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            ValueListenableBuilder<Source>(
                              valueListenable: source,
                              builder: (context, value, child) {
                                return Text.rich(
                                  TextSpan(
                                    text:
                                        '${CustomLocalizations.of(context).source} '
                                        '${value == Source.Spotify ? CustomLocalizations.of(context).spotify : value == Source.YouTube ? CustomLocalizations.of(context).youTube : CustomLocalizations.of(context).youTubeMusic}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              CustomLocalizations.of(context).remadeBy,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              CustomLocalizations.of(context).madeBy,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget CustomEndDrawer() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Drawer(width: screenWidth, child: PlayScreen());
  }

  // ignore: non_constant_identifier_names
  Widget NavBar() {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool rotated = MediaQuery.sizeOf(context).height < screenWidth;
    if (!rotated) {
      return ValueListenableBuilder(
        valueListenable: _selectedIndex,
        builder: (BuildContext context, int indexValue, Widget? child) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  // Swipe left
                  if (_selectedIndex.value < 7) {
                    onItemTapped(_selectedIndex.value + 1);
                  }
                } else if (details.primaryVelocity! > 0) {
                  // Swipe right
                  if (_selectedIndex.value > 0) {
                    onItemTapped(_selectedIndex.value - 1);
                  }
                }
              }
            },
            child: SizedBox(
              height: 76,
              child: BottomNavigationBar(
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(),
                selectedIconTheme: Theme.of(context)
                    .iconTheme
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
                unselectedIconTheme: Theme.of(context).iconTheme,
                selectedItemColor: Theme.of(context).colorScheme.secondary,
                unselectedItemColor: Theme.of(context).iconTheme.color,
                currentIndex:
                    (_selectedIndex.value >= 0 && _selectedIndex.value < 7)
                        ? _selectedIndex.value
                        : 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    activeIcon: const Icon(Icons.home_outlined),
                    label: CustomLocalizations.of(context).home,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.web_stories),
                    activeIcon: const Icon(Icons.web_stories_outlined),
                    label: CustomLocalizations.of(context).playlists,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.favorite),
                    activeIcon: const Icon(Icons.favorite_border),
                    label: CustomLocalizations.of(context).like,
                  ),
                  // Removed case 3 (YouTube)
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.vertical_distribute),
                    activeIcon: const Icon(Icons.vertical_distribute_outlined),
                    label: CustomLocalizations.of(context).nowPlaying,
                  ),
                  // Removed case 5 (Spotify)
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.download),
                    activeIcon: const Icon(Icons.download_outlined),
                    label: CustomLocalizations.of(context).local,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.bookmark),
                    activeIcon: const Icon(Icons.bookmark_outline),
                    label: CustomLocalizations.of(context).saved,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    activeIcon: const Icon(Icons.settings_outlined),
                    label: CustomLocalizations.of(context).settings,
                  ),
                ],
                onTap: (int index) {
                  onItemTapped(index);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink(); // Return an empty widget for rotated case
    }
  }
/* 
  // ignore: non_constant_identifier_names
  Widget FAB() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, index, _) {
        switch (index) {
          case 0:
            // Home page FAB
            return FloatingActionButton(
              onPressed: () {
                // TODO: implement home page action
              },
              child: const Icon(Icons.search),
            );
          case 1:
            // Playlists page FAB
            return FloatingActionButton(
              onPressed: () {
                // TODO: create a new playlist
              },
              child: const Icon(Icons.playlist_add),
            );
          case 2:
            // Favourites page FAB
            return FloatingActionButton(
              onPressed: () {
                // TODO: add current song to favourites
              },
              child: const Icon(Icons.favorite),
            );
          // add more cases as needed...
          default:
            // No FAB on other pages
            return const SizedBox.shrink();
        }
      },
    );
  }
 */
}
