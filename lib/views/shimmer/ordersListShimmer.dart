import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 184, 173, 173),
      highlightColor: Colors.grey.withOpacity(0.5),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              // height: height * 0.3,
              decoration: BoxDecoration(
                // color: Color(0xffABC3D5),
                border: Border.all(width: 1, color: shimmerBlack3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  UIHelper.verticalSpaceSm10,
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        UIHelper.horizontalSpaceSm10,
                        Container(height: 10, width: 50, color: shimmerBlack3),
                        Spacer(),
                        MaterialButton(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: shimmerBlack3,
                          onPressed: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //   Icons.check,
                                //   color: whiteColor,
                                // ),
                                SizedBox(width: 3),
                                GestureDetector(
                                  onTap: () {
                                    print("-----------");
                                  },
                                  child: kText(
                                    text: "---------",
                                    tColor: shimmerBlack3,
                                    fSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        UIHelper.horizontalSpaceSm10,
                      ],
                    ),
                  ),
                  Container(
                    //  / height: 120,
                    // color: redColor,
                    child: Row(
                      children: [
                        Container(
                          // color: yellowColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UIHelper.horizontalSpaceSm10,
                                  orderDeliveryTime(
                                    text1: "${"Tailor".tr}:",
                                    text2: "----------",
                                    text1Color: mainBlackcolor,
                                    text1FontWeight: fontWeightBold,
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpaceSm15,
                              Row(
                                children: [
                                  UIHelper.horizontalSpaceSm10,
                                  orderDeliveryTime(
                                    text1: "${"Ordered on".tr}: ",
                                    text1Color: mainBlackcolor,
                                    text1FontWeight: fontWeightBold,
                                    text1Font: 12.0,
                                    text2: "--/--/----",
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpaceSm15,
                              Row(
                                children: [
                                  UIHelper.horizontalSpaceSm10,
                                  orderDeliveryTime(
                                    text1: "${"Delivery".tr}: ",
                                    text1Color: mainBlackcolor,
                                    text1FontWeight: fontWeightBold,
                                    text1Font: 12.0,
                                    text2: "--/--/----",
                                  ),
                                ],
                              ),
                              UIHelper.verticalSpaceSm15,
                              Row(
                                children: [
                                  UIHelper.horizontalSpaceSm10,
                                  orderDeliveryTime(
                                    text1: "${"Total Amount".tr}: ",
                                    text1Color: mainBlackcolor,
                                    text1FontWeight: fontWeightBold,
                                    text1Font: 12.0,
                                    text2: "----------",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontaldivider(
                    verticalPadding: 3.0,
                    horizontalPadding: 0.0,
                    color: shimmerBlack3,
                  ),
                  UIHelper.verticalSpaceSm15,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      text: "----------------------",
                      () {
                        // List to store selected images
                      },
                      textcolor: mainBlackcolor,
                      color: shimmerBlack3,
                    ),
                  ),
                  UIHelper.verticalSpaceSm15,
                  // Container(
                  //   height: 10,
                  //   width: 60,
                  //   color: shimmerBlack3,
                  // ),
                  //    UIHelper.verticalSpaceSm15
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget orderDeliveryTime({
    text1Color,
    text2Color,
    String? text1,
    String? text2,
    text1Font,
    text2Font,
    text1FontWeight,
    text2FontWeight,
  }) {
    return Row(
      children: [
        SizedBox(
          width: Get.width * 0.24,
          child: kText(
            text: text1!.tr,
            fWeight: text1FontWeight,
            fSize: text1Font ?? 14.0,
            tColor: text1Color ?? appBlurTextColor,
          ),
        ),
        kText(
          text: text2!.tr,
          fSize: text2Font ?? 12.0,
          fWeight: text2FontWeight,
          tColor: text2Color ?? appBlurTextColor,
        ),
      ],
    );
  }
}
