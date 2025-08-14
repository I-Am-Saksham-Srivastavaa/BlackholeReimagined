import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

class BackupAndRestorePage extends StatefulWidget {
  const BackupAndRestorePage({super.key});

  @override
  State<BackupAndRestorePage> createState() => _BackupAndRestorePageState();
}

class _BackupAndRestorePageState extends State<BackupAndRestorePage> {
  final Box settingsBox = Hive.box('settings');
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String autoBackPath = Hive.box('settings').get(
    'autoBackPath',
    defaultValue: '/storage/emulated/0/BlackHole/Backups',
  ) as String;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10.0),
      children: [
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).createBack,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).createBackSub,
          ),
          dense: true,
          onTap: () {
            showModalBottomSheet(
              isDismissible: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                final List playlistNames = Hive.box('settings').get(
                  'playlistNames',
                  defaultValue: ['Favorite Songs'],
                ) as List;
                if (!playlistNames.contains('Favorite Songs')) {
                  playlistNames.insert(0, 'Favorite Songs');
                  settingsBox.put(
                    'playlistNames',
                    playlistNames,
                  );
                }

                final List<String> persist = [
                  CustomLocalizations.of(
                    context,
                  ).settings,
                  CustomLocalizations.of(
                    context,
                  ).playlists,
                ];

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

                final List<String> items = [
                  CustomLocalizations.of(
                    context,
                  ).settings,
                  CustomLocalizations.of(
                    context,
                  ).playlists,
                  CustomLocalizations.of(
                    context,
                  ).downs,
                  CustomLocalizations.of(
                    context,
                  ).cache,
                ];

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
                return StatefulBuilder(
                  builder: (
                    BuildContext context,
                    StateSetter setStt,
                  ) {
                    return BottomGradientContainer(
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                10,
                                0,
                                10,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, idx) {
                                return CheckboxListTile(
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  checkColor:
                                      Theme.of(context).colorScheme.secondary ==
                                              Colors.white
                                          ? Colors.black
                                          : null,
                                  value: checked.contains(
                                    items[idx],
                                  ),
                                  title: Text(
                                    items[idx],
                                  ),
                                  onChanged: persist.contains(items[idx])
                                      ? null
                                      : (bool? value) {
                                          value!
                                              ? checked.add(
                                                  items[idx],
                                                )
                                              : checked.remove(
                                                  items[idx],
                                                );
                                          setStt(
                                            () {},
                                          );
                                        },
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  CustomLocalizations.of(
                                    context,
                                  ).cancel,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () {
                                  createBackup(
                                    context,
                                    checked,
                                    boxNames,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  CustomLocalizations.of(
                                    context,
                                  ).ok,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).restore,
          ),
          subtitle: Text(
            '${CustomLocalizations.of(
              context,
            ).restoreSub}\n(${CustomLocalizations.of(
              context,
            ).restart})',
          ),
          dense: true,
          onTap: () async {
            await restore(context);
            currentTheme.refresh();
          },
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).autoBack,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).autoBackSub,
          ),
          keyName: 'autoBackup',
          defaultValue: false,
        ),
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).autoBackLocation,
          ),
          subtitle: Text(autoBackPath),
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[700],
            ),
            onPressed: () async {
              autoBackPath = await ExtStorageProvider.getExtStorage(
                    dirName: 'BlackHole/Backups',
                    writeAccess: true,
                  ) ??
                  '/storage/emulated/0/BlackHole/Backups';
              Hive.box('settings').put('autoBackPath', autoBackPath);
              setState(
                () {},
              );
            },
            child: Text(
              CustomLocalizations.of(
                context,
              ).reset,
            ),
          ),
          onTap: () async {
            final String temp = await Picker.selectFolder(
              context: context,
              message: CustomLocalizations.of(
                context,
              ).selectBackLocation,
            );
            if (temp.trim() != '') {
              autoBackPath = temp;
              Hive.box('settings').put('autoBackPath', temp);
              setState(
                () {},
              );
            } else {
              ShowSnackBar().showSnackBar(
                context,
                CustomLocalizations.of(
                  context,
                ).noFolderSelected,
              );
            }
          },
          dense: true,
        ),
      ],
    );
  }
}
