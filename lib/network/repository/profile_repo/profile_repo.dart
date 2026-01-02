import 'package:dio/dio.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';

class ProfileRepository {
  final ApiNetworkService _api = ApiNetworkService();

  /// ✅ Get user profile
  Future<Map<String, dynamic>?> getProfile(id) async {
    final response = await _api.getRequest(AppURL.getProfile(id));
    if (response == null) return null;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      return response.data;
    }
    return null;
  }

  /// ✅ Update user profile
  Future<Map<String, dynamic>?> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    final Response? response = await _api.postRequest(
      AppURL.updateProfile,
      data: data,
    );

    if (response == null) return null;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      return response.data;
    }
    return null;
  }

  /// ✅ Change password
  Future<Map<String, dynamic>?> changePassword({data}) async {
    final Response? response = await _api.postRequest(
      AppURL.forgotPasswordApi,
      data: data,
    );

    if (response == null) return null;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      return response.data;
    }
    return null;
  }
}
