import 'package:flutter/material.dart';
import 'package:oryn/index.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlayerGradientSelection extends StatefulWidget {
  const PlayerGradientSelection({super.key});

  @override
  State<PlayerGradientSelection> createState() =>
      _PlayerGradientSelectionState();
}

class _PlayerGradientSelectionState extends State<PlayerGradientSelection> {
  final List<String> types = [
    'simple',
    'halfLight',
    'halfDark',
    'fullLight',
    'fullDark',
    'fullMix',
  ];
  final List<String> recommended = [
    'halfDark',
    'fullDark',
  ];
  final Map<String, String> typeMapping = {
    'simple': 'Simple',
    'halfLight': 'Half Light',
    'halfDark': 'Half Dark',
    'fullLight': 'Full Light',
    'fullDark': 'Full Dark',
    'fullMix': 'Full Mix',
  };
  final List<Color?> gradientColor = [Colors.lightGreen, Colors.teal];
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'halfDark')
      .toString();

  List<Color> _getGradientColors(String type, BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    if (type == 'simple') {
      return isDarkTheme
          ? currentTheme.getBackGradient()
          : [const Color(0xfff5f9ff), Colors.white];
    }

    if (isDarkTheme) {
      final firstColor = (type == 'halfDark' || type == 'fullDark')
          ? gradientColor[1] ?? Colors.grey[900]!
          : gradientColor[0] ?? Colors.grey[900]!;
      final secondColor =
          type == 'fullMix' ? gradientColor[1] ?? Colors.black : Colors.black;
      return [firstColor, secondColor];
    }

    return [gradientColor[0] ?? const Color(0xfff5f9ff), Colors.white];
  }

  Alignment _getGradientEnd(String type) {
    if (type == 'simple') return Alignment.bottomRight;
    if (type == 'halfLight' || type == 'halfDark') return Alignment.center;
    return Alignment.bottomCenter;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView.builder(
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    gradientType = type;
                    Hive.box('settings').put('gradientType', type);
                  });
                },
                child: SizedBox(
                  child: Stack(
                    children: [
                      Card(
                        elevation: 5,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: gradientType == type ? 2.0 : 0.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        // ignore: use_decorated_box
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: type == 'simple'
                                  ? Alignment.topLeft
                                  : Alignment.topCenter,
                              end: _getGradientEnd(type),
                              colors: _getGradientColors(type, context),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const Spacer(
                            flex: 3,
                          ),
                          Center(
                            child: Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FittedBox(
                                child: SizedBox.square(
                                  dimension:
                                      MediaQuery.sizeOf(context).width / 5,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 3,
                          ),
                          Center(
                            child: Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FittedBox(
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 5,
                                  height: MediaQuery.sizeOf(context).width / 25,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: FittedBox(
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 5,
                                  height: MediaQuery.sizeOf(context).width / 25,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 3,
                          ),
                        ],
                      ),
                      if (gradientType == type)
                        const Center(child: Icon(Icons.check_rounded)),
                      if (recommended.contains(type))
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.star_rounded),
                          ),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(typeMapping[type]!),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}
