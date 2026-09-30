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

  Map<String, dynamic>? _body(Response? response) {
    if (response == null) return null;
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      log(
        '❌ Overtime API ${response.requestOptions.uri} → $code '
        '${response.data}',
      );
      return null;
    }
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
    final response = await _api.postRequest(
      AppURL.overtimeReject(id),
      data: {
        if (remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
        if (reason.trim().isNotEmpty) 'rejection_reason': reason.trim(),
      },
      headers: await _headers(),
    );
    return _body(response) != null;
  }

  String reportUrl({required String employeeId, required String month}) =>
      AppURL.overtimeReportPdf(employeeId: employeeId, month: month);
}
