import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:oryn/index.dart';

class SettingsPage extends StatefulWidget {
  final Function? callback;
  const SettingsPage({super.key, this.callback});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  final ValueNotifier<Map<String, dynamic>?> selected =
      ValueNotifier<Map<String, dynamic>?>(null);
  final List sectionsToShow = Hive.box('settings').get(
    'sectionsToShow',
    defaultValue: ['Home', 'Top Charts', 'YouTube', 'Library'],
  ) as List;

  @override
  void dispose() {
    controller.dispose();
    searchQuery.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => sectionsToShow.contains('Settings');

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: homeDrawer(
            context: context,
            padding: const EdgeInsets.only(left: 15.0),
          ),
          title: Text(
            CustomLocalizations.of(context).settings,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: Column(
          children: [
            //_searchBar(context),
            Expanded(child: _settingsItem(context)),
          ],
        ),
      ),
    );
  }

  /* Widget _searchBar(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      elevation: 2.0,
      child: SizedBox(
        height: 55.0,
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: searchQuery,
            builder: (BuildContext context, String query, Widget? child) {
              return TextField(
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.5,
                      color: Colors.transparent,
                    ),
                  ),
                  fillColor: Theme.of(context).colorScheme.secondary,
                  prefixIcon: const Icon(CupertinoIcons.search),
                  suffixIcon: query.trim() != ''
                      ? IconButton(
                          onPressed: () {
                            controller.clear();
                            searchQuery.value = '';
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  border: InputBorder.none,
                  hintText: CustomLocalizations.of(context).search,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                onChanged: (_) {
                  searchQuery.value = controller.text.trim();
                },
              );
            },
          ),
        ),
      ),
    );
  }
 */

  Widget _settingsItem(BuildContext context) {
    final List<Map<String, dynamic>> settingsList = [
      {
        'title': CustomLocalizations.of(
          context,
        ).theme,
        'icon': MdiIcons.themeLightDark,
        'onTap': ThemePage(
          callback: widget.callback,
        ),
        'isThreeLine': true,
        'items': [
          CustomLocalizations.of(context).darkMode,
          CustomLocalizations.of(context).accent,
          CustomLocalizations.of(context).useSystemTheme,
          CustomLocalizations.of(context).bgGrad,
          CustomLocalizations.of(context).cardGrad,
          CustomLocalizations.of(context).bottomGrad,
          CustomLocalizations.of(context).canvasColor,
          CustomLocalizations.of(context).cardColor,
          CustomLocalizations.of(context).useAmoled,
          CustomLocalizations.of(context).currentTheme,
          CustomLocalizations.of(context).saveTheme,
        ],
      },
      {
        'title': CustomLocalizations.of(
          context,
        ).ui,
        'icon': Icons.design_services_rounded,
        'onTap': AppUIPage(
          callback: widget.callback,
        ),
        'isThreeLine': true,
        'items': [
          CustomLocalizations.of(context).playerScreenBackground,
          CustomLocalizations.of(context).miniButtons,
          CustomLocalizations.of(context).useDenseMini,
          CustomLocalizations.of(context).blacklistedHomeSections,
          CustomLocalizations.of(context).changeOrder,
          CustomLocalizations.of(context).compactNotificationButtons,
          CustomLocalizations.of(context).showPlaylists,
          CustomLocalizations.of(context).showLast,
          CustomLocalizations.of(context).navTabs,
          CustomLocalizations.of(context).enableGesture,
          CustomLocalizations.of(context).volumeGestureEnabled,
          CustomLocalizations.of(context).useLessDataImage,
        ],
      },
      {
        'title': CustomLocalizations.of(
          context,
        ).musicPlayback,
        'icon': Icons.music_note_rounded,
        'onTap': MusicPlaybackPage(
          callback: widget.callback,
        ),
        'isThreeLine': true,
        'items': [
          CustomLocalizations.of(context).musicLang,
          CustomLocalizations.of(context).streamQuality,
          CustomLocalizations.of(context).chartLocation,
          CustomLocalizations.of(context).streamWifiQuality,
          CustomLocalizations.of(context).ytStreamQuality,
          CustomLocalizations.of(context).loadLast,
          CustomLocalizations.of(context).resetOnSkip,
          CustomLocalizations.of(context).enforceRepeat,
          CustomLocalizations.of(context).autoplay,
          CustomLocalizations.of(context).cacheSong,
        ],
      },
      {
        'title': CustomLocalizations.of(
          context,
        ).down,
        'icon': Icons.download_done_rounded,
        'onTap': const DownloadPage(),
        'isThreeLine': true,
        'items': [
          CustomLocalizations.of(context).downQuality,
          CustomLocalizations.of(context).downLocation,
          CustomLocalizations.of(context).downFilename,
          CustomLocalizations.of(context).ytDownQuality,
          CustomLocalizations.of(context).createAlbumFold,
          CustomLocalizations.of(context).createYtFold,
          CustomLocalizations.of(context).downLyrics,
        ],
      },
      {
        'title': CustomLocalizations.of(
          context,
        ).others,
        'icon': Icons.miscellaneous_services_rounded,
        'onTap': const PreferencesPage(),
        'isThreeLine': true,
        'items': [
          CustomLocalizations.of(context).lang,
          CustomLocalizations.of(context).includeExcludeFolder,
          CustomLocalizations.of(context).minAudioLen,
          CustomLocalizations.of(context).liveSearch,
          CustomLocalizations.of(context).useDown,
          CustomLocalizations.of(context).getLyricsOnline,
          CustomLocalizations.of(context).supportEq,
          CustomLocalizations.of(context).stopOnClose,
          CustomLocalizations.of(context).checkUpdate,
          CustomLocalizations.of(context).useProxy,
          CustomLocalizations.of(context).proxySet,
          CustomLocalizations.of(context).clearCache,
          CustomLocalizations.of(context).shareLogs,
        ],
      },
      {
        'title': CustomLocalizations.of(
          context,
        ).backNRest,
        'icon': Icons.settings_backup_restore_rounded,
        'onTap': const BackupAndRestorePage(),
        'isThreeLine': false,
        'items': [
          CustomLocalizations.of(context).createBack,
          CustomLocalizations.of(context).restore,
          CustomLocalizations.of(context).autoBack,
          CustomLocalizations.of(context).autoBackLocation,
        ],
      },
      {
        'title': CustomLocalizations.of(
          context,
        ).about,
        'icon': Icons.info_outline_rounded,
        'onTap': const AboutPage(),
        'isThreeLine': false,
        'items': [
          CustomLocalizations.of(context).version,
          CustomLocalizations.of(context).shareApp,
          CustomLocalizations.of(context).contactUs,
          CustomLocalizations.of(context).likedWork,
          CustomLocalizations.of(context).donateGpay,
          CustomLocalizations.of(context).joinTg,
          CustomLocalizations.of(context).moreInfo,
        ],
      },
    ];

    final List<Map> searchOptions = [];
    for (final Map e in settingsList) {
      for (final item in e['items'] as List) {
        searchOptions.add({'title': item, 'route': e['onTap']});
      }
    }

    final bool isRotated =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    // Add a PageController instance
    final PageController pageController = PageController();

    return Stack(
      children: [
        PageView(
          controller: pageController,
          children: [
            ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 15.0,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: settingsList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: SizedBox.square(
                    dimension: 40,
                    child: Icon(settingsList[index]['icon'] as IconData),
                  ),
                  title: Text(settingsList[index]['title'].toString()),
                  subtitle: Text(
                    (settingsList[index]['items'] as List).take(3).join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: !isRotated &&
                      (settingsList[index]['isThreeLine'] as bool? ?? false),
                  onTap: () {
                    searchQuery.value = '';
                    controller.text = '';
                    selected.value = settingsList[index];
                    pageController.nextPage(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: selected,
              builder: (context, value, child) {
                if (value == null) return const SizedBox();
                return value['onTap'] is Widget
                    ? value['onTap'] as Widget
                    : const SizedBox();
              },
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: searchQuery,
          builder: (BuildContext context, String query, Widget? child) {
            if (query != '') {
              final List<Map> results = _getSearchResults(searchOptions, query);
              return _searchSuggestions(context, results);
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  List<Map> _getSearchResults(
    List<Map> searchOptions,
    String query,
  ) {
    final String lowerQuery = query.toLowerCase();
    final List<Map> options = lowerQuery != ''
        ? searchOptions
            .where(
              (element) => element['title']
                  .toString()
                  .toLowerCase()
                  .contains(lowerQuery),
            )
            .toList()
        : List.empty();
    return options;
  }

  Widget _searchSuggestions(
    BuildContext context,
    List<Map> options,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      elevation: 8.0,
      child: SizedBox(
        height: options.length * 70,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 10, top: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: options.length,
          itemExtent: 70,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(options[index]['title'].toString()),
              onTap: () {
                searchQuery.value = '';
                controller.text = '';
                selected.value = options[index]['route'];
              },
            );
          },
        ),
      ),
    );
  }
}
