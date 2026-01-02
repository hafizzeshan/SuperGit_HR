import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/ui_helpers.dart';

class AddressShowShimmer extends StatelessWidget {
  const AddressShowShimmer({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 184, 173, 173),
      highlightColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 10,
                  margin: const EdgeInsets.only(top: 10),
                  color: shimmerBlack3,
                ),
                UIHelper.verticalSpaceSm10,
                Container(
                  width: 100,
                  height: 10,
                  margin: const EdgeInsets.only(top: 10),
                  color: shimmerBlack2,
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit, color: shimmerBlack3),
            UIHelper.horizontalSpaceSm10,
            Icon(Icons.delete, color: shimmerBlack3),
          ],
        ),
      ),
    );
  }
}
