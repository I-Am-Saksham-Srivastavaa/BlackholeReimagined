import 'package:oryn/index.dart';
import 'package:flutter/material.dart';

class SaavnUrlHandler extends StatelessWidget {
  final String token;
  final String type;
  const SaavnUrlHandler({super.key, required this.token, required this.type});

  @override
  Widget build(BuildContext context) {
    SaavnAPI().getSongFromToken(token, type).then((value) {
      if (type == 'song') {
        PlayerInvoke.init(
          songsList: value['songs'] as List,
          index: 0,
          isOffline: false,
        );
        Scaffold.of(context).openEndDrawer();
      }
      if (type == 'album' || type == 'playlist' || type == 'featured') {
        showBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SongsListPage(
              listItem: value,
            );
          },
        );
      }
    });
    return Container();
  }
}
