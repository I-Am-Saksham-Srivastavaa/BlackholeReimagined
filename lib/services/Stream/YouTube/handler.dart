import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

class YtUrlHandler extends StatelessWidget {
  final String id;
  final String type;
  const YtUrlHandler({super.key, required this.id, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 'v') {
      YouTubeServices.instance
          .formatVideoFromId(id: id)
          .then((Map? response) async {
        if (response != null) {
          PlayerInvoke.init(
            songsList: [response],
            index: 0,
            isOffline: false,
            recommend: false,
          );
        }
        Scaffold.of(context).openEndDrawer();
      });
    } else if (type == 'list') {
      Future.delayed(const Duration(milliseconds: 500), () {
        showBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return YouTubePlaylist(
              playlistId: id,
              type: '',
              // playlistImage: '',
              // playlistName: '',
              // playlistSubtitle: '',
              // playlistSecondarySubtitle: '',
            );
          },
        );
      });
    }
    return const SizedBox();
  }
}
