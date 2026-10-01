import 'package:flutter/material.dart';
import 'package:supergithr/main.dart';
import 'package:get/get.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

/// Back button with a proper touch target.
///
/// The icon itself is only 20px, so wrapping just the icon left a tap area far
/// below the 44pt (iOS) / 48dp (Material) minimum — people had to hit the
/// glyph exactly. This gives it a 48x48 box, makes the whole box tappable
/// (`HitTestBehavior.opaque`, not just the painted pixels) and adds a ripple
/// so the tap is visibly registered.
Widget appBarBackButton({bool isBlocked = false}) {
  return Center(
    child: SizedBox(
      height: 48,
      width: 48,
      // GestureDetector rather than InkWell: the ripple drew a circle that
      // made the (deliberately large) hit area visible on every tap. Opaque
      // hit testing keeps the whole 48x48 box tappable with nothing to see.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            isBlocked
                ? null
                : () {
                  final context = Get.context;
                  if (context != null) Navigator.of(context).maybePop();
                },
        child: const Center(
          child: Padding(
            // Optical alignment: the chevron sits visually left of centre.
            padding: EdgeInsets.only(left: 6.0),
            child: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          ),
        ),
      ),
    ),
  );
}

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
    leadingWidth: 70, // Increased width for better spacing
    systemOverlayStyle: kAppSystemUiStyle,
    backgroundColor: backgroundColor ?? kLightBlueBackgroundColor,
    leading: leadingWidget ?? appBarBackButton(isBlocked: isBlockBack == true),

    elevation: 0,
    centerTitle: centerTitle ?? true,
    title: Text(
      title?.tr ?? "title",
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
    leadingWidth: 70, // Increased width for better spacing
    backgroundColor: backgroundColor ?? kLightBlueBackgroundColor,
    systemOverlayStyle: kAppSystemUiStyle,
    leading: leadingWidget ?? appBarBackButton(),

    elevation: elevation ?? 0,
    centerTitle: centerTitle ?? true,
    title: Text(
      title ?? "title",
      style: textStyleMontserratMiddle(
        color: titleColor ?? mainBlackcolor,
        fontSize: titlefontSize,
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
