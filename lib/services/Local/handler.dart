import 'package:flutter/material.dart';
import 'package:oryn/index.dart';
import 'package:on_audio_query/on_audio_query.dart';

class OfflinePlayHandler extends StatelessWidget {
  final String id;
  const OfflinePlayHandler({super.key, required this.id});

  Future<List> playOfflineSong(String id) async {
    final OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
    await offlineAudioQuery.requestPermission();

    final List<SongModel> songs = await offlineAudioQuery.getSongs();
    final int index = songs.indexWhere((i) => i.id.toString() == id);

    return [index, songs];
  }

  @override
  Widget build(BuildContext context) {
    playOfflineSong(id).then((value) {
      PlayerInvoke.init(
        songsList: value[1] as List<SongModel>,
        index: value[0] as int,
        isOffline: true,
        recommend: false,
      );
      Scaffold.of(context).openEndDrawer();
    });
    return const SizedBox();
  }
}
