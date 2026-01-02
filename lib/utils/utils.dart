import 'dart:async';
import 'dart:developer';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:supergithr/utils/app_assets.dart';
import 'package:supergithr/views/colors.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Utils {
  static void fieldFocusChange(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static void showToast(String content) {
    Fluttertoast.showToast(
      msg: content,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static snackBar(String message, bool isError) {
    DelightToastBar(
      animationDuration: const Duration(milliseconds: 400),
      snackbarDuration: const Duration(seconds: 3),
      position: DelightSnackbarPosition.top,
      autoDismiss: true,
      builder:
          (context) => Container(
            width: 100.w,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.w),
            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 4,
                  offset: Offset(-4, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                isError
                    ? Icon(Icons.error, color: Colors.red, size: 18.sp)
                    : CircleAvatar(
                      radius: 15,
                      backgroundColor: whiteColor,
                      child: Image.asset(
                        "assets/icons/logo1.png",
                        height: 25.sp,
                        width: 25.sp,
                      ),
                    ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      // ToastCard(
      //   shadowColor: Colors.black26,
      //   color: AppColor.secondary,
      //   leading: SizedBox(height: 25.sp,width: 25.sp,
      //   child: isError? Icon(Icons.error,color: Colors.redAccent,size: 20.sp,)
      //       : Image.asset("assets/logo_symbol.png"),
      //   ),
      //   title: Text(
      //     maxLines: 4,
      //     overflow: TextOverflow.ellipsis,
      //     message,
      //     textAlign: TextAlign.start,
      //     style: AppFontStyles.title_4(
      //       fontSize: 15.sp,
      //       color: Colors.white,
      //       fontWeight: FontWeight.w500,
      //     ),
      //   ),
      // ),
    ).show(Get.key.currentContext!);
    // Get.snackbar(
    //     isError?"Error"/*TranslationKeys.error.tr*/:message,
    //     isError? message:"",
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.white12,
    //     borderRadius: 15,
    //     //  borderWidth: 3.sp,
    //     //  borderColor: isError?Colors.red:CupertinoColors.systemGreen,
    //     duration: const Duration(milliseconds: 3500),
    //     barBlur: 13,
    //     colorText: isError?Colors.red: CupertinoColors.systemGreen,
    //     leftBarIndicatorColor: isError?Colors.red:CupertinoColors.systemGreen,
    //     borderWidth: 3.sp,
    //     animationDuration: const Duration(milliseconds: 600),
    //     instantInit: false,
    //     dismissDirection: DismissDirection.horizontal,
    //     icon:isError?
    //     Icon(Icons.error,color: Colors.red,size: 25.sp,)
    //         : Icon(CupertinoIcons.checkmark_alt_circle_fill,color: CupertinoColors.systemGreen,size: 25.sp,),
    //     isDismissible: true,
    //     boxShadows: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.1),
    //         blurRadius: 8,
    //         spreadRadius: 2,
    //         offset: const Offset(0, 4),
    //       )
    //     ],
    //     /*  onTap: (getSnackBar) {
    //   Get.back();
    // },*/
    //     padding:  EdgeInsets.symmetric(vertical: 1.h,horizontal: 3),
    //     margin: EdgeInsets.symmetric(vertical: 5.h,horizontal: 5.w)
    // );
  }

  static void showLoadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      useRootNavigator: false,
      builder: (context) {
        Color color = kPrimaryColor;
        return Dialog(
          alignment: Alignment.center,
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 150,
            width: 150,
            child: Lottie.asset(
              AppAssets.loading,
              repeat: true,
              frameRate: const FrameRate(90),
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(const [
                    'Shape Layer 1',
                    '**',
                    'Fill 1',
                  ], value: color),
                  ValueDelegate.color(const [
                    'Shape Layer 2',
                    '**',
                    'Fill 1',
                  ], value: color),
                  ValueDelegate.color(const [
                    'Shape Layer 3',
                    '**',
                    'Fill 1',
                  ], value: color),
                  ValueDelegate.color(const [
                    'Shape Layer 4',
                    '**',
                    'Fill 1',
                  ], value: color),
                  ValueDelegate.color(const [
                    'Shape Layer 5',
                    '**',
                    'Fill 1',
                  ], value: color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> checkPermission(List<Permission> permissions) async {
    Map<Permission, PermissionStatus> permissionStatuses = {};

    for (Permission permission in permissions) {
      final status = await permission.request();
      permissionStatuses[permission] = status;
    }

    permissionStatuses.forEach((permission, status) async {
      if (status.isDenied) {
        Utils.showToast("Enable $permission Permission for better Experience");
        //openAppSettings();
      } else if (status.isGranted) {
        debugPrint("Permission $permission $status");
        // Do something else with the granted permission
      }
    });
  }

  static Future<PermissionStatus> askPermission(Permission permission) async {
    final status = await permission.request();
    log("$permission STATUS: $status");
    return PermissionStatus.denied;
  }

  static void showRemoveDataDialog(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🗑️ Title
                Text(
                  "Are you sure to remove selected data?",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                /// 🔘 Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /// ❌ Cancel
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    /// ✅ Yes
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Confirm",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // static showLanguageDialog(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Consumer<LocalizationProvider>(
  //           builder: (context, localeProvider, _) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 Text(
  //                   AppLocalizations.of(context)!.translate("Language"),
  //                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 SizedBox(height: 2.h),
  //                 ListTile(
  //                   trailing: localeProvider.locale == Locale('en')
  //                       ? const Icon(
  //                           Icons.check,
  //                           color: CupertinoColors.activeGreen,
  //                         )
  //                       : null,
  //                   leading: SizedBox(
  //                     height: 3.h,
  //                     width: 3.h * 1.5,
  //                     child: Flag.fromCode(
  //                       FlagsCode.US,
  //                       height: 3.h,
  //                       width: 3.h * 1.5,
  //                       fit: BoxFit.fill,
  //                     ),
  //                   ),
  //                   title: Text(
  //                     "English",
  //                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   onTap: () async {
  //                     localeProvider.setLocale(const Locale('en'));
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //                 ListTile(
  //                   trailing: localeProvider.locale == Locale('ar')
  //                       ? const Icon(
  //                           Icons.check,
  //                           color: CupertinoColors.activeGreen,
  //                         )
  //                       : null,
  //                   leading: SizedBox(
  //                     height: 3.h,
  //                     width: 3.h * 1.5,
  //                     child: Flag.fromCode(
  //                       FlagsCode.SA,
  //                       height: 3.h,
  //                       width: 3.h * 1.5,
  //                       fit: BoxFit.fill,
  //                     ),
  //                   ),
  //                   title: Text(
  //                     "عربي",
  //                     style: Theme.of(context).textTheme.bodyMedium,
  //                   ),
  //                   onTap: () async {
  //                     localeProvider.setLocale(const Locale('ar'));
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  static const Map<String, String> nationalityToCode = {
    'Afghan': 'AF',
    'Albanian': 'AL',
    'Algerian': 'DZ',
    'Andorran': 'AD',
    'Angolan': 'AO',
    'Antiguan or Barbudan': 'AG',
    'Argentine': 'AR',
    'Armenian': 'AM',
    'Australian': 'AU',
    'Austrian': 'AT',
    'Azerbaijani': 'AZ',
    'Bahamian': 'BS',
    'Bahraini': 'BH',
    'Bangladeshi': 'BD',
    'Barbadian': 'BB',
    'Belarusian': 'BY',
    'Belgian': 'BE',
    'Belizean': 'BZ',
    'Beninese': 'BJ',
    'Bhutanese': 'BT',
    'Bolivian': 'BO',
    'Bosnian or Herzegovinian': 'BA',
    'Botswanan': 'BW',
    'Brazilian': 'BR',
    'Bruneian': 'BN',
    'Bulgarian': 'BG',
    'Burkinabé': 'BF',
    'Burundian': 'BI',
    'Cabo Verdean': 'CV',
    'Cambodian': 'KH',
    'Cameroonian': 'CM',
    'Canadian': 'CA',
    'Central African': 'CF',
    'Chadian': 'TD',
    'Chilean': 'CL',
    'Chinese': 'CN',
    'Colombian': 'CO',
    'Comorian': 'KM',
    'Congolese (Congo)': 'CG',
    'Congolese (DRC)': 'CD',
    'Costa Rican': 'CR',
    'Croatian': 'HR',
    'Cuban': 'CU',
    'Cypriot': 'CY',
    'Czech': 'CZ',
    'Danish': 'DK',
    'Djiboutian': 'DJ',
    'Dominican': 'DM',
    'Dominican Republic': 'DO',
    'Ecuadorian': 'EC',
    'Egyptian': 'EG',
    'Salvadoran': 'SV',
    'Equatorial Guinean': 'GQ',
    'Eritrean': 'ER',
    'Estonian': 'EE',
    'Eswatini': 'SZ',
    'Ethiopian': 'ET',
    'Fijian': 'FJ',
    'Finnish': 'FI',
    'French': 'FR',
    'Gabonese': 'GA',
    'Gambian': 'GM',
    'Georgian': 'GE',
    'German': 'DE',
    'Ghanaian': 'GH',
    'Greek': 'GR',
    'Grenadian': 'GD',
    'Guatemalan': 'GT',
    'Guinean': 'GN',
    'Bissau-Guinean': 'GW',
    'Guyanese': 'GY',
    'Haitian': 'HT',
    'Honduran': 'HN',
    'Hungarian': 'HU',
    'Icelandic': 'IS',
    'Indian': 'IN',
    'Indonesian': 'ID',
    'Iranian': 'IR',
    'Iraqi': 'IQ',
    'Irish': 'IE',
    'Israeli': 'IL',
    'Italian': 'IT',
    'Jamaican': 'JM',
    'Japanese': 'JP',
    'Jordanian': 'JO',
    'Kazakh': 'KZ',
    'Kenyan': 'KE',
    'Kiribati': 'KI',
    'North Korean': 'KP',
    'South Korean': 'KR',
    'Kuwaiti': 'KW',
    'Kyrgyz': 'KG',
    'Lao': 'LA',
    'Latvian': 'LV',
    'Lebanese': 'LB',
    'Basotho': 'LS',
    'Liberian': 'LR',
    'Libyan': 'LY',
    'Liechtenstein': 'LI',
    'Lithuanian': 'LT',
    'Luxembourgish': 'LU',
    'Malagasy': 'MG',
    'Malawian': 'MW',
    'Malaysian': 'MY',
    'Maldivian': 'MV',
    'Malian': 'ML',
    'Maltese': 'MT',
    'Marshallese': 'MH',
    'Mauritanian': 'MR',
    'Mauritian': 'MU',
    'Mexican': 'MX',
    'Micronesian': 'FM',
    'Moldovan': 'MD',
    'Monégasque': 'MC',
    'Mongolian': 'MN',
    'Montenegrin': 'ME',
    'Moroccan': 'MA',
    'Mozambican': 'MZ',
    'Burmese': 'MM',
    'Namibian': 'NA',
    'Nauruan': 'NR',
    'Nepali': 'NP',
    'Dutch': 'NL',
    'New Zealander': 'NZ',
    'Nicaraguan': 'NI',
    'Nigerien': 'NE',
    'Nigerian': 'NG',
    'Macedonian': 'MK',
    'Norwegian': 'NO',
    'Omani': 'OM',
    'Pakistani': 'PK',
    'Palauan': 'PW',
    'Panamanian': 'PA',
    'Papua New Guinean': 'PG',
    'Paraguayan': 'PY',
    'Peruvian': 'PE',
    'Filipino': 'PH',
    'Polish': 'PL',
    'Portuguese': 'PT',
    'Palestinian': 'PS',
    'Qatari': 'QA',
    'Romanian': 'RO',
    'Russian': 'RU',
    'Rwandan': 'RW',
    'Saint Kitts and Nevis': 'KN',
    'Saint Lucian': 'LC',
    'Saint Vincentian': 'VC',
    'Samoan': 'WS',
    'San Marinese': 'SM',
    'São Toméan': 'ST',
    'saudi': 'SA',
    'Senegalese': 'SN',
    'Serbian': 'RS',
    'Seychellois': 'SC',
    'Sierra Leonean': 'SL',
    'Singaporean': 'SG',
    'Slovak': 'SK',
    'Slovene': 'SI',
    'Solomon Islander': 'SB',
    'Somali': 'SO',
    'South African': 'ZA',
    'Spanish': 'ES',
    'Sri Lankan': 'LK',
    'Sudanese': 'SD',
    'Surinamese': 'SR',
    'Swedish': 'SE',
    'Swiss': 'CH',
    'Syrian': 'SY',
    'Taiwanese': 'TW',
    'Tajik': 'TJ',
    'Tanzanian': 'TZ',
    'Thai': 'TH',
    'Timorese': 'TL',
    'Togolese': 'TG',
    'Tongan': 'TO',
    'Trinidadian or Tobagonian': 'TT',
    'Tunisian': 'TN',
    'Turkish': 'TR',
    'Turkmen': 'TM',
    'Tuvaluan': 'TV',
    'Ugandan': 'UG',
    'Ukrainian': 'UA',
    'Emirati': 'AE',
    'British': 'GB',
    'American': 'US',
    'Uruguayan': 'UY',
    'Uzbek': 'UZ',
    'Vanuatuan': 'VU',
    'Venezuelan': 'VE',
    'Vietnamese': 'VN',
    'Yemeni': 'YE',
    'Zambian': 'ZM',
    'Zimbabwean': 'ZW',
  };
}

extension ShimmerExtension on Widget {
  Widget myShimmer({Color? color}) {
    return animate(onPlay: (controller) => controller.repeat()).shimmer(
      color: color ?? Colors.grey.shade400,
      duration: const Duration(seconds: 1),
    );
  }
}
