// ignore_for_file: avoid_classes_with_only_static_members

import 'package:audio_service/audio_service.dart';
import 'package:oryn/index.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

class StreamPlayerService {
  static Future<void> refreshYtLink(Map playItem) async {
    final int expiredAt = int.parse((playItem['expire_at'] ?? '0').toString());
    if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 > expiredAt) {
      Logger.root.info(
        'before service | youtube link expired for ${playItem["title"]}',
      );
      if (Hive.box('ytlinkcache').containsKey(playItem['id'])) {
        final cache = await Hive.box('ytlinkcache').get(playItem['id']);
        if (cache is List) {
          int minExpiredAt = 0;
          for (final e in cache) {
            final int cachedExpiredAt = int.parse(e['expireAt'].toString());
            if (minExpiredAt == 0 || cachedExpiredAt < minExpiredAt) {
              minExpiredAt = cachedExpiredAt;
            }
          }

          if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 >
              minExpiredAt) {
            Logger.root
                .info('youtube link expired in cache for ${playItem["title"]}');
            final newData = await YouTubeServices.instance
                .refreshLink(playItem['id'].toString());
            Logger.root.info(
              'before service | received new link for ${playItem["title"]}',
            );
            if (newData != null) {
              playItem['url'] = newData['url'];
              playItem['duration'] = newData['duration'];
              playItem['expire_at'] = newData['expire_at'];
            }
          } else {
            Logger.root
                .info('youtube link found in cache for ${playItem["title"]}');
            playItem['url'] = cache.last['url'];
            playItem['expire_at'] = cache.last['expireAt'];
          }
        } else {
          final newData = await YouTubeServices.instance
              .refreshLink(playItem['id'].toString());
          Logger.root.info(
            'before service | received new link for ${playItem["title"]}',
          );
          if (newData != null) {
            playItem['url'] = newData['url'];
            playItem['duration'] = newData['duration'];
            playItem['expire_at'] = newData['expire_at'];
          }
        }
      } else {
        final newData = await YouTubeServices.instance
            .refreshLink(playItem['id'].toString());
        Logger.root.info(
          'before service | received new link for ${playItem["title"]}',
        );
        if (newData != null) {
          playItem['url'] = newData['url'];
          playItem['duration'] = newData['duration'];
          playItem['expire_at'] = newData['expire_at'];
        }
      }
    }
  }

  static Future<void> setValues(
    List response,
    int index, {
    bool recommend = true,
  }) async {
    final List<MediaItem> queue = [];
    final Map playItem = response[index] as Map;
    final Map? nextItem =
        index == response.length - 1 ? null : response[index + 1] as Map;
    if (playItem['genre'] == 'YouTube') {
      await refreshYtLink(playItem);
    }
    if (nextItem != null && nextItem['genre'] == 'YouTube') {
      await refreshYtLink(nextItem);
    }

    queue.addAll(
      response.map(
        (song) => MediaItemConverter.mapToMediaItem(
          song as Map,
          autoplay: recommend,
        ),
      ),
    );
    await PlayerInvoke.updateNplay(queue, index);
  }
}
