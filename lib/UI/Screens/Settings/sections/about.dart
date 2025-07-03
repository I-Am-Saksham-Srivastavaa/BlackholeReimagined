import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    setState(
      () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10.0,
                10.0,
                10.0,
                10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      CustomLocalizations.of(
                        context,
                      ).version,
                    ),
                    subtitle: Text(
                      CustomLocalizations.of(
                        context,
                      ).versionSub,
                    ),
                    onTap: () {
                      ShowSnackBar().showSnackBar(
                        context,
                        CustomLocalizations.of(
                          context,
                        ).checkingUpdate,
                        noAction: true,
                      );

                      /* GitHub.getLatestVersion().then(
                            (String latestVersion) async {
                              if (compareVersion(
                                latestVersion,
                                appVersion!,
                              )) {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  CustomLocalizations.of(context).updateAvailable,
                                  duration: const Duration(seconds: 15),
                                  action: SnackBarAction(
                                    textColor:
                                        Theme.of(context).colorScheme.secondary,
                                    label: CustomLocalizations.of(context).update,
                                    onPressed: () async {
                                      String arch = '';
                                      if (Platform.isAndroid) {
                                        List? abis = await Hive.box('settings')
                                            .get('supportedAbis') as List?;

                                        if (abis == null) {
                                          final DeviceInfoPlugin deviceInfo =
                                              DeviceInfoPlugin();
                                          final AndroidDeviceInfo
                                              androidDeviceInfo =
                                              await deviceInfo.androidInfo;
                                          abis =
                                              androidDeviceInfo.supportedAbis;
                                          await Hive.box('settings')
                                              .put('supportedAbis', abis);
                                        }
                                        if (abis.contains('arm64')) {
                                          arch = 'arm64';
                                        } else if (abis.contains('armeabi')) {
                                          arch = 'armeabi';
                                        }
                                      }
                                      Navigator.pop(context);
                                      launchUrl(
                                        Uri.parse(
                                          'https://sangwan5688.github.io/download?platform=${Platform.operatingSystem}&arch=$arch',
                                        ),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  CustomLocalizations.of(
                                    context,
                                  )
                                      .latest,
                                );
                              }
                            },
                          );
                         */
                    },
                    trailing: Text(
                      'v$appVersion',
                      style: const TextStyle(fontSize: 12),
                    ),
                    dense: true,
                  ),
                  ListTile(
                    title: Text(
                      CustomLocalizations.of(
                        context,
                      ).shareApp,
                    ),
                    subtitle: Text(
                      CustomLocalizations.of(
                        context,
                      ).shareAppSub,
                    ),
                    onTap: () {
                      Share.share(
                        '${CustomLocalizations.of(
                          context,
                        ).shareAppText}:\n\n',
                      );
                    },
                    dense: true,
                  ),
                  ListTile(
                    title: Text(
                      CustomLocalizations.of(
                        context,
                      ).likedWork,
                    ),
                    subtitle: Text(
                      CustomLocalizations.of(
                        context,
                      ).buyCoffee,
                    ),
                    dense: true,
                    onTap: () {
                      launchUrl(
                        Uri.parse(
                          'https://www.buymeacoffee.com/',
                        ),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      CustomLocalizations.of(
                        context,
                      ).donateGpay,
                    ),
                    subtitle: Text(
                      CustomLocalizations.of(
                        context,
                      ).donateGpaySub,
                    ),
                    dense: true,
                    isThreeLine: true,
                    onTap: () {
                      const String upiUrl =
                          'upi://pay?pa=the.saksham.srivastavaa-1@oksbi';
                      launchUrl(
                        Uri.parse(upiUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    onLongPress: () {
                      copyToClipboard(
                        context: context,
                        text: 'the.saksham.srivastavaa-1@oksbi',
                        displayText: CustomLocalizations.of(
                          context,
                        ).upiCopied,
                      );
                    },
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey[700],
                      ),
                      onPressed: () {
                        copyToClipboard(
                          context: context,
                          text: 'the.saksham.srivastavaa-1@oksbi',
                          displayText: CustomLocalizations.of(
                            context,
                          ).upiCopied,
                        );
                      },
                      child: Text(
                        CustomLocalizations.of(
                          context,
                        ).copy,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      CustomLocalizations.of(
                        context,
                      ).contactUs,
                    ),
                    subtitle: Text(
                      CustomLocalizations.of(
                        context,
                      ).contactUsSub,
                    ),
                    dense: true,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 100,
                            child: GradientContainer(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.gmail,
                                        ),
                                        iconSize: 40,
                                        tooltip: CustomLocalizations.of(
                                          context,
                                        ).gmail,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'mailto:the.saksham.srivastavaa@gmail.com',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).gmail,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.telegram,
                                        ),
                                        iconSize: 40,
                                        tooltip: CustomLocalizations.of(
                                          context,
                                        ).tg,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://t.me/',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).tg,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.instagram,
                                        ),
                                        iconSize: 40,
                                        tooltip: CustomLocalizations.of(
                                          context,
                                        ).insta,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://instagram.com/',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).insta,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                      ).joinTg,
                    ),
                    subtitle: Text(
                      CustomLocalizations.of(
                        context,
                      ).joinTgSub,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 100,
                            child: GradientContainer(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.telegram,
                                        ),
                                        iconSize: 40,
                                        tooltip: CustomLocalizations.of(
                                          context,
                                        ).tgGp,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://t.me/',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).tgGp,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          MdiIcons.telegram,
                                        ),
                                        iconSize: 40,
                                        tooltip: CustomLocalizations.of(
                                          context,
                                        ).tgCh,
                                        onPressed: () {
                                          Navigator.pop(context);
                                          launchUrl(
                                            Uri.parse(
                                              'https://t.me/',
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                      Text(
                                        CustomLocalizations.of(
                                          context,
                                        ).tgCh,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    dense: true,
                  ),
                  ListTile(
                    title: Text(
                      CustomLocalizations.of(
                        context,
                      ).moreInfo,
                    ),
                    dense: true,
                    onTap: () {
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return Info();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ]),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: <Widget>[
              const Spacer(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                  child: Center(
                    child: Text(
                      CustomLocalizations.of(context).remadeBy,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
