import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Login and save token
  Future<Map<String, dynamic>?> login({
    required Map<String, dynamic> data,
  }) async {
    final response = await _api.postRequest(AppURL.loginApi, data: data);

    if (response == null) return null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;

      // ✅ Save token if available
      if (responseData != null && responseData['data'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', responseData['data']['token']);
      }

      return responseData;
    } else {
      return null;
    }
  }

  /// ✅ Register
  Future<Map<String, dynamic>?> register({
    required Map<String, dynamic> data,
  }) async {
    final response = await _api.postRequest(AppURL.registerApi, data: data);
    if (response == null) return null;
    return response.statusCode == 200 || response.statusCode == 201
        ? response.data
        : null;
  }

  /// ✅ 1. Send Forgot Password OTP
  Future<Map<String, dynamic>?> sendForgotOtp(Map<String, dynamic> data) async {
    final response = await _api.postRequest(
      AppURL.forgotPasswordApi,
      data: data,
    );

    if (response == null) return null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      return {"error": response.data?['message'] ?? "Something went wrong"};
    }
  }

  /// ✅ 2. Verify Forgot Password OTP
  Future<Map<String, dynamic>?> verifyPassOTP(Map<String, dynamic> data) async {
    final response = await _api.postRequest(AppURL.veriftyOTP, data: data);

    if (response == null) return null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      return {"error": response.data?['message'] ?? "OTP verification failed"};
    }
  }

  /// ✅ 3. Confirm Forgot Password (Reset Password)
  Future<Map<String, dynamic>?> confirmForgotPassword(
    Map<String, dynamic> data,
  ) async {
    final response = await _api.postRequest(
      AppURL.confirmForgotPasswordApi,
      data: data,
    );

    if (response == null) return null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      return {"error": response.data?['message'] ?? "Password reset failed"};
    }
  }



}
