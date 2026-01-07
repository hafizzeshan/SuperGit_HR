import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supergithr/dependency_binding/dependency_bindings.dart';
import 'package:supergithr/splash.dart';
import 'package:supergithr/translations/translations/app_localizations.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/translation_controller.dart';

// @pragma('vm:entry-point')
// // ✅ Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("💤 Background message received: ${message.data}");
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1️⃣ Initialize Firebase first
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 2️⃣ Register background handler
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // // 3️⃣ Initialize notification service
  // await NotificationService().init();
  // 4️⃣ Shared preferences for translations
  SharedPreferences preferences = await SharedPreferences.getInstance();
  Get.put(TranslationController(preferences: preferences));
  // 5️⃣ Print FCM token for testing
  getFCMToken();
  // 6️⃣ Run app
  runApp(const MyApp());

  // 7️⃣ System UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
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
            enableLog: true,
            navigatorKey: Get.key,
            title: 'SuperGit HR',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
