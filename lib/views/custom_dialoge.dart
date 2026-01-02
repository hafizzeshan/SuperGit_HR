import 'package:flutter/material.dart';
import 'package:supergithr/views/text_styles.dart';

class PlaceholderDialog extends StatelessWidget {
  PlaceholderDialog({
    this.icon,
    this.title,
    this.message,
    this.color,
    this.actions = const [],
    super.key,
  });

  final Widget? icon;
  final String? title;
  final Widget? message;
  var color;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width,
      //  height: height - 80.0,
      child: AlertDialog(
        backgroundColor: color,
        insetPadding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        icon: icon,
        title: title == null ? null : Text(title!, textAlign: TextAlign.center),
        titleTextStyle: textStyleMontserratBold(),
        content: message,
        contentTextStyle: textStyleMontserratMiddle(),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowButtonSpacing: 8.0,
        actions: actions,
      ),
    );
  }
}
