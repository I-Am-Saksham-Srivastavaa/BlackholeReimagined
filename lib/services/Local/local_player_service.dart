// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:io';

import 'package:oryn/index.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class LocalPlayerService {
  static Future<MediaItem> setTags(
      SongModel response, Directory tempDir) async {
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
      PlayerInvoke.updateNplay(queue, index);
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
      PlayerInvoke.updateNplay(queue, index);
    });
  }

  static void setDownValues(List response, int index) {
    final List<MediaItem> queue = [];
    queue.addAll(
      response.map(
        (song) => MediaItemConverter.downMapToMediaItem(song as Map),
      ),
    );
    PlayerInvoke.updateNplay(queue, index);
  }
}
