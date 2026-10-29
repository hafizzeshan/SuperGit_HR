import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { english, arabic }

class TranslationController extends GetxController {
  TranslationController({required this.preferences});

  Rx<Locale> local = const Locale('en', 'US').obs;
  VoidCallback? onLocaleChanged;
  SharedPreferences preferences;

  @override
  void onInit() {
    super.onInit();
    getLocal();
  }

  Future<void> changeLanguage(Language language) async {
    switch (language) {
      case Language.english:
        local.value = const Locale('en', 'US');
        preferences.setString("local", "en");
        break;
      case Language.arabic:
        local.value = const Locale('ar', 'SA');
        preferences.setString("local", "ar");
        break;
    }
    Get.updateLocale(local.value).then((_) {
      if (onLocaleChanged != null) {
        onLocaleChanged!();
      }
    });
  }

  Future<void> getLocal() async {
    String? currentLocal = preferences.getString("local");
    switch (currentLocal) {
      case "en":
        local.value = const Locale("en", "US");
        break;
      case "ar":
        local.value = const Locale("ar", "SA");
        break;
      default:
        local.value = const Locale("en", "US");
    }
  }

  Language getLanguage() {
    String? currentLocal = preferences.getString("local");
    switch (currentLocal) {
      case "ar":
        return Language.arabic;
      case "en":
        return Language.english;

      default:
        return Language.english;
    }
  }

  bool isLTR() {
    // Arabic is the only right-to-left language the app ships.
    return local.value.languageCode != "ar";
  }
}
