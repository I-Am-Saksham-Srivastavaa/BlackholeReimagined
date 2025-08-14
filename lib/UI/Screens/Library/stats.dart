import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:hive/hive.dart';

class Stats extends StatelessWidget {
  const Stats({super.key});

  int get songsPlayed => Hive.box('stats').length;
  Map get mostPlayed =>
      Hive.box('stats').get('mostPlayed', defaultValue: {}) as Map;

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text(CustomLocalizations.of(context).stats),
          centerTitle: true,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                elevation: 10.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        songsPlayed.toString(),
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(CustomLocalizations.of(context).songsPlayed),
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                elevation: 10.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(CustomLocalizations.of(context).mostPlayedSong),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        mostPlayed['title']?.toString() ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
