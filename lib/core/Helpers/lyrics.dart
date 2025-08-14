import 'dart:convert';
import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:oryn/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

// ignore: avoid_classes_with_only_static_members
class Lyrics {
  static Future<Map<String, String>> getLyrics({
    BuildContext? context,
    required String title,
    required String artist,
    String? audioFilePath,
    String? id,
  }) async {
    String lyrics = await getLrcLibLyrics(title, artist);
    if (lyrics.isNotEmpty) {
      return {
        'lyrics': lyrics,
        'type': 'lrc',
        'source': 'LRCLib',
      };
    } else {
      lyrics = await getMusixMatchLyrics(title: title, artist: artist);
      if (lyrics.isNotEmpty) {
        return {
          'lyrics': lyrics,
          'type': 'text',
          'source': 'Musixmatch',
        };
      } else {
        lyrics = await getOffLyrics(audioFilePath!);
        if (lyrics.isNotEmpty) {
          return {
            'lyrics': lyrics,
            'type': 'text',
            'source': 'Offline',
          };
        } else {
          if (context != null) {
            emptyScreen(
              context,
              3,
              CustomLocalizations.of(context).nothingTo,
              15,
              CustomLocalizations.of(context).showHere,
              50.0,
              CustomLocalizations.of(context).playSomething,
              23.0,
            );
          }
          return {
            'lyrics': '',
            'type': 'text',
            'source': '',
          };
        }
      }
    }
  }

  static Future<String> getLrcLibLyrics(String title, String artist) async {
    // Implementation for LRCLib
    try {
      final String apiUrl =
          'https://lrclib.net/api/get?track_name=${Uri.encodeComponent(title)}&artist_name=${Uri.encodeComponent(artist)}';
      Logger.root.info('Fetching lyrics from LRCLib: $apiUrl');
      final Response res = await get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final String decodedContent =
            utf8.decode(res.bodyBytes, allowMalformed: true);
        final RegExp lyricsRegExp =
            RegExp(r'"syncedLyrics"\s*:\s*"((?:\\.|[^"\\])*)"');
        final match = lyricsRegExp.firstMatch(decodedContent);
        if (match != null && match.groupCount >= 1) {
          // Unescape JSON string
          final String lyrics =
              match.group(1)!.replaceAll(r'\n', '\n').replaceAll(r'\"', '"');
          Logger.root.info('Lyrics found: $lyrics');
          return lyrics;
        }
      }
    } catch (e) {
      Logger.root.severe('Error in getLrcLibLyrics', e);
    }
    return '';
  }

  static Future<String> getOffLyrics(String path) async {
    if (path.isEmpty || !(await File(path).exists())) {
      return '';
    }
    try {
      final Audiotagger tagger = Audiotagger();
      final Tag? tags = await tagger.readTags(path: path);
      final String rawLyrics = tags?.lyrics ?? '';
      final String decodedLyrics =
          utf8.decode(rawLyrics.codeUnits, allowMalformed: false);
      return decodedLyrics;
    } catch (e) {
      return '';
    }
  }

  static Future<String> getMusixMatchLyrics({
    required String title,
    required String artist,
  }) async {
    try {
      final String link = await getLyricsLink(title, artist);
      Logger.root.info('Found Musixmatch Lyrics Link: $link');
      final String lyrics = await scrapLink(link);
      return lyrics;
    } catch (e) {
      Logger.root.severe('Error in getMusixMatchLyrics', e);
      return '';
    }
  }

  static Future<String> getLyricsLink(String song, String artist) async {
    const String authority = 'www.musixmatch.com';
    final String unencodedPath = '/search/$song $artist';
    final Response res = await get(Uri.https(authority, unencodedPath));
    if (res.statusCode != 200) return '';
    final String decodedContent =
        utf8.decode(res.bodyBytes, allowMalformed: true);
    Logger.root.info('Decoded Musixmatch search content: $decodedContent');
    final RegExpMatch? result =
        RegExp(r'href=\"(\/lyrics\/.*?)\"').firstMatch(decodedContent);
    return result == null ? '' : result[1]!;
  }

  static Future<String> scrapLink(String unencodedPath) async {
    Logger.root.info('Trying to scrap lyrics from $unencodedPath');
    const String authority = 'www.musixmatch.com';
    final Response res = await get(Uri.https(authority, unencodedPath));
    if (res.statusCode != 200) return '';
    final String decodedContent =
        utf8.decode(res.bodyBytes, allowMalformed: true);
    Logger.root.info('Decoded lyrics page content: $decodedContent');
    final List<String?> lyrics = RegExp(
      r'<span class=\"lyrics__content__ok\">(.*?)<\/span>',
      dotAll: true,
    ).allMatches(decodedContent).map((m) => m[1]).toList();

    return lyrics.isEmpty ? '' : lyrics.join('\n');
  }

  static Future<Map<String, String>> stream({
    required String id,
    required String title,
    required String artist,
    required String audioFilePath,
    required BuildContext context,
  }) async {
    final Map<String, String> result = {
      'lyrics': '',
      'type': 'text',
      'source': '',
      'id': id,
    };

    String lyrics = await getLrcLibLyrics(title, artist);
    if (lyrics.isNotEmpty) {
      result['lyrics'] = lyrics;
      result['type'] = 'lrc';
      result['source'] = 'LRCLib';
      await Future.delayed(
          const Duration(seconds: 5)); // 5 second delay for synced lyrics
      return result;
    } else {
      lyrics = await getMusixMatchLyrics(title: title, artist: artist);
      if (lyrics.isNotEmpty) {
        result['lyrics'] = lyrics;
        result['type'] = 'text';
        result['source'] = 'Musixmatch';
        return result;
      } else {
        lyrics = await getOffLyrics(audioFilePath);
        if (lyrics.isNotEmpty) {
          result['lyrics'] = lyrics;
          result['type'] = 'text';
          result['source'] = 'Offline';
          return result;
        } else {
          emptyScreen(
            context,
            3,
            CustomLocalizations.of(context).nothingTo,
            15,
            CustomLocalizations.of(context).showHere,
            50.0,
            CustomLocalizations.of(context).playSomething,
            23.0,
          );
          return result;
        }
      }
    }
  }
}
