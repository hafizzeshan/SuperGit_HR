import 'package:get/get.dart';
import 'package:supergithr/controllers/translation_controller.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

/// Localization Helper Utilities
/// Provides convenient methods for working with translations
class LocalizationHelper {
  /// Get the translation controller instance
  static TranslationController get controller =>
      Get.find<TranslationController>();

  /// Check if current language is RTL (Right-to-Left)
  static bool get isRTL => !controller.isLTR();

  /// Check if current language is LTR (Left-to-Right)
  static bool get isLTR => controller.isLTR();

  /// Get current language
  static Language get currentLanguage => controller.getLanguage();

  /// Check if current language is English
  static bool get isEnglish => currentLanguage == Language.english;

  /// Check if current language is Arabic
  static bool get isArabic => currentLanguage == Language.arabic;

  /// Check if current language is Urdu
  static bool get isUrdu => currentLanguage == Language.urdu;

  /// Get current language code (en, ar, ur)
  static String get languageCode => controller.local.value.languageCode;

  /// Get current locale
  static String get localeName =>
      '${controller.local.value.languageCode}_${controller.local.value.countryCode}';

  /// Change language
  static Future<void> changeLanguage(Language language) async {
    await controller.changeLanguage(language);
  }

  /// Get greeting based on time of day
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return TranslationKeys.goodMorning.tr;
    } else if (hour < 17) {
      return TranslationKeys.goodAfternoon.tr;
    } else {
      return TranslationKeys.goodEvening.tr;
    }
  }

  /// Get day name in current language
  static String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return TranslationKeys.monday.tr;
      case 2:
        return TranslationKeys.tuesday.tr;
      case 3:
        return TranslationKeys.wednesday.tr;
      case 4:
        return TranslationKeys.thursday.tr;
      case 5:
        return TranslationKeys.friday.tr;
      case 6:
        return TranslationKeys.saturday.tr;
      case 7:
        return TranslationKeys.sunday.tr;
      default:
        return '';
    }
  }

  /// Get status text with proper translation
  static String getLeaveStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return TranslationKeys.approved.tr;
      case 'pending':
        return TranslationKeys.pending.tr;
      case 'rejected':
        return TranslationKeys.rejected.tr;
      default:
        return status;
    }
  }

  /// Format number based on locale
  static String formatNumber(num number) {
    // You can add locale-specific number formatting here
    return number.toString();
  }

  /// Get language display name
  static String getLanguageDisplayName(Language language) {
    switch (language) {
      case Language.english:
        return 'English';
      case Language.arabic:
        return 'العربية';
      case Language.urdu:
        return 'اردو';
    }
  }

  /// Get language flag emoji
  static String getLanguageFlag(Language language) {
    switch (language) {
      case Language.english:
        return '🇬🇧';
      case Language.arabic:
        return '🇸🇦';
      case Language.urdu:
        return '🇵🇰';
    }
  }
}
