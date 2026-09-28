import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder cards for the home announcements strip.
///
/// Deliberately mirrors `_buildLargeAnnouncementCard` — same 260×250 size,
/// radius and inner layout — so the first paint doesn't jump when the real
/// announcements arrive.
class AnnouncementShimmer extends StatelessWidget {
  final int itemCount;

  const AnnouncementShimmer({super.key, this.itemCount = 2});

  @override
  Widget build(BuildContext context) {
    Widget block(double width, double height, [double radius = 6]) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return SizedBox(
      height: 250,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder:
              (_, __) => Container(
                width: 260,
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // date pill
                    block(110, 34, 20),
                    const Spacer(),
                    // title
                    block(double.infinity, 16),
                    const SizedBox(height: 10),
                    // message lines
                    block(double.infinity, 11),
                    const SizedBox(height: 8),
                    block(170, 11),
                    const SizedBox(height: 18),
                    block(96, 13),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
