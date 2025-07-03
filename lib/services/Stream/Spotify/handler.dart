import 'package:oryn/index.dart';
import 'package:flutter/material.dart';

class SpotifyUrlHandler extends StatelessWidget {
  final String id;
  final String type;
  const SpotifyUrlHandler({super.key, required this.id, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 'track') {
      callSpotifyFunction(
        function: (String accessToken) {
          SpotifyApi().getTrackDetails(accessToken, id).then((value) {
            showBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SearchPage(
                  query: (value['artists'] != null &&
                          (value['artists'] as List).isNotEmpty)
                      ? '${value["name"]} by ${value["artists"][0]["name"]}'
                      : value['name'].toString(),
                );
              },
            );
          });
        },
      );
    }
    return Container();
  }
}
