import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class SearchTextField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatter;
  final bool isEnable;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Widget? prefixIcon;

  final Color? fillColor;

  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;

  final VoidCallback? onEditingComplete;
  const SearchTextField({
    super.key,
    this.hint = '',
    required this.onChanged,
    this.inputFormatter,
    this.isEnable = true,
    this.suffixIcon,
    this.controller,
    this.prefixIcon,
    this.onEditingComplete,
    this.fillColor,
    this.hintTextStyle,
    this.textStyle,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        //Edited by hafiz
        controller: widget.controller,
        //end
        onChanged: widget.onChanged,
        autofocus: false,
        style: textStyleMontserratMiddle(),
        cursorColor: appButtonColor,
        inputFormatters: widget.inputFormatter,
        onEditingComplete: widget.onEditingComplete,
        decoration: InputDecoration(
          isDense: true,
          suffixIcon: widget.suffixIcon,
          hintText: widget.hint,
          hintStyle:
              widget.hintTextStyle ??
              textStyleMontserratMiddle(color: greyColor, fontSize: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                widget.prefixIcon ??
                Image.asset('images/search.png', height: 18, width: 18),
          ),
          filled: true,
          fillColor: widget.fillColor ?? Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            borderSide: BorderSide(width: 1, color: greyColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            borderSide: BorderSide(width: 1, color: greyColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            borderSide: BorderSide(width: 1, color: greyColor),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 12,
          ),
          // contentPadding:
          //     const EdgeInsets.only(top: 12, right: 10, left: 10, bottom: 12)),
        ),
      ),
    );
  }
}
