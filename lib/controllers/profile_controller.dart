import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
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
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  /// ✅ Change Password Controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  /// ✅ Observables
  final isLoading = false.obs;
  final updateLoading = false.obs;
  final selectedAvatar = Rxn<PlatformFile>();

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
      // Field shows a fixed +966 prefix, so keep only the local part
      phoneController.text = Utils.saudiLocalPart(
        userModel.value.mobileNumber ?? "",
      );
      nationalIdController.text = userModel.value.documentId ?? "";
      nationalityController.text = userModel.value.nationality ?? "";
      genderController.text = userModel.value.gender ?? "";
      dateOfBirthController.text = userModel.value.dateOfBirth ?? "";
      selectedAvatar.value = null;
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
      final response = await _repo.getProfile(idToUse);
      isLoading.value = false;

      if (response != null && response["data"] != null) {
        var model = UserModel.fromJson(response["data"]);

        // Keep our cache-busted avatar URL if the server returned the same
        // underlying URL, so a freshly updated picture doesn't go stale again.
        final incoming = model.avatarUrl;
        final current = userModel.value.avatarUrl;
        if (incoming != null &&
            current != null &&
            current != incoming &&
            _removeCacheBuster(current) == _removeCacheBuster(incoming)) {
          final json = model.toJson();
          json['avatar_url'] = current;
          model = UserModel.fromJson(json);
        }
        userModel.value = model;

        // ✅ Save in SharedPreferences for persistence
        await prefs.setString('user_model', jsonEncode(model.toJson()));

        // ✅ Populate text fields
        givenNameController.text = model.firstNameEn ?? "";
        familyNameController.text = model.lastNameEn ?? "";
        emailController.text = model.email ?? "";
        // Field shows a fixed +966 prefix, so keep only the local part
        phoneController.text = Utils.saudiLocalPart(model.mobileNumber ?? "");
        nationalIdController.text = model.documentId ?? "";
        nationalityController.text = model.nationality ?? "";
        genderController.text = model.gender ?? "";
        dateOfBirthController.text = model.dateOfBirth ?? "";
        selectedAvatar.value = null;

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

  /// ✅ Pick profile avatar image from device
  Future<void> pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedAvatar.value = result.files.first;
      }
    } catch (e) {
      Utils.snackBar(TranslationKeys.failedToPickImage.tr, true);
    }
  }

  /// Remove the `v=<millis>` cache-buster we append to avatar URLs.
  String _removeCacheBuster(String url) =>
      url.replaceAll(RegExp(r'[?&]v=\d+$'), '');

  Future<bool> _uploadSelectedAvatar(String employeeId) async {
    final avatarFile = selectedAvatar.value;
    if (avatarFile == null ||
        avatarFile.path == null ||
        avatarFile.path!.isEmpty) {
      return true;
    }

    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          avatarFile.path!,
          filename: avatarFile.name,
        ),
      });

      final response = await _repo.uploadAvatar(
        employeeId: employeeId,
        formData: formData,
      );

      print("🖼️ Avatar upload raw response: $response");
      if (response != null && response["data"] != null) {
        final responseData = response["data"];
        String? newUrl;
        if (responseData is Map<String, dynamic>) {
          newUrl =
              (responseData['avatar_url'] ?? responseData['avatarUrl'])
                  as String?;
        }
        print("🖼️ avatar_url from response: $newUrl");
        // Backend may not echo the URL back — the avatar endpoint is stable,
        // so fall back to the URL we already have.
        final oldUrl = userModel.value.avatarUrl;
        if (newUrl == null || newUrl.isEmpty) newUrl = oldUrl;

        if (newUrl != null && newUrl.isNotEmpty) {
          // If the URL didn't change, Flutter's image cache would keep
          // showing the old picture — evict it and append a cache-buster so
          // every screen reloads the fresh image.
          if (oldUrl != null && oldUrl.isNotEmpty) {
            await NetworkImage(oldUrl).evict();
          }
          if (_removeCacheBuster(newUrl) == _removeCacheBuster(oldUrl ?? '')) {
            final base = _removeCacheBuster(newUrl);
            final sep = base.contains('?') ? '&' : '?';
            newUrl = "$base${sep}v=${DateTime.now().millisecondsSinceEpoch}";
          }
          final updatedJson = userModel.value.toJson();
          updatedJson['avatar_url'] = newUrl;
          userModel.value = UserModel.fromJson(updatedJson);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'user_model',
            jsonEncode(userModel.value.toJson()),
          );
          print("🖼️ Avatar URL now used by app: $newUrl");
        }
        selectedAvatar.value = null;
        return true;
      }
    } catch (e) {
      print('⚠️ Avatar upload failed: $e');
    }
    return false;
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
  //     Utils.snackBar("${TranslationKeys.errorLoadingProfile.tr}: $e", true);
  //   }
  // }

  /// Map the localized gender label shown in the UI back to the API enum.
  /// The API only accepts: Male, Female, Other (capitalized).
  String _normalizeGender(String value) {
    if (value == TranslationKeys.male.tr) return 'Male';
    if (value == TranslationKeys.female.tr) return 'Female';
    switch (value.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return value;
    }
  }

  /// ✅ Update User Profile
  Future<bool> updateProfile() async {
    final givenName = givenNameController.text.trim();
    final familyName = familyNameController.text.trim();
    final email = emailController.text.trim();
    // API only accepts the +9665XXXXXXXX form
    final phone = Utils.normalizeSaudiMobile(phoneController.text.trim());
    final nationalId = nationalIdController.text.trim();
    final nationality = nationalityController.text.trim();
    final gender = _normalizeGender(genderController.text.trim());
    // API expects YYYY-MM-DD; profile API may return a full ISO timestamp
    final dateOfBirth = dateOfBirthController.text.trim().split('T').first;

    final fullName =
        "$givenName ${familyName.isNotEmpty ? familyName : ''}".trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        nationalId.isEmpty ||
        nationality.isEmpty ||
        gender.isEmpty ||
        dateOfBirth.isEmpty) {
      Utils.snackBar(TranslationKeys.pleaseFillAllFields.tr, true);
      return false;
    }

    updateLoading.value = true;
    try {
      final data = {
        "name": fullName,
        "first_name_en": givenName,
        "last_name_en": familyName,
        "national_id": nationalId,
        "document_id": nationalId,
        "nationality": nationality,
        "gender": gender,
        "phone": phone,
        "phone_number": phone,
        "mobile_number": phone,
        "email": email,
        "date_of_birth": dateOfBirth,
      };
      final avatarUrl = userModel.value.avatarUrl;
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        // Don't persist our local cache-buster param on the server
        data["avatar_url"] = _removeCacheBuster(avatarUrl);
      }

      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employee_id');
      final response =
          employeeId != null && employeeId.isNotEmpty
              ? await _repo.updateEmployeeProfile(
                employeeId: employeeId,
                data: data,
              )
              : await _repo.updateProfile(data: data);

      if (response != null && response["data"] != null) {
        final updatedModel = UserModel.fromJson(response["data"]);
        userModel.value = updatedModel;

        // ✅ Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_model', jsonEncode(updatedModel.toJson()));

        if (selectedAvatar.value != null &&
            employeeId != null &&
            employeeId.isNotEmpty) {
          final uploaded = await _uploadSelectedAvatar(employeeId);
          if (!uploaded) {
            Utils.snackBar(TranslationKeys.failedToUpdateProfile.tr, true);
            return false;
          }
        }

        Utils.snackBar(TranslationKeys.profileUpdatedSuccessfully.tr, false);
        // Refresh from server in the background so the app holds the
        // latest saved data (avatar cache-buster is preserved by getProfile).
        getProfile();
        return true;
      } else {
        Utils.snackBar(
          Utils.extractApiError(
            response,
            TranslationKeys.failedToUpdateProfile.tr,
          ),
          true,
        );
        return false;
      }
    } catch (e) {
      Utils.snackBar("${TranslationKeys.error.tr}: $e", true);
      return false;
    } finally {
      // Keep the loader visible until everything (avatar upload included) ends
      updateLoading.value = false;
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
      Utils.snackBar("${TranslationKeys.errorChangingPassword.tr}: $e", true);
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
    nationalIdController.dispose();
    nationalityController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
