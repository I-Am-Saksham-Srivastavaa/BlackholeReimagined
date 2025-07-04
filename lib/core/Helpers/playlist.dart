import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import 'package:oryn/index.dart';

bool checkPlaylist(String name, String key) {
  if (name != 'Favorite Songs') {
    Hive.openBox(name).then((value) {
      return Hive.box(name).containsKey(key);
    });
  }
  return Hive.box(name).containsKey(key);
}

Future<void> removeLiked(String key) async {
  final Box likedBox = Hive.box('Favorite Songs');
  likedBox.delete(key);
  // setState(() {});
}

Future<void> addMapToPlaylist(String name, Map info) async {
  if (name != 'Favorite Songs') await Hive.openBox(name);
  final Box playlistBox = Hive.box(name);
  final List songs = playlistBox.values.toList();
  info.addEntries([MapEntry('dateAdded', DateTime.now().toString())]);
  addSongsCount(
    name,
    playlistBox.values.length + 1,
    songs.length >= 4 ? songs.sublist(0, 4) : songs.sublist(0, songs.length),
  );
  playlistBox.put(info['id'].toString(), info);
}

Future<void> addItemToPlaylist(String name, MediaItem mediaItem) async {
  if (name != 'Favorite Songs') await Hive.openBox(name);
  final Box playlistBox = Hive.box(name);
  final Map info = MediaItemConverter.mediaItemToMap(mediaItem);
  info.addEntries([MapEntry('dateAdded', DateTime.now().toString())]);
  final List songs = playlistBox.values.toList();
  addSongsCount(
    name,
    playlistBox.values.length + 1,
    songs.length >= 4 ? songs.sublist(0, 4) : songs.sublist(0, songs.length),
  );
  playlistBox.put(mediaItem.id, info);
}

Future<void> addPlaylist(String inputName, List data) async {
  final RegExp avoid = RegExp(r'[\.\\\*\:\"\?#/;\|]');
  String name = inputName.replaceAll(avoid, '').replaceAll('  ', ' ');

  final List playlistNames =
      Hive.box('settings').get('playlistNames', defaultValue: []) as List;

  if (name.trim() == '') {
    name = 'Playlist ${playlistNames.length}';
  }
  while (playlistNames.contains(name)) {
    // ignore: use_string_buffers
    name += ' (1)';
  }

  await Hive.openBox(name);
  final Box playlistBox = Hive.box(name);

  addSongsCount(
    name,
    data.length,
    data.length >= 4 ? data.sublist(0, 4) : data.sublist(0, data.length),
  );
  final Map result = {for (final v in data) v['id'].toString(): v};
  playlistBox.putAll(result);

  playlistNames.add(name);
  Hive.box('settings').put('playlistNames', playlistNames);
}
