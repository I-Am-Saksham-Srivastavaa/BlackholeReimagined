import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).canvasColor, // Use theme color
        highlightColor:
            Theme.of(context).colorScheme.secondary, // Use theme color
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Column(
            children: [
              _discoverShimmer(),
              _contentShimmer(),
              _contentShimmer(),
              _contentShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _discoverShimmer() {
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: BasicShimmerContainer(Size(220, 30)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 100,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: .20 / 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (_, item) {
                return const ListTile(
                  contentPadding: EdgeInsetsDirectional.all(5),
                  leading: BasicShimmerContainer(Size(50, 50)),
                  title: BasicShimmerContainer(Size(90, 20)),
                  subtitle: BasicShimmerContainer(Size(40, 15)),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _contentShimmer() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: BasicShimmerContainer(Size(220, 30)),
        ),
        SizedBox(height: 10),
        ContextListWidget(itemCount: 15),
      ],
    );
  }
}

class ContextListWidget extends StatelessWidget {
  const ContextListWidget({super.key, required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 10),
            child: BasicShimmerContainer(Size(150, 80)),
          );
        },
      ),
    );
  }
}

class BasicShimmerContainer extends StatelessWidget {
  const BasicShimmerContainer(this.size, {super.key, this.radius = 10});
  final Size size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.grey[400], // Use a fully opaque color
        border: Border.all(color: Colors.grey[800]!), // Add dark border
      ),
      height: size.height,
      width: size.width,
    );
  }
}
