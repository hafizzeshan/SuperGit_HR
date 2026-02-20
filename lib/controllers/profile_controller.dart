import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/models/user_model.dart';
import 'package:supergithr/network/repository/profile_repo/profile_repo.dart';
import 'package:supergithr/utils/utils.dart';

import '../translations/translations/translation_keys.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();

  /// ✅ Text Controllers
  final TextEditingController givenNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// ✅ Change Password Controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// ✅ Observables
  final isLoading = false.obs;
  final updateLoading = false.obs;

  final userModel = UserModel().obs;

  /// ✅ Load Cached User (from SharedPreferences)
  Future<void> loadCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_model');

    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      userModel.value = UserModel.fromJson(data);

      // Populate text fields
      givenNameController.text = userModel.value.firstNameEn ?? "";
      familyNameController.text = userModel.value.lastNameEn ?? "";
      emailController.text = userModel.value.email ?? "";
      phoneController.text = userModel.value.mobileNumber ?? "";
    }
  }

  Future<void> getProfile() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try user_id first (might be what the API expects)
      String? userId = prefs.getString('user_id');
      String? employeeId = prefs.getString('employee_id');

      String? idToUse = userId ?? employeeId;

      if (idToUse == null || idToUse.isEmpty) {
        isLoading.value = false;
        print("❌ No user_id or employee_id found");
        // Don't show error to user since we have cached data from login
        await loadCachedUser();
        return;
      }

      print(
        "🔹 Fetching profile for ID: $idToUse (user_id: $userId, employee_id: $employeeId)",
      );
      final response = await _repo.getProfile(employeeId);
      isLoading.value = false;

      if (response != null && response["data"] != null) {
        final model = UserModel.fromJson(response["data"]);
        userModel.value = model;

        // ✅ Save in SharedPreferences for persistence
        await prefs.setString('user_model', jsonEncode(model.toJson()));

        // ✅ Populate text fields
        givenNameController.text = model.firstNameEn ?? "";
        familyNameController.text = model.lastNameEn ?? "";
        emailController.text = model.email ?? "";
        phoneController.text = model.mobileNumber ?? "";

        print("✅ Profile loaded successfully from API");
        print("User Model: ${model.toJson()}");
      } else {
        print("⚠️ Profile API returned null - using cached data from login");
        // Don't show error snackbar since we have data from login
        // Just load cached data silently
        await loadCachedUser();
      }
    } catch (e) {
      isLoading.value = false;
      print("⚠️ Profile fetch failed: $e");

      // Don't show error to user if it's just a 404 (employee not found in that endpoint)
      // We already have user data from login response

      // Try to load cached data as fallback
      try {
        await loadCachedUser();
        print("✅ Using cached user data from login");
      } catch (cacheError) {
        print("❌ Failed to load cached user: $cacheError");
        // Only show error if we truly have no data
        Utils.snackBar(TranslationKeys.unableToLoadUserProfile.tr, true);
      }
    }
  }

  // /// ✅ Fetch User Profile (and cache it)
  // Future<void> getProfile() async {
  //   isLoading.value = true;
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final employeeId = prefs.getString('employee_id') ?? "";

  //     final response = await _repo.getProfile(employeeId);
  //     isLoading.value = false;

  //     if (response != null && response["data"] != null) {
  //       final model = UserModel.fromJson(response["data"]);
  //       userModel.value = model;

  //       // ✅ Save in SharedPreferences for persistence
  //       await prefs.setString('user_model', jsonEncode(model.toJson()));

  //       // ✅ Populate text fields
  //       givenNameController.text = model.firstNameEn ?? "";
  //       familyNameController.text = model.lastNameEn ?? "";
  //       emailController.text = model.email ?? "";
  //       phoneController.text = model.mobileNumber ?? "";
  //       // get model details
  //       await prefs.getString('user_model');
  //       print("employee: ${employeeId}");
  //       print("User Model: ${model.toJson()}");
  //     }
  //   } catch (e) {
  //     isLoading.value = false;
  //     Utils.snackBar("Error loading profile: $e", true);
  //   }
  // }

  /// ✅ Update User Profile
  Future<void> updateProfile() async {
    final givenName = givenNameController.text.trim();
    final familyName = familyNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (givenName.isEmpty ||
        familyName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty) {
      Utils.snackBar(TranslationKeys.pleaseFillAllFields.tr, true);
      return;
    }

    updateLoading.value = true;
    try {
      final data = {
        "first_name_en": givenName,
        "last_name_en": familyName,
        "email": email,
        "mobile_number": phone,
      };

      final response = await _repo.updateProfile(data: data);
      updateLoading.value = false;

      if (response != null && response["data"] != null) {
        final updatedModel = UserModel.fromJson(response["data"]);
        userModel.value = updatedModel;

        // ✅ Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_model', jsonEncode(updatedModel.toJson()));

        Utils.snackBar(TranslationKeys.profileUpdatedSuccessfully.tr, false);
      } else {
        Utils.snackBar(TranslationKeys.failedToUpdateProfile.tr, true);
      }
    } catch (e) {
      updateLoading.value = false;
      Utils.snackBar("${TranslationKeys.error.tr}: $e", true);
    }
  }

  /// ✅ Change Password
  Future<void> changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Utils.snackBar(TranslationKeys.pleaseFillAllPasswordFields.tr, true);
      return;
    }

    if (newPass != confirmPass) {
      Utils.snackBar(TranslationKeys.newPasswordsDoNotMatch.tr, true);
      return;
    }

    final data = {
      "old_password": oldPass,
      "new_password": newPass,
      "confirm_password": confirmPass,
    };

    isLoading.value = true;
    try {
      final response = await _repo.changePassword(data: data);
      isLoading.value = false;

      if (response != null) {
        Utils.snackBar(TranslationKeys.passwordChangedSuccessfully.tr, false);
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        Utils.snackBar(TranslationKeys.failedToChangePassword.tr, true);
      }
    } catch (e) {
      isLoading.value = false;
      Utils.snackBar("Error changing password: $e", true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadCachedUser(); // ✅ Load local data first
  }

  @override
  void onClose() {
    givenNameController.dispose();
    familyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
