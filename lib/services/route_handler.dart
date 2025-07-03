import 'package:oryn/index.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

// ignore: avoid_classes_with_only_static_members
class HandleRoute {
  static Route? handleRoute(String? url) {
    Logger.root.info('received route url: $url');
    if (url == null) return null;
    if (url.contains('saavn')) {
      final RegExpMatch? songResult =
          RegExp(r'.*saavn.com.*?\/(song)\/.*?\/(.*)').firstMatch('$url?');
      if (songResult != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => SaavnUrlHandler(
            token: songResult[2]!,
            type: songResult[1]!,
          ),
        );
      } else {
        final RegExpMatch? playlistResult = RegExp(
          r'.*saavn.com\/?s?\/(featured|playlist|album)\/.*\/(.*_)?[?/]',
        ).firstMatch('$url?');
        if (playlistResult != null) {
          return PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => SaavnUrlHandler(
              token: playlistResult[2]!,
              type: playlistResult[1]!,
            ),
          );
        }
      }
    } else if (url.contains('spotify')) {
      // TODO: Add support for spotify links
      Logger.root.info('received spotify link');
      final RegExpMatch? songResult =
          RegExp(r'.*spotify.com.*?\/(track)\/(.*?)[/?]').firstMatch('$url/');
      if (songResult != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => SpotifyUrlHandler(
            id: songResult[2]!,
            type: songResult[1]!,
          ),
        );
      }
    } else if (url.contains('youtube') || url.contains('youtu.be')) {
      // TODO: Add support for youtube links
      Logger.root.info('received youtube link');
      final RegExpMatch? videoId =
          RegExp(r'.*[\?\/](v|list)[=\/](.*?)[\/\?&#]').firstMatch('$url/');
      if (videoId != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => YtUrlHandler(
            id: videoId[2]!,
            type: videoId[1]!,
          ),
        );
      }
    } else {
      final RegExpMatch? fileResult =
          RegExp(r'\/[0-9]+\/([0-9]+)\/').firstMatch('$url/');
      if (fileResult != null) {
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => OfflinePlayHandler(
            id: fileResult[1]!,
          ),
        );
      }
    }
    return null;
  }
}
