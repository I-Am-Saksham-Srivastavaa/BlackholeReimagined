import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:oryn/index.dart';

class Watermark extends StatelessWidget {
  const Watermark({
    super.key,
    required this.widget,
  });

  final HomeScreen widget;

  @override
  Widget build(BuildContext context) {
    final bool rotated =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Positioned(
      top: rotated ? 0 : -MediaQuery.of(context).size.height * 0.1,
      right: rotated ? 20 : -MediaQuery.of(context).size.height * 0.1,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.07,
          child: ValueListenableBuilder<Source>(
            valueListenable: widget.source,
            builder: (context, source, _) {
              IconData iconData;
              switch (source) {
                case Source.Spotify:
                  iconData = MdiIcons.spotify;
                case Source.YouTube:
                  iconData = MdiIcons.youtube;
                case Source.YouTubeMusic:
                  iconData = MdiIcons.youtubeTv;
                default:
                  iconData = Icons.music_note;
              }
              return Icon(
                iconData,
                size: MediaQuery.of(context).size.height * 0.3,
                color: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
        ),
      ),
    );
  }
}
