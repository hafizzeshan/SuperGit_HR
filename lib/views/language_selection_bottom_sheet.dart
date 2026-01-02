import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/translation_controller.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';

/// Modern Language Selection Bottom Sheet
/// Supports English, Arabic, and Urdu languages
class LanguageSelectionBottomSheet {
  static void show(BuildContext context) {
    final TranslationController translationController =
        Get.find<TranslationController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                kText(
                  text: "Select Language".tr,
                  fSize: 20.0,
                  fWeight: FontWeight.bold,
                  tColor: Colors.black87,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
            UIHelper.verticalSpaceSm10,
            kText(
              text: "Choose your preferred language".tr,
              fSize: 14.0,
              tColor: Colors.grey.shade600,
            ),
            UIHelper.verticalSpaceSm20,

            // Language Options
            Obx(() {
              // Observe the actual observable variable
              final currentLocale = translationController.local.value;
              final currentLanguage = translationController.getLanguage();
              
              return Column(
                children: [
                  _buildLanguageTile(
                    context: context,
                    language: Language.english,
                    title: "English",
                    subtitle: "English",
                    flag: "🇬🇧",
                    isSelected: currentLanguage == Language.english,
                    onTap: () async {
                      await translationController
                          .changeLanguage(Language.english);
                      Navigator.pop(context);
                    },
                  ),
                  UIHelper.verticalSpaceSm10,
                  _buildLanguageTile(
                    context: context,
                    language: Language.arabic,
                    title: "العربية",
                    subtitle: "Arabic",
                    flag: "🇸🇦",
                    isSelected: currentLanguage == Language.arabic,
                    onTap: () async {
                      await translationController
                          .changeLanguage(Language.arabic);
                      Navigator.pop(context);
                    },
                  ),
                  UIHelper.verticalSpaceSm10,
                  _buildLanguageTile(
                    context: context,
                    language: Language.urdu,
                    title: "اردو",
                    subtitle: "Urdu",
                    flag: "🇵🇰",
                    isSelected: currentLanguage == Language.urdu,
                    onTap: () async {
                      await translationController.changeLanguage(Language.urdu);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            }),

            UIHelper.verticalSpaceSm20,
          ],
        ),
      ),
    );
  }

  static Widget _buildLanguageTile({
    required BuildContext context,
    required Language language,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? linearGradient2 : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag emoji
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            UIHelper.horizontalSpaceSm15,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: title,
                    fSize: 16.0,
                    fWeight: FontWeight.bold,
                    tColor: isSelected ? Colors.white : Colors.black87,
                  ),
                  UIHelper.verticalSpaceSm5,
                  kText(
                    text: subtitle,
                    fSize: 13.0,
                    tColor: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            // Check icon
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: kPrimaryColor,
                  size: 20,
                ),
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade400,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
