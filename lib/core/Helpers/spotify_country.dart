import 'package:flutter/material.dart';
import 'package:oryn/index.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SpotifyCountry {
  Future<String> changeCountry({required BuildContext context}) async {
    String region =
        Hive.box('settings').get('region', defaultValue: 'India') as String;
    if (!CountryCodes.localChartCodes.containsKey(region)) {
      region = 'India';
    }

    await showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        const Map<String, String> codes = CountryCodes.localChartCodes;
        final List<String> countries = codes.keys.toList();
        return BottomGradientContainer(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              10,
              0,
              10,
            ),
            itemCount: countries.length,
            itemBuilder: (context, idx) {
              return ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  title: Text(
                    countries[idx],
                  ),
                  leading: Radio(
                    value: countries[idx],
                    groupValue: region,
                    onChanged: (value) {
                      localSongs = [];
                      region = countries[idx];
                      localFetched = false;
                      localFetchFinished.value = false;
                      Hive.box('settings').put('region', region);
                      Navigator.pop(context);
                    },
                  ),
                  selected: region == countries[idx],
                  onTap: () {
                    localSongs = [];
                    region = countries[idx];
                    localFetchFinished.value = false;
                    Hive.box('settings').put('region', region);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        );
      },
    );
    return region;
  }
}
