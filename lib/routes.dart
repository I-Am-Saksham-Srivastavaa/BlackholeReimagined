import 'package:flutter/material.dart';
import 'package:oryn/base.dart';
import 'package:oryn/index.dart';
import 'package:hive/hive.dart';

Widget initialFuntion() {
  return Hive.box('settings').get('userId') != null ? Base() : AuthScreen();
}

final Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => initialFuntion(),
  '/pref': (context) => const PrefScreen(),
  '/setting': (context) => const SettingsPage(),
  '/info': (context) => Info(),
  '/playlists': (context) => PlaylistScreen(),
  '/nowplaying': (context) => NowPlaying(),
  '/recent': (context) => RecentlyPlayed(),
  '/downloads': (context) => const Downloads(),
  '/stats': (context) => const Stats(),
};
