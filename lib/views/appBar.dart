import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

AppBar appBarrWitoutAction({
  actionWidget,
  String? title,
  actionIcon,
  BuildContext? context,
  backgroundColor,
  centerTitle,
  leadinIconColor,
  leadinBorderColor,
  leadingWidget,
  titleColor,
  isBlockBack,
}) {
  return AppBar(
    titleSpacing: 0.0,
    leadingWidth: 55,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // or any dark color
      statusBarIconBrightness: Brightness.dark,
    ),
    backgroundColor: backgroundColor ?? Colors.transparent,
    leading:
        leadingWidget ??
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 2,
                color: leadinBorderColor ?? Color(0xffE8ECF4),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),

    elevation: 0,
    centerTitle: centerTitle ?? true,
    title: Text(
      title!.tr ?? "title",
      style: textStyleMontserratMiddle(
        color: titleColor ?? mainBlackcolor,
        fontSize: 18.0,
      ),
    ),
  );
}

Widget appBarrWitoutActionWidget({
  actionWidget,
  String? title,
  actionIcon,
  context,
  backgroundColor,
  centerTitle,
  leadinIconColor,
  leadinBorderColor,
  leadingWidget,
  titleColor,
  isBlockBack,
}) {
  return leadingWidget ??
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          height: 60,
          width: 60,
          child: InkWell(
            onTap: () {
              context.pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: leadinBorderColor ?? Color(0xffF4EAE6),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 7,
                    right: 7,
                    bottom: 7,
                    top: 7,
                  ),
                  child: Image.asset('images/backlogo.png'),
                ),
              ),
            ),
          ),
        ),
      );
}

AppBar appBarrWitAction({
  title,
  context,
  actionwidget,
  backgroundColor,
  elevation,
  leadinIconColor,
  centerTitle,
  double titlefontSize = 18.0,
  leadingWidget,
  titleColor,
}) {
  return AppBar(
    leadingWidth: 55,
    backgroundColor: backgroundColor ?? Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white, // or any dark color
      statusBarBrightness: Brightness.light, // for Android
    ),
    leading:
        leadingWidget ??
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 2, color: Color(0xffE8ECF4)),
            ),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),

    elevation: elevation ?? 0,
    centerTitle: centerTitle ?? true,
    title: Text(
      title ?? "title",
      style: textStyleMontserratMiddle(
        color: titleColor ?? mainBlackcolor,
        fontSize: titlefontSize ?? 18.0,
      ),
    ),
    actions: [
      Padding(padding: EdgeInsets.only(right: 12), child: actionwidget),
    ],
  );
}

Widget verticaldivider({verticalPadding, horizontalPadding, height, color}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: verticalPadding ?? 12,
      horizontal: horizontalPadding ?? 0,
    ),
    child: Container(
      height: height ?? Get.height,
      width: 1,
      color: color ?? greyColor,
    ),
  );
}

Widget horizontaldivider({verticalPadding, horizontalPadding, color}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding ?? 10,
      vertical: verticalPadding ?? 15,
    ),
    child: Container(height: 1, width: Get.width, color: color ?? greyColor),
  );
}
