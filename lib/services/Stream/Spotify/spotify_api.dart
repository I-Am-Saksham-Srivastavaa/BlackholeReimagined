import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

class SpotifyApi {
  final Map<String, List<Map<String, dynamic>>> _playlistTracksCache = {};
  final List<String> _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  /// You can signup for spotify developer account and get your own clientID and clientSecret incase you don't want to use these
  String clientID = '334caa7fdc474dcf84348de6d9a1adf3';
  String clientSecret = '308c7ff10fa74b468ff8e9d177900075';

  final String redirectUrl = 'blackhole://spotify/auth';
  final String spotifyApiUrl = 'https://accounts.spotify.com/api';
  final String spotifyApiBaseUrl = 'https://api.spotify.com/v1';
  final String spotifyUserPlaylistEndpoint = '/me/playlists';
  final String spotifyPlaylistTrackEndpoint = '/playlists';
  final String spotifyRegionalChartsEndpoint = '/views/charts-regional';
  final String spotifyFeaturedPlaylistsEndpoint = '/browse/featured-playlists';
  final String spotifyBaseUrl = 'https://accounts.spotify.com';
  final String requestToken = 'https://accounts.spotify.com/api/token';

  String requestAuthorization() =>
      'https://accounts.spotify.com/authorize?client_id=$clientID&response_type=code&redirect_uri=$redirectUrl&scope=${_scopes.join('%20')}';

  // Future<String> authenticate() async {
  //   final url = SpotifyApi().requestAuthorization();
  //   final callbackUrlScheme = 'accounts.spotify.com';

  //   try {
  //     final result = await FlutterWebAuth.authenticate(
  //         url: url, callbackUrlScheme: callbackUrlScheme);
  // print('got result....');
  // print(result);
  //     return result;
  //   } catch (e) {
  // print('Got error: $e');
  //     return 'ERROR';
  //   }
  // }

  Future<List<String>> getAccessToken({
    String? code,
    String? refreshToken,
  }) async {
    final Map<String, String> headers = {
      'Authorization':
          "Basic ${base64.encode(utf8.encode("$clientID:$clientSecret"))}",
    };

    Map<String, String>? body;
    if (code != null) {
      body = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUrl,
      };
    } else if (refreshToken != null) {
      body = {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      };
    }

    if (body == null) {
      return [];
    }

    try {
      final Uri path = Uri.parse(requestToken);
      final response = await post(path, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body) as Map;
        final accessToken = result['access_token'].toString();
        final refreshToken = result['refresh_token'].toString();
        final expiresIn = result['expires_in'].toString();

        Logger.root.info('Access Token: $accessToken');
        Logger.root.info('Refresh Token: $refreshToken');
        Logger.root.info('Expires In: $expiresIn');

        return <String>[
          accessToken,
          refreshToken,
          expiresIn,
        ];
      } else {
        Logger.root.severe(
          'Error in getAccessToken, called: $path, returned: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      Logger.root.severe('Error in getting spotify access token: $e');
    }
    return [];
  }

  Future<List> getUserPlaylists(String accessToken) async {
    try {
      final Uri path =
          Uri.parse('$spotifyApiBaseUrl$spotifyUserPlaylistEndpoint?limit=50');

      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final List playlists = result['items'] as List;
        return playlists;
      } else {
        Logger.root.severe(
          'Error in getUserPlaylists, called: $path, returned: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      Logger.root.severe('Error in getting spotify user playlists: $e');
    }
    return [];
  }

  Future<Map> searchTrack({
    required String accessToken,
    required String query,
    int limit = 10,
    String type = 'track',
  }) async {
    if (query.trim().isEmpty) {
      Logger.root.warning('searchTrack called with an empty query.');
      return {'error': 'Query cannot be empty'};
    }

    final Uri path = Uri.parse(
      '$spotifyApiBaseUrl/search?q=$query&type=$type&limit=$limit',
    );

    try {
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map;
        return result;
      } else {
        final errorMsg = jsonDecode(response.body)['error']?['message'] ?? 'Unknown error';
        Logger.root.severe(
          'Error in searchTrack, called: $path, returned: ${response.statusCode}, message: $errorMsg',
        );
        return {'error': errorMsg};
      }
    } catch (e, stacktrace) {
      Logger.root.severe('Exception in searchTrack: $e', stacktrace);
      return {'error': e.toString()};
    }
  }

  Future<Map> getTrackDetails(String accessToken, String trackId) async {
    final Uri path = Uri.parse(
      '$spotifyApiBaseUrl/tracks/$trackId',
    );
    final response = await get(
      path,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map;
      return result;
    } else {
      Logger.root.severe(
        'Error in getTrackDetails, called: $path, returned: ${response.statusCode}',
        response.body,
      );
    }
    return {};
  }


  Stream<List<Map<String, dynamic>>> streamAllTracksOfPlaylist(
    String accessToken,
    String playlistId,
  ) async* {
    // Check Cache First
    if (_playlistTracksCache.containsKey(playlistId)) {
      Logger.root.info('✅ Cache hit for playlist: $playlistId');
      yield _playlistTracksCache[playlistId]!;
      return;
    }

    final List<Map<String, dynamic>> allTracks = [];

    final Map<String, dynamic> firstPage = await getHundredTracksOfPlaylist(
      accessToken,
      playlistId,
      0,
    );

    if (firstPage.containsKey('error')) {
      Logger.root.severe(
        '❌ Error fetching first page for playlist $playlistId: ${firstPage['error']}',
      );
      yield [];
      return;
    }

    final int total = firstPage['total'] as int;
    final List<Map<String, dynamic>> firstTracks =
        List<Map<String, dynamic>>.from(firstPage['tracks'] as List);
    allTracks.addAll(firstTracks);
    yield firstTracks;

    for (int offset = 100; offset < total; offset += 100) {
      final Map<String, dynamic> nextPage = await getHundredTracksOfPlaylist(
        accessToken,
        playlistId,
        offset,
      );

      if (nextPage.containsKey('error')) {
        Logger.root.warning(
          '⚠️ Partial failure at offset $offset for playlist $playlistId: ${nextPage['error']}',
        );
        break;
      }

      final List<Map<String, dynamic>> nextTracks =
          List<Map<String, dynamic>>.from(nextPage['tracks'] as List);
      allTracks.addAll(nextTracks);
      yield nextTracks;
    }

    // Cache after successful fetch
    _playlistTracksCache[playlistId] = allTracks;
    Logger.root.info('✅ Cached ${allTracks.length} tracks for $playlistId');
  }

  /// Returns all tracks of a playlist (in one go, non-streaming)
  Future<List<Map<String, dynamic>>> getAllTracksOfPlaylist(
    String accessToken,
    String playlistId,
  ) async {
    final List<Map<String, dynamic>> tracks = [];
    int totalTracks = 100;

    // If the tracks are cached, we return the cached version
    if (_playlistTracksCache.containsKey(playlistId)) {
      Logger.root.info('✅ Returning cached tracks for $playlistId');
      return _playlistTracksCache[playlistId]!;
    }

    // Fetch the first batch of tracks
    final Map<String, dynamic> data = await getHundredTracksOfPlaylist(
      accessToken,
      playlistId,
      0,
    );

    if (data.containsKey('error')) {
      Logger.root.severe('❌ Error in getAllTracksOfPlaylist: ${data['error']}');
      return [];
    }

    totalTracks = data['total'] as int;
    tracks.addAll(List<Map<String, dynamic>>.from(data['tracks'] as List));

    // If there are more than 100 tracks, we fetch the remaining tracks
    for (int offset = 100; offset < totalTracks; offset += 100) {
      final Map<String, dynamic> nextData = await getHundredTracksOfPlaylist(
        accessToken,
        playlistId,
        offset,
      );
      if (nextData.containsKey('error')) {
        Logger.root.warning(
          '⚠️ Partial error at offset $offset: ${nextData['error']}',
        );
        break;
      }
      tracks
          .addAll(List<Map<String, dynamic>>.from(nextData['tracks'] as List));
    }

    // Cache all tracks after fetching
    _playlistTracksCache[playlistId] = tracks;
    return tracks;
  }

  /// Fetches up to 100 tracks starting from a given offset
  Future<Map<String, dynamic>> getHundredTracksOfPlaylist(
    String accessToken,
    String playlistId,
    int offset,
  ) async {
    final Uri path = Uri.parse(
      '$spotifyApiBaseUrl$spotifyPlaylistTrackEndpoint/$playlistId/tracks?limit=100&offset=$offset',
    );

    try {
      final response = await get(
        path,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> tracks =
            List<Map<String, dynamic>>.from(result['items'] as List);
        final int total = result['total'] as int;
        return {'tracks': tracks, 'total': total};
      } else if (response.statusCode == 404) {
        Logger.root.warning(
          '⚠️ Playlist not found: $playlistId (status 404)',
        );
        return {'error': 'Playlist not found'};
      } else {
        final errorMsg = result['error']?['message'] ?? 'Unknown error';
        Logger.root.severe(
          '❌ Error fetching tracks: $errorMsg (status ${response.statusCode})',
        );
        return {'error': errorMsg};
      }
    } catch (e, stacktrace) {
      Logger.root.severe('❌ Exception during track fetch: $e', stacktrace);
      return {'error': e.toString()};
    }
  }
}
