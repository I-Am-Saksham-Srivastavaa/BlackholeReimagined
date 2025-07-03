import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:oryn/index.dart';

Widget sourceSelector({
  required ValueNotifier<Source> source,
}) {
  return ValueListenableBuilder<Source>(
    valueListenable: source,
    builder: (context, value, child) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              source.value = Source.Spotify;
              Logger.root.info('Source changed to Spotify');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                MdiIcons.spotify,
                color: value == Source.Spotify
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).iconTheme.color?.withAlpha(51),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              source.value = Source.YouTube;
              Logger.root.info('Source changed to YouTube');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                MdiIcons.youtube,
                color: value == Source.YouTube
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).iconTheme.color?.withAlpha(51),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              source.value = Source.YouTubeMusic;
              Logger.root.info('Source changed to YouTube Music');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                MdiIcons.youtubeTv,
                color: value == Source.YouTubeMusic
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).iconTheme.color?.withAlpha(51),
                size: 28,
              ),
            ),
          ),
        ],
      );
    },
  );
}
