import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:supergithr/views/colors.dart';

const fontWeightExtraLight = FontWeight.w200;
const fontWeightLight = FontWeight.w300;
const fontWeightRegular = FontWeight.w400;
const fontWeightMedium = FontWeight.w500;
const fontWeightW600 = FontWeight.w600;
const fontWeightSemiBold = FontWeight.w700;
const fontWeightBold = FontWeight.w700;
const fontWeightExtraBold = FontWeight.w800;
const double fontMedium1 = 12.0;

TextStyle textStyleExoRegular({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  Color? underlineColor,
  double? height,
  bool decoration = false,
}) => GoogleFonts.exo(
  height: height,
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: fontWeightRegular,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleExoMiddle({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  FontWeight? weight,
  Color? underlineColor,
  double? height,
  bool decoration = false,
}) => GoogleFonts.exo(
  decorationColor: underlineColor ?? color,
  height: height,
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: weight ?? fontWeightMedium,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationStyle: TextDecorationStyle.solid,
);

TextStyle textStyleExoSemiBold({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  FontWeight? weight,
  Color? underlineColor,
  double? height,
  bool decoration = false,
}) => GoogleFonts.exo(
  height: height,
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: weight ?? fontWeightSemiBold,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleExoBold({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  bool decoration = false,
  Color? underlineColor,
  FontWeight? weight,
}) => GoogleFonts.exo(
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: weight ?? fontWeightExtraBold,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleExoExtraBold({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  Color? underlineColor,
}) => GoogleFonts.exo(
  fontSize: fontSize ?? fontMedium1,
  fontWeight: fontWeightExtraBold,
  letterSpacing: letterSpacing ?? 0,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleMontserratRegular({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  Color? underlineColor,
  double? height,
  bool decoration = false,
}) => GoogleFonts.inter(
  height: height,
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: fontWeightRegular,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleMontserratMiddle({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  FontWeight? weight,
  Color? underlineColor,
  double? height,
  bool decoration = false,
}) => GoogleFonts.inter(
  decorationColor: underlineColor ?? color,
  height: height,
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: weight ?? fontWeightMedium,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationStyle: TextDecorationStyle.solid,
);

TextStyle textStyleMontserratSemiBold({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  FontWeight? weight,
  Color? underlineColor,
  double? height,
  bool decoration = false,
}) => GoogleFonts.inter(
  height: height,
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: weight ?? fontWeightSemiBold,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleMontserratBold({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  bool decoration = false,
  Color? underlineColor,
  FontWeight? weight,
}) => GoogleFonts.inter(
  color: color ?? (Get.isDarkMode ? whiteColor : mainBlackcolor),
  fontSize: fontSize ?? fontMedium1,
  fontWeight: weight ?? fontWeightBold,
  letterSpacing: letterSpacing ?? 0,
  decoration: decoration ? TextDecoration.underline : null,
  decorationColor: underlineColor ?? color,
);

TextStyle textStyleMontserratExtraBold({
  Color? color,
  double? fontSize,
  double? letterSpacing,
  Color? underlineColor,
}) => GoogleFonts.montserrat(
  fontSize: fontSize ?? fontMedium1,
  fontWeight: fontWeightExtraBold,
  letterSpacing: letterSpacing ?? 0,
  decorationColor: underlineColor ?? color,
);
