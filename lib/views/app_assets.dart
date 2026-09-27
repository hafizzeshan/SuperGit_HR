import 'package:flutter/foundation.dart';

class AppAssets {
  /// iOS ships the new HR artwork (App Store submission). Android keeps the
  /// logo it was released with on Google Play, so the live app is unchanged.
  static final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;

  static String logo =
      _isIOS ? "assets/icons/app_logo.png" : "assets/icons/newlogo1.png";

  /// Smaller mark used inside snackbars.
  static String snackbarLogo =
      _isIOS ? "assets/icons/app_logo.png" : "assets/icons/newlogo.png";

  static String splashLogo2 = "assets/icons/splashlogo2.png";

  static String loading = "assets/icons/loading.json";
  static String home = "assets/icons/home_nav.png";
  static String approved = "assets/icons/requests_nav.png";
  static String chat = "assets/icons/chat_nav.png";
  static String setting = "assets/icons/settings_nav.png";
}
