import 'dart:convert';
import 'dart:io';

import 'yt_music.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeServices {
  static const String searchAuthority = 'www.youtube.com';
  static const Map paths = {
    'search': '/results',
    'channel': '/channel',
    'music': '/music',
    'playlist': '/playlist',
  };
  static const Map<String, String> headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0',
  };
  final YoutubeExplode yt = YoutubeExplode();

  YouTubeServices._privateConstructor();

  static final YouTubeServices _instance =
      YouTubeServices._privateConstructor();

  static YouTubeServices get instance {
    return _instance;
  }

  Future<List<Video>> getPlaylistSongs(String id) async {
    final List<Video> results = await yt.playlists.getVideos(id).toList();
    return results;
  }

  Future<Video?> getVideoFromId(String id) async {
    try {
      final Video result = await yt.videos.get(id);
      return result;
    } catch (e) {
      Logger.root.severe('Error while getting video from id', e);
      return null;
    }
  }

  Future<Map?> formatVideoFromId({
    required String id,
    Map? data,
    bool? getUrl,
  }) async {
    final Video? vid = await getVideoFromId(id);
    if (vid == null) {
      return null;
    }
    final Map? response = await formatVideo(
      video: vid,
      quality: Hive.box('settings')
          .get(
            'ytQuality',
            defaultValue: 'Low',
          )
          .toString(),
      data: data,
      getUrl: getUrl ?? true,
      // preferM4a: Hive.box(
      //         'settings')
      //     .get('preferM4a',
      //         defaultValue:
      //             true) as bool
    );
    return response;
  }

  Future<Map?> refreshLink(String id, {bool useYTM = true}) async {
    String quality;
    try {
      quality =
          Hive.box('settings').get('quality', defaultValue: 'Low').toString();
    } catch (e) {
      quality = 'Low';
    }
    if (useYTM) {
      final Map res = await YtMusicService().getSongData(
        videoId: id,
        quality: quality,
      );
      return res;
    }
    final Video? res = await getVideoFromId(id);
    if (res == null) {
      return null;
    }
    final Map? data = await formatVideo(video: res, quality: quality);
    return data;
  }

  Future<Playlist> getPlaylistDetails(String id) async {
    final Playlist metadata = await yt.playlists.get(id);
    return metadata;
  }

  Future<Map<String, List>> getMusicHome() async {
    final Uri link = Uri.https(
      searchAuthority,
      paths['music'].toString(),
    );
    try {
      final Response response = await get(link);
      if (response.statusCode != 200) {
        return {};
      }
      final String searchResults =
          RegExp(r'(\"contents\":{.*?}),\"metadata\"', dotAll: true)
              .firstMatch(response.body)![1]!;
      final Map data = json.decode('{$searchResults}') as Map;

      final List result = data['contents']['twoColumnBrowseResultsRenderer']
              ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'] as List;

      final List headResult = data['header']['carouselHeaderRenderer']
          ['contents'][0]['carouselItemRenderer']['carouselItems'] as List;

      final List shelfRenderer = result.map((element) {
        return element['itemSectionRenderer']['contents'][0]['shelfRenderer'];
      }).toList();

      final List finalResult = shelfRenderer.map((element) {
        final playlistItems = element['title']['runs'][0]['text'].trim() ==
                    'Charts' ||
                element['title']['runs'][0]['text'].trim() == 'Classements'
            ? formatChartItems(
                element['content']['horizontalListRenderer']['items'] as List,
              )
            : element['title']['runs'][0]['text']
                        .toString()
                        .contains('Music Videos') ||
                    element['title']['runs'][0]['text']
                        .toString()
                        .contains('Nouveaux clips') ||
                    element['title']['runs'][0]['text']
                        .toString()
                        .contains('En Musique Avec Moi') ||
                    element['title']['runs'][0]['text']
                        .toString()
                        .contains('Performances Uniques')
                ? formatVideoItems(
                    element['content']['horizontalListRenderer']['items']
                        as List,
                  )
                : formatItems(
                    element['content']['horizontalListRenderer']['items']
                        as List,
                  );
        if (playlistItems.isNotEmpty) {
          return {
            'title': element['title']['runs'][0]['text'],
            'playlists': playlistItems,
          };
        } else {
          Logger.root.severe(
            "got null in getMusicHome for '${element['title']['runs'][0]['text']}'",
          );
          return null;
        }
      }).toList();

      final List finalHeadResult = formatHeadItems(headResult);
      finalResult.removeWhere((element) => element == null);

      return {'body': finalResult, 'head': finalHeadResult};
    } catch (e) {
      Logger.root.severe('Error in getMusicHome: $e');
      return {};
    }
  }

  Future<List> getSearchSuggestions({required String query}) async {
    const baseUrl =
        'https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=';
    // 'https://invidious.snopyta.org/api/v1/search/suggestions?q=';
    final Uri link = Uri.parse(baseUrl + query);
    try {
      final Response response = await get(link, headers: headers);
      if (response.statusCode != 200) {
        return [];
      }
      final unescape = HtmlUnescape();
      // final Map res = jsonDecode(response.body) as Map;
      final List res = (jsonDecode(response.body) as List)[1] as List;
      // return (res['suggestions'] as List).map((e) => unescape.convert(e.toString())).toList();
      return res.map((e) => unescape.convert(e.toString())).toList();
    } catch (e) {
      Logger.root.severe('Error in getSearchSuggestions: $e');
      return [];
    }
  }

  List formatVideoItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['gridVideoRenderer']['title']['simpleText'],
          'type': 'video',
          'description': e['gridVideoRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridVideoRenderer']['shortViewCountText']['simpleText'],
          'videoId': e['gridVideoRenderer']['videoId'],
          'firstItemId': e['gridVideoRenderer']['videoId'],
          'image':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
          'imageMin': e['gridVideoRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['gridVideoRenderer']['thumbnail']['thumbnails'][1]
              ['url'],
          'imageStandard': e['gridVideoRenderer']['thumbnail']['thumbnails'][2]
              ['url'],
          'imageMax':
              e['gridVideoRenderer']['thumbnail']['thumbnails'].last['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      Logger.root.severe('Error in formatVideoItems: $e');
      return List.empty();
    }
  }

  List formatChartItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['gridPlaylistRenderer']['title']['runs'][0]['text'],
          'type': 'chart',
          'description': e['gridPlaylistRenderer']['shortBylineText']['runs'][0]
              ['text'],
          'count': e['gridPlaylistRenderer']['videoCountText']['runs'][0]
              ['text'],
          'playlistId': e['gridPlaylistRenderer']['navigationEndpoint']
              ['watchEndpoint']['playlistId'],
          'firstItemId': e['gridPlaylistRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageStandard': e['gridPlaylistRenderer']['thumbnail']['thumbnails']
              [0]['url'],
          'imageMax': e['gridPlaylistRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      Logger.root.severe('Error in formatChartItems: $e');
      return List.empty();
    }
  }

  List formatItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['compactStationRenderer']['title']['simpleText'],
          'type': 'playlist',
          'description': e['compactStationRenderer']['description']
              ['simpleText'],
          'count': e['compactStationRenderer']['videoCountText']['runs'][0]
              ['text'],
          'playlistId': e['compactStationRenderer']['navigationEndpoint']
              ['watchEndpoint']['playlistId'],
          'firstItemId': e['compactStationRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['compactStationRenderer']['thumbnail']['thumbnails'][0]
              ['url'],
          'imageMedium': e['compactStationRenderer']['thumbnail']['thumbnails']
              [0]['url'],
          'imageStandard': e['compactStationRenderer']['thumbnail']
              ['thumbnails'][1]['url'],
          'imageMax': e['compactStationRenderer']['thumbnail']['thumbnails'][2]
              ['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      Logger.root.severe('Error in formatItems: $e');
      return List.empty();
    }
  }

  List formatHeadItems(List itemsList) {
    try {
      final List result = itemsList.map((e) {
        return {
          'title': e['defaultPromoPanelRenderer']['title']['runs'][0]['text'],
          'type': 'video',
          'description':
              (e['defaultPromoPanelRenderer']['description']['runs'] as List)
                  .map((e) => e['text'])
                  .toList()
                  .join(),
          'videoId': e['defaultPromoPanelRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'firstItemId': e['defaultPromoPanelRenderer']['navigationEndpoint']
              ['watchEndpoint']['videoId'],
          'image': e['defaultPromoPanelRenderer']
                          ['largeFormFactorBackgroundThumbnail']
                      ['thumbnailLandscapePortraitRenderer']['landscape']
                  ['thumbnails']
              .last['url'],
          'imageMedium': e['defaultPromoPanelRenderer']
                      ['largeFormFactorBackgroundThumbnail']
                  ['thumbnailLandscapePortraitRenderer']['landscape']
              ['thumbnails'][1]['url'],
          'imageStandard': e['defaultPromoPanelRenderer']
                      ['largeFormFactorBackgroundThumbnail']
                  ['thumbnailLandscapePortraitRenderer']['landscape']
              ['thumbnails'][2]['url'],
          'imageMax': e['defaultPromoPanelRenderer']
                          ['largeFormFactorBackgroundThumbnail']
                      ['thumbnailLandscapePortraitRenderer']['landscape']
                  ['thumbnails']
              .last['url'],
        };
      }).toList();

      return result;
    } catch (e) {
      Logger.root.severe('Error in formatHeadItems: $e');
      return List.empty();
    }
  }

  Future<Map?> formatVideo({
    required Video video,
    required String quality,
    Map? data,
    bool getUrl = true,
    // bool preferM4a = true,
  }) async {
    if (video.duration?.inSeconds == null) return null;
    List<String> allUrls = [];
    List<Map> urlsData = [];
    String finalUrl = '';
    String expireAt = '0';
    if (getUrl) {
      urlsData = await getYtStreamUrls(video.id.value);
      final Map finalUrlData =
          quality == 'High' ? urlsData.last : urlsData.first;
      finalUrl = finalUrlData['url'].toString();
      expireAt = finalUrlData['expireAt'].toString();
      allUrls = urlsData.map((e) => e['url'].toString()).toList();
    }
    return {
      'id': video.id.value,
      'album': (data?['album'] ?? '') != ''
          ? data!['album']
          : video.author.replaceAll('- Topic', '').trim(),
      'duration': video.duration?.inSeconds.toString(),
      'title':
          (data?['title'] ?? '') != '' ? data!['title'] : video.title.trim(),
      'artist': (data?['artist'] ?? '') != ''
          ? data!['artist']
          : video.author.replaceAll('- Topic', '').trim(),
      'image': video.thumbnails.maxResUrl,
      'secondImage': video.thumbnails.highResUrl,
      'language': 'YouTube',
      'genre': 'YouTube',
      'expire_at': expireAt,
      'url': finalUrl,
      'allUrls': allUrls,
      'urlsData': urlsData,
      'year': video.uploadDate?.year.toString(),
      '320kbps': 'false',
      'has_lyrics': 'false',
      'release_date': video.publishDate.toString(),
      'album_id': video.channelId.value,
      'subtitle':
          (data?['subtitle'] ?? '') != '' ? data!['subtitle'] : video.author,
      'perma_url': video.url,
    };
    // For invidous
    // if (video['liveNow'] == true) return null;
    // try {
    //   final Uri link = Uri.https(
    //     'invidious.snopyta.org',
    //     'api/v1/videos/${video["videoId"]}',
    //   );
    //   final Response response = await get(link, headers: headers);
    //   if (response.statusCode != 200) {
    //     return {};
    //   }
    //   final jsonData = jsonDecode(response.body) as Map;
    //   final urls = (jsonData['adaptiveFormats'] as List)
    //       .where((e) => e['container'] == 'm4a');

    //   return {
    //     'id': jsonData['videoId'],
    //     'album': jsonData['author'],
    //     'duration': jsonData['lengthSeconds'],
    //     'title': jsonData['title'],
    //     'artist': jsonData['author'],
    //     'image': jsonData['videoThumbnails'][0]['url'],
    //     'secondImage': jsonData['videoThumbnails'][2]?['url'],
    //     'language': 'YouTube',
    //     'genre': 'YouTube',
    //     'url':
    //         'https://yewtu.be/latest_version?id=${video["videoId"]}&itag=${quality == "High" ? 140 : 139}&local=true&listen=1',
    //     'lowUrl':
    //         'https://yewtu.be/latest_version?id=09cZRYupO4s&itag=139&local=true&listen=1',
    //     'highUrl':
    //         'https://yewtu.be/latest_version?id=09cZRYupO4s&itag=140&local=true&listen=1',
    //     'year': jsonData['published'].toString().yearFromEpoch,
    //     '320kbps': 'false',
    //     'has_lyrics': 'false',
    //     'release_date': jsonData['published'].toString().dateFromEpoch,
    //     'album_id': jsonData['authorId'].toString(),
    //     'artist_id': jsonData['authorId'].toString(),
    //     'subtitle': jsonData['author'],
    //     'perma_url': 'https://youtube.com/watch?v=${jsonData["videoId"]}',
    //   };
    // } catch (e) {
    //   return {};
    // }
  }

  Future<List<Map>> fetchSearchResults(String query) async {
    final List<Video> searchResults = await yt.search.search(query);
    final List<Map> videoResult = [];
    for (final Video vid in searchResults) {
      final res = await formatVideo(video: vid, quality: 'High', getUrl: false);
      if (res != null) videoResult.add(res);
    }
    return [
      {
        'title': 'Videos',
        'items': videoResult,
        'allowViewAll': false,
      }
    ];
    // return searchResults;

    // For parsing html
    // Uri link = Uri.https(searchAuthority, searchPath, {"search_query": query});
    // final Response response = await get(link);
    // if (response.statusCode != 200) {
    // return [];
    // }
    // List searchResults = RegExp(
    // r'\"videoId\"\:\"(.*?)\",\"thumbnail\"\:\{\"thumbnails\"\:\[\{\"url\"\:\"(.*?)".*?\"title\"\:\{\"runs\"\:\[\{\"text\"\:\"(.*?)\"\}\].*?\"longBylineText\"\:\{\"runs\"\:\[\{\"text\"\:\"(.*?)\",.*?\"lengthText\"\:\{\"accessibility\"\:\{\"accessibilityData\"\:\{\"label\"\:\"(.*?)\"\}\},\"simpleText\"\:\"(.*?)\"\},\"viewCountText\"\:\{\"simpleText\"\:\"(.*?) views\"\}.*?\"commandMetadata\"\:\{\"webCommandMetadata\"\:\{\"url\"\:\"(/watch?.*?)\".*?\"shortViewCountText\"\:\{\"accessibility\"\:\{\"accessibilityData\"\:\{\"label\"\:\"(.*?) views\"\}\},\"simpleText\"\:\"(.*?) views\"\}.*?\"channelThumbnailSupportedRenderers\"\:\{\"channelThumbnailWithLinkRenderer\"\:\{\"thumbnail\"\:\{\"thumbnails\"\:\[\{\"url\"\:\"(.*?)\"')
    // .allMatches(response.body)
    // .map((m) {
    // List<String> parts = m[6].toString().split(':');
    // int dur;
    // if (parts.length == 3)
    // dur = int.parse(parts[0]) * 60 * 60 +
    // int.parse(parts[1]) * 60 +
    // int.parse(parts[2]);
    // if (parts.length == 2)
    // dur = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    // if (parts.length == 1) dur = int.parse(parts[0]);

    // return {
    //   'id': m[1],
    //   'image': m[2],
    //   'title': m[3],
    //     'longLength': m[5],
    //     'length': m[6],
    //     'totalViewsCount': m[7],
    //     'url': 'https://www.youtube.com' + m[8],
    //     'album': '',
    //     'channelName': m[4],
    //     'channelImage': m[11],
    //     'duration': dur.toString(),
    //     'longViews': m[9] + ' views',
    //     'views': m[10] + ' views',
    //     'artist': '',
    //     "year": '',
    //     "language": '',
    //     "320kbps": '',
    //     "has_lyrics": '',
    //     "release_date": '',
    //     "album_id": '',
    //     'subtitle': '',
    //   };
    // }).toList();
    // For invidous
    // try {
    //   final Uri link =
    //       Uri.https('invidious.snopyta.org', 'api/v1/search', {'q': query});
    //   final Response response = await get(link, headers: headers);
    //   if (response.statusCode != 200) {
    //     return [];
    //   }
    //   return jsonDecode(response.body) as List;
    // } catch (e) {
    //   return [];
    // }
  }

  String getExpireAt(String url) {
    return RegExp('expire=(.*?)&').firstMatch(url)!.group(1) ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 5.5).toString();
  }

  Future<List<Map>> getYtStreamUrls(String videoId) async {
    try {
      List<Map> urlData = [];

      // check cache first
      if (Hive.box('ytlinkcache').containsKey(videoId)) {
        final cachedData = Hive.box('ytlinkcache').get(videoId);
        if (cachedData is List) {
          int minExpiredAt = 0;
          for (final e in cachedData) {
            final int cachedExpiredAt = int.parse(e['expireAt'].toString());
            if (minExpiredAt == 0 || cachedExpiredAt < minExpiredAt) {
              minExpiredAt = cachedExpiredAt;
            }
          }

          if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 >
              minExpiredAt) {
            // cache expired
            urlData = await getUri(videoId);
          } else {
            // giving cache link
            Logger.root.info('cache found for $videoId');
            urlData = cachedData as List<Map>;
          }
        } else {
          // old version cache is present
          urlData = await getUri(videoId);
        }
      } else {
        //cache not present
        urlData = await getUri(videoId);
      }

      try {
        await Hive.box('ytlinkcache')
            .put(
              videoId,
              urlData,
            )
            .onError(
              (error, stackTrace) => Logger.root.severe(
                'Hive Error in formatVideo, you probably forgot to open box.\nError: $error',
              ),
            );
      } catch (e) {
        Logger.root.severe(
          'Hive Error in formatVideo, you probably forgot to open box.\nError: $e',
        );
      }

      return urlData;
    } catch (e) {
      Logger.root.severe('Error in getYtStreamUrls: $e');
      return [];
    }
  }

  Future<List<Map>> getUri(
    String videoId,
    // {bool preferM4a = true}
  ) async {
    final List<AudioOnlyStreamInfo> sortedStreamInfo =
        await getStreamInfo(videoId);
    return sortedStreamInfo
        .map(
          (e) => {
            'bitrate': e.bitrate.kiloBitsPerSecond.round().toString(),
            'codec': e.codec.subtype,
            'qualityLabel': e.qualityLabel,
            'size': e.size.totalMegaBytes.toStringAsFixed(2),
            'url': e.url.toString(),
            'expireAt': getExpireAt(e.url.toString()),
          },
        )
        .toList();
  }

  Future<List<AudioOnlyStreamInfo>> getStreamInfo(
    String videoId, {
    bool onlyMp4 = false,
  }) async {
    final StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(VideoId(videoId));
    final List<AudioOnlyStreamInfo> sortedStreamInfo = manifest.audioOnly
        .toList()
      ..sort((a, b) => a.bitrate.compareTo(b.bitrate));
    if (onlyMp4 || Platform.isIOS || Platform.isMacOS) {
      final List<AudioOnlyStreamInfo> m4aStreams = sortedStreamInfo
          .where((element) => element.audioCodec.contains('mp4'))
          .toList();

      if (m4aStreams.isNotEmpty) {
        return m4aStreams;
      }
    }

    return sortedStreamInfo;
  }

  Stream<List<int>> getStreamClient(
    AudioOnlyStreamInfo streamInfo,
  ) {
    return yt.videos.streamsClient.get(streamInfo);
  }
}
