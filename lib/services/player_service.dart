import 'dart:io';
import 'package:oryn/index.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

// ignore: avoid_classes_with_only_static_members
class PlayerInvoke {
  static final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  static Future<void> init({
    required List songsList,
    required int index,
    bool fromMiniplayer = false,
    bool? isOffline,
    bool recommend = true,
    bool fromDownloads = false,
    bool shuffle = false,
    String? playlistBox,
  }) async {
    final int globalIndex = index < 0 ? 0 : index;
    bool? offline = isOffline;
    final List finalList = songsList.toList();
    if (shuffle) finalList.shuffle();
    if (offline == null) {
      if (audioHandler.mediaItem.value?.extras!['url'].startsWith('http')
          as bool) {
        offline = false;
      } else {
        offline = true;
      }
    }

    if (!fromMiniplayer) {
      if (Platform.isIOS) {
        // Don't know why but it fixes the playback issue with iOS Side
        audioHandler.stop();
      }
      if (offline) {
        fromDownloads
            ? setDownValues(finalList, globalIndex)
            : (Platform.isWindows || Platform.isLinux)
                ? setOffDesktopValues(finalList, globalIndex)
                : setOffValues(finalList, globalIndex);
      } else {
        setValues(
          finalList,
          globalIndex,
          recommend: recommend,
          // playlistBox: playlistBox,
        );
      }
    }
  }

  static Future<MediaItem> setTags(
    SongModel response,
    Directory tempDir,
  ) async {
    String playTitle = response.title;
    playTitle == ''
        ? playTitle = response.displayNameWOExt
        : playTitle = response.title;
    String playArtist = response.artist!;
    playArtist == '<unknown>'
        ? playArtist = 'Unknown'
        : playArtist = response.artist!;

    final String playAlbum = response.album!;
    final int playDuration = response.duration ?? 180000;
    final String imagePath = '${tempDir.path}/${response.displayNameWOExt}.png';

    final MediaItem tempDict = MediaItem(
      id: response.id.toString(),
      album: playAlbum,
      duration: Duration(milliseconds: playDuration),
      title: playTitle.split('(')[0],
      artist: playArtist,
      genre: response.genre,
      artUri: Uri.file(imagePath),
      extras: {
        'url': response.data,
        'date_added': response.dateAdded,
        'date_modified': response.dateModified,
        'size': response.size,
        'year': response.getMap['year'],
      },
    );
    return tempDict;
  }

  static void setOffDesktopValues(List response, int index) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      final List<MediaItem> queue = [];
      queue.addAll(
        response.map(
          (song) => MediaItem(
            id: song['id'].toString(),
            album: song['album'].toString(),
            artist: song['artist'].toString(),
            duration: Duration(
              seconds: int.parse(
                (song['duration'] == null || song['duration'] == 'null')
                    ? '180'
                    : song['duration'].toString(),
              ),
            ),
            title: song['title'].toString(),
            artUri: Uri.file(file.path),
            genre: song['genre'].toString(),
            extras: {
              'url': song['path'].toString(),
              'subtitle': song['subtitle'],
              'quality': song['quality'],
            },
          ),
        ),
      );
      updateNplay(queue, index);
    });
  }

  static void setOffValues(List response, int index) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      final List<MediaItem> queue = [];
      for (int i = 0; i < response.length; i++) {
        queue.add(
          await setTags(response[i] as SongModel, tempDir),
        );
      }
      updateNplay(queue, index);
    });
  }

  static void setDownValues(List response, int index) {
    final List<MediaItem> queue = [];
    queue.addAll(
      response.map(
        (song) => MediaItemConverter.downMapToMediaItem(song as Map),
      ),
    );
    updateNplay(queue, index);
  }

  static Future<void> refreshYtLink(Map playItem) async {
    // final bool cacheSong =
    // Hive.box('settings').get('cacheSong', defaultValue: true) as bool;
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
            // cache expired
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
            // giving cache link
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
    // String? playlistBox,
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
          // playlistBox: playlistBox,
        ),
      ),
    );
    await updateNplay(queue, index);
  }

  static Future<void> updateNplay(List<MediaItem> queue, int index) async {
    await audioHandler.updateQueue(queue);
    await audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    await audioHandler.customAction('skipToMediaItem', {'index': index});
    await audioHandler.play();
    final String repeatMode =
        Hive.box('settings').get('repeatMode', defaultValue: 'None').toString();
    final bool enforceRepeat =
        Hive.box('settings').get('enforceRepeat', defaultValue: false) as bool;
    if (enforceRepeat) {
      switch (repeatMode) {
        case 'None':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        case 'All':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        case 'One':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        default:
          break;
      }
    } else {
      audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
      Hive.box('settings').put('repeatMode', 'None');
    }
  }
}
