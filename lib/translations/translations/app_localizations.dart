import 'package:get/get.dart';
import 'package:supergithr/translations/languages/arabic_local.dart';
import 'package:supergithr/translations/languages/english_local.dart';
import 'package:supergithr/translations/languages/urdu_local.dart';

class GetLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    /// English
    'en_US': EnglishLocal.getEnglish(),
    /// Arabic
    'ar_SA': ArabicLocal.getArabic(),
    /// Urdu
    'ur_PK': UrduLocal.getUrdu(),
  };
}
