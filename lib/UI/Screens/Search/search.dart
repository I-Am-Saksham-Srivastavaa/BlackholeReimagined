import 'dart:io';

import 'package:flutter/material.dart' hide SearchBar;
import 'package:oryn/index.dart';

import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

class SearchPage extends StatefulWidget {
  final String query;
  final bool fromHome;
  final bool fromDirectSearch;
  final String? searchType;
  final bool autofocus;
  const SearchPage({
    super.key,
    required this.query,
    this.fromHome = false,
    this.fromDirectSearch = false,
    this.searchType,
    this.autofocus = false,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  bool fetchResultCalled = false;
  bool fetched = false;
  bool alertShown = false;
  bool? fromHome;
  List<Map<dynamic, dynamic>> searchedList = [];
  String searchType =
      Hive.box('settings').get('searchType', defaultValue: 'ytm').toString();
  List searchHistory =
      Hive.box('settings').get('search', defaultValue: []) as List;
  bool liveSearch =
      Hive.box('settings').get('liveSearch', defaultValue: true) as bool;
  final ValueNotifier<List<String>> topSearch = ValueNotifier<List<String>>(
    [],
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.query;
    if (widget.searchType != null) {
      searchType = widget.searchType!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchResults() async {
    Logger.root.info(
      'fetching search results for ${query == '' ? widget.query : query}',
    );
    switch (searchType) {
      case 'ytm':
        Logger.root.info('calling yt music search');
        YtMusicService()
            .search(query == '' ? widget.query : query)
            .then((value) {
          setState(() {
            final songSection =
                value.firstWhere((element) => element['title'] == 'Songs');
            songSection['allowViewAll'] = true;
            searchedList = value;
            fetched = true;
          });
        });
      case 'yt':
        Logger.root.info('calling youtube search');
        YouTubeServices.instance
            .fetchSearchResults(query == '' ? widget.query : query)
            .then((value) {
          setState(() {
            searchedList = value;
            fetched = true;
          });
        });
      case 'saavn':
        Logger.root.info('calling saavn search');
        searchedList = await SaavnAPI()
            .fetchSearchResults(query == '' ? widget.query : query);
        for (final element in searchedList) {
          if (element['title'] != 'Top Result') {
            element['allowViewAll'] = true;
          }
        }
        setState(() {
          fetched = true;
        });
    }
  }

  Future<void> getTrendingSearch() async {
    topSearch.value = await SaavnAPI().getTopSearches();
  }

  void addToHistory(String title) {
    final tempquery = title.trim();
    if (tempquery == '') {
      return;
    }
    final idx = searchHistory.indexOf(tempquery);
    if (idx != -1) {
      searchHistory.removeAt(idx);
    }
    searchHistory.insert(
      0,
      tempquery,
    );
    if (searchHistory.length > 10) {
      searchHistory = searchHistory.sublist(0, 10);
    }
    Hive.box('settings').put(
      'search',
      searchHistory,
    );
  }

  @override
  Widget build(BuildContext context) {
    fromHome ??= widget.fromHome;
    if (!fetchResultCalled) {
      fetchResultCalled = true;
      fromHome! ? getTrendingSearch() : fetchResults();
    }
    return GradientContainer(
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SearchBar(
            controller: _controller,
            liveSearch: liveSearch,
            autofocus: widget.autofocus,
            hintText: CustomLocalizations.of(context).searchText,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () {
                if ((fromHome ?? false) || widget.fromDirectSearch) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    fromHome = true;
                    _controller.text = '';
                  });
                }
              },
            ),
            body: (fromHome!)
                ? SearchHistoryWidget(
                    searchHistory: searchHistory,
                    topSearch: topSearch,
                    onHistoryTap: (selectedQuery) {
                      setState(() {
                        fetched = false;
                        query = selectedQuery;
                        addToHistory(query);
                        _controller.text = query;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: query.length),
                        );
                        fetchResultCalled = false;
                        fromHome = false;
                        searchedList = [];
                      });
                    },
                    onDeleteHistory: (index) {
                      setState(() {
                        searchHistory.removeAt(index);
                        Hive.box('settings').put(
                          'search',
                          searchHistory,
                        );
                      });
                    },
                  )
                : SearchResultPage(
                    fetched: fetched,
                    searchedList: searchedList,
                    searchType: searchType,
                    query: query == '' ? widget.query : query,
                    onFetchResults: fetchResults,
                    onNothingFound: () {
                      setState(() {
                        alertShown = true;
                      });
                    },
                  ),
            onSubmitted: (String submittedQuery) {
              setState(() {
                fetched = false;
                fromHome = false;
                fetchResultCalled = false;
                query = submittedQuery;
                _controller.text = submittedQuery;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: query.length),
                );
                searchedList = [];
              });
            },
            onQueryChanged: (changedQuery) {
              return YouTubeServices.instance
                  .getSearchSuggestions(query: changedQuery);
            },
          ),
        ),
      ),
    );
  }
}

class SearchHistoryWidget extends StatelessWidget {
  const SearchHistoryWidget({
    super.key,
    required this.searchHistory,
    required this.topSearch,
    required this.onHistoryTap,
    required this.onDeleteHistory,
  });

  final List searchHistory;
  final ValueNotifier<List<String>> topSearch;
  final ValueChanged<String> onHistoryTap;
  final ValueChanged<int> onDeleteHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5.0,
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(
            height: 65,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              children: List<Widget>.generate(
                searchHistory.length,
                (int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: (Platform.isWindows ||
                              Platform.isLinux ||
                              Platform.isMacOS)
                          ? 5.0
                          : 0.0,
                    ),
                    child: GestureDetector(
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 0; i < searchHistory.length; i++)
                            ListTile(
                              title: Text(searchHistory[i].toString()),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => onDeleteHistory(i),
                              ),
                              onTap: () => onHistoryTap(
                                  searchHistory[i].toString().trim()),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: topSearch,
            builder: (
              BuildContext context,
              List<String> value,
              Widget? child,
            ) {
              if (value.isEmpty) return const SizedBox();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Text(
                          CustomLocalizations.of(context).trendingSearch,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: List<Widget>.generate(
                        value.length,
                        (int index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: (Platform.isWindows ||
                                      Platform.isLinux ||
                                      Platform.isMacOS)
                                  ? 5.0
                                  : 0.0,
                            ),
                            child: ChoiceChip(
                              label: Text(value[index]),
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                fontWeight: FontWeight.normal,
                              ),
                              selected: false,
                              onSelected: (bool selected) {
                                if (selected) {
                                  // Handle trending search chip tap
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
