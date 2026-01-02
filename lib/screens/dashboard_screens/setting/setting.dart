import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/attendance_controller.dart';
import 'package:supergithr/controllers/employee_history_controller.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/models/user_model.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/screens/dashboard_screens/home/holidays/holidays.dart';
import 'package:supergithr/screens/dashboard_screens/setting/announcement_screen.dart';
import 'package:supergithr/screens/dashboard_screens/setting/doc/personal_document.dart';
import 'package:supergithr/screens/dashboard_screens/setting/profile_view.dart';
import 'package:supergithr/splash.dart';
import 'package:supergithr/utils/utils.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/views/customText.dart';
import 'package:supergithr/views/ui_helpers.dart';
import 'package:supergithr/views/language_selection_bottom_sheet.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  ProfileController profileController = Get.find<ProfileController>();
  @override
  void initState() {
    super.initState();
    // pr.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final model = profileController.userModel.value;
    final firstName = model.firstNameEn ?? "User";
    final lastName = model.lastNameEn ?? "";
    final fullName = "$firstName $lastName".trim();
    final phone = model.mobileNumber ?? "N/A";

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: appBarrWitoutAction(
        title: TranslationKeys.about.tr,
        leadingWidget: SizedBox(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildProfileCard(name: fullName, phone: phone),
          const SizedBox(height: 20),
          // _buildTile(
          //   icon: Icons.person_outline,
          //   label: "Educational Documents",
          //   onTap: () => Get.to(EducationalDocumentsScreen()),
          // ),
          _buildTile(
            icon: Icons.folder_shared_rounded,
            label: TranslationKeys.personalDocuments.tr,
            onTap: () => Get.to(PersonalDocumentsScreen()),
          ),
          _buildTile(
            icon: Icons.language_rounded,
            label: TranslationKeys.changeLanguage.tr,
            onTap: () {
              LanguageSelectionBottomSheet.show(context);
            },
          ),
          _buildTile(
            icon: Icons.campaign_rounded,
            label: TranslationKeys.announcements.tr,
            onTap: () => Get.to(AnnouncementScreen()),
          ),
          _buildTile(
            icon: Icons.flag_rounded,
            label: TranslationKeys.holidays.tr,
            onTap: () => Get.to(() => HolidayScreen()),
          ),
          _buildTile(
            icon: Icons.logout_rounded,
            label: TranslationKeys.logout.tr,
            onTap: () => _handleLogout(),
          ),
        ],
      ),
    );
  }

  /// ⚠️ Handle logout with clock-out check
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final clockInTime = prefs.getString('clock_in_time');

    // Check if user is currently clocked in
    if (clockInTime != null && clockInTime.isNotEmpty) {
      // User is clocked in - get location first, then show warning
      await _getLocationAndShowWarning();
    } else {
      // User is not clocked in - proceed with normal logout
      UIHelper().showLogoutBottomSheet(
        context: context,
        onConfirmLogout: () {
          _logoutUser();
          Get.back();
        },
      );
    }
  }

  /// 📍 Get location and show warning dialog with address
  Future<void> _getLocationAndShowWarning() async {
    try {
      // ✅ Step 1: Check and request location services FIRST
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        // Show dialog asking user to enable location
        bool? shouldEnable = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: kText(
                    text: "Location Required",
                    fSize: 18.0,
                    fWeight: FontWeight.bold,
                    tColor: Colors.black87,
                  ),
                ),
              ],
            ),
            content: kText(
              text:
                  "Location services are required to clock out. Please enable location to continue with logout.",
              fSize: 14.0,
              tColor: Colors.black87,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: kText(
                  text: "Cancel",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: kText(
                  text: "Enable Location",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.white,
                ),
              ),
            ],
          ),
        );

        if (shouldEnable != true) {
          // User cancelled
          return;
        }

        // Request location service
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Utils.snackBar(
            "Location service is required to clock out before logout",
            true,
          );
          return;
        }
      }

      // ✅ Step 2: Check location permissions
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          Utils.snackBar("Location permission is required to clock out", true);
          return;
        }
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        // Show dialog to open settings
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: kText(
              text: "Permission Required",
              fSize: 18.0,
              fWeight: FontWeight.bold,
              tColor: Colors.black87,
            ),
            content: kText(
              text:
                  "Location permission is permanently denied. Please enable it in app settings to continue.",
              fSize: 14.0,
              tColor: Colors.black87,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: kText(
                  text: "Cancel",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.grey,
                ),
              ),
            ],
          ),
        );
        return;
      }

      // ✅ Step 3: Now get location with LocationController
      // Show loading while getting location
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                kText(
                  text: "Getting your location...",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.black87,
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Get LocationController
      final locationController =
          Get.isRegistered<LocationController>()
              ? Get.find<LocationController>()
              : Get.put(LocationController());

      // Get current location and address
      await locationController.getCurrentLocation();

      // Close loading dialog
      Get.back();

      // Check if location was successfully retrieved
      if (locationController.currentLatLng.value == null) {
        Utils.snackBar("Failed to get location. Please try again.", true);
        return;
      }

      // Show warning dialog with address
      _showClockOutWarningDialog(
        address: locationController.address.value,
        coords: locationController.currentLatLng.value,
      );
    } catch (e) {
      print("❌ Error getting location: $e");

      // Close loading if open
      if (Get.isDialogOpen!) Get.back();

      // Show error
      Utils.snackBar("Failed to get location. Please try again.", true);
    }
  }

  /// ⚠️ Show warning dialog for clocked-in users with address
  void _showClockOutWarningDialog({
    required String address,
    required LatLng? coords,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: kText(
                    text: "Clock Out Required",
                    fSize: 18.0,
                    fWeight: FontWeight.bold,
                    tColor: Colors.black87,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kText(
                  text:
                      "You are currently clocked in. If you logout now, you will be automatically clocked out.",
                  fSize: 14.0,
                  tColor: Colors.black87,
                  textalign: TextAlign.left,
                ),
                SizedBox(height: 16),
                // Show current location
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kText(
                              text: "Clock-out Location:",
                              fSize: 12.0,
                              fWeight: FontWeight.w600,
                              tColor: Colors.blue.shade900,
                            ),
                            SizedBox(height: 4),
                            kText(
                              text:
                                  address.isNotEmpty
                                      ? address
                                      : "Getting address...",
                              fSize: 13.0,
                              tColor: Colors.black87,
                              textalign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                kText(
                  text:
                      "Do you want to proceed with logout and automatic clock out?",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.black87,
                  textalign: TextAlign.left,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: kText(
                  text: "Cancel",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _autoClockOutAndLogout(coords: coords);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: kText(
                  text: "Yes, Logout",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  /// 🔄 Automatically clock out and then logout
  Future<void> _autoClockOutAndLogout({required LatLng? coords}) async {
    try {
      print("🔹 Auto clock-out before logout...");

      // Validate coordinates
      if (coords == null) {
        Utils.snackBar("Location not available. Please try again.", true);
        return;
      }

      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                kText(
                  text: "Clocking out...",
                  fSize: 14.0,
                  fWeight: FontWeight.w600,
                  tColor: Colors.black87,
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      print("📍 Using location: ${coords.latitude}, ${coords.longitude}");

      // Get LocationController for address
      final locationController =
          Get.isRegistered<LocationController>()
              ? Get.find<LocationController>()
              : Get.put(LocationController());

      // Clock out with coordinates from LocationController
      if (Get.isRegistered<AttendanceController>()) {
        final attendanceController = Get.find<AttendanceController>();

        // Clock out with actual location
        await attendanceController.clockOut(
          method: "auto",
          sourceDevice: "mobile",
          remarks:
              locationController.address.value.isNotEmpty
                  ? locationController.address.value
                  : "Auto clock-out on logout",
          coords: coords, // ✅ Use coordinates from LocationController
        );

        print("✅ Auto clock-out successful with location: $coords");
      }

      // Close loading dialog
      if (Get.isDialogOpen!) Get.back();

      // Proceed with logout
      await _logoutUser();
    } catch (e) {
      print("❌ Error during auto clock-out: $e");

      // Close loading dialog
      if (Get.isDialogOpen!) Get.back();

      // Show error and ask if they still want to logout
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: kText(
            text: "Clock Out Failed",
            fSize: 16.0,
            fWeight: FontWeight.bold,
            tColor: Colors.black87,
          ),
          content: kText(
            text:
                "Failed to clock out automatically. Do you still want to logout?",
            fSize: 14.0,
            tColor: Colors.black87,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: kText(
                text: "Cancel",
                fSize: 14.0,
                fWeight: FontWeight.w600,
                tColor: Colors.grey,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _logoutUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: kText(
                text: "Logout Anyway",
                fSize: 14.0,
                fWeight: FontWeight.w600,
                tColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 🧹 Clear all saved preferences and navigate to login
  Future<void> _logoutUser() async {
    try {
      print("🔹 Starting logout process...");

      // 1. Clear auth token from ApiNetworkService (removes from Dio headers)
      final apiService = ApiNetworkService();
      await apiService.clearAuthToken();
      print("✅ Auth token cleared from API service");

      // 2. Clear ALL SharedPreferences data (including authToken, tokenSavedAt, user_model, employee_id, etc.)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("✅ All SharedPreferences data cleared");

      // 3. Reset all controllers to clear any cached data
      try {
        // Reset ProfileController
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          profileController.userModel.value = UserModel();
          profileController.givenNameController.clear();
          profileController.familyNameController.clear();
          profileController.emailController.clear();
          profileController.phoneController.clear();
          profileController.oldPasswordController.clear();
          profileController.newPasswordController.clear();
          profileController.confirmPasswordController.clear();
          print("✅ ProfileController reset");
        }

        // Reset LeaveController
        if (Get.isRegistered<LeaveController>()) {
          final leaveController = Get.find<LeaveController>();
          leaveController.leaveTypes.clear();
          leaveController.leaveHistory.clear();
          leaveController.clearForm();
          print("✅ LeaveController reset");
        }

        // Reset AttendanceHistoryController
        if (Get.isRegistered<AttendanceHistoryController>()) {
          final attendanceController = Get.find<AttendanceHistoryController>();
          attendanceController.todayLogsModel.value = null;
          attendanceController.allLogsModel.value = null;
          print("✅ AttendanceHistoryController reset");
        }

        // Reset AttendanceController (clock-in/out state)
        if (Get.isRegistered<AttendanceController>()) {
          final attendanceController = Get.find<AttendanceController>();
          attendanceController.clockInTime.value = null;
          attendanceController.clockInAddress.value = "";
          attendanceController.elapsedTime.value = "00:00:00";
          print("✅ AttendanceController reset");
        }
      } catch (e) {
        print("⚠️ Error resetting controllers: $e");
      }

      print("✅ Logout complete, navigating to splash screen");

      // 4. Navigate to splash screen (which will redirect to login)
      Get.offAll(() => const SplashScreen());
    } catch (e) {
      print("❌ Error during logout: $e");
      // Even if there's an error, still try to navigate to splash
      Get.offAll(() => const SplashScreen());
    }
  }

  Widget _buildProfileCard({required String name, required String phone}) {
    return InkWell(
      onTap: () => Get.to(() => ProfileViewScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          //  color: mainBlackcolor.withOpacity(0.05),
          gradient: linearGradient2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mainBlackcolor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: mainBlackcolor.withOpacity(0.2),
              child: Icon(Icons.person, size: 30, color: whiteColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kText(
                    text: name,
                    fWeight: FontWeight.bold,
                    fSize: 16.0,
                    tColor: whiteColor,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: whiteColor),
                      const SizedBox(width: 6),
                      kText(text: phone, tColor: whiteColor, fSize: 13.0),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: whiteColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          // color: appblueColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          gradient: linearGradient2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: whiteColor),
            const SizedBox(width: 16),
            Expanded(
              child: kText(
                text: label,
                fWeight: FontWeight.w600,
                fSize: 14.0,
                tColor: whiteColor,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: whiteColor),
          ],
        ),
      ),
    );
  }
}
