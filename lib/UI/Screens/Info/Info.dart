import 'package:oryn/index.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double separationHeight = MediaQuery.sizeOf(context).height * 0.035;

    return GradientContainer(
      child: Stack(
        children: [
          Positioned(
            left: MediaQuery.sizeOf(context).width / 2,
            top: MediaQuery.sizeOf(context).width / 5,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: const Image(
                fit: BoxFit.fill,
                image: AssetImage(
                  'assets/icon-white-trans.png',
                ),
              ),
            ),
          ),
          const GradientContainer(
            child: null,
            opacity: true,
          ),
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
              title: Text(
                CustomLocalizations.of(context).about,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const SizedBox(
                          width: 150,
                          child: Image(
                            image: AssetImage('assets/ic_launcher.png'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        CustomLocalizations.of(context).appTitle,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('v$appVersion'),
                    ],
                  ),
                  SizedBox(
                    height: separationHeight,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    child: Column(
                      children: [
                        Text(
                          CustomLocalizations.of(context).aboutLine1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            launchUrl(
                              Uri.parse(
                                'https://github.com/I-Am-Saksham-Srivastavaa/BlackHole',
                              ),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width / 4,
                            child: Image(
                              image: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const AssetImage(
                                      'assets/GitHub_Logo_White.png',
                                    )
                                  : const AssetImage('assets/GitHub_Logo.png'),
                            ),
                          ),
                        ),
                        Text(
                          CustomLocalizations.of(context).aboutLine2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: separationHeight,
                  ),
                  Column(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          launchUrl(
                            Uri.parse(
                              'https://www.buymeacoffee.com/',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width / 2,
                          child: const Image(
                            image: AssetImage('assets/black-button.png'),
                          ),
                        ),
                      ),
                      Text(
                        CustomLocalizations.of(context).or,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          const String upiUrl =
                              'upi://pay?pa=the.saksham.srivastavaa-1@oksbi';
                          launchUrl(
                            Uri.parse(upiUrl),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        onLongPress: () {
                          copyToClipboard(
                            context: context,
                            text: 'the.saksham.srivastavaa-1@oksbi',
                            displayText: CustomLocalizations.of(
                              context,
                            ).upiCopied,
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width / 2,
                          child: Image(
                            image: AssetImage(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 'assets/gpay-white.png'
                                  : 'assets/gpay-white.png',
                            ),
                          ),
                        ),
                      ),
                      Text(
                        CustomLocalizations.of(context).sponsor,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: separationHeight,
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                      child: Center(
                        child: Text(
                          CustomLocalizations.of(context).madeBy,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Text(
                        CustomLocalizations.of(context).remadeBy,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
