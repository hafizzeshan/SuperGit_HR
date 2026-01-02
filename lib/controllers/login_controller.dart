import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/controllers/leave_controller.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/network/repository/auth_repo.dart/auth_repo.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/screens/dashboard_screens/dashboard.dart';
import 'package:supergithr/utils/utils.dart';

class LoginController extends GetxController {
  final AuthRepository _repo = AuthRepository();
  final _profileController = Get.find<ProfileController>();
  LeaveController get leaveController => Get.find<LeaveController>();

  var isPasswordVisible = false.obs;

  // Reactive loading state
  final isLoading = false.obs;

  /// ✅ Login Function
  Future<void> loginUser(payload) async {
    final email = payload['email']?.trim();
    final password = payload['password']?.trim();
    if (email == null ||
        password == null ||
        email.isEmpty ||
        password.isEmpty) {
      Utils.snackBar("Please fill all fields", true);
      return;
    }

    isLoading.value = true;

    String fcmToken = await getFCMToken();
    final data = {
      "email": email,
      "password": password,
      "device_name": Platform.isAndroid ? "Android" : "iOS",
      "fcm_token": fcmToken.isEmpty ? "empty_fcm" : fcmToken,
    };

    final response = await _repo.login(data: data);
    print("Login Response: $response");
    isLoading.value = false;

    if (response != null && response['data'] != null) {
      final prefs = await SharedPreferences.getInstance();
      final token = response['data']['token'];
      final refresh_token = response['data']['refresh_token'];
      final userData = response['data']['user'];
      final employeeId = userData['employee_id'];
      final userId =
          userData['id']; // This might be what the profile endpoint needs

      print("🔹 Token after login: $token");
      print("🔹 employeeId after login: $employeeId");
      print("🔹 userId after login: $userId");
      print("🔹 Full User data from login: $userData");

      if (token != null) {
        ApiNetworkService().saveAuthToken(token);
        await prefs.setString('authToken', token);
        await prefs.setString('refreshToken', refresh_token);
        await prefs.setString('employee_id', employeeId ?? '');

        // Save user_id if available (might be needed for profile endpoint)
        if (userId != null) {
          await prefs.setString('user_id', userId);
          print("✅ user_id saved: $userId");
        }

        // ✅ Save basic user data from login response as fallback
        if (userData != null) {
          // Parse the full name into first and last name
          final fullName = userData['name'] ?? '';
          final nameParts = fullName.trim().split(RegExp(r'\s+'));
          final firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          final basicUserModel = {
            'id': employeeId,
            'user_id': userId,
            'email': userData['email'],
            'mobile_number': userData['mobile_number'],
            'first_name_en': firstName,
            'last_name_en': lastName,
            'employee_id': employeeId,
          };
          await prefs.setString('user_model', jsonEncode(basicUserModel));
          print("✅ Basic user data saved from login response");
          print("   First Name: $firstName, Last Name: $lastName");

          // Load this data into the profile controller immediately
          _profileController.loadCachedUser();
        }
      }

      Utils.snackBar(response['message'] ?? "Login successful", false);

      /// ✅ Skip profile fetch - login response already has all needed data
      /// The profile endpoint returns 404 due to tenant configuration
      /// We already have: email, name, employee_id, user_id from login
      print(
        "✅ Using user data from login response (profile endpoint not needed)",
      );

      // Uncomment below if profile endpoint becomes available:
      // await Future.delayed(const Duration(milliseconds: 500));
      // try {
      //   await _profileController.getProfile();
      // } catch (e) {
      //   print("⚠️ Profile fetch failed, using basic login data: $e");
      // }

      /// ✅ Navigate to Dashboard
      Get.offAll(() => DashBorad(index: 0));
      Future.delayed(const Duration(seconds: 1));
      leaveController.fetchLeaveTypes();
    } else {
      Utils.snackBar("Invalid credentials or server error", true);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future getFCMToken() async {
    String? token = "";
    //await FirebaseMessaging.instance.getToken();
    debugPrint("🔹 FCM Token: $token");
    return token ?? "";
  }
}
