import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// The locale date and time formatting should follow.
///
/// The app ships English and Arabic. Arabic renders month and weekday names
/// in Arabic while keeping Latin digits, which matches the numbers shown
/// everywhere else in the UI.
String get appDateLocale => Get.locale?.languageCode == 'ar' ? 'ar' : 'en';

/// [DateFormat] for the language the app is currently showing.
DateFormat appDateFormat(String pattern) => DateFormat(pattern, appDateLocale);
