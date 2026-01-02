import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/controllers/profile_controller.dart';
import 'package:supergithr/network/repository/auth_repo.dart/auth_repo.dart';
import 'package:supergithr/screens/dashboard_screens/dashboard.dart';
import 'package:supergithr/utils/utils.dart';

import '../../../../network/services/api_network.dart';

class RegisterController extends GetxController {
  final AuthRepository _repo = AuthRepository();
  final _profileController = Get.put(ProfileController());

  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController documentIdController = TextEditingController();
  final TextEditingController providerIdController = TextEditingController();

  // Reactive variables
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  /// ✅ Register Function
  Future<void> registerUser(BuildContext context) async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final givenName = firstNameController.text.trim();
    final familyName = lastNameController.text.trim();
    final documentId = documentIdController.text.trim();
    final providerId = providerIdController.text.trim();

    // 🧩 Validate required fields
    if (email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        givenName.isEmpty ||
        familyName.isEmpty ||
        documentId.isEmpty ||
        providerId.isEmpty) {
      Utils.snackBar("Please fill all fields", true);
      return;
    }

    if (password != confirmPassword) {
      Utils.snackBar("Passwords do not match", true);
      return;
    }

    isLoading.value = true;

    try {
      String fcm_token = await getFCMToken();

      // 🔹 Register Payload
      final data = {
        "email": email,
        "phone": phone,
        "password": password,
        "password_confirmation": confirmPassword,
        "given_name": givenName,
        "family_name": familyName,
        "country": "SA", // Dummy Field
        "provider_id": providerId,
        "document_id": documentId,
        "role_id": 7,
        "business_id": 28, // Dummy Field
        "branch_id": 18, // Dummy Field
        "fcm_token": fcm_token,
      };

      final response = await _repo.register(data: data);
      isLoading.value = false;
      print(response.toString());
      if (response != null) {
        ApiNetworkService().saveAuthToken(response['data']['token']);
        Utils.snackBar("Registration Successful", false);

        // Profile endpoint returns 404 - should save user data from registration response instead
        // await _profileController.getProfile();

        Get.offAll(() => DashBorad(index: 0));
      }
    } catch (e) {
      isLoading.value = false;
      Utils.snackBar("Something went wrong. Please try again.", true);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    documentIdController.dispose();
    providerIdController.dispose();
    super.onClose();
  }

  Future getFCMToken() async {
    String? token = "";
    // await FirebaseMessaging.instance.getToken();
    debugPrint("🔹 FCM Token: $token");
    return token ?? "";
  }
}
