import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _VerticalSpaceSm5 = 5.0;
  static const double _VerticalSpaceSm10 = 10.0;
  static const double _VerticalSpaceSm15 = 15.0;
  static const double _VerticalSpaceSm20 = 20.0;
  static const double _VerticalSpaceSm25 = 20.0;
  static const double _VerticalSpaceL30 = 30.0;
  static const double _VerticalSpaceL35 = 30.0;
  static const double _VerticalSpaceL40 = 40.0;
  static const double _VerticalSpaceL45 = 45.0;
  static const double _VerticalSpaceL50 = 50.0;
  static const double _VerticalSpaceXL55 = 55.0;
  static const double _VerticalSpaceSXL60 = 60.0;
  static const double _VerticalSpaceSXL65 = 65.0;
  static const double _VerticalSpaceSXL70 = 70.0;
  static const double _VerticalSpaceXL75 = 70.0;
  static const double _VerticalSpaceXL80 = 75.0;
  static const double _VerticalSpaceXL85 = 80.0;
  static const double _VerticalSpaceXL90 = 85.0;
  static const double _VerticalSpaceXL95 = 90.0;
  static const double _VerticalSpaceXL100 = 100.0;

  // Vertical spacing constants. Adjust to your liking.

  static const double _HorizontalSpaceSm5 = 5.0;
  static const double _HorizontalSpaceSm10 = 10.0;
  static const double _HorizontalSpaceSm15 = 15.0;
  static const double _HorizontalSpaceSm20 = 20.0;
  static const double _HorizontalSpaceSm25 = 20.0;
  static const double _HorizontalSpaceL30 = 30.0;
  static const double _HorizontalSpaceL35 = 30.0;
  static const double _HorizontalSpaceL40 = 40.0;
  static const double _HorizontalSpaceL45 = 45.0;
  static const double _HorizontalSpaceL50 = 50.0;
  static const double _HorizontalSpaceXL55 = 55.0;
  static const double _HorizontalSpaceSXL60 = 60.0;
  static const double _HorizontalSpaceSXL65 = 65.0;
  static const double _HorizontalSpaceSXL70 = 70.0;
  static const double _HorizontalSpaceeXL75 = 70.0;
  static const double _HorizontalSpaceXL80 = 75.0;
  static const double _HorizontalSpaceXL85 = 80.0;
  static const double _HorizontalSpaceXL90 = 85.0;
  static const double _HorizontalSpaceXL95 = 90.0;
  static const double _HorizontalSpaceXL100 = 100.0;

  // horizontal sized boxes
  static const Widget horizontalSpaceSm5 = SizedBox(width: _HorizontalSpaceSm5);
  static const Widget horizontalSpaceSm10 = SizedBox(
    width: _HorizontalSpaceSm10,
  );
  static const Widget horizontalSpaceSm15 = SizedBox(
    width: _HorizontalSpaceSm15,
  );
  static const Widget horizontalSpaceSm20 = SizedBox(
    width: _HorizontalSpaceSm20,
  );
  static const Widget horizontalSpaceSm25 = SizedBox(
    width: _HorizontalSpaceSm25,
  );
  static const Widget horizontalSpaceMd30 = SizedBox(
    width: _HorizontalSpaceL30,
  );
  static const Widget horizontalSpaceMd35 = SizedBox(
    width: _HorizontalSpaceL35,
  );
  static const Widget horizontalSpaceMd40 = SizedBox(
    width: _HorizontalSpaceL40,
  );
  static const Widget horizontalSpaceL45 = SizedBox(width: _HorizontalSpaceL45);
  static const Widget horizontalSpaceL50 = SizedBox(width: _HorizontalSpaceL50);
  static const Widget horizontalSpaceXL55 = SizedBox(
    width: _HorizontalSpaceXL55,
  );
  static const Widget horizontalSpaceXL60 = SizedBox(
    width: _HorizontalSpaceSXL60,
  );
  static const Widget horizontalSpaceXL65 = SizedBox(
    width: _HorizontalSpaceSXL65,
  );
  static const Widget horizontalSpaceXL70 = SizedBox(
    width: _HorizontalSpaceSXL70,
  );
  static const Widget horizontalSpaceXL75 = SizedBox(
    width: _HorizontalSpaceeXL75,
  );
  static const Widget horizontalSpaceXL80 = SizedBox(
    width: _HorizontalSpaceXL80,
  );
  static const Widget horizontalSpaceXL85 = SizedBox(
    width: _HorizontalSpaceXL85,
  );
  static const Widget horizontalSpaceXL90 = SizedBox(
    width: _HorizontalSpaceXL90,
  );
  static const Widget horizontalSpaceXL95 = SizedBox(
    width: _HorizontalSpaceXL95,
  );
  static const Widget horizontalSpaceXL100 = SizedBox(
    width: _HorizontalSpaceXL100,
  );

  // verticalsized boxes

  static const Widget verticalSpaceSm5 = SizedBox(height: _VerticalSpaceSm5);
  static const Widget verticalSpaceSm10 = SizedBox(height: _VerticalSpaceSm10);
  static const Widget verticalSpaceSm15 = SizedBox(height: _VerticalSpaceSm15);
  static const Widget verticalSpaceSm20 = SizedBox(height: _VerticalSpaceSm20);
  static const Widget verticalSpaceSm25 = SizedBox(height: _VerticalSpaceSm25);
  static const Widget verticalSpaceMd30 = SizedBox(height: _VerticalSpaceL30);
  static const Widget verticalSpaceMd35 = SizedBox(height: _VerticalSpaceL35);
  static const Widget verticalSpaceMd40 = SizedBox(height: _VerticalSpaceL40);
  static const Widget verticalSpaceL45 = SizedBox(height: _VerticalSpaceL45);
  static const Widget verticalSpaceL50 = SizedBox(height: _VerticalSpaceL50);
  static const Widget verticalSpaceXL55 = SizedBox(height: _VerticalSpaceXL55);
  static const Widget verticalSpaceXL60 = SizedBox(height: _VerticalSpaceSXL60);
  static const Widget verticalSpaceeXL65 = SizedBox(
    height: _VerticalSpaceSXL65,
  );
  static const Widget verticalSpaceXL70 = SizedBox(height: _VerticalSpaceSXL70);
  static const Widget verticalSpaceXL75 = SizedBox(height: _VerticalSpaceXL75);
  static const Widget verticalSpaceXL80 = SizedBox(height: _VerticalSpaceXL80);
  static const Widget verticalSpaceXL85 = SizedBox(height: _VerticalSpaceXL85);
  static const Widget verticalSpaceXL90 = SizedBox(height: _VerticalSpaceXL90);
  static const Widget verticalSpaceXL95 = SizedBox(height: _VerticalSpaceXL95);
  static const Widget verticalSpaceXL100 = SizedBox(
    height: _VerticalSpaceXL100,
  );

  static void showMySnak({
    String title = "",
    String message = "",
    bool? isError,
  }) {
    if (isError!) {
      Get.snackbar(
        title.tr,
        message.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        title.tr,
        message.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void showLogoutBottomSheet({
    required BuildContext context,
    required VoidCallback onConfirmLogout,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kText(
                text: TranslationKeys.areYouSureWantToLogout.tr,
                fSize: 16.0,
                fWeight: FontWeight.bold,
                tColor: Colors.black87,
                textalign: TextAlign.center,
              ),
              UIHelper.verticalSpaceSm20,
              UIHelper.verticalSpaceSm25,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: kText(
                        text: TranslationKeys.cancel.tr,
                        fSize: 14.0,
                        fWeight: FontWeight.w600,
                        tColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirmLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: kText(
                        text: TranslationKeys.logout.tr,
                        fSize: 14.0,
                        fWeight: FontWeight.w600,
                        tColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpaceSm25,
            ],
          ),
        );
      },
    );
  }

  // static String getCurrencyFormate(text) {
  //   final oCcy = new NumberFormat("#,##0.00", "en_US");
  //   return oCcy.format(int.parse(text));
  // }

  // static showDialogOk(
  //   context, {
  //   required title,
  //   required message,
  //   onOk,
  //   onOkTap,
  //   onConfirm,
  // }) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Dialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20.0)),
  //           child: Container(
  //             width: Get.width * 0.3,
  //             padding: EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(20),
  //               gradient: LinearGradient(
  //                 begin: Alignment(-0.71, 0.94),
  //                 end: Alignment(0.8, -0.82),
  //                 colors: [
  //                   Color.fromARGB(255, 170, 157, 187),
  //                   Color.fromARGB(255, 41, 172, 212),
  //                   Color.fromARGB(255, 3, 24, 80)
  //                 ],
  //                 stops: [0.0, 0.03, 1.0],
  //               ),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: textStyleLMS(fontSize: 22.0, color: Colors.white),
  //                 ),
  //                 UIHelper.verticalSpaceSm,
  //                 Text(
  //                   message,
  //                   style: textStyleLMS(fontSize: 16.0, color: Colors.white),
  //                 ),
  //                 UIHelper.verticalSpaceMd,
  //                 onOk != null
  //                     ? Container(
  //                         width: 150,
  //                         child: Custombutton(
  //                           onOkTap ??
  //                               () {
  //                                 Get.back();
  //                               },
  //                           text: "Ok",
  //                           textcolor: Colors.white,
  //                           buttonBorderColor: Colors.transparent,
  //                           circleRadius: 25.0,
  //                           color: redButton,
  //                         ),
  //                       )
  //                     : Container(),
  //                 onConfirm != null
  //                     ? Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             width: 150,
  //                             child: Custombutton(
  //                               () {
  //                                 Get.back();
  //                               },
  //                               text: "Cancel",
  //                               textcolor: Colors.white,
  //                               buttonBorderColor: Colors.transparent,
  //                               circleRadius: 25.0,
  //                               color: grey600,
  //                             ),
  //                           ),
  //                           UIHelper.horizontalSpaceMd,
  //                           Container(
  //                             width: 150,
  //                             child: Custombutton(
  //                               onConfirm,
  //                               text: "Confirm",
  //                               textcolor: Colors.white,
  //                               buttonBorderColor: Colors.transparent,
  //                               circleRadius: 25.0,
  //                               color: redButton,
  //                             ),
  //                           ),
  //                         ],
  //                       )
  //                     : Container()
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  static const mapKey = "AIzaSyDVX6dMqw5wbVC1t47hNg3xOEuseEwmA_c";

  //todo modify the theme
  /* static ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    backgroundColor: Colors.grey[700],
    brightness: Brightness.dark,
  );
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.red,
    accentColor: Colors.red[400],
    backgroundColor: Colors.grey[200],
    brightness: Brightness.light,
  );*/

  static String getShortName({required string, required limitTo}) {
    var buffer = StringBuffer();
    var split = string.split(' ');
    print(split.length);
    for (var i = 0; i < (split.length); i++) {
      try {
        buffer.write(split[i][0].toString().toUpperCase());
      } on Exception catch (ca) {
        print(ca.toString());
        // TODO
      }
    }

    return buffer.toString();
  }

  static Widget moneyRichText({
    text1,
    text2,
    t1Color,
    t2Color,
    t1FontSize,
    t2FontSize,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text1 ?? '10000',
            style: textStyleMontserratMiddle(
              fontSize: t1FontSize ?? 25,
              color: t1Color ?? whiteColor,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            // child: SizedBox(width: 3)
            child: Container(width: 3),
          ),
          TextSpan(
            text: text2 ?? 'SAR'.tr,
            style: textStyleMontserratMiddle(
              fontSize: t2FontSize ?? 10,
              color: t2Color ?? greyColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget amountTile({
    leadingColor,
    titleText,
    trailingAmont,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 8.0,
      minVerticalPadding: 0.0,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: lightblueBackgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: leadingColor ?? redColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
      title: Text(
        titleText.toString().tr,
        style: textStyleMontserratMiddle(color: greyColor, fontSize: 17),
      ),
    );
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    return picked;
  }

  static Future showDialogue({
    required context,
    loader,
    onTap,
    title,
    subTiltle,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: greyColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              kText(
                text: title ?? "title".tr,
                fSize: 15.0,
                tColor: appdarkIconColor,
                fWeight: FontWeight.bold,
              ),
              Spacer(),
              loader
                  ? Center(
                    child: CircularProgressIndicator(color: appButtonColor),
                  )
                  : Container(),
            ],
          ),
          content: kText(
            text: subTiltle ?? 'Are you sure you want to download'.tr,
            fSize: 14.0,
            height: 1.5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: kText(
                text: 'Cancel'.tr,
                fSize: 15.0,
                fWeight: FontWeight.bold,
                tColor: appdarkIconColor,
              ),
            ),
            TextButton(
              onPressed: onTap ?? () async {},
              child: kText(
                text: "Ok".tr,
                fSize: 15.0,
                fWeight: FontWeight.bold,
                tColor: appdarkIconColor,
              ),
            ),
          ],
        );
      },
    );
  }

  showGenderBottomSheet({context, onTapM, onTapF}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kText(
                text: "Select Gender",
                fSize: 16.0,
                fWeight: FontWeight.bold,
              ),
              UIHelper.verticalSpaceSm20,
              ListTile(
                title: kText(text: "Male", fSize: 14.0),
                onTap:
                    onTapM ??
                    () {
                      Navigator.pop(context);
                    },
              ),
              ListTile(
                title: kText(text: "Female", fSize: 14.0),
                onTap:
                    onTapF ??
                    () {
                      Navigator.pop(context);
                    },
              ),
            ],
          ),
        );
      },
    );
  }

  void showPrintOptionsDialog(BuildContext context, Uint8List pdfBytes) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: kText(
              text: "Select an Option",
              fSize: 18.0,
              fWeight: fontWeightBold,
              tColor: appblueColor,
            ),
            actions: [
              CupertinoActionSheetAction(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility, color: appblueColor),
                    SizedBox(width: 12),
                    kText(
                      text: "View PDF",
                      fSize: 16.0,
                      fWeight: fontWeightBold,
                      tColor: Colors.black,
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   CupertinoPageRoute(
                  //     builder: (context) => PDFViewerScreen(pdfBytes: pdfBytes),
                  //   ),
                  // );
                },
              ),
              CupertinoActionSheetAction(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.share, color: appblueColor),
                    SizedBox(width: 12),
                    kText(
                      text: "Share PDF",
                      fSize: 16.0,
                      fWeight: fontWeightBold,
                      tColor: Colors.black,
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'prescription.pdf',
                  );
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              child: kText(text: "Cancel", tColor: Colors.red),
              onPressed: () => Navigator.pop(context),
            ),
          ),
    );
  }

  // static Widget bottomSheetPickImage(BuildContext context) {
  //   final userViewModel = Provider.of<UserViewModel>(context);
  //   final ImagePicker picker = ImagePicker();
  //   return Container(
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(16.0),
  //         topRight: Radius.circular(16.0),
  //       ),
  //     ),
  //     child: Wrap(
  //       alignment: WrapAlignment.end,
  //       crossAxisAlignment: WrapCrossAlignment.end,
  //       children: [
  //         ListTile(
  //           leading: const Icon(Icons.camera_alt),
  //           title: const Text('Camera'),
  //           onTap: () async {
  //             Get.back();
  //             final XFile? image = await picker.pickImage(
  //                 source: ImageSource.camera, imageQuality: 5);
  //             userViewModel.setImage(image);
  //             userViewModel.imageData =
  //                 userViewModel.convertImageToBytes(image!.path);
  //             print(userViewModel.imageData!['data']);
  //             print(userViewModel.imageData!['fileType']);
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.image),
  //           title: Text('Gallery'),
  //           onTap: () async {
  //             Get.back();
  //             final XFile? image = await picker.pickImage(
  //                 source: ImageSource.gallery, imageQuality: 5);
  //             userViewModel.setImage(image);
  //             userViewModel.imageData =
  //                 userViewModel.convertImageToBytes(image!.path);
  //             print(userViewModel.imageData!['data']);
  //             print(userViewModel.imageData!['fileType']);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // static Widget selectImageFile(
  //   onTap, {
  //   image,
  //   text,
  // }) {
  //   return Expanded(
  //       child: Container(
  //           color: lightButtonColor,
  //           height: Get.height * 0.2,
  //           width: 70,
  //           child: InkWell(
  //             onTap: onTap,
  //             child: Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Image(
  //                     image: image ?? AssetImage("images/files.jpeg"),
  //                     height: 50,
  //                     width: 50,
  //                   ),
  //                   UIHelper.verticalSpaceSm5,
  //                   kText(text: text ?? "Files")
  //                 ],
  //               ),
  //             ),
  //           )));
  // }

  // static List<Country> get countriesList {
  //   return const [
  //     Country(
  //       name: "Saudi Arabia",
  //       nameTranslations: {
  //         "en": "Saudi Arabia",
  //         "ar": "السعودية",
  //         "fa": "عربستان سعودی"
  //       },
  //       flag: "🇸🇦",
  //       code: "SA",
  //       dialCode: "966",
  //       minLength: 9,
  //       maxLength: 9,
  //     ),
  //     Country(
  //       name: "United Arab Emirates",
  //       nameTranslations: {
  //         "en": "United Arab Emirates",
  //         "ar": "الإمارات",
  //         "fa": "امارات متحده عربی"
  //       },
  //       flag: "🇦🇪",
  //       code: "AE",
  //       dialCode: "971",
  //       minLength: 9,
  //       maxLength: 9,
  //     ),
  //     Country(
  //       name: "Bahrain",
  //       nameTranslations: {"en": "Bahrain", "ar": "البحرين", "fa": "بحرین"},
  //       flag: "🇧🇭",
  //       code: "BH",
  //       dialCode: "973",
  //       minLength: 8,
  //       maxLength: 8,
  //     ),
  //     Country(
  //       name: "Qatar",
  //       nameTranslations: {"en": "Qatar", "ar": "قطر", "fa": "قطر"},
  //       flag: "🇶🇦",
  //       code: "QA",
  //       dialCode: "974",
  //       minLength: 8,
  //       maxLength: 8,
  //     ),
  //     Country(
  //       name: "Kuwait",
  //       nameTranslations: {"en": "Kuwait", "ar": "الكويت", "fa": "کویت"},
  //       flag: "🇰🇼",
  //       code: "KW",
  //       dialCode: "965",
  //       minLength: 8,
  //       maxLength: 8,
  //     ),
  //     Country(
  //       name: "Oman",
  //       nameTranslations: {"en": "Oman", "ar": "عمان", "fa": "عمان"},
  //       flag: "🇴🇲",
  //       code: "OM",
  //       dialCode: "968",
  //       minLength: 8,
  //       maxLength: 8,
  //     ),
  //     Country(
  //       name: "Pakistan",
  //       flag: "🇵🇰",
  //       code: "PK",
  //       dialCode: "92",
  //       nameTranslations: {"en": "Pakistan", "ar": "باكستان", "fa": "پاکستان"},
  //       minLength: 10,
  //       maxLength: 10,
  //     ),
  //   ];
  // }

  static showSuccessDialog({
    context,
    titleimage,
    title,
    subtitle,
    bottomWidget,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red.shade100,
                child:
                    titleimage ??
                    Icon(Icons.person, size: 50, color: appButtonColor2),
              ),
              UIHelper.verticalSpaceSm25,
              kText(
                text: title ?? 'Title',
                fSize: 18.0,
                fWeight: fontWeightBold,
                tColor: appButtonColor,
                textalign: TextAlign.center,
              ),
              UIHelper.verticalSpaceSm25,
              kText(
                text: subtitle ?? 'your dialogue subtitle',
                fSize: 15.0,
                height: 1.5,
                textalign: TextAlign.center,
                tColor: appblueColor2,
              ),
              UIHelper.verticalSpaceMd35,
              bottomWidget ??
                  CustomButton(() {
                    Get.back();
                  }, text: "Button"),
            ],
          ),
        );
      },
    );
  }

  Future<List<T>?> showCustomBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T, bool) onItemSelected,
    required List<T> selectedItems,
    bool allowMultipleSelection = true, // Default to multiple selection
  }) async {
    final TextEditingController searchController = TextEditingController();
    List<T> filteredItems = List.from(items);
    return await showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to expand dynamically
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterItems(String query) {
              setModalState(() {
                if (query.isEmpty) {
                  filteredItems = List.from(items);
                } else {
                  filteredItems =
                      items
                          .where(
                            (item) => itemLabel(
                              item,
                            ).toLowerCase().contains(query.toLowerCase()),
                          )
                          .toList();
                }
              });
            }

            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height:
                  selectedItems.isNotEmpty
                      ? 600
                      : 500, // Adjust height dynamically
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// **🔹 Title**
                  kText(text: title, fSize: 16.0, fWeight: FontWeight.bold),
                  UIHelper.verticalSpaceSm10,

                  /// **🔹 Search Bar**
                  TextField(
                    controller: searchController,
                    onChanged: filterItems,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceSm10,

                  /// **🔹 List of Items**
                  Expanded(
                    child:
                        filteredItems.isEmpty
                            ? Center(child: Text("No items found"))
                            : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = selectedItems.contains(item);

                                return ListTile(
                                  title: kText(
                                    text: itemLabel(item),
                                    fSize: 14.0,
                                  ),
                                  trailing:
                                      isSelected
                                          ? Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                          : Icon(
                                            Icons.radio_button_unchecked,
                                            color: appButtonColor,
                                          ),
                                  onTap: () {
                                    setModalState(() {
                                      if (allowMultipleSelection) {
                                        // Allow multiple selections
                                        if (isSelected) {
                                          selectedItems.remove(item);
                                        } else {
                                          selectedItems.add(item);
                                        }
                                      } else {
                                        // Allow only single selection
                                        selectedItems.clear();
                                        selectedItems.add(item);
                                      }
                                      onItemSelected(item, !isSelected);
                                    });
                                  },
                                );
                              },
                            ),
                  ),
                  UIHelper.verticalSpaceSm20,

                  /// **🔹 Confirm Button**
                  CustomButton(() {
                    Navigator.pop(context, selectedItems);
                  }, text: "Confirm Selection"),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
