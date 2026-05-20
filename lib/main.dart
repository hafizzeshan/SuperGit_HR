import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supergithr/firebase_options.dart';
import 'package:supergithr/dependency_binding/dependency_bindings.dart';
import 'package:supergithr/splash.dart';
import 'package:supergithr/translations/translations/app_localizations.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/translation_controller.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // 1️⃣ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 4️⃣ Shared preferences for translations
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Get.put(TranslationController(preferences: preferences));
  // 5️⃣ Print FCM token for testing
  getFCMToken();
  // 7️⃣ System UI overlay — dark status bar icons everywhere.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android: dark icons
      statusBarBrightness: Brightness.light, // iOS: dark icons
    ),
  );

  // 6️⃣ Run app
  runApp(const MyApp());
}

Future<void> getFCMToken() async {
  // String? token = await FirebaseMessaging.instance.getToken();
  // debugPrint("🔹 FCM Token: $token");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationController translationController =
        Get.find<TranslationController>();
    return ResponsiveSizer(
      builder:
          (context, orientation, screenType) => GetMaterialApp(
            navigatorKey: Get.key,
            builder: (context, child) {
              return SafeArea(
                top: false,
                bottom: true,
                left: false,
                right: false,
                child: child!,
              );
            },
            enableLog: true,
            title: 'SuperGit HR',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark, // Android
                  statusBarBrightness: Brightness.light, // iOS
                ),
              ),
            ),
            translations: GetLocalization(),
            initialBinding: DependencyBindings(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('ar', 'SA'), // Arabic
              Locale('ur', 'PK'), // Urdu
            ],
            locale: translationController.local.value,
            home: SplashScreen(),
          ),
    );
  }
}
