import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomButton extends StatelessWidget {
  double? width;
  var color;
  var child;
  String text;
  var textcolor;
  var weight;
  var fsize;
  var onTap;
  var buttonBorderColor;
  var icon;
  var circleRadius;
  bool? isDisable;
  var letterspacing;
  var height;
  var elevation;
  var leadingIcon;
  var textAlign;
  var ownText;
  bool? isLoading;
  var underlineText;

  CustomButton(
    this.onTap, {
    super.key,
    this.child,
    this.ownText,
    this.isLoading,
    this.elevation,
    this.textAlign,
    this.leadingIcon,
    this.color,
    this.fsize,
    required this.text,
    this.textcolor,
    this.buttonBorderColor,
    this.underlineText,
    this.weight,
    this.isDisable,
    this.icon,
    this.height,
    this.circleRadius,
    this.letterspacing,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      elevation: elevation ?? 0.0,
      padding: EdgeInsets.zero,
      disabledColor: Color(0xff1d1b201f),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1.5,
          color: buttonBorderColor ?? Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(circleRadius ?? 10),
      ),
      minWidth: width ?? MediaQuery.of(context).size.width,
      height: height ?? 45,
      color: color ?? appblueColor,
      child:
          child ?? isLoading ?? false
              ? const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeAlign: 0.5,
                    strokeCap: StrokeCap.round,
                    color: whiteColor,
                  ),
                ),
              )
              : ownText ??
                  Text(
                    text.tr,
                    textAlign: textAlign ?? TextAlign.center,
                    style: textStyleMontserratMiddle(
                      color: textcolor ?? whiteColor,
                      fontSize: fsize ?? 16.0,
                      letterSpacing: letterspacing ?? 0,
                      decoration: underlineText ?? false,
                    ),
                  ),

      // trailing:
      //     Icon(Icons.arrow_forward, color: textcolor ?? Colors.black),
    );
  }
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onTap,
    this.height,
    this.width,
  });
  final bool isLoading;
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 45,
        width: width ?? 90.w,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          //  color: kPrimaryColor,
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(10),
          // gradient: linearGradient,
        ),
        child:
            isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}
