import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:oryn/main.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final Box settingsBox = Hive.box('settings');
  final ValueNotifier<bool> includeOrExclude = ValueNotifier<bool>(
    Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool,
  );
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  String lang =
      Hive.box('settings').get('lang', defaultValue: 'English') as String;
  bool useProxy =
      Hive.box('settings').get('useProxy', defaultValue: false) as bool;

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
            ).lang,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).langSub,
          ),
          onTap: () {},
          trailing: DropdownButton(
            value: lang,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(
                  () {
                    lang = newValue;
                    MyApp.of(context).setLocale(
                      Locale.fromSubtags(
                        languageCode:
                            LanguageCodes.languageCodes[newValue] ?? 'en',
                      ),
                    );
                    Hive.box('settings').put('lang', newValue);
                  },
                );
              }
            },
            items: LanguageCodes.languageCodes.keys
                .map<DropdownMenuItem<String>>((language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(
                  language,
                ),
              );
            }).toList(),
          ),
          dense: true,
        ),
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).includeExcludeFolder,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).includeExcludeFolderSub,
          ),
          dense: true,
          onTap: () {
            final GlobalKey<AnimatedListState> listKey =
                GlobalKey<AnimatedListState>();
            showModalBottomSheet(
              isDismissible: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                return BottomGradientContainer(
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ),
                  child: AnimatedList(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      10,
                      0,
                      10,
                    ),
                    key: listKey,
                    initialItemCount: includedExcludedPaths.length + 2,
                    itemBuilder: (cntxt, idx, animation) {
                      if (idx == 0) {
                        return ValueListenableBuilder(
                          valueListenable: includeOrExclude,
                          builder: (
                            BuildContext context,
                            bool value,
                            Widget? widget,
                          ) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: <Widget>[
                                    ChoiceChip(
                                      label: Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).excluded,
                                      ),
                                      selectedColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.2),
                                      labelStyle: TextStyle(
                                        color: !value
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                        fontWeight: !value
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      selected: !value,
                                      onSelected: (bool selected) {
                                        includeOrExclude.value = !selected;
                                        settingsBox.put(
                                          'includeOrExclude',
                                          !selected,
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    ChoiceChip(
                                      label: Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).included,
                                      ),
                                      selectedColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.2),
                                      labelStyle: TextStyle(
                                        color: value
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                        fontWeight: value
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      selected: value,
                                      onSelected: (bool selected) {
                                        includeOrExclude.value = selected;
                                        settingsBox.put(
                                          'includeOrExclude',
                                          selected,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5.0,
                                    top: 5.0,
                                    bottom: 10.0,
                                  ),
                                  child: Text(
                                    value
                                        ? CustomLocalizations.of(
                                            context,
                                          ).includedDetails
                                        : CustomLocalizations.of(
                                            context,
                                          ).excludedDetails,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      if (idx == 1) {
                        return ListTile(
                          title: Text(
                            CustomLocalizations.of(context).addNew,
                          ),
                          leading: const Icon(
                            CupertinoIcons.add,
                          ),
                          onTap: () async {
                            final String temp = await Picker.selectFolder(
                              context: context,
                            );
                            if (temp.trim() != '' &&
                                !includedExcludedPaths.contains(temp)) {
                              includedExcludedPaths.add(temp);
                              Hive.box('settings').put(
                                'includedExcludedPaths',
                                includedExcludedPaths,
                              );
                              listKey.currentState!.insertItem(
                                includedExcludedPaths.length,
                              );
                            } else {
                              if (temp.trim() == '') {
                                Navigator.pop(context);
                              }
                              ShowSnackBar().showSnackBar(
                                context,
                                temp.trim() == ''
                                    ? 'No folder selected'
                                    : 'Already added',
                              );
                            }
                          },
                        );
                      }

                      return SizeTransition(
                        sizeFactor: animation,
                        child: ListTile(
                          leading: const Icon(
                            CupertinoIcons.folder,
                          ),
                          title: Text(
                            includedExcludedPaths[idx - 2].toString(),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              CupertinoIcons.clear,
                              size: 15.0,
                            ),
                            tooltip: 'Remove',
                            onPressed: () {
                              includedExcludedPaths.removeAt(idx - 2);
                              Hive.box('settings').put(
                                'includedExcludedPaths',
                                includedExcludedPaths,
                              );
                              listKey.currentState!.removeItem(
                                idx,
                                (context, animation) => Container(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).minAudioLen,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).minAudioLenSub,
          ),
          dense: true,
          onTap: () {
            showTextInputDialog(
              context: context,
              title: CustomLocalizations.of(
                context,
              ).minAudioAlert,
              initialText: (Hive.box('settings')
                      .get('minDuration', defaultValue: 10) as int)
                  .toString(),
              keyboardType: TextInputType.number,
              onSubmitted: (String value, BuildContext context) {
                if (value.trim() == '') {
                  value = '0';
                }
                Hive.box('settings').put('minDuration', int.parse(value));
                Navigator.pop(context);
              },
            );
          },
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).liveSearch,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).liveSearchSub,
          ),
          keyName: 'liveSearch',
          isThreeLine: false,
          defaultValue: true,
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).useDown,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).useDownSub,
          ),
          keyName: 'useDown',
          isThreeLine: true,
          defaultValue: true,
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).getLyricsOnline,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).getLyricsOnlineSub,
          ),
          keyName: 'getLyricsOnline',
          isThreeLine: true,
          defaultValue: true,
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).supportEq,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).supportEqSub,
          ),
          keyName: 'supportEq',
          isThreeLine: true,
          defaultValue: false,
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).stopOnClose,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).stopOnCloseSub,
          ),
          isThreeLine: true,
          keyName: 'stopForegroundService',
          defaultValue: true,
        ),
        // const BoxSwitchTile(
        //   title: Text('Remove Service from foreground when paused'),
        //   subtitle: Text(
        //       "If turned on, you can slide notification when paused to stop the service. But Service can also be stopped by android to release memory. If you don't want android to stop service while paused, turn it off\nDefault: On\n"),
        //   isThreeLine: true,
        //   keyName: 'stopServiceOnPause',
        //   defaultValue: true,
        // ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).checkUpdate,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).checkUpdateSub,
          ),
          keyName: 'checkUpdate',
          isThreeLine: true,
          defaultValue: true,
        ),
        BoxSwitchTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).useProxy,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).useProxySub,
          ),
          keyName: 'useProxy',
          defaultValue: false,
          isThreeLine: true,
          onChanged: ({required bool val, required Box box}) {
            useProxy = val;
            setState(
              () {},
            );
          },
        ),
        Visibility(
          visible: useProxy,
          child: ListTile(
            title: Text(
              CustomLocalizations.of(
                context,
              ).proxySet,
            ),
            subtitle: Text(
              CustomLocalizations.of(
                context,
              ).proxySetSub,
            ),
            dense: true,
            trailing: Text(
              '${Hive.box('settings').get("proxyIp", defaultValue: "103.47.67.134")}:${Hive.box('settings').get("proxyPort", defaultValue: 8080)}',
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final controller = TextEditingController(
                    text: settingsBox
                        .get('proxyIp', defaultValue: '103.47.67.134')
                        .toString(),
                  );
                  final controller2 = TextEditingController(
                    text: settingsBox
                        .get('proxyPort', defaultValue: 8080)
                        .toString(),
                  );
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              CustomLocalizations.of(
                                context,
                              ).ipAdd,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          autofocus: true,
                          controller: controller,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Text(
                              CustomLocalizations.of(
                                context,
                              ).port,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          autofocus: true,
                          controller: controller2,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
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
                              Theme.of(context).colorScheme.secondary ==
                                      Colors.white
                                  ? Colors.black
                                  : null,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          settingsBox.put(
                            'proxyIp',
                            controller.text.trim(),
                          );
                          settingsBox.put(
                            'proxyPort',
                            int.parse(
                              controller2.text.trim(),
                            ),
                          );
                          Navigator.pop(context);
                          setState(
                            () {},
                          );
                        },
                        child: Text(
                          CustomLocalizations.of(
                            context,
                          ).ok,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).clearCache,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).clearCacheSub,
          ),
          trailing: SizedBox(
            height: 70.0,
            width: 70.0,
            child: Center(
              child: FutureBuilder(
                future: File(Hive.box('cache').path!).length(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<int> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      '${((snapshot.data ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB',
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          dense: true,
          isThreeLine: true,
          onTap: () async {
            Hive.box('cache').clear();
            setState(
              () {},
            );
          },
        ),
        ListTile(
          title: Text(
            CustomLocalizations.of(
              context,
            ).shareLogs,
          ),
          subtitle: Text(
            CustomLocalizations.of(
              context,
            ).shareLogsSub,
          ),
          onTap: () async {
            final Directory tempDir = await getTemporaryDirectory();
            final files = <XFile>[XFile('${tempDir.path}/logs/logs.txt')];
            Share.shareXFiles(files);
          },
          dense: true,
          isThreeLine: true,
        ),
      ],
    );
  }
}
