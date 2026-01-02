import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supergithr/network/repository/auth_repo.dart/auth_repo.dart';
import 'package:supergithr/utils/utils.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final isLoading = false.obs;
  final isResending = false.obs;

  /// ✅ 1. Send Forgot OTP
  Future<void> sendForgotOtp(String email) async {
    if (email.isEmpty) {
      Utils.snackBar("Please enter your email", true);
      return;
    }

    isLoading.value = true;
    try {
      final data = {"email": email};
      final response = await _repo.sendForgotOtp(data);
      isLoading.value = false;

      if (response == null) {
        Utils.snackBar("Something went wrong", true);
        return;
      }

      if (response['error'] != null) {
        Utils.snackBar("${response['error']}", true);
      } else if (response['otp'] != null) {
        Utils.snackBar("${response['message']}", false);

        final otpData = {
          "email": email,
          "otp": response['otp'],
          "purpose": "forgot_password",
        };
        print("$otpData");
        // Navigate to OTP Verification Screen
        // Get.to(() => OTPVerificationScreen(data: otpData));
      }
    } catch (e) {
      isLoading.value = false;
      Utils.snackBar("Error: $e", true);
    }
  }

  /// ✅ 2. Verify Forgot Password OTP
  Future<void> verifyPassOTP(String email, String otp) async {
    if (otp.isEmpty) {
      Utils.snackBar("Please enter OTP", true);
      return;
    }

    isLoading.value = true;
    try {
      final data = {"email": email, "otp": otp};
      final response = await _repo.verifyPassOTP(data);
      isLoading.value = false;

      if (response == null) {
        Utils.snackBar("Something went wrong", true);
        return;
      }

      if (response['error'] != null) {
        Utils.snackBar("${response['error']}", true);
      } else if (response['token'] != null) {
        Utils.snackBar("${response['message']}", false);

        final tokenData = {
          "email": email,
          "token": response['token'],
          "purpose": "forgot_password",
        };

        // Navigate to Reset Password Screen
        // Get.to(() => ResetPasswordScreen(data: tokenData));
      }
    } catch (e) {
      isLoading.value = false;
      Utils.snackBar("Error: $e", true);
    }
  }

  /// ✅ 3. Confirm New Password
  Future<void> confirmForgotPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Utils.snackBar("Please fill all fields", true);
      return;
    }

    if (newPassword.length < 6) {
      Utils.snackBar("Password must be at least 6 characters", true);
      return;
    }

    if (newPassword != confirmPassword) {
      Utils.snackBar("Passwords do not match", true);
      return;
    }

    isLoading.value = true;
    try {
      final data = {
        "email": email,
        "token": token,
        "password": newPassword,
        "password_confirmation": confirmPassword,
      };

      final response = await _repo.confirmForgotPassword(data);
      isLoading.value = false;

      if (response == null) {
        Utils.snackBar("Something went wrong", true);
        return;
      }

      if (response['error'] != null) {
        Utils.snackBar("${response['error']}", true);
        return;
      }

      if (response['message'] == "Password reset successfully") {
        Utils.snackBar("${response['message']}", false);
        //  Get.offAll(() => const PasswordChangedScreen());
      } else {
        Utils.snackBar(response['message'] ?? "Unknown response", true);
      }
    } catch (e) {
      isLoading.value = false;
      Utils.snackBar("Error: $e", true);
    }
  }

  /// ✅ 4. Resend OTP
  Future<void> resendOtp(String email) async {
    isResending.value = true;
    try {
      final data = {"email": email};
      final response = await _repo.sendForgotOtp(data);
      isResending.value = false;

      if (response == null) return Utils.snackBar("Something went wrong", true);
      if (response['error'] != null)
        return Utils.snackBar("${response['error']}", true);

      Utils.snackBar("OTP resent successfully", false);
    } catch (e) {
      isResending.value = false;
      Utils.snackBar("Error: $e", true);
    }
  }
}
