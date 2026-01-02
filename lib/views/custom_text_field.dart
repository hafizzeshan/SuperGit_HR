import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String? hint;

  // final String? text;
  final TextEditingController? controller;
  final bool? isHide;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  TextInputType? keyboardType;
  FocusNode? focusNode;
  bool? isvalid;
  bool? required;
  int? maxLines;
  var readOnly;
  var fontSize;
  String? label;
  var onTap;
  var egText;
  var border;
  var fieldWidth;
  var height;
  var prefix;
  var backGroundcolor;
  var hintColor;
  var elevationn;
  bool? autoFocus;
  var cursorColor;
  FontWeight? weight;
  var letterSpacing;
  TextStyle? placeholder;
  TextStyle? textstyle;
  TextInputFormatter? formate;
  var borderColor;
  var suffixIcon;
  var borderRadius;
  var initialValue;
  String? errorMsg;
  TextDirection? textDirection;
  int? maxLength;
  var textAlign;
  var textAlignVertical;
  var prefixText;
  bool isMobileNumber;
  String validationText;
  List<TextInputFormatter>? inputFormatters;

  CustomTextField({
    super.key,
    this.maxLength,
    this.controller,
    this.cursorColor,
    this.validationText = "Required*",
    this.isMobileNumber = false,
    this.suffixIcon,
    this.textDirection,
    this.errorMsg,
    this.textAlign,
    this.hint,
    this.autoFocus,
    this.isHide,
    this.label,
    this.elevationn,
    this.backGroundcolor,
    this.initialValue,
    //  this.text,
    this.onChanged,
    this.focusNode,
    this.isvalid,
    this.hintColor,
    this.letterSpacing,
    required this.required,
    this.borderRadius,
    this.inputFormatters,
    this.keyboardType,
    this.prefixText,
    this.maxLines,
    this.readOnly,
    this.fontSize,
    this.onTap,
    this.egText,
    this.border,
    this.formate,
    this.fieldWidth,
    this.height,
    this.prefix,
    this.weight,
    this.placeholder,
    this.borderColor,
    this.validator,
    this.textstyle,
    this.textAlignVertical,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool iserror = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: widget.maxLength ?? 50,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              null, // Hide max length counter
      //cursorHeight: 25,
      textDirection: widget.textDirection,
      // showCursor: widget.isMobileNumber ? false : true,
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.isHide ?? false,
      textAlignVertical: widget.textAlignVertical,
      focusNode: widget.focusNode,
      autofocus: widget.autoFocus ?? false,
      //   textAlign: pr.isEnglish! ? TextAlign.left : TextAlign.right,
      controller: widget.controller,
      cursorHeight: 17,
      cursorRadius: Radius.circular(10),
      // initialValue: widget.initialValue,
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return widget.validationText ?? "Enter Some Text";
            }
            return null;
          },
      readOnly: widget.readOnly ?? false,
      keyboardType: widget.keyboardType ?? TextInputType.name,
      onTap: widget.onTap ?? () async {},
      cursorColor: kPrimaryColor,

      style: textStyleMontserratMiddle(
        color: mainBlackcolor,
        fontSize: widget.fontSize ?? 16,
      ),

      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        prefixText: widget.prefixText,
        prefixIcon: widget.prefix,
        suffixIcon: widget.suffixIcon,
        focusColor: Colors.white,
        hintText: widget.hint != null ? widget.hint!.tr : "",
        contentPadding: const EdgeInsets.all(10),
        prefixStyle: textStyleMontserratMiddle(
          color: mainBlackcolor,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          //  borderSide: BorderSide(color: kSecondaryColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appButtonColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appButtonColor),
        ),
        fillColor: Colors.grey,
        // hintText: "",
        errorText: widget.errorMsg?.tr,
        //make hint text
        hintStyle: textStyleMontserratMiddle(
          color: widget.hintColor ?? Colors.grey,
          fontSize: 15,
        ),

        //create lable
        //  labelText: widget.label!.tr,
        alignLabelWithHint: true,
        // label: kText(
        //   text: "Name",
        //   textalign: TextAlign.center,
        // ),
        //lable style
        labelStyle: textStyleMontserratMiddle(color: Colors.grey, fontSize: 15),
      ),
    );
  }

  String? defaultValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text'.tr;
    }
    return null;
  }
}
