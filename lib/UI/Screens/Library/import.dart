import 'package:app_links/app_links.dart';

import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportPlaylist extends StatelessWidget {
  ImportPlaylist({super.key});

  final Box settingsBox = Hive.box('settings');
  final List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];

  void _triggerImport({required String type, required BuildContext context}) {
    switch (type) {
      case 'file':
        importFile(
          context,
          playlistNames,
          settingsBox,
        );
      case 'youtube':
        importYt(
          context,
          playlistNames,
          settingsBox,
        );
      case 'spotify':
        connectToSpotify(
          context,
          playlistNames,
          settingsBox,
        );
      case 'youtube-link':
        importYtViaLink(
          context,
          playlistNames,
          settingsBox,
        );
      case 'jiosaavn':
        importJioSaavn(
          context,
          playlistNames,
          settingsBox,
        );
      case 'resso':
        importResso(
          context,
          playlistNames,
          settingsBox,
        );
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> workingImports = [
      {
        'title': CustomLocalizations.of(context).importFile,
        'icon': MdiIcons.import,
        'type': 'file',
      },
    ];

    final List<Map<String, dynamic>> underDevelopmentImports = [
      {
        'title': CustomLocalizations.of(context).importSpotify,
        'icon': MdiIcons.spotify,
        'type': 'spotify',
      },
      {
        'title': 'YouTube via Link',
        'icon': MdiIcons.youtubeSubscription,
        'type': 'youtube-link',
      },
      {
        'title': 'YouTube Playlist',
        'icon': MdiIcons.youtube,
        'type': 'youtube',
      },
      {
        'title': CustomLocalizations.of(context).importJioSaavn,
        'icon': Icons.music_note_rounded,
        'type': 'jiosaavn',
      },
      {
        'title': CustomLocalizations.of(context).importResso,
        'icon': Icons.music_note_rounded,
        'type': 'resso',
      },
    ];

    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        // Working Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Working',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...workingImports.map((import) => ListTile(
              title: Text(import['title']),
              leading: SizedBox.square(
                dimension: 50,
                child: Center(
                  child: Icon(
                    import['icon'],
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
              onTap: () {
                _triggerImport(
                  type: import['type'],
                  context: context,
                );
              },
            )),

        // Under Development Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Under Development',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...underDevelopmentImports.map((import) => ListTile(
              title: Text(
                import['title'],
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
              subtitle: Text(
                'Coming Soon',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontSize: 12,
                ),
              ),
              leading: SizedBox.square(
                dimension: 50,
                child: Center(
                  child: Icon(
                    import['icon'],
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ),
              enabled: false,
            )),
      ],
    );
  }
}

Future<void> importFile(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  await importFilePlaylist(context, playlistNames);
}

Future<void> connectToSpotify(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  final String? accessToken = await retriveAccessToken();

  if (accessToken == null) {
    launchUrl(
      Uri.parse(
        SpotifyApi().requestAuthorization(),
      ),
      mode: LaunchMode.externalApplication,
    );
    final appLinks = AppLinks();
    appLinks.allUriLinkStream.listen(
      (uri) async {
        final link = uri.toString();
        if (link.contains('code=')) {
          final code = link.split('code=')[1];
          settingsBox.put('spotifyAppCode', code);
          final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
          final List<String> data =
              await SpotifyApi().getAccessToken(code: code);
          if (data.isNotEmpty) {
            settingsBox.put('spotifyAccessToken', data[0]);
            settingsBox.put('spotifyRefreshToken', data[1]);
            settingsBox.put(
              'spotifyTokenExpireAt',
              currentTime + int.parse(data[2]),
            );
            await fetchPlaylists(
              data[0],
              context,
              playlistNames,
              settingsBox,
            );
          }
        }
      },
    );
  } else {
    await fetchPlaylists(
      accessToken,
      context,
      playlistNames,
      settingsBox,
    );
  }
}

Future<void> importYt(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  showTextInputDialog(
    context: context,
    title: CustomLocalizations.of(context).enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (String value, BuildContext context) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addYtPlaylist(link);
      if (data.isNotEmpty) {
        if (data['songs'] == null || data['songs'].length == 0) {
          Logger.root.severe(
            'Failed to import YT playlist. Data not empty but title or the count is empty.',
          );
          ShowSnackBar().showSnackBar(
            context,
            '${CustomLocalizations.of(context).failedImport}\n${CustomLocalizations.of(context).confirmViewable}',
            duration: const Duration(seconds: 3),
          );
        } else {
          await addPlaylist(data['name'].toString(), data['songs'] as List);

          // await SearchAddPlaylist.showProgress(
          //   (data['songs'] as List).length,
          //   context,
          //   SearchAddPlaylist.ytSongsAdder(
          //     data['name'].toString(),
          //     data['songs'] as List,
          //   ),
          // );
        }
      } else {
        Logger.root.severe(
          'Failed to import YT playlist. Data is empty.',
        );
        ShowSnackBar().showSnackBar(
          context,
          CustomLocalizations.of(context).failedImport,
        );
      }
    },
  );
}

Future<void> importYtViaLink(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  showTextInputDialog(
    context: context,
    title: CustomLocalizations.of(context).enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (String value, BuildContext context) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addYtPlaylist(link);
      if (data.isNotEmpty) {
        if (data['songs'] == null || data['songs'].length == 0) {
          Logger.root.severe(
            'Failed to import YT playlist via link. Data not empty but title or the count is empty.',
          );
          ShowSnackBar().showSnackBar(
            context,
            '${CustomLocalizations.of(context).failedImport}\n${CustomLocalizations.of(context).confirmViewable}',
            duration: const Duration(seconds: 3),
          );
        } else {
          await addPlaylist(data['name'].toString(), data['songs'] as List);
        }
      } else {
        Logger.root.severe(
          'Failed to import YT playlist via link. Data is empty.',
        );
        ShowSnackBar().showSnackBar(
          context,
          CustomLocalizations.of(context).failedImport,
        );
      }
    },
  );
}

Future<void> importResso(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  showTextInputDialog(
    context: context,
    title: CustomLocalizations.of(context).enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (String value, BuildContext context) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addRessoPlaylist(link);
      if (data.isNotEmpty) {
        String playName = data['title'].toString();
        while (playlistNames.contains(playName) ||
            await Hive.boxExists(playName)) {
          // ignore: use_string_buffers
          playName = '$playName (1)';
        }
        playlistNames.add(playName);
        settingsBox.put(
          'playlistNames',
          playlistNames,
        );

        await SearchAddPlaylist.showProgress(
          data['count'] as int,
          context,
          SearchAddPlaylist.ressoSongsAdder(
            playName,
            data['tracks'] as List,
          ),
        );
      } else {
        Logger.root.severe(
          'Failed to import Resso playlist. Data is empty.',
        );
        ShowSnackBar().showSnackBar(
          context,
          CustomLocalizations.of(context).failedImport,
        );
      }
    },
  );
}

Future<void> importSpotify(
  BuildContext context,
  String accessToken,
  String playlistId,
  String playlistName,
  Box settingsBox,
  List playlistNames,
) async {
  final Map data = await SearchAddPlaylist.addSpotifyPlaylist(
    playlistName,
    accessToken,
    playlistId,
  );
  if (data.isNotEmpty &&
      data['tracks'] != null &&
      (data['tracks'] as List).isNotEmpty) {
    String playName = data['title'].toString();
    while (playlistNames.contains(playName) || await Hive.boxExists(playName)) {
      // ignore: use_string_buffers
      playName = '$playName (1)';
    }
    playlistNames.add(playName);
    settingsBox.put(
      'playlistNames',
      playlistNames,
    );

    await SearchAddPlaylist.showProgress(
      data['count'] as int,
      context,
      SearchAddPlaylist.spotifySongsAdder(
        playName,
        data['tracks'] as List,
      ),
    );
  } else {
    Logger.root.severe(
      'Failed to import Spotify playlist. Data is empty.',
    );
    ShowSnackBar().showSnackBar(
      context,
      CustomLocalizations.of(context).failedImport,
    );
  }
}

Future<void> importSpotifyViaLink(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
  String accessToken,
) async {
  showTextInputDialog(
    context: context,
    title: CustomLocalizations.of(context).enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (String value, BuildContext ctxt) async {
      Navigator.pop(ctxt);
      final String playlistId = value.split('?')[0].split('/').last;
      final playlistName = CustomLocalizations.of(context).spotifyPublic;
      await importSpotify(
        context,
        accessToken,
        playlistId,
        playlistName,
        settingsBox,
        playlistNames,
      );
    },
  );
}

Future<void> importJioSaavn(
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  showTextInputDialog(
    context: context,
    title: CustomLocalizations.of(context).enterPlaylistLink,
    initialText: '',
    keyboardType: TextInputType.url,
    onSubmitted: (String value, BuildContext context) async {
      final String link = value.trim();
      Navigator.pop(context);
      final Map data = await SearchAddPlaylist.addJioSaavnPlaylist(
        link,
      );

      if (data.isNotEmpty) {
        final String playName = data['title'].toString();
        await addPlaylist(playName, data['tracks'] as List);
        playlistNames.add(playName);
      } else {
        Logger.root.severe('Failed to import JioSaavn playlist. data is empty');
        ShowSnackBar().showSnackBar(
          context,
          CustomLocalizations.of(context).failedImport,
        );
      }
    },
  );
}

Future<void> fetchPlaylists(
  String accessToken,
  BuildContext context,
  List playlistNames,
  Box settingsBox,
) async {
  final List spotifyPlaylists =
      await SpotifyApi().getUserPlaylists(accessToken);
  showModalBottomSheet(
    isDismissible: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext contxt) {
      return BottomGradientContainer(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          itemCount: spotifyPlaylists.length + 1,
          itemBuilder: (ctxt, idx) {
            if (idx == 0) {
              return ListTile(
                title: Text(
                  CustomLocalizations.of(context).importPublicPlaylist,
                ),
                leading: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: Colors.transparent,
                  child: SizedBox.square(
                    dimension: 50,
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  await importSpotifyViaLink(
                    context,
                    playlistNames,
                    settingsBox,
                    accessToken,
                  );
                  Navigator.pop(context);
                },
              );
            }

            final String playName = spotifyPlaylists[idx - 1]['name']
                .toString()
                .replaceAll('/', ' ');
            final int playTotal =
                spotifyPlaylists[idx - 1]['tracks']['total'] as int;
            return playTotal == 0
                ? const SizedBox()
                : ListTile(
                    title: Text(playName),
                    subtitle: Text(
                      playTotal == 1
                          ? '$playTotal ${CustomLocalizations.of(context).song}'
                          : '$playTotal ${CustomLocalizations.of(context).songs}',
                    ),
                    leading: imageCard(
                      imageUrl:
                          (spotifyPlaylists[idx - 1]['images'] as List).isEmpty
                              ? ''
                              : spotifyPlaylists[idx - 1]['images'][0]['url']
                                  .toString(),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final String playName = spotifyPlaylists[idx - 1]['name']
                          .toString()
                          .replaceAll('/', ' ');
                      final String playlistId =
                          spotifyPlaylists[idx - 1]['id'].toString();

                      importSpotify(
                        context,
                        accessToken,
                        playlistId,
                        playName,
                        settingsBox,
                        playlistNames,
                      );
                    },
                  );
          },
        ),
      );
    },
  );
  return;
}
