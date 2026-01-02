import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MyProfileShimmer extends StatelessWidget {
  const MyProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: SizedBox(
        height: Get.height,
        child: ListView.builder(
          itemCount: 8,
          itemBuilder: (c, i) {
            return Column(
              children: [
                titlewWidget(title: "My Orders", image: 'images/order.png'),
                horizontaldivider(
                  color: shimmerBlack3,
                  horizontalPadding: 0.0,
                  verticalPadding: 5.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget titlewWidget({onTap, String? title, image, imagecolor}) {
    return ListTile(
      //  onTap: onTap ?? () {},
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      title: kText(text: "-----------", fWeight: fontWeightMedium, fSize: 16.0),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }
}
