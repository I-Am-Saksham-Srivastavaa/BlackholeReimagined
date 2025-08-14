import 'package:flutter/material.dart';
import 'package:oryn/index.dart';

class SearchResultPage extends StatelessWidget {
  final bool fetched;
  final List<Map<dynamic, dynamic>> searchedList;
  final String searchType;
  final String query;
  final Future<void> Function() onFetchResults;
  final VoidCallback onNothingFound;

  const SearchResultPage({
    super.key,
    required this.fetched,
    required this.searchedList,
    required this.searchType,
    required this.query,
    required this.onFetchResults,
    required this.onNothingFound,
  });

  @override
  Widget build(BuildContext context) {
    if (!fetched) {
      return const Center(child: CircularProgressIndicator());
    }
    if (searchedList.isEmpty) {
      onNothingFound();
      return emptyScreen(
        context,
        0,
        ':( ',
        100,
        CustomLocalizations.of(context).sorry,
        60,
        CustomLocalizations.of(context).resultsNotFound,
        20,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: searchedList.map((Map section) {
          final String title = section['title'].toString();
          final List? items = section['items'] as List?;
          if (items == null || items.isEmpty) {
            return const SizedBox();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 17, right: 15, top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (section['allowViewAll'] == true)
                      GestureDetector(
                        onTap: () {
                          // Handle "View All" navigation
                        },
                        child: Row(
                          children: [
                            Text(
                              CustomLocalizations.of(context).viewAll,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: items.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MediaTile(
                    title: item['title'].toString(),
                    subtitle: item['subtitle'].toString(),
                    leadingWidget: imageCard(
                      borderRadius: 7.0,
                      placeholderImage: AssetImage('assets/cover.jpg'),
                      imageUrl: item['image'].toString(),
                    ),
                    onTap: () {
                      // Handle item tap
                    },
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
