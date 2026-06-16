import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

import '../custom_text_field.dart';

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: SizedBox(
        height: 525,
        child: Column(
          children: [
            CircleAvatar(radius: 45),
            CustomTextField(
                required: true,
                hint: TranslationKeys.name.tr,
                label: TranslationKeys.name.tr),
            UIHelper.verticalSpaceSm15,
            CustomTextField(
                required: true,
                hint: TranslationKeys.phone.tr,
                label: TranslationKeys.phone.tr),
            UIHelper.verticalSpaceSm15,
            CustomTextField(
                required: true,
                hint: TranslationKeys.country.tr,
                label: TranslationKeys.country.tr),
            UIHelper.verticalSpaceSm15,
            CustomTextField(
                required: true,
                hint: TranslationKeys.city.tr,
                label: TranslationKeys.city.tr),
            UIHelper.verticalSpaceSm15,
            CustomTextField(
                required: true,
                hint: TranslationKeys.address.tr,
                label: TranslationKeys.address.tr),
          ],
        ),
      ),
    );
  }
}
