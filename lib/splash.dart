import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/controllers/holiday_controller.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/controllers/loan_controller.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/controllers/announcement_controller.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/screens/auth/login_Screen.dart';
import 'package:supergithr/screens/dashboard_screens/dashboard.dart';
import 'package:supergithr/services/force_update_service.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/app_assets.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/force_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      initializeApp();
    });
  }

  Future<void> initializeApp() async {
    print("🔹 Initializing App...");
    await Future.delayed(const Duration(seconds: 2));

    // ✅ Check for force update before anything else
    final updateInfo = await ForceUpdateService().checkForUpdate();
    if (updateInfo != null && mounted) {
      print(
        "🔹 Force update required: v${updateInfo.currentVersion} → v${updateInfo.minVersion}",
      );
      if (mounted) setState(() => isLoading = false);
      ForceUpdateDialog.show(context, updateInfo);
      return;
    }

    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("authToken") ?? "";
    final savedTime = pref.getInt('tokenSavedAt');

    if (token.isNotEmpty && savedTime != null) {
      print("🔹 Auth token found, validating expiry...");

      // ✅ Check if token is expired (20 hours)
      final savedAt = DateTime.fromMillisecondsSinceEpoch(savedTime);
      final now = DateTime.now();
      const tokenExpiryDuration = Duration(hours: 20);

      if (now.difference(savedAt) > tokenExpiryDuration) {
        // ❌ Token expired - clear and navigate to login WITHOUT making API calls
        print("❌ Token expired (saved at: $savedAt, now: $now)");
        await pref.remove("authToken");
        await pref.remove("tokenSavedAt");
        Utils.snackBar(TranslationKeys.sessionExpired.tr, true);
        Get.offAll(() => const LoginScreen());
        if (mounted) setState(() => isLoading = false);
        return;
      }

      // ✅ Token is still valid - proceed with API calls
      print(
        "✅ Token is valid (saved at: $savedAt, expires in: ${tokenExpiryDuration.inHours - now.difference(savedAt).inHours} hours)",
      );

      ProfileController userController = Get.find();
      LeaveController leaveController = Get.find();
      AttendanceHistoryController attendanceHistoryController = Get.find();
      HolidayController holidayController = Get.find();
      LoanController loanController = Get.find();
      AnnouncementController announcementController = Get.find();

      await ApiNetworkService().saveAuthToken(token);

      try {
        // Load cached user data first
        await userController.loadCachedUser();
        print("✅ User data loaded from cache");

        // Make API calls to refresh data (these will run in background)
        leaveController.fetchLeaveTypes();
        attendanceHistoryController.getTodayLogs();
        holidayController.fetchHolidays(); // ✅ Fetch holidays in splash
        loanController.fetchLoans(); // ✅ Fetch loans in splash
        announcementController
            .fetchAnnouncements(); // ✅ Fetch announcements in splash

        Get.offAll(() => DashBorad(index: 0));
        print("🔹 Token valid, navigating to Dashboard.");
      } catch (e) {
        print("❌ Error during initialization: $e");
        Utils.snackBar(TranslationKeys.sessionExpired.tr, true);
        await pref.remove("authToken");
        await pref.remove("tokenSavedAt");
        Get.offAll(() => const LoginScreen());
      }
    } else {
      print("🔹 No auth token found, navigating to Login Screen.");
      Get.offAll(() => const LoginScreen());
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: splashGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                Spacer(),
                // Main Logo
                SizedBox(
                  height: 15.h,
                  width: 15.h,
                  child: Image.asset(AppAssets.logo),
                ),
                // Splash Logo
                Container(
                  // color: redColor,
                  // height: 30.h,
                  // width: 30.h,
                  child: Image.asset(AppAssets.splashLogo2),
                ),
                Spacer(),

                // Loading Indicator with WHITE color since bg is blue/gradient
                SizedBox(
                  height: 20.sp,
                  width: 20.sp,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(height: 2.h),

                // Text in WHITE
                kText(
                  text: TranslationKeys.loading.tr,
                  fSize: 14.0,
                  fWeight: FontWeight.bold,
                  tColor: kPrimaryColor,
                ),

                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
