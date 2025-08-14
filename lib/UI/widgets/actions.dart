import 'package:oryn/index.dart';
import 'package:flutter/material.dart';

Widget actions({
  required ValueNotifier<Source> source,
}) {
  return ValueListenableBuilder<Source>(
    valueListenable: source,
    builder: (context, value, child) {
      List<Widget> actionsList;
      switch (value) {
        case Source.Spotify:
          actionsList = spotifyAction(context);
        case Source.YouTube:
          actionsList = youtubeAction(context);
        case Source.YouTubeMusic:
          actionsList = youtubeMusicAction(context);
        case Source.Saavn:
          actionsList = saavnAction(context);
        default:
          actionsList = [];
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: actionsList,
      );
    },
  );
}

List<Widget> spotifyAction(BuildContext context) {
  return [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.my_location_rounded),
        onPressed: () async {
          await SpotifyCountry().changeCountry(context: context);
        },
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.settings_remote),
        onPressed: () async {},
      ),
    ),
  ];
}

List<Widget> youtubeAction(BuildContext context) {
  return [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.my_location_rounded),
        onPressed: () async {
          await SpotifyCountry().changeCountry(context: context);
        },
      ),
    ),
  ];
}

List<Widget> youtubeMusicAction(BuildContext context) {
  return [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.my_location_rounded),
        onPressed: () async {
          await SpotifyCountry().changeCountry(context: context);
        },
      ),
    ),
  ];
}

List<Widget> saavnAction(BuildContext context) {
  return [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        icon: const Icon(Icons.my_location_rounded),
        onPressed: () async {
          await SpotifyCountry().changeCountry(context: context);
        },
      ),
    ),
  ];
}
