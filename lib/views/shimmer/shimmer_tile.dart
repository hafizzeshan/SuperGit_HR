import 'package:flutter/material.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 184, 173, 173),
      highlightColor: Colors.grey.withOpacity(0.5),
      child: InkWell(
        onTap: () async {},
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // color: Colors.black,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 25),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: SizedBox(
                          width: width / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: width / 3,
                                height: 15,
                                color: Colors.black,
                              ),
                              UIHelper.verticalSpaceSm10,
                              Container(
                                width: width / 4,
                                height: 15,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerListView extends StatelessWidget {
  const ShimmerListView({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 184, 173, 173),
      highlightColor: Colors.grey.withOpacity(0.5),
      child: ListView.separated(
        itemCount: 10,
        separatorBuilder: (context, index) {
          return horizontaldivider(
            horizontalPadding: 0.0,
            verticalPadding: 10.0,
          );
        },
        itemBuilder: (context, index) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(text: "", fSize: 17.0, fWeight: fontWeightBold),
                  UIHelper.verticalSpaceSm15,
                  kText(text: "", fSize: 15.0, tColor: Color(0xff4C4541)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
