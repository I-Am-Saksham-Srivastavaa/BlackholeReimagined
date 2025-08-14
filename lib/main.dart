import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oryn/theme.dart';
import 'package:oryn/index.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sizer/sizer.dart';

import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Paint.enableDithering = true; No longer needed

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('BlackHole/Database');
  } else if (Platform.isIOS) {
    await Hive.initFlutter('Database');
  } else {
    await Hive.initFlutter();
  }
  for (final box in hiveBoxes) {
    await openHiveBox(
      box['name'].toString(),
      limit: box['limit'] as bool? ?? false,
    );
  }
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();
  runApp(MyApp());
}

Future<void> setOptimalDisplayMode() async {
  await FlutterDisplayMode.setHighRefreshRate();
  // final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  // final DisplayMode active = await FlutterDisplayMode.active;

  // final List<DisplayMode> sameResolution = supported
  //     .where(
  //       (DisplayMode m) => m.width == active.width && m.height == active.height,
  //     )
  //     .toList()
  //   ..sort(
  //     (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
  //   );

  // final DisplayMode mostOptimalMode =
  //     sameResolution.isNotEmpty ? sameResolution.first : active;

  // await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> startService() async {
  await initializeLogging();
  MetadataGod.initialize();
  final audioHandlerHelper = AudioHandlerHelper();
  final AudioPlayerHandler audioHandler =
      await audioHandlerHelper.getAudioHandler();
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    Logger.root.severe('Failed to open $boxName Box', error, stackTrace);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/BlackHole/$boxName.hive');
      lockFile = File('$dirPath/BlackHole/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

/// Called when Doing Background Work initiated from Widget
// @pragma('vm:entry-point')
// Future<void> backgroundCallback(Uri? data) async {
//   if (data?.host == 'controls') {
//     final audioHandler = await AudioHandlerHelper().getAudioHandler();
//     if (data?.path == '/play') {
//       audioHandler.play();
//     } else if (data?.path == '/pause') {
//       audioHandler.pause();
//     } else if (data?.path == '/skipNext') {
//       audioHandler.skipToNext();
//     } else if (data?.path == '/skipPrevious') {
//       audioHandler.skipToPrevious();
//     }

//     // await HomeWidget.saveWidgetData<String>(
//     //   'title',
//     //   audioHandler?.mediaItem.value?.title,
//     // );
//     // await HomeWidget.saveWidgetData<String>(
//     //   'subtitle',
//     //   audioHandler?.mediaItem.value?.displaySubtitle,
//     // );
//     // await HomeWidget.updateWidget(name: 'BlackHoleMusicWidget');
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  // ignore: unreachable_from_main
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  late StreamSubscription _intentTextStreamSubscription;
  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentTextStreamSubscription.cancel();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // HomeWidget.setAppGroupId('com.infinity.oryn');
    // HomeWidget.registerBackgroundCallback(backgroundCallback);
    final String systemLangCode = Platform.localeName.substring(0, 2);
    final String? lang = Hive.box('settings').get('lang') as String?;
    if (lang == null &&
        LanguageCodes.languageCodes.values.contains(systemLangCode)) {
      _locale = Locale(systemLangCode);
    } else {
      _locale = Locale(LanguageCodes.languageCodes[lang ?? 'English'] ?? 'en');
    }

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });

    if (Platform.isAndroid || Platform.isIOS) {
      void handleSharedMedia(
          List<SharedMediaFile> items, BuildContext context) {
        if (items.isEmpty) return;

        for (final item in items) {
          switch (item.type) {
            case SharedMediaType.text:
              final String text = item.path; // Shared text comes as path
              Logger.root.info('Received shared TEXT: $text');

              Future.delayed(const Duration(seconds: 1), () {
                try {
                  final route = HandleRoute.handleRoute(text);
                  if (route != null) {
                    navigatorKey.currentState?.push(route);
                  } else {
                    Logger.root
                        .warning('Route was null for shared text: $text');
                  }
                } catch (e, stack) {
                  Logger.root.severe('Error handling shared text', e, stack);
                }
              });

            case SharedMediaType.file:
              final String filePath = item.path;
              Logger.root.info('Received shared FILE: $filePath');

              // Example: Handle .json playlist import
              if (filePath.endsWith('.json')) {
                final List playlistNames = Hive.box('settings')
                        .get('playlistNames')
                        ?.toList() as List? ??
                    ['Favorite Songs'];

                importFilePlaylist(
                  null,
                  playlistNames,
                  path: filePath,
                  pickFile: false,
                ).then((_) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return PlaylistScreen();
                    },
                  );
                });
              } else {
                Logger.root.info('Unsupported file type shared: $filePath');
              }

            default:
              Logger.root.warning('Unknown shared media type: ${item.type}');
          }
        }
      }

      // ✅ For when app is in memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> sharedItems) {
          handleSharedMedia(sharedItems, context);
        },
        onError: (err) {
          Logger.root.severe('ERROR in getMediaStream', err);
        },
      );

      // ✅ For when app is launched from closed state
      ReceiveSharingIntent.instance.getInitialMedia().then(
        (List<SharedMediaFile> sharedItems) {
          handleSharedMedia(sharedItems, context);
        },
      ).catchError((err) {
        Logger.root.severe('ERROR in getInitialMedia', err);
      });
    }

// Shared handler for all types of input
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.system
            ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                ? Brightness.light
                : Brightness.dark
            : AppTheme.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarIconBrightness:
            AppTheme.themeMode == ThemeMode.system
                ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark
                : AppTheme.themeMode == ThemeMode.dark
                    ? Brightness.light
                    : Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizerUtil.setScreenSize(constraints, orientation);
              return MaterialApp(
                title: 'BlackHole',
                restorationScopeId: 'blackhole',
                debugShowCheckedModeBanner: false,
                themeMode: AppTheme.themeMode,
                theme: AppTheme.lightTheme(
                  context: context,
                ),
                darkTheme: AppTheme.darkTheme(
                  context: context,
                ),
                locale: _locale,
                localizationsDelegates: const [
                  CustomLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LanguageCodes.languageCodes.entries
                    .map((languageCode) => Locale(languageCode.value, ''))
                    .toList(),
                routes: namedRoutes,
                navigatorKey: navigatorKey,
              );
            },
          );
        },
      ),
    );
  }
}
