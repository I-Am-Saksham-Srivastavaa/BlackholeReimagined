import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.source,
    required this.onItemTapped,
    super.key,
  });

  final ValueNotifier<Source> source;
  final void Function(int) onItemTapped;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String name =
        Hive.box('settings').get('name', defaultValue: 'Guest') as String;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool rotated = MediaQuery.sizeOf(context).height < screenWidth;
    return SafeArea(
      child: Stack(
        children: [
          Watermark(widget: widget),
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxScrolled,
            ) {
              return <Widget>[
                SliverAppBar(
                  actions: [actions(source: widget.source)],
                  expandedHeight: 135,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  // pinned: true,
                  toolbarHeight: 65,
                  // floating: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: GestureDetector(
                          onTap: () async {
                            showTextInputDialog(
                              context: context,
                              title: 'Name',
                              initialText: name,
                              keyboardType: TextInputType.name,
                              onSubmitted:
                                  (String value, BuildContext context) {
                                Hive.box('settings').put(
                                  'name',
                                  value.trim(),
                                );
                                name = value.trim();
                                Navigator.pop(context);
                              },
                            );
                            // setState(() {});
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                height: 60,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15.0,
                                    ),
                                    child: Text(
                                      CustomLocalizations.of(
                                        context,
                                      ).homeGreet,
                                      style: TextStyle(
                                        letterSpacing: 2,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: Hive.box(
                                        'settings',
                                      ).listenable(),
                                      builder: (
                                        BuildContext context,
                                        Box box,
                                        Widget? child,
                                      ) {
                                        return Text(
                                          (box.get('name') == null ||
                                                  box.get('name') == '')
                                              ? 'Guest'
                                              : box
                                                  .get(
                                                    'name',
                                                  )
                                                  .split(
                                                    ' ',
                                                  )[0]
                                                  .toString(),
                                          style: const TextStyle(
                                            letterSpacing: 2,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  stretch: true,
                  toolbarHeight: 65,
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, child) {
                        return GestureDetector(
                          child: AnimatedContainer(
                            width: (!_scrollController.hasClients ||
                                    _scrollController.positions.length > 1)
                                ? MediaQuery.sizeOf(context).width
                                : max(
                                    MediaQuery.sizeOf(context).width -
                                        _scrollController.offset
                                            .roundToDouble(),
                                    MediaQuery.sizeOf(context).width -
                                        (rotated ? 0 : 75),
                                  ),
                            height: 55.0,
                            duration: const Duration(
                              milliseconds: 150,
                            ),
                            padding: const EdgeInsets.all(2.0),
                            // margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                              color: Theme.of(context).cardColor,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5.0,
                                  offset: Offset(1.5, 1.5),
                                  // shadow direction: bottom right
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  CupertinoIcons.search,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  CustomLocalizations.of(
                                    context,
                                  ).searchText,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () => showBottomSheet(
                            context: context,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.only(top: 42.0),
                              child: const SearchPage(
                                query: '',
                                fromHome: true,
                                autofocus: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ];
            },
            body: HomeContext(
              onItemTapped: widget.onItemTapped,
            ),
          ),
          if (!rotated)
            homeDrawer(
              context: context,
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            ),
        ],
      ),
    );
  }
}
