import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergithr/network/services/api_network.dart';
import 'package:supergithr/network/services/app_urls.dart';

/// Overtime requests and the two-tier (manager → admin) approval chain.
///
/// Lives on the hr2 service, so calls use absolute URLs plus the tenant
/// header, the same as ethics reports and remote work.
class OvertimeRepository {
  final ApiNetworkService _api = ApiNetworkService();

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final tenantId = prefs.getString('tenant_id') ?? '';
    return {if (tenantId.isNotEmpty) 'X-Tenant-ID': tenantId};
  }


  /// Last message the service returned for a failed call, so the controller
  /// can show what actually went wrong ("remote clock-in already exists for
  /// today") instead of a generic failure.
  String lastError = '';

  /// Reads the message out of an error body, in the order the service uses.
  static String _messageOf(dynamic data) {
    if (data is String) return data.trim();
    if (data is! Map) return '';
    for (final key in ['message', 'error', 'msg', 'detail', 'details']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is Map && v['message'] is String) return '${v['message']}'.trim();
      if (v is List && v.isNotEmpty) return '${v.first}'.trim();
    }
    return '';
  }

  Map<String, dynamic>? _body(Response? response) {
    if (response == null) {
      lastError = '';
      return null;
    }
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      lastError = _messageOf(response.data);
      log(
        '❌ Overtime API ${response.requestOptions.uri} → $code '
        '${response.data}',
      );
      return null;
    }
    lastError = '';
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// One call serves all three roles — pass `employeeId` for an employee's own
  /// list, `currentApproverId` for a manager's queue, or neither plus a
  /// `status` for the admin view.
  Future<Map<String, dynamic>?> list({
    String? employeeId,
    String? currentApproverId,
    int page = 1,
    int limit = 10,
    String? status,
    String? month,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _api.getRequest(
      AppURL.overtimeListV2(
        employeeId: employeeId,
        currentApproverId: currentApproverId,
        page: page,
        limit: limit,
        status: status,
        month: month,
        startDate: startDate,
        endDate: endDate,
      ),
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> create(Map<String, dynamic> data) async {
    final response = await _api.postRequest(
      AppURL.overtimeBase,
      data: data,
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>?> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.putRequest(
      AppURL.overtimeRecord(id),
      data: data,
      headers: await _headers(),
    );
    return _body(response);
  }

  Future<bool> delete(String id) async {
    final response = await _api.deleteRequest(
      AppURL.overtimeRecord(id),
      headers: await _headers(),
    );
    return _body(response) != null;
  }

  /// Manager sign-off: moves the request into the admin queue.
  Future<bool> managerApprove({required String id, String remarks = ''}) async {
    final response = await _api.postRequest(
      AppURL.overtimeManagerApprove(id),
      data: {if (remarks.trim().isNotEmpty) 'remarks': remarks.trim()},
      headers: await _headers(),
    );
    return _body(response) != null;
  }

  /// Final HR approval: commits the overtime to payroll.
  Future<bool> adminApprove({required String id, String remarks = ''}) async {
    final response = await _api.postRequest(
      AppURL.overtimeAdminApprove(id),
      data: {if (remarks.trim().isNotEmpty) 'remarks': remarks.trim()},
      headers: await _headers(),
    );
    return _body(response) != null;
  }

  /// Shared by both tiers — the service decides who rejected from the token.
  Future<bool> reject({
    required String id,
    String remarks = '',
    String reason = '',
  }) async {
    // The service reads the reason from either key, so send one trimmed
    // string in both — the same way the web client does.
    final text = (reason.trim().isNotEmpty ? reason : remarks).trim();
    final response = await _api.postRequest(
      AppURL.overtimeReject(id),
      data: {'remarks': text, 'rejection_reason': text},
      headers: await _headers(),
    );
    return _body(response) != null;
  }

  String reportUrl({required String employeeId, required String month}) =>
      AppURL.overtimeReportPdf(employeeId: employeeId, month: month);
}
