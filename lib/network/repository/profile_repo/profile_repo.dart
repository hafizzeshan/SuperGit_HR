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

  /// ✅ Update employee profile by employee ID
  Future<Map<String, dynamic>?> updateEmployeeProfile({
    required String employeeId,
    required Map<String, dynamic> data,
  }) async {
    final Response? response = await _api.putRequest(
      AppURL.employeeProfile(employeeId),
      data: data,
    );

    if (response == null) return null;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      return response.data;
    }
    return null;
  }

  /// ✅ Upload or update employee avatar
  Future<Map<String, dynamic>?> uploadAvatar({
    required String employeeId,
    required FormData formData,
    bool usePut = true,
  }) async {
    final Response? response =
        usePut
            ? await _api.putRequest(
              AppURL.employeeAvatar(employeeId),
              data: formData,
              isMultipart: true,
            )
            : await _api.postRequest(
              AppURL.employeeAvatar(employeeId),
              data: formData,
              isMultipart: true,
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
