import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

class PlaylistHead extends StatelessWidget {
  final List songsList;
  final bool offline;
  final bool fromDownloads;
  const PlaylistHead({
    super.key,
    required this.songsList,
    required this.fromDownloads,
    required this.offline,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 20.0, right: 10.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${songsList.length} ${CustomLocalizations.of(
              context,
            ).songs}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              PlayerInvoke.init(
                songsList: songsList,
                index: 0,
                isOffline: offline,
                fromDownloads: fromDownloads,
                recommend: false,
                shuffle: true,
              );
            },
            icon: const Icon(Icons.shuffle_rounded),
            label: Text(
              CustomLocalizations.of(context).shuffle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () {
              PlayerInvoke.init(
                songsList: songsList,
                index: 0,
                isOffline: offline,
                fromDownloads: fromDownloads,
                recommend: false,
              );
            },
            tooltip: CustomLocalizations.of(context).shuffle,
            icon: const Icon(Icons.play_arrow_rounded),
            iconSize: 30.0,
          ),
        ],
      ),
    );
  }
}
