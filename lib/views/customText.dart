import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/views/text_styles.dart';

class kText extends StatelessWidget {
  final String text;
  final Color? tColor;
  final double? fSize;
  final FontWeight? fWeight;
  final TextStyle? style;
  final double? height;
  final int? maxLines;
  final TextOverflow? textoverflow;
  final TextAlign? textalign;
  final bool? textUnderLine;
  final Alignment? align;
  final Color? uderlineColor;
  final Gradient? gradient; // ✅ NEW

  const kText({
    required this.text,
    this.tColor,
    this.fSize,
    this.fWeight,
    this.style,
    this.height,
    this.maxLines,
    this.textoverflow,
    this.textalign,
    this.textUnderLine,
    this.align,
    this.uderlineColor,
    this.gradient, // ✅ NEW
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text.tr,
      overflow: textoverflow ?? TextOverflow.visible,
      maxLines: maxLines,
      textAlign: textalign,
      style:
          style ??
          textStyleMontserratMiddle(
            height: height ?? 1.0,
            fontSize: fSize ?? 14.0,
            color: tColor,
            weight: fWeight ?? FontWeight.normal,
            decoration: textUnderLine ?? false,
            underlineColor: uderlineColor ?? tColor,
          ),
    );

    // ✅ Apply gradient if provided
    if (gradient != null) {
      return ShaderMask(
        shaderCallback:
            (bounds) => gradient!.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
        child: textWidget,
      );
    } else {
      return textWidget;
    }
  }
}
