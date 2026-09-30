import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';

/// Employee-side access to the Ethics Reports service.
///
/// This module lives on a different host to the rest of the app, so every call
/// uses an absolute URL and carries the tenant header the service requires.
class EthicsRepository {
  final ApiNetworkService _api = ApiNetworkService();

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final tenantId = prefs.getString('tenant_id') ?? '';
    return {if (tenantId.isNotEmpty) 'X-Tenant-ID': tenantId};
  }

  Map<String, dynamic>? _body(Response? response) {
    if (response == null) return null;
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      log(
        '❌ Ethics API ${response.requestOptions.uri} → $code '
        '${response.data}',
      );
      return null;
    }
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Reports submitted by the signed-in employee.
  Future<Map<String, dynamic>?> myReports({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.getRequest(
      AppURL.ethicsMyReports(page: page, pageSize: pageSize),
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> details(String id) async {
    final response = await _api.getRequest(
      AppURL.ethicsReport(id),
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> create(Map<String, dynamic> payload) async {
    final response = await _api.postRequest(
      AppURL.ethicsReports,
      data: payload,
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _api.putRequest(
      AppURL.ethicsReport(id),
      data: payload,
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<bool> delete(String id) async {
    final response = await _api.deleteRequest(
      AppURL.ethicsReport(id),
      headers: await _headers(),
    );
    return _body(response) != null;
  }

  Future<Map<String, dynamic>?> uploadAttachment({
    required String reportId,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _api.postRequest(
      AppURL.ethicsAttachments(reportId),
      data: formData,
      isMultipart: true,
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<bool> deleteAttachment({
    required String reportId,
    required String attachmentId,
  }) async {
    final response = await _api.deleteRequest(
      AppURL.ethicsAttachment(reportId, attachmentId),
      headers: await _headers(),
    );
    return _body(response) != null;
  }
}
